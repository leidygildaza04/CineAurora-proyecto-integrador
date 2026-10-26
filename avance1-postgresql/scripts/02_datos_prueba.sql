-- =====================================================================
-- Proyecto Integrador 2026-2 - Avance 1: Núcleo transaccional
-- Empresa : Cine Aurora (grupo Cinemas 8) - Bogotá D.C., Colombia
-- Script  : 02_datos_prueba.sql
-- Requiere: Ejecutar antes 01_creacion_tablas.sql (11 tablas)
-- Registros:
--   actores_directores 40 | peliculas 15 | salas 8 | staff 15
--   tipos_boleta 4 | espectadores 30 | contratos 30 | funciones 30
--   funcion_staff 104 | ventas 30 | detalle_ventas 35
-- =====================================================================
SET client_encoding = 'UTF8';

TRUNCATE funcion_staff, detalle_ventas, ventas, funciones, contratos, espectadores,
         tipos_boleta, staff, salas, peliculas, actores_directores RESTART IDENTITY CASCADE;

-- 1. ACTORES_DIRECTORES (40)
INSERT INTO actores_directores (nombre_artistico, nombre_completo, rol, nacionalidad, fecha_nacimiento, email_contacto) VALUES
  ('Rodrigo Moreno', 'Rodrigo Moreno Torres', 'Director', 'Colombiana', '1969-06-01', 'rodrigo.moreno1@artistas-cine.co'),
  ('Sofía Zapata', 'Sofía Zapata Bernal', 'Actor', 'Argentina', '1957-03-08', 'sofia.zapata2@artistas-cine.co'),
  ('Felipe Ramírez', 'Felipe Ramírez Gómez', 'Director', 'Española', '1979-08-06', 'felipe.ramirez3@artistas-cine.co'),
  ('Elena Vargas', 'Elena Vargas Ospina', 'Actor', 'Colombiana', '1982-04-24', NULL),
  ('Esteban Salazar', 'Esteban Salazar Cifuentes', 'Director', 'Colombiana', '1974-02-13', 'esteban.salazar5@artistas-cine.co'),
  ('Sofía Vargas', 'Sofía Vargas Ramírez', 'Director', 'Francesa', '1967-10-10', 'sofia.vargas6@artistas-cine.co'),
  ('Camilo Vargas', 'Camilo Vargas Rojas', 'Actor', NULL, '1975-10-21', 'camilo.vargas7@artistas-cine.co'),
  ('Verónica Herrera', 'Verónica Herrera Gómez', 'Actor', 'Mexicana', '1959-04-15', 'veronica.herrera8@artistas-cine.co'),
  ('Álvaro Ramírez', 'Álvaro Ramírez Zapata', 'Director', 'Colombiana', '1989-06-27', 'alvaro.ramirez9@artistas-cine.co'),
  ('Emilio Pardo', 'Emilio Pardo Torres', 'Director', 'Española', '1954-02-07', 'emilio.pardo10@artistas-cine.co'),
  ('Gloria Cifuentes', 'Gloria Cifuentes Mejía', 'Ambos', 'Uruguaya', '1950-10-12', 'gloria.cifuentes11@artistas-cine.co'),
  ('Isabela Restrepo', 'Isabela Restrepo Ospina', 'Actor', 'Uruguaya', NULL, 'isabela.restrepo12@artistas-cine.co'),
  ('Verónica Castillo', 'Verónica Castillo Villamizar', 'Ambos', 'Francesa', '1974-03-21', 'veronica.castillo13@artistas-cine.co'),
  ('Nicolás Navarro', 'Nicolás Navarro Bernal', 'Actor', 'Colombiana', '1964-10-08', 'nicolas.navarro14@artistas-cine.co'),
  ('Ricardo Rojas', 'Ricardo Rojas Peña', 'Actor', 'Mexicana', '1990-09-07', 'ricardo.rojas15@artistas-cine.co'),
  ('Daniela Acosta', 'Daniela Acosta Quintero', 'Actor', 'Uruguaya', '1988-02-14', 'daniela.acosta16@artistas-cine.co'),
  ('Mateo Herrera', 'Mateo Herrera Gómez', 'Director', 'Francesa', '1982-05-08', 'mateo.herrera17@artistas-cine.co'),
  ('Laura Ortiz', 'Laura Ortiz Salazar', 'Ambos', 'Brasileña', '1988-08-10', 'laura.ortiz18@artistas-cine.co'),
  ('Andrea Rojas', 'Andrea Rojas Bernal', 'Ambos', 'Peruana', '1996-02-05', 'andrea.rojas19@artistas-cine.co'),
  ('Mauricio Quintero', 'Mauricio Quintero Duarte', 'Actor', 'Colombiana', '1991-10-20', NULL),
  ('Julián Ortiz', 'Julián Ortiz Vargas', 'Director', 'Colombiana', '1963-12-01', 'julian.ortiz21@artistas-cine.co'),
  ('Julián Ortiz S.', 'Julián Ortiz Salazar', 'Actor', 'Peruana', '1978-04-02', 'julian.ortiz22@artistas-cine.co'),
  ('Santiago Rojas', 'Santiago Rojas Navarro', 'Actor', 'Colombiana', '1973-09-19', 'santiago.rojas23@artistas-cine.co'),
  ('Esteban Torres', 'Esteban Torres Cárdenas', 'Actor', NULL, '1958-08-11', 'esteban.torres24@artistas-cine.co'),
  ('Andrea Palacios', 'Andrea Palacios Castillo', 'Actor', 'Colombiana', '1987-01-01', 'andrea.palacios25@artistas-cine.co'),
  ('Carolina Bernal', 'Carolina Bernal Cárdenas', 'Actor', 'Española', '1994-05-02', 'carolina.bernal26@artistas-cine.co'),
  ('Camilo Restrepo', 'Camilo Restrepo Cifuentes', 'Actor', 'Colombiana', '1954-08-03', 'camilo.restrepo27@artistas-cine.co'),
  ('Leonardo Moreno', 'Leonardo Moreno Castillo', 'Actor', 'Argentina', '1954-02-15', 'leonardo.moreno28@artistas-cine.co'),
  ('Catalina Cárdenas', 'Catalina Cárdenas Peña', 'Director', 'Colombiana', '1952-12-24', 'catalina.cardenas29@artistas-cine.co'),
  ('Esteban Montoya', 'Esteban Montoya Bernal', 'Director', 'Colombiana', '1971-06-03', 'esteban.montoya30@artistas-cine.co'),
  ('Carolina Acosta', 'Carolina Acosta Torres', 'Director', 'Estadounidense', '1976-01-28', 'carolina.acosta31@artistas-cine.co'),
  ('Lucía Palacios', 'Lucía Palacios Ramírez', 'Director', 'Chilena', '1989-11-13', NULL),
  ('Daniela Palacios', 'Daniela Palacios Ramírez', 'Ambos', 'Chilena', '1988-02-03', 'daniela.palacios33@artistas-cine.co'),
  ('Sebastián Cifuentes', 'Sebastián Cifuentes Herrera', 'Actor', 'Chilena', '1966-07-24', 'sebastian.cifuentes34@artistas-cine.co'),
  ('Camila Pardo', 'Camila Pardo Bernal', 'Actor', 'Peruana', '1997-12-19', 'camila.pardo35@artistas-cine.co'),
  ('Paula Ospina', 'Paula Ospina Giraldo', 'Ambos', 'Colombiana', '1984-02-17', 'paula.ospina36@artistas-cine.co'),
  ('Manuela Ramírez', 'Manuela Ramírez Navarro', 'Ambos', 'Colombiana', '1988-02-16', 'manuela.ramirez37@artistas-cine.co'),
  ('Camilo Mejía', 'Camilo Mejía Arango', 'Director', 'Estadounidense', '1957-08-25', 'camilo.mejia38@artistas-cine.co'),
  ('Sara Lozano', 'Sara Lozano Bernal', 'Ambos', 'Brasileña', '1981-05-01', 'sara.lozano39@artistas-cine.co'),
  ('Isabela Navarro', 'Isabela Navarro Castillo', 'Director', 'Mexicana', '1993-10-07', 'isabela.navarro40@artistas-cine.co');

