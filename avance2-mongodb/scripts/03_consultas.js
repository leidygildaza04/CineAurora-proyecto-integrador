
use("cine_aurora");

// CONSULTA 1: Buscar fichas técnicas de una película
db.fichas_tecnicas_peliculas.find({
  id_pelicula: 1
});

// CONSULTA 2: Buscar proyecciones en formato 3D
db.requisitos_proyeccion.find({
  tipo_proyeccion: "3D"
});

// CONSULTA 3: Consultar reseñas con calificación alta
db.resenas_peliculas.find({
  calificacion: { $gte: 4 }
});

// CONSULTA 4: Consultar incidentes de seguridad
db.reportes_incidentes.find({
  tipo_incidente: "Seguridad"
});

// CONSULTA 5: Buscar reseñas de un espectador
db.resenas_peliculas.find({
  id_espectador: 10
});

// CONSULTA 6: Consultar incidentes de una sala
db.reportes_incidentes.find({
  id_sala: 1
});

// AGREGACIÓN 1: Promedio de calificaciones por película
db.resenas_peliculas.aggregate([
  {
    $group: {
      _id: "$id_pelicula",
      promedio_calificacion: { $avg: "$calificacion" },
      total_resenas: { $sum: 1 }
    }
  },
  {
    $sort: { promedio_calificacion: -1 }
  }
]);

// AGREGACIÓN 2: Cantidad de incidentes por tipo
db.reportes_incidentes.aggregate([
  {
    $group: {
      _id: "$tipo_incidente",
      total_incidentes: { $sum: 1 }
    }
  },
  {
    $sort: { total_incidentes: -1 }
  }
]);

// AGREGACIÓN 3: Cantidad de funciones por tipo de proyección
db.requisitos_proyeccion.aggregate([
  {
    $group: {
      _id: "$tipo_proyeccion",
      total_funciones: { $sum: 1 }
    }
  },
  {
    $sort: { total_funciones: -1 }
  }
]);

print("Consultas y agregaciones ejecutadas correctamente.");

