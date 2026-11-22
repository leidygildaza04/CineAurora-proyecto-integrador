# Cine Aurora (Grupo Cinemas 8) — Proyecto Integrador: Arquitectura Políglota PostgreSQL + MongoDB

Proyecto integrador de **Bases de Datos 2** que combina un núcleo transaccional en **PostgreSQL**, una capa documental en **MongoDB** y un módulo de integración (API REST + interfaz web) que consulta y escribe en ambos motores.

## Información del proyecto

| Campo | Detalle |
|---|---|
| Universidad | Universidad El Bosque |
| Facultad | Ingeniería — Programa de Ingeniería de Sistemas |
| Asignatura | Bases de Datos 2 |
| Docente | Francisco Barguil |
| Grupo | **Cinemas 8** (grupo de 2 integrantes) |
| Empresa | **Cine Aurora** |
| Avance 1 (PostgreSQL) | 15 de octubre de 2026 |
| Avance 2 (MongoDB) | 12 de noviembre de 2026 |
| Entrega final (integración) | 22 de noviembre de 2026, 11:59 PM |
| Sustentación con demo en vivo | 24 o 26 de noviembre de 2026 |

## Integrantes

- Yeison Alejandro Silva Rodriguez
- Leidy Vanessa Gil Daza

## Identidad de la empresa

**Cine Aurora** (perteneciente al grupo **Cinemas 8**) es un complejo cinematográfico ubicado en Bogotá D.C., Colombia. Su enfoque principal es la exhibición de cine de autor, clásico e independiente (drama, documental, animación, romance, musical), combinado con estrenos comerciales de aventura, terror y ciencia ficción.

Además de la proyección comercial, Cine Aurora organiza eventos culturales especiales como conversatorios, ciclos temáticos y presentaciones en vivo con directores y actores invitados, por lo que requiere un sistema integrado de contratación de artistas y asignación de personal de staff.

### Datos operativos

- **Capacidad total:** 1.200 espectadores distribuidos en 8 salas.
- **Distribución de salas:**
  - 2 VIP (Aurora: 80 p, Boreal: 100 p)
  - 2 formato 3D (Eclipse: 150 p, Fénix: 160 p)
  - 4 formato 2D (Cenit: 120 p, Delta: 120 p, Galaxia: 220 p, Horizonte: 250 p)
- **Modalidad transaccional:** mixta (taquilla física vinculada a un empleado taquillero y venta virtual de autoservicio).
- **Categorías de boleta:** General, Estudiante (20 % desc.), Tercera Edad (30 % desc.) y Matiné (25 % desc.).
- **Artistas registrados:** 40 actores/directores vinculados mediante contratos de tipo Charla, Presentación o Ciclo.

---

## Arquitectura políglota

| Motor | Rol dentro del sistema | Qué guarda |
|---|---|---|
| **PostgreSQL** | Núcleo transaccional (consistencia ACID) | Películas, salas, funciones, espectadores, staff, contratos, ventas y detalle de ventas |
| **MongoDB** | Capa documental (esquema flexible) | Fichas técnicas, requisitos de proyección, reseñas e incidentes |
| **API Node.js (Express)** | Capa de integración | Se conecta a los dos motores al mismo tiempo, combina la información y la expone por HTTP |
| **Frontend web** | Interfaz de exposición | Catálogo de películas, horarios y reseñas |

El diagrama de arquitectura está en `avance2-mongodb/diagrama-arquitectura-poliglota/`.

**Criterio de reparto:** lo que exige integridad referencial y transacciones (ventas, aforo, contratos) vive en PostgreSQL; lo que varía de forma o crece sin estructura fija (fichas, requisitos técnicos, reseñas, incidentes) vive en MongoDB. Las dos capas se relacionan por identificadores compartidos (`id_pelicula`, `id_funcion`, `id_sala`, `id_espectador`, `id_staff`).

---

## Estructura del repositorio

```
CineAurora-proyecto-integrador/
├── README.md
├── avance1-postgresql/
│   ├── modelo-er/
│   ├── modelo-relacional/
│   ├── scripts/                 (01_creacion_tablas ... 05_consultas)
│   ├── evidencias/
│   └── Documento PDF avance/avance1-informe.pdf
├── avance2-mongodb/
│   ├── diagrama-arquitectura-poliglota/
│   ├── scripts/                 (01_creacion_colecciones ... 03_consultas)
│   ├── evidencias/
│   └── Documento PDF avance 2/avance2-informe_final.pdf
└── entrega-final/
    ├── script-integracion/      (código Node.js: backend)
    ├── modulo-api/              (API REST, frontend y colección Postman)
    ├── informe-final-consolidado.pdf
    └── portafolio-individual/
        └── [nombre-estudiante]-reflexion.pdf
```

---

## Requisitos previos