-- 2. PELICULAS (15, títulos ficticios)
INSERT INTO peliculas (titulo, genero, duracion_min, clasificacion, anio_estreno, idioma) VALUES
  ('El Último Tranvía de Chapinero', 'Drama', 112, '12+', 2024, 'Español'),
  ('Cartas desde el Páramo', 'Drama', 98, '15+', 2023, 'Español'),
  ('La Noche del Relojero', 'Suspenso', 104, '15+', 2022, 'Español'),
  ('Sombras en Technicolor', 'Drama', 128, '12+', 1958, 'Inglés'),
  ('Mar de Lava', 'Aventura', 117, '7+', 2025, 'Inglés'),
  ('Pequeños Faroles', 'Animación', 86, 'T', 2025, 'Español'),
  ('Kintsugi', 'Drama', 101, '12+', 2024, 'Japonés'),
  ('El Jardín de Vidrio', 'Romance', 109, '12+', 2021, 'Francés'),
  ('Frontera Líquida', 'Documental', 92, 'T', 2023, 'Español'),
  ('Rojo Carmesí', 'Terror', 95, '18+', 2024, 'Inglés'),
  ('Doña Remedios', 'Comedia', 99, '7+', 2022, 'Español'),
  ('La Última Función', 'Drama', 121, '12+', 1964, 'Francés'),
  ('Horizonte Cero', 'Ciencia ficción', 133, '12+', 2025, 'Inglés'),
  ('Tango en la Lluvia', 'Musical', 106, '7+', 1971, 'Español'),
  ('Os Meninos do Rio Azul', 'Drama', 114, '12+', 2023, 'Portugués');

