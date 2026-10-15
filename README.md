Cine Aurora (Grupo Cinemas 8) — Avance 1: Núcleo Transaccional en PostgreSQL

Información del Proyecto

Universidad: Universidad El Bosque

Facultad: Ingeniería — Programa de Ingeniería de Sistemas

Asignatura: Bases de Datos 2

Docente: Francisco Barguil

Fecha de Entrega: 15 de Octubre de 2026

Integrantes (Grupo de 2)

Yeison Alejandro Silva Rodriguez

Leidy Vanessa Gil Daza

Identidad de la Empresa

Cine Aurora (perteneciente al grupo Cinemas 8) es un complejo cinematográfico ubicado en Bogotá D.C., Colombia. Nuestro enfoque principal es la exhibición de cine de autor, clásico e independiente (drama, documental, animación, romance, musical), combinado con estrenos comerciales de aventura, terror y ciencia ficción.

Además de la proyección comercial de películas, Cine Aurora organiza eventos culturales especiales como conversatorios, ciclos temáticos y presentaciones en vivo con directores y actores invitados, requiriendo un sistema integrado de contratación de artistas y asignación de personal de staff.

Datos Operativos

Capacidad Total: 1.200 espectadores distribuidos en 8 salas.

Distribución de Salas:

2 VIP (Aurora: 80p, Boreal: 100p)

2 Formato 3D (Eclipse: 150p, Fénix: 160p)

4 Formato 2D (Cenit: 120p, Delta: 120p, Galaxia: 220p, Horizonte: 250p)

Modalidad Transaccional: Mixta (Taquilla física vinculada a empleado taquillero y venta virtual autoservicio).

Categorías de Boleta: General, Estudiante (20% desc.), Tercera Edad (30% desc.) y Matiné (25% desc.).

Artistas Registrados: 40 actores/directores vinculados mediante contratos de tipo Charla, Presentación o Ciclo.




Descripción del Núcleo Transaccional

1. Modelo Relacional en 3FN (11 Tablas)

El diseño garantiza la eliminación de redundancias y anomalías a través de 11 entidades normalizadas:

2. Triggers de Integridad (8 Triggers en 7 Tablas)

Para asegurar el control distribuido de la base de datos, se implementaron triggers automatizados:

trg_validar_aforo_sala (Boleta): Controla que no se vendan más boletas que la capacidad total de la sala.

trg_impedir_silla_duplicada (Boleta): Evita la sobreventa de la misma silla en una misma función.

trg_actualizar_total_venta (Boleta): Recalcula automáticamente el total acumulado en la cabecera Venta.

trg_validar_horario_funcion (Funcion): Garantiza que las horas fin sean posteriores al inicio.

trg_validar_cargo_taquillero (Venta): Verifica que solo empleados con cargo 'Taquillero' procesen ventas físicas.

trg_validar_vigencia_contrato (Contrato_Artista): Asegura que el monto del contrato sea positivo y en fechas coherentes.

trg_validar_tipo_sala (Sala): Restringe los tipos de sala únicamente a '2D', '3D' o 'VIP'.

trg_validar_unicidad_staff (Staff_Funcion): Evita asignar dos veces al mismo empleado en el mismo rol para la misma función.

3. Procedimientos Almacenados Transaccionales

Todos los procedimientos cuentan con gestión formal de errores (EXCEPTION y RAISE EXCEPTION):

sp_programar_funcion: Valida solapamientos de horario en la sala antes de insertar una nueva función (incluyendo tiempo de limpieza).

sp_registrar_venta_taquilla: Procesa la transacción atómica de venta de boleta, aplicando los porcentajes de descuento por categoría y generando la boleta.

sp_mantenimiento_estado_funciones: Procedimiento de mantenimiento para archivar o actualizar estados de funciones concluidas.

4. Consultas Analíticas Avanzadas

Incluye reportes complejos con agregaciones (SUM, AVG, COUNT), agrupamientos (GROUP BY), filtros agregados (HAVING) y combinaciones múltiples (JOIN).

Instrucciones de Despliegue y Ejecución