- PostgreSQL 14 o superior, con una base de datos llamada `cine_aurora`.
- MongoDB 6 o superior (local o Atlas), con una base de datos llamada `cine_aurora`.
- Node.js 18 o superior y npm.
- `mongosh` para ejecutar los scripts de la Fase 2.
- Opcional: Postman, para importar la colección de pruebas.

---

## Instrucciones de ejecución

### Fase 1 — Núcleo transaccional (PostgreSQL)

Crear la base de datos y ejecutar los scripts **en este orden**:

```bash
createdb -U postgres cine_aurora
psql -U postgres -d cine_aurora -f avance1-postgresql/scripts/01_creacion_tablas.sql
psql -U postgres -d cine_aurora -f avance1-postgresql/scripts/02_datos_prueba.sql
psql -U postgres -d cine_aurora -f avance1-postgresql/scripts/03_triggers.sql
psql -U postgres -d cine_aurora -f avance1-postgresql/scripts/04_procedimientos.sql
psql -U postgres -d cine_aurora -f avance1-postgresql/scripts/05_consultas.sql
```

**Contenido de la fase:**

1. **Modelo relacional en 3FN (11 tablas):** `actores_directores`, `peliculas`, `salas`, `staff`, `tipos_boleta`, `espectadores`, `contratos`, `funciones`, `ventas`, `detalle_ventas` y `funcion_staff`.
2. **Triggers de integridad (8):**
   - `trg_calcular_precio` (`detalle_ventas`): calcula el precio final de la boleta aplicando el descuento de su categoría.
   - `trg_validar_capacidad` (`detalle_ventas`): impide vender más boletas que la capacidad de la sala.
   - `trg_validar_taquillero` (`ventas`): verifica que las ventas presenciales las registre un empleado con cargo de taquillero.
   - `trg_validar_horario_funcion` (`funciones`): garantiza que la hora de fin sea posterior a la de inicio y que no se crucen horarios en la sala.
   - `trg_validar_contrato` (`contratos`): valida montos positivos y fechas coherentes.
   - `trg_validar_mantenimiento_sala` (`salas`): controla los cambios de estado de mantenimiento de una sala.
   - `trg_validar_inactivar_staff` (`staff`): evita inactivar personal que tiene asignaciones pendientes.
   - `trg_normalizar_espectador` (`espectadores`): normaliza los datos del espectador (por ejemplo, el correo) antes de guardarlos.
3. **Procedimientos almacenados (3), con `RAISE EXCEPTION` y bloque `EXCEPTION`:**
   - `registrar_venta`: registra la cabecera y el detalle de una venta como una sola transacción y devuelve el id de la venta y el total.
   - `reporte_ventas_funcion`: reporte de una función (ventas, boletas, recaudo y porcentaje de ocupación).
   - `actualizar_estado_funciones`: pasa las funciones a *En curso* o *Finalizada* según la fecha de corte.
4. **Consultas analíticas (3):** rentabilidad por película, ocupación por sala y espectadores que más gastan (JOIN, GROUP BY, HAVING, subconsultas y agregaciones).

### Fase 2 — Capa documental (MongoDB)

```bash
mongosh "mongodb://localhost:27017" avance2-mongodb/scripts/01_creacion_colecciones.js
mongosh "mongodb://localhost:27017" avance2-mongodb/scripts/02_datos_prueba.js
mongosh "mongodb://localhost:27017" avance2-mongodb/scripts/03_consultas.js
```

**Colecciones (con validación `$jsonSchema`):**

| Colección | Contenido |
|---|---|
| `fichas_tecnicas_peliculas` | Versiones, idiomas, subtítulos, elenco y clasificaciones por país |
| `requisitos_proyeccion` | Tipo de proyección y requerimientos técnicos por función y sala |
| `resenas_peliculas` | Calificación, texto y respuesta de la empresa |
| `reportes_incidentes` | Incidentes por sala y función, con detalles variables según el tipo |

El script `03_consultas.js` incluye 6 consultas y 3 agregaciones (promedio de calificaciones por película, incidentes por tipo y funciones por tipo de proyección).

### Fase 3 — Integración funcional (API + interfaz)

**1. Configurar las variables de entorno.** Dentro de `entrega-final/script-integracion/`, crear un archivo `.env` (no se sube al repositorio) con este contenido:

```env
PORT=3000
DB_HOST=localhost
DB_PORT=5432
DB_NAME=cine_aurora
DB_USER=postgres
DB_PASSWORD=<tu_contraseña_de_postgres>
MONGO_URI=mongodb://localhost:27017
```

**2. Instalar dependencias e iniciar el servidor:**

```bash
cd entrega-final/script-integracion
npm install
node server.js
```

El servidor abre la conexión a **MongoDB y PostgreSQL** al arrancar y queda disponible en `http://localhost:3000`.