-- 3. SALAS (8; capacidad total 1.200)
INSERT INTO salas (nombre, tipo, capacidad, estado) VALUES
  ('Sala Aurora', 'VIP', 80, 'Activa'),
  ('Sala Boreal', 'VIP', 100, 'Activa'),
  ('Sala Cenit', '2D', 120, 'Activa'),
  ('Sala Delta', '2D', 120, 'Activa'),
  ('Sala Eclipse', '3D', 150, 'Activa'),
  ('Sala Fénix', '3D', 160, 'Activa'),
  ('Sala Galaxia', '2D', 220, 'Activa'),
  ('Sala Horizonte', '2D', 250, 'Activa');

-- 4. STAFF (15: ids 1-2 gerentes, 3-6 taquilleros, 7-10 proyeccionistas, 11-15 acomodadores; el 15 está inactivo)
INSERT INTO staff (documento, nombre_completo, cargo, fecha_ingreso, salario, estado) VALUES
  ('1010100927', 'Andrea Rojas Zapata', 'Gerente', '2024-08-16', 6500000, 'Activo'),
  ('1010108175', 'Valentina Pardo Lozano', 'Gerente', '2023-07-26', 6500000, 'Activo'),
  ('1010116435', 'Héctor Pardo Mejía', 'Taquillero', '2024-04-05', 1900000, 'Activo'),
  ('1010124674', 'Lucía Cárdenas Giraldo', 'Taquillero', '2022-02-09', 1900000, 'Activo'),
  ('1010131957', 'Daniel Ospina Quintero', 'Taquillero', '2023-07-13', 2100000, 'Activo'),
  ('1010139917', 'Andrea Quintero Lozano', 'Taquillero', '2025-06-03', 1900000, 'Activo'),
  ('1010147556', 'Rodrigo Villamizar Restrepo', 'Proyeccionista', '2024-06-10', 3100000, 'Activo'),
  ('1010155572', 'Verónica Ramírez Cifuentes', 'Proyeccionista', '2025-08-07', 2900000, 'Activo'),
  ('1010163496', 'Rodrigo Mejía Zapata', 'Proyeccionista', '2022-02-15', 2900000, 'Activo'),
  ('1010171648', 'Catalina Cifuentes Montoya', 'Proyeccionista', '2022-04-07', 3000000, 'Activo'),
  ('1010179201', 'Álvaro Rojas Arango', 'Acomodador', '2025-09-23', 1600000, 'Activo'),
  ('1010187906', 'Tomás Mejía Ortiz', 'Acomodador', '2024-09-23', 1800000, 'Activo'),
  ('1010195191', 'Manuela Restrepo Zapata', 'Acomodador', '2025-04-03', 1700000, 'Activo'),
  ('1010203411', 'Daniela Castillo Ospina', 'Acomodador', '2023-01-13', 1800000, 'Activo'),
  ('1010211380', 'Verónica Cifuentes Acosta', 'Acomodador', '2024-08-11', 1800000, 'Inactivo');

-- 5. TIPOS_BOLETA (4)
INSERT INTO tipos_boleta (nombre, porcentaje_descuento, descripcion) VALUES
  ('General', 0, 'Tarifa regular'),
  ('Estudiante', 20, 'Presentando carné estudiantil vigente'),
  ('Tercera edad', 30, 'Mayores de 60 años'),
  ('Matiné', 25, 'Funciones que inician antes de las 5:00 p. m.');

