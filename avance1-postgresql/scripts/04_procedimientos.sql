-- =====================================================================
-- Proyecto Integrador 2026-2 - Avance 1: Núcleo transaccional
-- Empresa : Cine Aurora (grupo Cinemas 8) - Bogotá D.C., Colombia
-- Script  : 04_procedimientos.sql

-- Aquí están los 3 procedimientos almacenados. Se corre después
-- despúes de los 3 scripts (tablas),(datos),(triggers).
--
-- Los 3 llevan manejo de errores: las validaciones las hago con
-- RAISE EXCEPTION y al final de cada uno hay un bloque EXCEPTION que atrapa
-- cualquier error y lo vuelve a lanzar con un mensaje.
--
-- Las pruebas están al final, comentadas. Se ejecutan una por una.
-- =====================================================================

-- =====================================================================
-- PROCEDIMIENTO 1: registrar_venta  (cálculo / transacción)
--
-- Registra una venta completa la cabecera en ventas y su detalle en
-- detalle_ventas, y calcula el total. Antes de guardar revisa que el
-- espectador, la función y el tipo de boleta existan, que la función esté
-- programada, que la cantidad sea mayor que cero y que haya cupo.
--
-- Es una transacción: la venta y el detalle quedan los dos o ninguno. Si
-- algo falla, el EXCEPTION cancela todo.
--
-- El precio lo calcula el trigger 1, por eso en el detalle envío 0.
-- Devuelve el id de la venta y el total.
-- =====================================================================
CREATE OR REPLACE PROCEDURE registrar_venta(
    p_id_espectador  INT,
    p_id_staff       INT,
    p_canal          VARCHAR,
    p_id_funcion     INT,
    p_id_tipo_boleta INT,
    p_cantidad       INT,
    OUT p_id_venta   INT,
    OUT p_total      NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_existe          INT;
    v_estado_funcion  VARCHAR(15);
    v_capacidad       INT;
    v_vendidas        INT;
    v_precio_unitario NUMERIC(10,2);
BEGIN
    -- reviso los datos que me mandan
    IF p_cantidad IS NULL OR p_cantidad <= 0 THEN
        RAISE EXCEPTION 'La cantidad de boletas debe ser mayor que cero';
    END IF;

    IF p_canal NOT IN ('Presencial', 'Online') THEN
        RAISE EXCEPTION 'El canal "%" no es válido. Debe ser Presencial u Online', p_canal;
    END IF;

    -- el espectador tiene que existir
    SELECT COUNT(*) INTO v_existe
    FROM espectadores
    WHERE id_espectador = p_id_espectador;

    IF v_existe = 0 THEN
        RAISE EXCEPTION 'El espectador % no existe', p_id_espectador;
    END IF;

    -- el tipo de boleta tiene que existir
    SELECT COUNT(*) INTO v_existe
    FROM tipos_boleta
    WHERE id_tipo_boleta = p_id_tipo_boleta;

    IF v_existe = 0 THEN
        RAISE EXCEPTION 'El tipo de boleta % no existe', p_id_tipo_boleta;
    END IF;

    -- busco el estado de la función y la capacidad de su sala
    SELECT f.estado, s.capacidad INTO v_estado_funcion, v_capacidad
    FROM funciones f
    INNER JOIN salas s ON s.id_sala = f.id_sala
    WHERE f.id_funcion = p_id_funcion;

    IF v_estado_funcion IS NULL THEN
        RAISE EXCEPTION 'La función % no existe', p_id_funcion;
    END IF;

    -- solo se vende para funciones que todavía no han pasado
    IF v_estado_funcion <> 'Programada' THEN
        RAISE EXCEPTION 'La función % está % y ya no admite ventas', p_id_funcion, v_estado_funcion;
    END IF;

    -- cuento las boletas pagadas que ya hay para ver si queda cupo
    SELECT COALESCE(SUM(d.cantidad), 0) INTO v_vendidas
    FROM detalle_ventas d
    INNER JOIN ventas v ON v.id_venta = d.id_venta
    WHERE d.id_funcion = p_id_funcion
      AND v.estado = 'Pagada';

    IF v_vendidas + p_cantidad > v_capacidad THEN
        RAISE EXCEPTION 'No hay cupo: solo quedan % boleta(s) para la función %',
            v_capacidad - v_vendidas, p_id_funcion;
    END IF;

    -- todo bien: guardo la venta (cabecera)
    INSERT INTO ventas (id_espectador, id_staff, canal)
    VALUES (p_id_espectador, p_id_staff, p_canal)
    RETURNING id_venta INTO p_id_venta;

    -- y su detalle. El precio va en 0 porque lo calcula el trigger
    INSERT INTO detalle_ventas (id_venta, id_funcion, id_tipo_boleta, cantidad, precio_unitario)
    VALUES (p_id_venta, p_id_funcion, p_id_tipo_boleta, p_cantidad, 0)
    RETURNING precio_unitario INTO v_precio_unitario;

    -- total = precio de cada boleta por la cantidad
    p_total := v_precio_unitario * p_cantidad;

    RAISE NOTICE 'Venta % registrada: % boleta(s) a % c/u. Total: %',
        p_id_venta, p_cantidad, v_precio_unitario, p_total;

EXCEPTION
    WHEN OTHERS THEN
        -- si algo falló, se cancela todo y aviso con un mensaje claro
        RAISE EXCEPTION 'No se pudo registrar la venta: %', SQLERRM;
END;
$$;

-- =====================================================================
-- PROCEDIMIENTO 2: reporte_ventas_funcion  (reporte con agregación)
--
-- Este procedimiento arma el reporte de una función: de qué película es, en
-- qué sala, cuántas ventas tiene, cuántas boletas se vendieron, cuánta
-- plata se recaudó y qué porcentaje de la sala está ocupado.
--
-- Aquí uso funciones de agregación: COUNT(DISTINCT ...) para las ventas,
-- SUM(cantidad) para las boletas y SUM(cantidad * precio_unitario) para el
-- recaudo. Solo cuento las ventas pagadas, las anuladas no suman.
--
-- Parámetro: id de la función. Devuelve una fila con el reporte.
-- =====================================================================
CREATE OR REPLACE PROCEDURE reporte_ventas_funcion(
    p_id_funcion      INT,
    OUT p_pelicula    VARCHAR,
    OUT p_sala        VARCHAR,
    OUT p_inicio      TIMESTAMP,
    OUT p_capacidad   INT,
    OUT p_ventas      INT,
    OUT p_boletas     INT,
    OUT p_recaudo     NUMERIC,
    OUT p_ocupacion   NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- datos de la función: película, sala, hora de inicio y capacidad
    SELECT p.titulo, s.nombre, f.fecha_hora_inicio, s.capacidad
      INTO p_pelicula, p_sala, p_inicio, p_capacidad
    FROM funciones f
    INNER JOIN peliculas p ON p.id_pelicula = f.id_pelicula
    INNER JOIN salas s     ON s.id_sala = f.id_sala
    WHERE f.id_funcion = p_id_funcion;

    IF p_pelicula IS NULL THEN
        RAISE EXCEPTION 'La función % no existe', p_id_funcion;
    END IF;

    -- aquí están las agregaciones: ventas, boletas y recaudo
    SELECT COUNT(DISTINCT v.id_venta),
           COALESCE(SUM(d.cantidad), 0),
           COALESCE(SUM(d.cantidad * d.precio_unitario), 0)
      INTO p_ventas, p_boletas, p_recaudo
    FROM detalle_ventas d
    INNER JOIN ventas v ON v.id_venta = d.id_venta
    WHERE d.id_funcion = p_id_funcion
      AND v.estado = 'Pagada';

    -- porcentaje de la sala que está ocupado
    p_ocupacion := ROUND(100.0 * p_boletas / p_capacidad, 1);

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'No se pudo generar el reporte: %', SQLERRM;
END;
$$;

-- =====================================================================
-- PROCEDIMIENTO 3: actualizar_estado_funciones  (mantenimiento / operación)
--
-- Este procedimiento es para mantener las funciones al día. Mira la fecha
-- de corte (por defecto, ahora mismo) y hace dos cosas:
--   - las funciones que ya terminaron pasan a Finalizada
--   - las que están pasando en este momento pasan a En curso
--
-- Se lo puede ejecutar el administrador cuando quiera, por ejemplo al
-- cerrar el día. Me devuelve cuántas funciones cambió de cada tipo.
--
-- Parámetro: fecha de corte (opcional, va al final). Con otra fecha puedo
-- probar qué pasaría más adelante sin esperar a que llegue ese día.
-- =====================================================================
CREATE OR REPLACE PROCEDURE actualizar_estado_funciones(
    OUT p_finalizadas  INT,
    OUT p_en_curso     INT,
    p_fecha_corte      TIMESTAMP DEFAULT NOW()
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_fecha_corte IS NULL THEN
        RAISE EXCEPTION 'La fecha de corte no puede ser NULL';
    END IF;

    -- cuento cuántas ya terminaron y las paso a Finalizada
    SELECT COUNT(*) INTO p_finalizadas
    FROM funciones
    WHERE estado IN ('Programada', 'En curso')
      AND fecha_hora_fin < p_fecha_corte;

    UPDATE funciones
    SET estado = 'Finalizada'
    WHERE estado IN ('Programada', 'En curso')
      AND fecha_hora_fin < p_fecha_corte;

    -- cuento cuántas están pasando ahora y las paso a En curso
    SELECT COUNT(*) INTO p_en_curso
    FROM funciones
    WHERE estado = 'Programada'
      AND fecha_hora_inicio <= p_fecha_corte
      AND fecha_hora_fin >= p_fecha_corte;

    UPDATE funciones
    SET estado = 'En curso'
    WHERE estado = 'Programada'
      AND fecha_hora_inicio <= p_fecha_corte
      AND fecha_hora_fin >= p_fecha_corte;

    RAISE NOTICE 'Funciones actualizadas: % finalizada(s) y % en curso', p_finalizadas, p_en_curso;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'No se pudo actualizar el estado de las funciones: %', SQLERRM;
END;
$$;

-- ---------------------------------------------------------------------
-- Consulta para ver los procedimientos que quedaron creados 
-- ---------------------------------------------------------------------
SELECT proname AS procedimiento,
       pg_get_function_arguments(oid) AS parametros
FROM pg_proc
WHERE pronamespace = 'public'::regnamespace
  AND prokind = 'p'
ORDER BY proname;

-- =====================================================================
-- PRUEBAS
-- Las ejecuto una por una: selecciono el bloque y ejecuto
-- Las que dicen "Prueba FALLA" tienen que mostrar el error del procedimiento.
-- Las que empiezan con BEGIN van en pasos: el BEGIN con el CALL, luego la
-- consulta para revisar (la "b") y al final el ROLLBACK (la "c") para no
-- dejar datos de prueba guardados.
-- =====================================================================

-- # PRUEBA 1 (procedimiento 1): venta en línea completa. El espectador 1 compra 2 boletas Estudiante para la función 21 (3D, base 22000, 20 %): cada una 17600, total 35200
-- BEGIN;
-- CALL registrar_venta(1, NULL, 'Online', 21, 2, 2, NULL, NULL);

-- # PRUEBA 1b: reviso lo que se guardó (se ejecuta justo después de la 1, antes del ROLLBACK)
-- SELECT v.id_venta, v.canal, v.estado, d.id_funcion, d.cantidad, d.precio_unitario
-- FROM ventas v
-- INNER JOIN detalle_ventas d ON d.id_venta = v.id_venta
-- WHERE v.id_venta = (SELECT MAX(id_venta) FROM ventas);

-- # PRUEBA 1c: se hace rollback para no dejar la venta de prueba
-- ROLLBACK;

-- # PRUEBA 2 (procedimiento 1): más boletas que sillas
-- -- Prueba FALLA:
-- CALL registrar_venta(1, NULL, 'Online', 21, 1, 9999, NULL, NULL);

-- # PRUEBA 3 (procedimiento 1): función que no existe
-- -- Prueba FALLA:
-- CALL registrar_venta(1, NULL, 'Online', 9999, 1, 2, NULL, NULL);

-- # PRUEBA 4 (procedimiento 1): función que ya terminó (la 1 está Finalizada)
-- -- Prueba FALLA:
-- CALL registrar_venta(1, NULL, 'Online', 1, 1, 2, NULL, NULL);

-- # PRUEBA 5 (procedimiento 1): venta presencial con un gerente (el empleado 1). Aquí el error lo da el trigger 3 y el procedimiento lo repite con su mensaje
-- -- Prueba FALLA:
-- CALL registrar_venta(1, 1, 'Presencial', 21, 1, 2, NULL, NULL);

-- # PRUEBA 6 (procedimiento 2): reporte de la función 21
-- CALL reporte_ventas_funcion(21, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

-- # PRUEBA 7 (procedimiento 2): función que no existe
-- -- Prueba FALLA:
-- CALL reporte_ventas_funcion(9999, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

-- # PRUEBA 8 (procedimiento 3): como si hoy fuera 31/12/2026, las 10 funciones programadas ya terminaron
-- BEGIN;
-- CALL actualizar_estado_funciones(NULL, NULL, '2026-12-31 00:00');

-- # PRUEBA 8b: reviso cómo quedaron los estados (justo después de la 8, antes del ROLLBACK)
-- SELECT estado, COUNT(*) AS funciones FROM funciones GROUP BY estado ORDER BY estado;

-- # PRUEBA 8c: se hace rollback 
-- ROLLBACK;

-- # PRUEBA 9 (procedimiento 3): fecha de corte NULL
-- -- Prueba FALLA:
-- CALL actualizar_estado_funciones(NULL, NULL, NULL);