import 'package:recetario_utez/dominio/receta.dart';

Dificultad dificultadDesdeTexto(Object? valor) {
  return switch (valor) {
    'Easy' => Dificultad.facil,
    'Medium' => Dificultad.media,
    'Hard' => Dificultad.dificil,
    _ => Dificultad.desconocida,
  };
}

Receta recetaDesdeJson(Map<String, dynamic> json) {
  return switch (json) {
    {
      'id': int id,
      'name': String nombre,
      'cuisine': String cocina,
      'prepTimeMinutes': int prep,
      'cookTimeMinutes': int coccion,
      'servings': int porciones,
      'rating': num calificacion,
    } =>
      Receta(
        id: id,
        nombre: nombre,
        cocina: cocina,
        dificultad: dificultadDesdeTexto(json['difficulty']),
        minutosPreparacion: prep,
        minutosCoccion: coccion,
        porciones: porciones,
        calificacion: calificacion.toDouble(),
        etiquetas: _listaDeTextos(json, 'tags'),
        ingredientes: _listaDeTextos(json, 'ingredients'),
      ),
    _ => throw FormatException('Receta con forma inesperada', json),
  };
}

List<String> _listaDeTextos(Map<String, dynamic> json, String llave) {
  if (!json.containsKey(llave)) return const [];
  final valor = json[llave];
  if (valor is! List) {
    throw FormatException(' "$llave" no es una lista', valor);
  }
  return [
    for (final elemento in valor)
      if (elemento is String)
        elemento
      else
        throw FormatException('Elemento de "$llave" no es texto', elemento),
  ];
}

PaginaRecetas paginaDesdeJson(Map<String, dynamic> json) {
  return switch (json) {
    {'recipes': List lista, 'total': int total} => PaginaRecetas(
      recetas: [
        for (final item in lista)
          switch (item) {
            Map<String, dynamic> mapa => recetaDesdeJson(mapa),
            _ => throw FormatException(
              'Elemento de recipes no es objeto',
              item,
            ),
          },
      ],
      total: total,
    ),
    _ => throw FormatException('Página con forma inesperada', json),
  };
}