-- 6. ESPECTADORES (30)
INSERT INTO espectadores (documento, nombre_completo, email, fecha_nacimiento, fecha_registro) VALUES
  ('1047692958', 'Héctor Montoya Villamizar', 'hector.montoya1@correo.co', '1961-03-18', '2025-11-19'),
  ('1737874856', 'Esteban Quintero Castillo', 'esteban.quintero2@correo.co', '1996-12-15', '2026-08-25'),
  ('1575500520', 'Lucía Palacios Arango', 'lucia.palacios3@correo.co', '1984-09-10', '2026-07-31'),
  ('1611264377', 'Elena Cifuentes Rojas', 'elena.cifuentes4@correo.co', '1996-05-10', '2026-05-10'),
  ('1594880075', 'Daniela Villamizar Acosta', 'daniela.villamizar5@correo.co', '1974-09-09', '2026-03-21'),
  ('1015299775', 'Lucía Vargas Salazar', NULL, '2007-10-13', '2025-06-15'),
  ('1614373511', 'Catalina Gómez Beltrán', 'catalina.gomez7@correo.co', '1995-02-16', '2025-07-18'),
  ('1869416641', 'Gabriel Torres Bernal', 'gabriel.torres8@correo.co', '1983-07-09', '2025-10-05'),
  ('1521673111', 'Carolina Quintero Castillo', 'carolina.quintero9@correo.co', '1996-09-11', '2025-07-26'),
  ('1763881316', 'Ricardo Salazar Restrepo', 'ricardo.salazar10@correo.co', '1999-01-02', '2025-09-08'),
  ('1391551035', 'Nicolás Mejía Ramírez', 'nicolas.mejia11@correo.co', '1993-04-20', '2026-02-11'),
  ('1279029926', 'Felipe Quintero Peña', 'felipe.quintero12@correo.co', '2000-12-07', '2026-05-26'),
  ('1453887027', 'Andrea Acosta Salazar', 'andrea.acosta13@correo.co', '1999-09-20', '2025-08-21'),
  ('1242112239', 'Catalina Vargas Villamizar', 'catalina.vargas14@correo.co', '1954-09-20', '2026-03-28'),
  ('1657603222', 'Esteban Mejía Bernal', 'esteban.mejia15@correo.co', '1953-06-07', '2025-09-20'),
  ('1790155590', 'Ricardo Acosta Herrera', 'ricardo.acosta16@correo.co', '1955-02-09', '2025-12-16'),
  ('1766815095', 'Felipe Salazar Giraldo', 'felipe.salazar17@correo.co', '1965-03-07', '2025-12-24'),
  ('1766678370', 'Camilo Herrera Vargas', NULL, '1959-09-21', '2026-06-24'),
  ('1124002741', 'Camila Beltrán Lozano', 'camila.beltran19@correo.co', '2002-01-02', '2026-06-26'),
  ('1208144341', 'Elena Restrepo Beltrán', 'elena.restrepo20@correo.co', '1952-02-07', '2025-08-28'),
  ('1741181277', 'Gabriel Navarro Bernal', 'gabriel.navarro21@correo.co', '2000-08-03', '2026-06-27'),
  ('1390716850', 'Felipe Moreno Pardo', 'felipe.moreno22@correo.co', '1986-07-07', '2026-04-04'),
  ('1448039258', 'Isabela Ramírez Cifuentes', 'isabela.ramirez23@correo.co', '1975-08-12', '2026-06-14'),
  ('1560357962', 'Isabela Pardo Bernal', 'isabela.pardo24@correo.co', '1973-01-11', '2025-07-14'),
  ('1376118627', 'Laura Palacios Restrepo', 'laura.palacios25@correo.co', '1988-05-09', '2025-07-30'),
  ('1588611428', 'Gabriel Giraldo Bernal', 'gabriel.giraldo26@correo.co', '1980-12-12', '2026-06-28'),
  ('1208446206', 'Natalia Zapata Rojas', NULL, '1993-02-26', '2025-11-22'),
  ('1680036674', 'Leonardo Quintero Herrera', 'leonardo.quintero28@correo.co', '1990-01-08', '2025-10-18'),
  ('1092499844', 'Leonardo Moreno Vargas', 'leonardo.moreno29@correo.co', '2005-07-17', '2026-02-10'),
  ('1670776874', 'Héctor Arango Herrera', 'hector.arango30@correo.co', '2005-02-24', '2025-09-30');