**3. Abrir la interfaz web.** Abrir `index.html` (carpeta del frontend) en el navegador, o servirlo con cualquier servidor estático. La interfaz consume la API en `http://127.0.0.1:3000/api`.

**4. Verificar las conexiones:**

```bash
curl http://localhost:3000/api/prueba-db
```

### Endpoints de la API

> Los endpoints de integración combinan información de PostgreSQL y MongoDB en una sola respuesta. Todos devuelven códigos HTTP coherentes (`200`, `201`, `400`, `404`, `409`, `500`) y un cuerpo JSON con el campo `mensaje`.

**Consulta de un solo motor**

| Método | Ruta | Motor | Descripción |
|---|---|---|---|
| GET | `/api/peliculas` | PostgreSQL | Lista las películas |
| GET | `/api/peliculas/:id` | PostgreSQL | Detalle de una película (404 si no existe) |
| GET | `/api/funciones` | PostgreSQL | Funciones no canceladas con película y sala |
| GET | `/api/resenas` | MongoDB | Lista las reseñas |
| POST | `/api/resenas` | MongoDB | Publica una reseña (400 si faltan datos o la calificación no está entre 1 y 5) |

**Casos de uso de integración (PostgreSQL + MongoDB)**

| Caso | Ruta | Qué combina |
|---|---|---|
| 1. Función con sus reseñas | GET `/api/integracion/funciones/:id/resenas` | Función, película y sala (PostgreSQL) + reseñas de esa película (MongoDB) |
| 2. Película con sus requisitos técnicos | GET `/api/integracion/funciones/:id/requisitos` | Función y sala (PostgreSQL) + `requisitos_proyeccion` y ficha técnica (MongoDB) |
| 3. Ventas cruzadas con incidentes por sala | GET `/api/integracion/salas/ventas-incidentes` | Recaudo y boletas por sala (PostgreSQL) + incidentes por sala (MongoDB) |

**Transacción cruzada entre motores**

| Método | Ruta | Descripción |
|---|---|---|
| POST | `/api/integracion/ventas` | Registra la venta en PostgreSQL (`registrar_venta`) y, en la misma operación, genera el registro asociado en MongoDB. Si MongoDB falla, la venta de PostgreSQL se revierte (compensación), de modo que no queden datos a medias en un solo motor. |

Ejemplo de petición:

```bash
curl -X POST http://localhost:3000/api/integracion/ventas \
  -H "Content-Type: application/json" \
  -d '{"id_espectador": 1, "id_staff": 3, "canal": "Presencial", "id_funcion": 5, "id_tipo_boleta": 1, "cantidad": 2}'
```

**Manejo de errores contemplado**

- `400`: datos faltantes, tipos inválidos o ID no numérico.
- `404`: película, función o venta inexistente.
- `409`: violación de reglas del núcleo transaccional (aforo superado, función no programada, taquillero inválido), traducida desde los `RAISE EXCEPTION` de PostgreSQL.
- `500`: caída de alguno de los dos motores, con mensaje claro y sin exponer credenciales.

### Colección Postman

La colección documentada está en `entrega-final/modulo-api/` (archivo `.json`). Para usarla: *Postman → Import → seleccionar el archivo*, y definir la variable `baseUrl = http://localhost:3000`.

---

## Decisiones técnicas de conexión

- **Un único servicio, dos clientes.** El servidor Express mantiene un `Pool` de `pg` para PostgreSQL y un `MongoClient` para MongoDB, ambos configurados por variables de entorno.
- **Credenciales fuera del repositorio.** El archivo `.env` está en `.gitignore`; solo se versionan las variables de ejemplo.
- **Consultas parametrizadas** (`$1, $2...`) en PostgreSQL para evitar inyección SQL.
- **Consistencia entre motores.** PostgreSQL es la fuente de verdad de las ventas; la escritura en MongoDB se hace después de confirmar la transacción SQL y, si falla, se compensa revirtiendo la venta.
- **Identificadores compartidos** como llave lógica entre los dos motores, ya que MongoDB no impone integridad referencial.

---

## Evidencias

- Avance 1: capturas de creación de tablas, datos, triggers, procedimientos y consultas en `avance1-postgresql/evidencias/`.
- Avance 2: colecciones, fichas y consultas/agregaciones en `avance2-mongodb/evidencias/`.
- Entrega final: capturas de ejecución real de los casos de uso y de la transacción cruzada, incluidas en `entrega-final/informe-final-consolidado.pdf`.

## Documentos

- `avance1-postgresql/Documento PDF avance/avance1-informe.pdf`
- `avance2-mongodb/Documento PDF avance 2/avance2-informe_final.pdf`
- `entrega-final/informe-final-consolidado.pdf`
- `entrega-final/portafolio-individual/` (reflexión individual de cada integrante)

---

*Universidad El Bosque — Ingeniería de Sistemas — Bases de Datos 2 — 2026-II*
