
use("cine_aurora");

// 1. FICHAS TÉCNICAS
const fichas = [];

for (let i = 1; i <= 30; i++) {
  const pelicula = ((i - 1) % 15) + 1;

  fichas.push({
    id_ficha: i,
    id_pelicula: pelicula,
    titulo: [
      "El Último Tranvía de Chapinero",
      "Cartas desde el Páramo",
      "La Noche del Relojero",
      "Sombras en Technicolor",
      "Mar de Lava",
      "Pequeños Faroles",
      "Kintsugi",
      "El Jardín de Vidrio",
      "Frontera Líquida",
      "Rojo Carmesí",
      "Doña Remedios",
      "La Última Función",
      "Horizonte Cero",
      "Tango en la Lluvia",
      "Os Meninos do Rio Azul"
    ][pelicula - 1],
    versiones: [
      {
        formato: i % 2 === 0 ? "Digital 2D" : "Digital 3D",
        duracion_min: 90 + (i % 30),
        idioma: i % 2 === 0 ? "Español" : "Inglés",
        subtitulos: i % 2 === 0 ? ["Inglés"] : ["Español"]
      }
    ],
    elenco: [
      {
        id_actor_director: ((i - 1) % 40) + 1,
        papel: "Actor principal"
      }
    ],
    clasificaciones: [
      {
        pais: "Colombia",
        clasificacion: i % 2 === 0 ? "Todos" : "Mayores de 12 años"
      }
    ]
  });
}

db.fichas_tecnicas_peliculas.insertMany(fichas);

// 2. REQUISITOS DE PROYECCIÓN
const requisitos = [];

for (let i = 1; i <= 30; i++) {
  const tipo = ["2D", "3D", "IMAX", "Dolby Atmos"][((i - 1) % 4)];

  requisitos.push({
    id_funcion: i,
    id_sala: ((i - 1) % 8) + 1,
    tipo_proyeccion: tipo,
    requerimientos: {
      proyector: tipo === "3D" ? "Proyector 3D" : "Proyector digital",
      sonido: tipo === "Dolby Atmos" ? "Dolby Atmos" : "Estéreo",
      gafas_3d: tipo === "3D",
      resolucion: tipo === "IMAX" ? "4K" : "2K"
    }
  });
}

db.requisitos_proyeccion.insertMany(requisitos);

// 3. RESEÑAS DE PELÍCULAS
const resenas = [];

for (let i = 1; i <= 30; i++) {
  resenas.push({
    id_pelicula: ((i - 1) % 15) + 1,
    id_espectador: i,
    calificacion: (i % 5) + 1,
    texto: [
      "Excelente película, muy recomendada.",
      "Buena historia y actuaciones.",
      "La experiencia fue agradable.",
      "Me gustó la calidad de imagen.",
      "Una película entretenida."
    ][(i - 1) % 5],
    fecha: new Date(2026, 9, i),
    respuesta_empresa: {
      respondida: i % 2 === 0,
      mensaje: i % 2 === 0 ? "Gracias por compartir tu opinión." : ""
    }
  });
}

db.resenas_peliculas.insertMany(resenas);

// 4. REPORTES DE INCIDENTES
const incidentes = [];

for (let i = 1; i <= 30; i++) {
  const tipo = ["Falla técnica", "Queja", "Seguridad"][((i - 1) % 3)];

  incidentes.push({
    id_sala: ((i - 1) % 8) + 1,
    id_funcion: i,
    id_staff: ((i - 1) % 15) + 1,
    tipo_incidente: tipo,
    descripcion: [
      "Problema con el sistema de proyección.",
      "Reclamo presentado por un espectador.",
      "Novedad reportada durante la función."
    ][(i - 1) % 3],
    fecha: new Date(2026, 9, i),
    detalles: tipo === "Falla técnica"
      ? { equipo: "Proyector", gravedad: "Media" }
      : tipo === "Queja"
      ? { motivo: "Servicio", canal: "Presencial" }
      : { zona: "Entrada", accion: "Verificación" }
  });
}

db.reportes_incidentes.insertMany(incidentes);

print("Datos de prueba insertados correctamente.");
