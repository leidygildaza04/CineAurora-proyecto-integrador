
const path = require('path');
require('dotenv').config({
    path: path.resolve(__dirname, '../../backend/.env')
});

const { Pool } = require('pg');
const { MongoClient } = require('mongodb');

const pool = new Pool({
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    database: process.env.DB_NAME,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD
});

const mongoClient = new MongoClient(process.env.MONGO_URI);

let mongoDB;

async function conectar() {
    await pool.query('SELECT NOW()');
    await mongoClient.connect();
    mongoDB = mongoClient.db(process.env.MONGO_DB || 'cine_aurora');

    console.log('PostgreSQL conectado');
    console.log('MongoDB conectado');
}

async function caso1FuncionesResenas() {
    console.log('\nCASO 1: FUNCIONES Y RESEÑAS');

    const resultado = await pool.query(`
        SELECT
            f.id_funcion,
            f.id_pelicula,
            f.id_sala,
            f.fecha_hora_inicio,
            f.estado,
            p.titulo,
            s.nombre AS sala
        FROM funciones f
        INNER JOIN peliculas p ON p.id_pelicula = f.id_pelicula
        INNER JOIN salas s ON s.id_sala = f.id_sala
        ORDER BY f.fecha_hora_inicio
    `);

    const funciones = resultado.rows;

    for (const funcion of funciones) {
        const resenas = await mongoDB
            .collection('resenas_peliculas')
            .find({ id_pelicula: funcion.id_pelicula })
            .toArray();

        console.log({
            funcion: funcion.id_funcion,
            pelicula: funcion.titulo,
            sala: funcion.sala,
            resenas: resenas.map(r => ({
                calificacion: r.calificacion,
                texto: r.texto
            }))
        });
    }
}

async function caso2PeliculasRequisitos() {
    console.log('\nCASO 2: PELICULAS Y REQUISITOS TECNICOS');

    const resultado = await pool.query(`
        SELECT
            f.id_funcion,
            f.id_pelicula,
            f.id_sala,
            p.titulo,
            f.fecha_hora_inicio
        FROM funciones f
        INNER JOIN peliculas p ON p.id_pelicula = f.id_pelicula
        ORDER BY f.id_funcion
    `);

    for (const funcion of resultado.rows) {
        const requisito = await mongoDB
            .collection('requisitos_proyeccion')
            .findOne({ id_funcion: funcion.id_funcion });

        console.log({
            pelicula: funcion.titulo,
            funcion: funcion.id_funcion,
            sala: funcion.id_sala,
            requisitos: requisito || 'Sin requisitos registrados'
        });
    }
}

async function caso3VentasIncidentes() {
    console.log('\nCASO 3: VENTAS E INCIDENTES POR SALA');

    const resultado = await pool.query(`
        SELECT
            s.id_sala,
            s.nombre AS sala,
            COUNT(d.id_detalle) AS detalles_ventas,
            COALESCE(SUM(d.cantidad), 0) AS boletas_vendidas,
            COALESCE(SUM(d.cantidad * d.precio_unitario), 0) AS total_ventas
        FROM salas s
        LEFT JOIN funciones f ON f.id_sala = s.id_sala
        LEFT JOIN detalle_ventas d ON d.id_funcion = f.id_funcion
        LEFT JOIN ventas v ON v.id_venta = d.id_venta
            AND v.estado = 'Pagada'
        GROUP BY s.id_sala, s.nombre
        ORDER BY s.id_sala
    `);

    for (const sala of resultado.rows) {
        const incidentes = await mongoDB
            .collection('reportes_incidentes')
            .find({ id_sala: sala.id_sala })
            .toArray();

        console.log({
            sala: sala.sala,
            boletas: Number(sala.boletas_vendidas),
            total_ventas: Number(sala.total_ventas),
            incidentes: incidentes.map(i => ({
                tipo: i.tipo_incidente,
                descripcion: i.descripcion,
                fecha: i.fecha
            }))
        });
    }
}

async function registrarVenta(datos) {
    const client = await pool.connect();

    try {
        await client.query('BEGIN');

        const resultado = await client.query(
            `CALL public.registrar_venta($1, $2, $3, $4, $5, $6, NULL, NULL)`,
            [
                datos.id_espectador,
                datos.id_staff ?? null,
                datos.canal,
                datos.id_funcion,
                datos.id_tipo_boleta,
                datos.cantidad
            ]
        );

        const salida = resultado.rows[0];

        if (!salida || salida.p_id_venta == null) {
            throw new Error('El procedimiento no devolvió el identificador de la venta');
        }

        const venta = {
            id_venta: Number(salida.p_id_venta),
            id_espectador: Number(datos.id_espectador),
            id_staff: datos.id_staff ?? null,
            canal: datos.canal,
            id_funcion: Number(datos.id_funcion),
            id_tipo_boleta: Number(datos.id_tipo_boleta),
            cantidad: Number(datos.cantidad),
            total: Number(salida.p_total),
            fecha: new Date()
        };

        await client.query(`
            CREATE TABLE IF NOT EXISTS public.integracion_ventas_pendientes (
                id_venta INTEGER PRIMARY KEY,
                datos JSONB NOT NULL,
                estado VARCHAR(20) NOT NULL DEFAULT 'PENDIENTE',
                fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                fecha_sincronizacion TIMESTAMP
            )
        `);

        await client.query(
            `INSERT INTO public.integracion_ventas_pendientes
             (id_venta, datos, estado)
             VALUES ($1, $2, 'PENDIENTE')`,
            [venta.id_venta, JSON.stringify(venta)]
        );

        await client.query('COMMIT');

        try {
            await sincronizarVenta(venta);

            await pool.query(
                `UPDATE public.integracion_ventas_pendientes
                 SET estado = 'SINCRONIZADA',
                     fecha_sincronizacion = CURRENT_TIMESTAMP
                 WHERE id_venta = $1`,
                [venta.id_venta]
            );

            return {
                mensaje: 'Venta registrada y sincronizada correctamente',
                venta
            };
        } catch (errorMongo) {
            return {
                mensaje: 'Venta registrada en PostgreSQL, pendiente de sincronización con MongoDB',
                venta,
                sincronizacion: 'PENDIENTE',
                error: errorMongo.message
            };
        }
    } catch (error) {
        await client.query('ROLLBACK').catch(() => {});
        throw error;
    } finally {
        client.release();
    }
}

async function sincronizarVenta(venta) {
    await mongoDB.collection('ventas_integradas').updateOne(
        { id_venta: venta.id_venta },
        { $setOnInsert: venta },
        { upsert: true }
    );
}

async function main() {
    try {
        await conectar();

        await caso1FuncionesResenas();
        await caso2PeliculasRequisitos();
        await caso3VentasIncidentes();

        console.log('\nLos tres casos de integración finalizaron correctamente.');
    } catch (error) {
        console.error('\nError de integración:', error.message);
        process.exitCode = 1;
    } finally {
        await mongoClient.close();
        await pool.end();
    }
}

main();
