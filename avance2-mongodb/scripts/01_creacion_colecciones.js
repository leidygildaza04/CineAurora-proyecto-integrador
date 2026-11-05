use("cine_aurora");

// 1. Fichas técnicas de películas
db.createCollection("fichas_tecnicas_peliculas", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["id_pelicula", "titulo", "versiones"],
      properties: {
        id_pelicula: { bsonType: "int" },
        titulo: { bsonType: "string" },
        versiones: {
          bsonType: "array",
          items: {
            bsonType: "object",
            required: ["formato", "duracion_min"],
            properties: {
              formato: { bsonType: "string" },
              duracion_min: { bsonType: "int" },
              idioma: { bsonType: "string" },
              subtitulos: { bsonType: "array" }
            }
          }
        },
        elenco: { bsonType: "array" },
        clasificaciones: { bsonType: "array" }
      }
    }
  },
  validationLevel: "strict",
  validationAction: "error"
});

// 2. Requisitos técnicos de proyección
db.createCollection("requisitos_proyeccion", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["id_funcion", "id_sala", "tipo_proyeccion"],
      properties: {
        id_funcion: { bsonType: "int" },
        id_sala: { bsonType: "int" },
        tipo_proyeccion: { bsonType: "string" },
        requerimientos: { bsonType: "object" }
      }
    }
  },
  validationLevel: "strict",
  validationAction: "error"
});

// 3. Reseñas de películas
db.createCollection("resenas_peliculas", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["id_pelicula", "id_espectador", "calificacion", "texto"],
      properties: {
        id_pelicula: { bsonType: "int" },
        id_espectador: { bsonType: "int" },
        calificacion: {
          bsonType: ["int", "double"],
          minimum: 1,
          maximum: 5
        },
        texto: { bsonType: "string" },
        fecha: { bsonType: "date" },
        respuesta_empresa: { bsonType: "object" }
      }
    }
  },
  validationLevel: "strict",
  validationAction: "error"
});

// 4. Reportes de incidentes
db.createCollection("reportes_incidentes", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["id_sala", "tipo_incidente", "descripcion", "fecha"],
      properties: {
        id_sala: { bsonType: "int" },
        id_funcion: { bsonType: ["int", "null"] },
        id_staff: { bsonType: ["int", "null"] },
        tipo_incidente: { bsonType: "string" },
        descripcion: { bsonType: "string" },
        fecha: { bsonType: "date" },
        detalles: { bsonType: "object" }
      }
    }
  },
  validationLevel: "strict",
  validationAction: "error"
});

print("Las cuatro colecciones fueron creadas correctamente.");