-- 7. CONTRATOS (30)
INSERT INTO contratos (id_actor_director, id_pelicula, tipo_contrato, fecha_inicio, fecha_fin, valor, estado) VALUES
  (17, 8, 'Presentacion', '2026-11-07', '2026-11-07', 800000, 'Vigente'),
  (17, 5, 'Ciclo', '2026-11-18', '2026-12-30', 6800000, 'Vigente'),
  (3, 7, 'Charla', '2026-10-07', '2026-10-07', 1450000, 'Finalizado'),
  (4, 7, 'Presentacion', '2026-10-16', '2026-10-18', 1950000, 'Vigente'),
  (31, 11, 'Ciclo', '2026-11-21', '2026-12-06', 6700000, 'Cancelado'),
  (3, 11, 'Charla', '2026-10-13', '2026-10-13', 550000, 'Vigente'),
  (21, 2, 'Charla', '2026-10-18', '2026-10-19', 1300000, 'Vigente'),
  (30, 3, 'Charla', '2026-07-30', '2026-07-31', 800000, 'Finalizado'),
  (4, 6, 'Charla', '2026-08-09', '2026-08-10', 1150000, 'Finalizado'),
  (39, 5, 'Charla', '2026-10-16', '2026-10-16', 850000, 'Vigente'),
  (8, 9, 'Ciclo', '2026-11-07', '2026-12-08', 4750000, 'Vigente'),
  (16, 4, 'Charla', '2026-11-06', '2026-11-06', 900000, 'Vigente'),
  (28, 1, 'Charla', '2026-07-10', '2026-07-10', 600000, 'Finalizado'),
  (11, 9, 'Charla', '2026-10-04', '2026-10-05', 1000000, 'Finalizado'),
  (32, 12, 'Charla', '2026-07-20', '2026-07-21', 1150000, 'Finalizado'),
  (17, 7, 'Charla', '2026-10-03', '2026-10-04', 1150000, 'Finalizado'),
  (24, 10, 'Presentacion', '2026-10-27', '2026-10-29', 2150000, 'Vigente'),
  (32, 14, 'Presentacion', '2026-09-15', '2026-09-15', 1450000, 'Finalizado'),
  (20, 8, 'Ciclo', '2026-09-11', '2026-10-17', 8800000, 'Vigente'),
  (8, 6, 'Presentacion', '2026-11-23', '2026-11-25', 2250000, 'Vigente'),
  (26, 15, 'Charla', '2026-09-02', '2026-09-03', 1050000, 'Finalizado'),
  (26, 10, 'Presentacion', '2026-08-19', '2026-08-21', 1350000, 'Finalizado'),
  (30, 15, 'Ciclo', '2026-07-06', '2026-07-30', 7150000, 'Finalizado'),
  (28, 2, 'Charla', '2026-11-17', '2026-11-17', 900000, 'Vigente'),
  (7, 15, 'Ciclo', '2026-07-22', '2026-08-11', 7550000, 'Cancelado'),
  (15, 8, 'Charla', '2026-09-25', '2026-09-26', 1000000, 'Finalizado'),
  (9, 8, 'Presentacion', '2026-11-15', '2026-11-15', 1900000, 'Vigente'),
  (25, 14, 'Presentacion', '2026-10-27', '2026-10-27', 1150000, 'Vigente'),
  (27, 15, 'Charla', '2026-09-01', '2026-09-02', 800000, 'Finalizado'),
  (28, 9, 'Ciclo', '2026-09-09', '2026-10-12', 7100000, 'Cancelado');

