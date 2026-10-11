-- =====================================================================
-- Proyecto Integrador 2026-2 - Avance 1: Núcleo transaccional
-- Empresa : Cine Aurora (grupo Cinemas 8) - Bogotá D.C., Colombia
-- Script  : 03_triggers.sql
-- Requiere: 01_creacion_tablas.sql y 02_datos_prueba.sql
-- Las pruebas están al final, comentadas: se ejecutan una por una.
-- =====================================================================

-- =====================================================================
-- TRIGGER 1: calcular el precio de la boleta (tabla detalle_ventas)
--
-- Este trigger calcula solo el precio unitario. Coge el precio base de la
-- función y le quita el descuento que tenga el tipo de boleta (estudiante,
-- tercera edad, matiné...). Así nadie tiene que escribir el precio a mano
-- y no se puede cobrar cualquier valor.
--
-- =====================================================================
CREATE OR REPLACE FUNCTION calcular_precio_fn()
RETURNS trigger AS $$
DECLARE
    v_precio_base NUMERIC(10,2);
    v_descuento   NUMERIC(5,2);
BEGIN
    -- busco el precio base de la función que se está vendiendo
    SELECT precio_base INTO v_precio_base
    FROM funciones
    WHERE id_funcion = NEW.id_funcion;

    -- busco cuánto descuento tiene el tipo de boleta
    SELECT porcentaje_descuento INTO v_descuento
    FROM tipos_boleta
    WHERE id_tipo_boleta = NEW.id_tipo_boleta;

    -- precio final = precio base menos el descuento
    NEW.precio_unitario := v_precio_base * (1 - v_descuento / 100);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_calcular_precio ON detalle_ventas;
CREATE TRIGGER trg_calcular_precio
    BEFORE INSERT ON detalle_ventas
    FOR EACH ROW
    EXECUTE FUNCTION calcular_precio_fn();

-- =====================================================================
-- TRIGGER 2: validar la capacidad de la sala (tabla detalle_ventas)
--
-- Este trigger no deja vender más boletas de las que caben en la sala.
-- Suma las boletas que ya están pagadas para esa función, le suma las que
-- se quieren vender ahora y compara con la capacidad de la sala. Las
-- ventas anuladas no cuentan porque esas sillas quedan libres.
--
-- =====================================================================
CREATE OR REPLACE FUNCTION validar_capacidad_fn()
RETURNS trigger AS $$
DECLARE
    v_estado_venta VARCHAR(10);
    v_capacidad    INT;
    v_sala         VARCHAR(50);
    v_vendidas     INT;
BEGIN
    -- miro si la venta está pagada o anulada
    SELECT estado INTO v_estado_venta
    FROM ventas
    WHERE id_venta = NEW.id_venta;

    -- solo reviso el cupo si la venta está pagada
    IF v_estado_venta = 'Pagada' THEN
        -- saco la capacidad de la sala donde es la función
        SELECT s.capacidad, s.nombre INTO v_capacidad, v_sala
        FROM funciones f
        INNER JOIN salas s ON s.id_sala = f.id_sala
        WHERE f.id_funcion = NEW.id_funcion;

        -- cuento cuántas boletas pagadas ya hay para esa función
        SELECT COALESCE(SUM(d.cantidad), 0) INTO v_vendidas
        FROM detalle_ventas d
        INNER JOIN ventas v ON v.id_venta = d.id_venta
        WHERE d.id_funcion = NEW.id_funcion
          AND v.estado = 'Pagada'
          AND d.id_detalle <> NEW.id_detalle;

        -- si las vendidas más las nuevas pasan la capacidad, lo paro
        IF v_vendidas + NEW.cantidad > v_capacidad THEN
            RAISE EXCEPTION
                'Capacidad insuficiente en la función % (%). Capacidad: %, vendidas: %, solicitadas: %',
                NEW.id_funcion, v_sala, v_capacidad, v_vendidas, NEW.cantidad;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_validar_capacidad ON detalle_ventas;
CREATE TRIGGER trg_validar_capacidad
    BEFORE INSERT OR UPDATE ON detalle_ventas
    FOR EACH ROW
    EXECUTE FUNCTION validar_capacidad_fn();

-- =====================================================================
-- TRIGGER 3: validar el taquillero de la venta (tabla ventas)
--
-- Este trigger revisa quién registra la venta. Si la venta es en línea no
-- puede tener taquillero. Y si tiene un empleado, ese empleado tiene que
-- ser Taquillero y estar activo. Por ejemplo, un gerente no puede vender
-- boletas en taquilla.
-- =====================================================================
CREATE OR REPLACE FUNCTION validar_taquillero_fn()
RETURNS trigger AS $$
DECLARE
    v_cargo  VARCHAR(20);
    v_estado VARCHAR(10);
