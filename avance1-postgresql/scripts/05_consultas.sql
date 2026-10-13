-- =====================================================================
-- Proyecto Integrador 2026-2 - Avance 1: Núcleo transaccional
-- Empresa : Cine Aurora (grupo Cinemas 8) - Bogotá D.C., Colombia
-- Script  : 05_consultas.sql
--
-- Aquí están las 3 consultas. Se corre después de los scripts (tablas) y
-- (datos). Cada una responde una pregunta que se haría la
-- administración del cine:
--
--   1. ¿Qué películas dejan más plata y cuáles no pagan lo que cuestan?
--      (JOIN de varias tablas + GROUP BY + SUM + subconsultas)
--   2. ¿Qué salas se están llenando y cuáles quedan vacías?
--      (JOIN + LEFT JOIN + subconsulta en el FROM + GROUP BY)
--   3. ¿Quiénes son los espectadores que más gastan?
--      (JOIN + GROUP BY + HAVING con subconsulta)
-- =====================================================================


-- =====================================================================
-- CONSULTA 1: rentabilidad por película
--
-- Propósito de negocio: saber cuánta plata entró por cada película (boletas
-- vendidas) y cuánta se pagó en contratos a actores y directores, para ver
-- cuáles dejan ganancia y cuáles no. Con esto la administración decide qué
-- películas volver a programar y a cuáles no vale la pena contratarles
-- más gente. Hice:
-- - Una subconsulta suma lo que se recaudó por película 
-- - Otra subconsulta suma lo que se pagó en contratos por películas
-- - Las pego con LEFT JOIN a la tabla películas para que también salgan
--   las que no tienen ventas o no tienen contratos (en 0).
-- - Hago las dos sumas por separado para que no se multipliquen las
--   filas al unir las tablas.
-- =====================================================================
SELECT p.titulo                              AS pelicula,
       p.genero,
       COALESCE(i.funciones, 0)              AS funciones,
       COALESCE(i.boletas, 0)                AS boletas_vendidas,
       COALESCE(i.recaudo, 0)                AS recaudo,
       COALESCE(c.contratos, 0)              AS contratos,
       COALESCE(c.costo_contratos, 0)        AS costo_contratos,
       COALESCE(i.recaudo, 0) - COALESCE(c.costo_contratos, 0) AS balance
FROM peliculas p
LEFT JOIN (
    SELECT f.id_pelicula,
           COUNT(DISTINCT f.id_funcion)          AS funciones,
           SUM(d.cantidad)                       AS boletas,
           SUM(d.cantidad * d.precio_unitario)   AS recaudo
    FROM detalle_ventas d
    INNER JOIN ventas v     ON v.id_venta = d.id_venta
    INNER JOIN funciones f  ON f.id_funcion = d.id_funcion
    WHERE v.estado = 'Pagada'
    GROUP BY f.id_pelicula
) i ON i.id_pelicula = p.id_pelicula
LEFT JOIN (
    SELECT ct.id_pelicula,
           COUNT(*)         AS contratos,
           SUM(ct.valor)    AS costo_contratos
    FROM contratos ct
    WHERE ct.estado <> 'Cancelado'
    GROUP BY ct.id_pelicula
) c ON c.id_pelicula = p.id_pelicula
ORDER BY balance DESC, p.titulo;


-- =====================================================================
-- CONSULTA 2: ocupación por sala
--
-- Propósito de negocio: ver qué tan llenas están las salas. Para cada sala
-- muestra cuántas funciones tuvo, cuántas boletas se vendieron y qué
-- porcentaje de las sillas ofrecidas se ocupó. Si una sala sale muy baja,
-- se le puede cambiar el tipo de películas o el horario; si sale muy
-- alta, conviene ponerle más funciones.
--
--Hice:
-- - Una subconsulta en el FROM cuenta las boletas pagadas por función.
-- - Pego esa subconsulta con LEFT JOIN a las funciones, así las
--     funciones sin ninguna venta también cuentan (con 0 boletas).
-- - Las sillas ofrecidas son la capacidad de la sala multiplicada por
--     las funciones que tuvo. No cuento las funciones canceladas.
-- =====================================================================
SELECT s.nombre                                   AS sala,
       s.tipo,
       s.capacidad,
       COUNT(f.id_funcion)                        AS funciones,
       COALESCE(SUM(vb.boletas), 0)               AS boletas_vendidas,
       SUM(s.capacidad)                           AS sillas_ofrecidas,
       ROUND(100.0 * COALESCE(SUM(vb.boletas), 0) / SUM(s.capacidad), 2) AS porcentaje_ocupacion
FROM salas s
INNER JOIN funciones f ON f.id_sala = s.id_sala
LEFT JOIN (
    SELECT d.id_funcion,
           SUM(d.cantidad) AS boletas
    FROM detalle_ventas d
    INNER JOIN ventas v ON v.id_venta = d.id_venta
    WHERE v.estado = 'Pagada'
    GROUP BY d.id_funcion
) vb ON vb.id_funcion = f.id_funcion
WHERE f.estado <> 'Cancelada'
GROUP BY s.id_sala, s.nombre, s.tipo, s.capacidad
ORDER BY porcentaje_ocupacion DESC, s.nombre;


-- =====================================================================
-- CONSULTA 3: espectadores que gastan más que el promedio
--
-- Propósito de negocio: encontrar a los clientes más valiosos, los que han
-- gastado más que el gasto promedio de los espectadores que compraron.
-- Con esa lista se puede hacer una promoción o un programa de fidelidad
-- para que sigan viniendo.
--
-- Hice:
--  - Uno espectadores, ventas y detalle de venta, y agrupo por
--     espectador para sumar lo que gastó cada uno.
--  - El HAVING compara ese gasto con una subconsulta que calcula el
--     promedio de gasto de todos los espectadores. Uso HAVING y no WHERE
--     porque comparo contra una suma (WHERE no puede usar SUM).
-- =====================================================================
SELECT e.id_espectador,
       e.nombre_completo                          AS espectador,
       COUNT(DISTINCT v.id_venta)                 AS compras,
       SUM(d.cantidad)                            AS boletas,
       SUM(d.cantidad * d.precio_unitario)        AS total_gastado
FROM espectadores e
INNER JOIN ventas v          ON v.id_espectador = e.id_espectador
INNER JOIN detalle_ventas d  ON d.id_venta = v.id_venta
WHERE v.estado = 'Pagada'
GROUP BY e.id_espectador, e.nombre_completo
HAVING SUM(d.cantidad * d.precio_unitario) > (
    SELECT AVG(t.gasto)
    FROM (
        SELECT SUM(d2.cantidad * d2.precio_unitario) AS gasto
        FROM ventas v2
        INNER JOIN detalle_ventas d2 ON d2.id_venta = v2.id_venta
        WHERE v2.estado = 'Pagada'
        GROUP BY v2.id_espectador
    ) t
)
ORDER BY total_gastado DESC, e.nombre_completo;