-- 8. FUNCIONES (30: 20 finalizadas y 10 programadas)
INSERT INTO funciones (id_sala, id_pelicula, fecha_hora_inicio, fecha_hora_fin, precio_base, estado) VALUES
  (1, 1, '2026-09-15 13:00:00', '2026-09-15 14:52:00', 35000, 'Finalizada'),
  (2, 8, '2026-09-15 15:30:00', '2026-09-15 17:19:00', 35000, 'Finalizada'),
  (3, 15, '2026-09-15 18:00:00', '2026-09-15 19:54:00', 18000, 'Finalizada'),
  (4, 7, '2026-09-15 20:30:00', '2026-09-15 22:11:00', 18000, 'Finalizada'),
  (5, 14, '2026-09-15 13:00:00', '2026-09-15 14:46:00', 22000, 'Finalizada'),
  (6, 6, '2026-09-15 15:30:00', '2026-09-15 16:56:00', 22000, 'Finalizada'),
  (7, 13, '2026-09-15 18:00:00', '2026-09-15 20:13:00', 18000, 'Finalizada'),
  (8, 5, '2026-09-15 20:30:00', '2026-09-15 22:27:00', 18000, 'Finalizada'),
  (1, 12, '2026-09-21 13:00:00', '2026-09-21 15:01:00', 35000, 'Finalizada'),
  (2, 4, '2026-09-21 15:30:00', '2026-09-21 17:38:00', 35000, 'Finalizada'),
  (3, 11, '2026-09-21 18:00:00', '2026-09-21 19:39:00', 18000, 'Finalizada'),
  (4, 3, '2026-09-21 20:30:00', '2026-09-21 22:14:00', 18000, 'Finalizada'),
  (5, 10, '2026-09-21 13:00:00', '2026-09-21 14:35:00', 22000, 'Finalizada'),
  (6, 2, '2026-09-21 15:30:00', '2026-09-21 17:08:00', 22000, 'Finalizada'),
  (7, 9, '2026-09-21 18:00:00', '2026-09-21 19:32:00', 18000, 'Finalizada'),
  (8, 1, '2026-09-21 20:30:00', '2026-09-21 22:22:00', 18000, 'Finalizada'),
  (1, 8, '2026-09-27 13:00:00', '2026-09-27 14:49:00', 35000, 'Finalizada'),
  (2, 15, '2026-09-27 15:30:00', '2026-09-27 17:24:00', 35000, 'Finalizada'),
  (3, 7, '2026-09-27 18:00:00', '2026-09-27 19:41:00', 18000, 'Finalizada'),
  (4, 14, '2026-09-27 20:30:00', '2026-09-27 22:16:00', 18000, 'Finalizada'),
  (5, 6, '2026-10-12 13:00:00', '2026-10-12 14:26:00', 22000, 'Programada'),
  (6, 13, '2026-10-12 15:30:00', '2026-10-12 17:43:00', 22000, 'Programada'),
  (7, 5, '2026-10-12 18:00:00', '2026-10-12 19:57:00', 18000, 'Programada'),
  (8, 12, '2026-10-12 20:30:00', '2026-10-12 22:31:00', 18000, 'Programada'),
  (1, 4, '2026-10-12 13:00:00', '2026-10-12 15:08:00', 35000, 'Programada'),
  (2, 11, '2026-10-12 15:30:00', '2026-10-12 17:09:00', 35000, 'Programada'),
  (3, 3, '2026-10-12 18:00:00', '2026-10-12 19:44:00', 18000, 'Programada'),
  (4, 10, '2026-10-12 20:30:00', '2026-10-12 22:05:00', 18000, 'Programada'),
  (5, 2, '2026-10-17 13:00:00', '2026-10-17 14:38:00', 22000, 'Programada'),
  (6, 9, '2026-10-17 15:30:00', '2026-10-17 17:02:00', 22000, 'Programada');

-- 9. FUNCION_STAFF (personal asignado a cada función)
INSERT INTO funcion_staff (id_funcion, id_staff, rol_en_funcion) VALUES
  (1, 1, 'Responsable'),
  (1, 7, 'Proyeccion'),
  (1, 13, 'Acomodacion'),
  (2, 2, 'Responsable'),
  (2, 8, 'Proyeccion'),
  (2, 13, 'Acomodacion'),
  (3, 1, 'Responsable'),
  (3, 9, 'Proyeccion'),
  (3, 13, 'Acomodacion'),
  (4, 1, 'Responsable'),
  (4, 10, 'Proyeccion'),
  (4, 12, 'Acomodacion'),
  (5, 2, 'Responsable'),
  (5, 7, 'Proyeccion'),
  (5, 11, 'Acomodacion'),
  (5, 13, 'Acomodacion'),
  (6, 1, 'Responsable'),
  (6, 8, 'Proyeccion'),
  (6, 11, 'Acomodacion'),
  (6, 12, 'Acomodacion'),
  (7, 2, 'Responsable'),
  (7, 9, 'Proyeccion'),
  (7, 11, 'Acomodacion'),
  (7, 13, 'Acomodacion'),
  (8, 1, 'Responsable'),
  (8, 10, 'Proyeccion'),
  (8, 13, 'Acomodacion'),
  (8, 12, 'Acomodacion'),
  (9, 1, 'Responsable'),
  (9, 7, 'Proyeccion'),
  (9, 13, 'Acomodacion'),
  (10, 2, 'Responsable'),
  (10, 8, 'Proyeccion'),
  (10, 12, 'Acomodacion'),
  (11, 1, 'Responsable'),
  (11, 9, 'Proyeccion'),
  (11, 11, 'Acomodacion'),
  (12, 1, 'Responsable'),
  (12, 10, 'Proyeccion'),
  (12, 12, 'Acomodacion'),
  (13, 2, 'Responsable'),
  (13, 7, 'Proyeccion'),
  (13, 13, 'Acomodacion'),
  (13, 11, 'Acomodacion'),
  (14, 2, 'Responsable'),
  (14, 8, 'Proyeccion'),
  (14, 11, 'Acomodacion'),
  (14, 14, 'Acomodacion'),
  (15, 1, 'Responsable'),
  (15, 9, 'Proyeccion'),
  (15, 14, 'Acomodacion'),
  (15, 11, 'Acomodacion'),
  (16, 1, 'Responsable'),
  (16, 10, 'Proyeccion'),
  (16, 14, 'Acomodacion'),
  (16, 13, 'Acomodacion'),
  (17, 1, 'Responsable'),
  (17, 7, 'Proyeccion'),
  (17, 14, 'Acomodacion'),
  (18, 2, 'Responsable'),
  (18, 8, 'Proyeccion'),
  (18, 13, 'Acomodacion'),
  (19, 1, 'Responsable'),
  (19, 9, 'Proyeccion'),
  (19, 13, 'Acomodacion'),
  (20, 1, 'Responsable'),
  (20, 10, 'Proyeccion'),
  (20, 12, 'Acomodacion'),
  (21, 2, 'Responsable'),
  (21, 7, 'Proyeccion'),
  (21, 13, 'Acomodacion'),
  (21, 12, 'Acomodacion'),
  (22, 2, 'Responsable'),
  (22, 8, 'Proyeccion'),
  (22, 14, 'Acomodacion'),
  (22, 11, 'Acomodacion'),
  (23, 2, 'Responsable'),
  (23, 9, 'Proyeccion'),
  (23, 12, 'Acomodacion'),
  (23, 11, 'Acomodacion'),
  (24, 2, 'Responsable'),
  (24, 10, 'Proyeccion'),
  (24, 12, 'Acomodacion'),
  (24, 14, 'Acomodacion'),
  (25, 1, 'Responsable'),
  (25, 7, 'Proyeccion'),
  (25, 11, 'Acomodacion'),
  (26, 1, 'Responsable'),
  (26, 8, 'Proyeccion'),
  (26, 13, 'Acomodacion'),
  (27, 2, 'Responsable'),
  (27, 9, 'Proyeccion'),
  (27, 13, 'Acomodacion'),
  (28, 2, 'Responsable'),
  (28, 10, 'Proyeccion'),
  (28, 12, 'Acomodacion'),
  (29, 1, 'Responsable'),
  (29, 7, 'Proyeccion'),
  (29, 11, 'Acomodacion'),
  (29, 12, 'Acomodacion'),
  (30, 2, 'Responsable'),
  (30, 8, 'Proyeccion'),
  (30, 14, 'Acomodacion'),
  (30, 11, 'Acomodacion');