BEGIN
    -- una venta en línea no pasa por taquilla, entonces no puede llevar empleado
    IF NEW.canal = 'Online' AND NEW.id_staff IS NOT NULL THEN
        RAISE EXCEPTION 'Una venta en línea no lleva taquillero (id_staff debe ser NULL)';
    END IF;

    IF NEW.id_staff IS NOT NULL THEN
        -- miro qué cargo tiene el empleado y si está activo
        SELECT cargo, estado INTO v_cargo, v_estado
        FROM staff
        WHERE id_staff = NEW.id_staff;

        -- tiene que ser taquillero
        IF v_cargo <> 'Taquillero' THEN
            RAISE EXCEPTION 'El empleado % es % y no puede registrar ventas. Debe ser Taquillero',
                NEW.id_staff, v_cargo;
        END IF;

        -- y tiene que estar activo
        IF v_estado <> 'Activo' THEN
            RAISE EXCEPTION 'El taquillero % está inactivo y no puede registrar ventas', NEW.id_staff;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_validar_taquillero ON ventas;
CREATE TRIGGER trg_validar_taquillero
    BEFORE INSERT ON ventas
    FOR EACH ROW
    EXECUTE FUNCTION validar_taquillero_fn();

-- =====================================================================
-- TRIGGER 4: horario de la función (tabla funciones)
--
-- Este trigger hace dos cosas. Primero calcula la hora de fin sumándole la
-- duración de la película a la hora de inicio, así no importa lo que se
-- escriba en fecha_hora_fin (es lo mismo que el ejemplo del subtotal de la
-- clase, asignar con NEW.campo := valor). Segundo, revisa que en esa sala
-- no haya otra función a la misma hora, porque dos películas no pueden
-- pasar al tiempo en la misma sala.
-- =====================================================================
CREATE OR REPLACE FUNCTION validar_horario_funcion_fn()
RETURNS trigger AS $$
DECLARE
    v_duracion INT;
    v_choque   INT;
BEGIN
    -- busco cuánto dura la película
    SELECT duracion_min INTO v_duracion
    FROM peliculas
    WHERE id_pelicula = NEW.id_pelicula;

    -- la hora de fin la calculo yo: inicio + duración
    NEW.fecha_hora_fin := NEW.fecha_hora_inicio + v_duracion * INTERVAL '1 minute';

    -- las funciones canceladas no ocupan la sala, esas no las reviso
    IF NEW.estado <> 'Cancelada' THEN
        -- busco si ya hay otra función en la misma sala que se cruce con esta
        SELECT id_funcion INTO v_choque
        FROM funciones
        WHERE id_sala = NEW.id_sala
          AND estado <> 'Cancelada'
          AND id_funcion <> NEW.id_funcion
          AND fecha_hora_inicio < NEW.fecha_hora_fin
          AND NEW.fecha_hora_inicio < fecha_hora_fin
        LIMIT 1;

        -- si encontró una, hay cruce y lo paro
        IF v_choque IS NOT NULL THEN
            RAISE EXCEPTION 'Cruce de horario en la sala %: choca con la función %',
                NEW.id_sala, v_choque;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_validar_horario_funcion ON funciones;
CREATE TRIGGER trg_validar_horario_funcion
    BEFORE INSERT OR UPDATE ON funciones
    FOR EACH ROW
    EXECUTE FUNCTION validar_horario_funcion_fn();

-- =====================================================================
-- TRIGGER 5: vigencia del contrato (tabla contratos)
--
-- Este trigger revisa que las fechas del contrato tengan sentido: la fecha
-- de fin no puede ser antes que la de inicio, y un contrato no se puede
-- marcar como Finalizado si su fecha de fin todavía no ha llegado.
-- =====================================================================
CREATE OR REPLACE FUNCTION validar_contrato_fn()
RETURNS trigger AS $$
BEGIN
    -- el contrato no puede terminar antes de empezar
    IF NEW.fecha_fin < NEW.fecha_inicio THEN
        RAISE EXCEPTION 'Vigencia inválida: la fecha de fin (%) es anterior a la de inicio (%)',
            NEW.fecha_fin, NEW.fecha_inicio;
    END IF;

    -- no se puede dar por finalizado algo que todavía no termina
    IF NEW.estado = 'Finalizado' AND NEW.fecha_fin > CURRENT_DATE THEN
        RAISE EXCEPTION 'El contrato no puede estar Finalizado: su fecha de fin (%) aún no llega',
            NEW.fecha_fin;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_validar_contrato ON contratos;
CREATE TRIGGER trg_validar_contrato
    BEFORE INSERT OR UPDATE ON contratos
    FOR EACH ROW
    EXECUTE FUNCTION validar_contrato_fn();