-- 10. VENTAS (30; las ventas en línea no tienen taquillero)
INSERT INTO ventas (id_espectador, id_staff, fecha_hora, canal, estado) VALUES
  (10, NULL, '2026-09-13 20:39:00', 'Online', 'Pagada'),
  (13, NULL, '2026-09-14 02:46:00', 'Online', 'Pagada'),
  (14, NULL, '2026-09-14 12:01:00', 'Online', 'Pagada'),
  (29, NULL, '2026-09-15 02:20:00', 'Online', 'Pagada'),
  (30, NULL, '2026-09-15 03:01:00', 'Online', 'Anulada'),
  (17, NULL, '2026-09-15 04:39:00', 'Online', 'Pagada'),
  (25, NULL, '2026-09-15 06:52:00', 'Online', 'Pagada'),
  (30, NULL, '2026-09-15 07:45:00', 'Online', 'Pagada'),
  (18, 4, '2026-09-15 11:57:00', 'Presencial', 'Pagada'),
  (25, 4, '2026-09-15 14:46:00', 'Presencial', 'Pagada'),
  (8, 6, '2026-09-15 17:05:00', 'Presencial', 'Pagada'),
  (17, NULL, '2026-09-19 06:16:00', 'Online', 'Pagada'),
  (18, NULL, '2026-09-19 06:54:00', 'Online', 'Pagada'),
  (11, NULL, '2026-09-20 01:27:00', 'Online', 'Anulada'),
  (16, NULL, '2026-09-20 13:55:00', 'Online', 'Pagada'),
  (18, NULL, '2026-09-21 05:31:00', 'Online', 'Pagada'),
  (13, NULL, '2026-09-21 05:54:00', 'Online', 'Pagada'),
  (22, NULL, '2026-09-21 07:45:00', 'Online', 'Pagada'),
  (1, 3, '2026-09-21 13:54:00', 'Presencial', 'Pagada'),
  (17, NULL, '2026-09-21 14:20:00', 'Online', 'Pagada'),
  (20, 5, '2026-09-27 16:12:00', 'Presencial', 'Pagada'),
  (27, 4, '2026-09-27 19:04:00', 'Presencial', 'Pagada'),
  (17, 6, '2026-10-05 14:46:00', 'Presencial', 'Pagada'),
  (17, 4, '2026-10-05 20:50:00', 'Presencial', 'Pagada'),
  (3, 6, '2026-10-06 13:32:00', 'Presencial', 'Pagada'),
  (25, 6, '2026-10-06 16:52:00', 'Presencial', 'Pagada'),
  (24, NULL, '2026-10-06 19:56:00', 'Online', 'Pagada'),
  (4, NULL, '2026-10-07 15:33:00', 'Online', 'Anulada'),
  (2, 3, '2026-10-07 16:15:00', 'Presencial', 'Pagada'),
  (13, 6, '2026-10-07 19:48:00', 'Presencial', 'Pagada');

-- 11. DETALLE_VENTAS (35: una o dos líneas por venta)
INSERT INTO detalle_ventas (id_venta, id_funcion, id_tipo_boleta, cantidad, precio_unitario) VALUES
  (1, 6, 2, 2, 17600.0),
  (2, 4, 1, 3, 18000.0),
  (2, 15, 2, 1, 14400.0),
  (3, 7, 3, 2, 12600.0),
  (4, 4, 2, 1, 14400.0),
  (5, 5, 2, 2, 17600.0),
  (6, 7, 1, 1, 18000.0),
  (7, 4, 1, 3, 18000.0),
  (8, 3, 1, 3, 18000.0),
  (8, 16, 2, 2, 14400.0),
  (9, 5, 3, 2, 15400.0),
  (10, 6, 4, 2, 16500.0),
  (11, 7, 1, 1, 18000.0),
  (12, 13, 3, 1, 15400.0),
  (13, 9, 3, 2, 24500.0),
  (14, 11, 1, 2, 18000.0),
  (15, 13, 3, 2, 15400.0),
  (16, 16, 3, 2, 12600.0),
  (16, 16, 1, 1, 18000.0),
  (17, 9, 2, 2, 28000.0),
  (18, 15, 1, 2, 18000.0),
  (19, 10, 3, 2, 24500.0),
  (20, 11, 3, 1, 12600.0),
  (21, 19, 3, 1, 12600.0),
  (22, 20, 1, 1, 18000.0),
  (23, 25, 3, 1, 24500.0),
  (24, 21, 3, 2, 15400.0),
  (24, 25, 3, 2, 24500.0),
  (25, 27, 1, 2, 18000.0),
  (26, 23, 1, 3, 18000.0),
  (27, 26, 4, 3, 26250.0),
  (28, 24, 1, 1, 18000.0),
  (29, 29, 4, 1, 16500.0),
  (29, 29, 1, 1, 22000.0),
  (30, 22, 1, 4, 22000.0);

-- ---------------------------------------------------------------------
-- VERIFICACIÓN (útil para la captura de evidencia)
-- ---------------------------------------------------------------------
SELECT 'actores_directores' AS tabla, COUNT(*) AS registros FROM actores_directores
UNION ALL SELECT 'contratos',      COUNT(*) FROM contratos
UNION ALL SELECT 'detalle_ventas', COUNT(*) FROM detalle_ventas
UNION ALL SELECT 'espectadores',   COUNT(*) FROM espectadores
UNION ALL SELECT 'funcion_staff',  COUNT(*) FROM funcion_staff
UNION ALL SELECT 'funciones',      COUNT(*) FROM funciones
UNION ALL SELECT 'peliculas',      COUNT(*) FROM peliculas
UNION ALL SELECT 'salas',          COUNT(*) FROM salas
UNION ALL SELECT 'staff',          COUNT(*) FROM staff
UNION ALL SELECT 'tipos_boleta',   COUNT(*) FROM tipos_boleta
UNION ALL SELECT 'ventas',         COUNT(*) FROM ventas
ORDER BY tabla;

-- =====================================================================
-- MUESTRA DE LOS DATOS CARGADOS (la uso de evidencia)
-- Ejecuto cada consulta por separado: selecciono, quito el "-- " y F5.
-- =====================================================================

-- Muestra 1: las primeras 5 ventas con su espectador y su total
-- SELECT v.id_venta, e.nombre_completo AS espectador, v.canal, v.estado,
--        SUM(d.cantidad * d.precio_unitario) AS total
-- FROM ventas v
-- INNER JOIN espectadores e   ON e.id_espectador = v.id_espectador
-- INNER JOIN detalle_ventas d ON d.id_venta = v.id_venta
-- GROUP BY v.id_venta, e.nombre_completo, v.canal, v.estado
-- ORDER BY v.id_venta
-- LIMIT 5;

-- Muestra 2: las primeras 5 funciones con su película y su sala
SELECT f.id_funcion, p.titulo AS pelicula, s.nombre AS sala,
       f.fecha_hora_inicio, f.fecha_hora_fin, f.estado
FROM funciones f
INNER JOIN peliculas p ON p.id_pelicula = f.id_pelicula
INNER JOIN salas s     ON s.id_sala = f.id_sala
ORDER BY f.id_funcion
LIMIT 5;