-- =====================================================================
-- TRIGGER 6: mantenimiento de salas (tabla salas)
--
-- Este trigger no deja poner una sala en mantenimiento si todavía tiene
-- funciones programadas o en curso, porque esas funciones se quedarían sin
-- sala. Aquí uso NEW y OLD: NEW es el estado que se quiere poner y OLD el
-- que tenía antes, y solo reviso cuando cambia a Mantenimiento.
-- =====================================================================
CREATE OR REPLACE FUNCTION validar_mantenimiento_sala_fn()
RETURNS trigger AS $$
DECLARE
    v_pendientes INT;
BEGIN
    -- solo me importa cuando la sala pasa a Mantenimiento
    IF NEW.estado = 'Mantenimiento' AND OLD.estado <> 'Mantenimiento' THEN
        -- cuento las funciones de esa sala que todavía no terminan
        SELECT COUNT(*) INTO v_pendientes
        FROM funciones
        WHERE id_sala = NEW.id_sala
          AND estado IN ('Programada', 'En curso');

        IF v_pendientes > 0 THEN
            RAISE EXCEPTION
                'La sala "%" tiene % función(es) programada(s) o en curso. No puede pasar a mantenimiento',
                NEW.nombre, v_pendientes;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_validar_mantenimiento_sala ON salas;
CREATE TRIGGER trg_validar_mantenimiento_sala
    BEFORE UPDATE ON salas
    FOR EACH ROW
    EXECUTE FUNCTION validar_mantenimiento_sala_fn();

-- =====================================================================
-- TRIGGER 7: inactivar personal (tabla staff)
--
-- Este trigger no deja inactivar a un empleado que todavía está asignado a
-- funciones programadas o en curso, porque esa función se quedaría sin la
-- persona que la atiende. Igual que el anterior, miro OLD y NEW para saber
-- si el empleado estaba Activo y lo quieren pasar a Inactivo.
-- =====================================================================
CREATE OR REPLACE FUNCTION validar_inactivar_staff_fn()
RETURNS trigger AS $$
DECLARE
    v_asignadas INT;
BEGIN
    -- solo reviso cuando pasa de Activo a Inactivo
    IF NEW.estado = 'Inactivo' AND OLD.estado = 'Activo' THEN
        -- cuento en cuántas funciones pendientes está asignado
        SELECT COUNT(*) INTO v_asignadas
        FROM funcion_staff fs
        INNER JOIN funciones f ON f.id_funcion = fs.id_funcion
        WHERE fs.id_staff = NEW.id_staff
          AND f.estado IN ('Programada', 'En curso');

        IF v_asignadas > 0 THEN
            RAISE EXCEPTION
                'El empleado "%" está asignado a % función(es) programada(s). No puede quedar inactivo',
                NEW.nombre_completo, v_asignadas;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_validar_inactivar_staff ON staff;
CREATE TRIGGER trg_validar_inactivar_staff
    BEFORE UPDATE ON staff
    FOR EACH ROW
    EXECUTE FUNCTION validar_inactivar_staff_fn();

-- =====================================================================
-- TRIGGER 8: normalizar espectadores (tabla espectadores)
--
-- Este trigger deja limpios los datos del espectador antes de guardarlos:
-- quita los espacios que sobran en el nombre y el correo, y pone el correo
-- en minúsculas (así no quedan "Ana@Correo.com" y "ana@correo.com" como si
-- fueran distintos). También rechaza fechas que están en el futuro, porque
-- nadie puede haber nacido o registrado mañana.
-- =====================================================================
CREATE OR REPLACE FUNCTION normalizar_espectador_fn()
RETURNS trigger AS $$
BEGIN
    -- limpio espacios y paso el correo a minúsculas
    NEW.nombre_completo := btrim(NEW.nombre_completo);
    NEW.email := lower(btrim(NEW.email));

    -- no se aceptan fechas futuras
    IF NEW.fecha_nacimiento > CURRENT_DATE THEN
        RAISE EXCEPTION 'La fecha de nacimiento (%) no puede ser futura', NEW.fecha_nacimiento;
    END IF;

    IF NEW.fecha_registro > CURRENT_DATE THEN
        RAISE EXCEPTION 'La fecha de registro (%) no puede ser futura', NEW.fecha_registro;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_normalizar_espectador ON espectadores;
CREATE TRIGGER trg_normalizar_espectador
    BEFORE INSERT OR UPDATE ON espectadores
    FOR EACH ROW
    EXECUTE FUNCTION normalizar_espectador_fn();

-- ---------------------------------------------------------------------
-- Consulta para ver los triggers que quedaron creados (la uso de evidencia)
-- ---------------------------------------------------------------------
SELECT event_object_table AS tabla,
       trigger_name       AS trigger,
       string_agg(event_manipulation, ' / ' ORDER BY event_manipulation) AS eventos,
       action_timing      AS momento
FROM information_schema.triggers
WHERE trigger_schema = 'public'
GROUP BY event_object_table, trigger_name, action_timing
ORDER BY event_object_table, trigger_name;

-- =====================================================================
-- PRUEBAS
-- Las ejecuto una por una: selecciono el bloque, le quito el "-- " del
-- inicio de cada línea y le doy F5.
-- Las que dicen "Prueba FALLA" tienen que mostrar el error del trigger.
-- Las que empiezan con BEGIN las corro hasta el RETURNING (ahí sale la
-- tabla con el resultado) y después ejecuto ROLLBACK para no dejar datos.
-- =====================================================================

-- ### PRUEBA 1 (trigger 1): el precio se calcula solo. Mando precio 0 y el trigger lo corrige.
-- -- Función 21 (Sala Eclipse 3D, precio base 22000), tipo Estudiante (20 %): tiene que dar 17600
-- BEGIN;
-- INSERT INTO detalle_ventas (id_venta, id_funcion, id_tipo_boleta, cantidad, precio_unitario)
-- VALUES (1, 21, 2, 1, 0)
-- RETURNING id_detalle, id_funcion, id_tipo_boleta, cantidad, precio_unitario;
-- ROLLBACK;

-- ### PRUEBA 2 (trigger 2): intento vender más boletas que sillas. La función 21 es de la sala Eclipse (150 sillas).
-- -- Prueba FALLA:
-- INSERT INTO detalle_ventas (id_venta, id_funcion, id_tipo_boleta, cantidad, precio_unitario)
-- VALUES (1, 21, 1, 9999, 0);

-- ### PRUEBA 3 (trigger 3): venta en línea con taquillero
-- -- Prueba FALLA:
-- INSERT INTO ventas (id_espectador, id_staff, canal) VALUES (1, 3, 'Online');

-- ### PRUEBA 4 (trigger 3): venta presencial hecha por un gerente (el empleado 1 es gerente)
-- -- Prueba FALLA:
-- INSERT INTO ventas (id_espectador, id_staff, canal) VALUES (1, 1, 'Presencial');

-- ### PRUEBA 5 (trigger 4): cruce de horario. La función 1 ocupa la sala 1 el 15/09/2026 de 13:00 a 14:52.
-- -- Prueba FALLA:
-- INSERT INTO funciones (id_sala, id_pelicula, fecha_hora_inicio, fecha_hora_fin, precio_base)
-- VALUES (1, 1, '2026-09-15 13:30', '2026-09-15 14:00', 16000);

-- ### PRUEBA 6 (trigger 4): la hora de fin se calcula sola. Mando fin 21:00 pero la película 1 dura 112 min, tiene que quedar 21:52
-- BEGIN;
-- INSERT INTO funciones (id_sala, id_pelicula, fecha_hora_inicio, fecha_hora_fin, precio_base)
-- VALUES (8, 1, '2027-01-10 20:00', '2027-01-10 21:00', 16000)
-- RETURNING id_funcion, fecha_hora_inicio, fecha_hora_fin;
-- ROLLBACK;

-- ### PRUEBA 7 (trigger 5): contrato Finalizado con fecha de fin en el futuro
-- -- Prueba FALLA:
-- INSERT INTO contratos (id_actor_director, id_pelicula, tipo_contrato, fecha_inicio, fecha_fin, valor, estado)
-- VALUES (1, 1, 'Charla', CURRENT_DATE, CURRENT_DATE + 10, 100000, 'Finalizado');

-- ### PRUEBA 8 (trigger 6): poner en mantenimiento la sala 5 (Eclipse), que tiene funciones programadas
-- -- Prueba FALLA:
-- UPDATE salas SET estado = 'Mantenimiento' WHERE id_sala = 5;

-- ### PRUEBA 9 (trigger 7): inactivar al empleado 1, que está asignado a funciones programadas
-- -- Prueba FALLA:
-- UPDATE staff SET estado = 'Inactivo' WHERE id_staff = 1;

-- ### PRUEBA 10 (trigger 8): el nombre y el correo quedan limpios (sin espacios y el correo en minúsculas)
-- BEGIN;
-- INSERT INTO espectadores (documento, nombre_completo, email)
-- VALUES ('PRUEBA-001', '   Cliente De Prueba  ', '  PRUEBA@Correo.CO ')
-- RETURNING id_espectador, nombre_completo, email;
-- ROLLBACK;

-- ### PRUEBA 11 (trigger 8): fecha de nacimiento en el futuro
-- -- Prueba FALLA:
-- INSERT INTO espectadores (documento, nombre_completo, fecha_nacimiento)
-- VALUES ('PRUEBA-002', 'Cliente Futuro', CURRENT_DATE + 30);