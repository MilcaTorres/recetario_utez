# Evidencias — Recetario UTEZ

**Nombre:** Milca Torres Méndez

**Matrícula:** I20233TN128

**Fecha:** 3 de noviembre de 2026

**Dispositivo donde se probó:** Teléfono Android

## 1. Del JSON a Dart

| JSON              | Campo Dart              | Tipo           | Regla (obligatorio, tolerado, valor por defecto)                                                        |
|-------------------|-------------------------|----------------|---------------------------------------------------------------------------------------------------------|
| `id`              | `id`                    | `int`          | Obligatorio                                                                                             |
| `name`            | `nombre`                | `String`       | Obligatorio                                                                                             |
| `cuisine`         | `cocina`                | `String`       | Obligatorio                                                                                             |
| `difficulty`      | `dificultad`            | `Dificultad`   | Tolerado: `Easy`, `Medium` y `Hard` se traducen; cualquier otro valor, `null` o número da `desconocida` |
| `prepTimeMinutes` | `minutosPreparacion`    | `int`          | Obligatorio                                                                                             |
| `cookTimeMinutes` | `minutosCoccion`        | `int`          | Obligatorio                                                                                             |
| `servings`        | `porciones`             | `int`          | Obligatorio                                                                                             |
| `rating`          | `calificacion`          | `double`       | Obligatorio; llega entero o decimal (`num`) y se convierte con `.toDouble()`                            |
| `tags`            | `etiquetas`             | `List<String>` | Opcional: si falta, lista vacía; si no es lista o algún elemento no es texto, `FormatException`         |
| `ingredients`     | `ingredientes`          | `List<String>` | Opcional: si falta, lista vacía; si no es lista o algún elemento no es texto, `FormatException`         |
| `recipes`         | `PaginaRecetas.recetas` | `List<Receta>` | Obligatorio; cada elemento debe ser un objeto; lista vacía es válida                                    |
| `total`           | `PaginaRecetas.total`   | `int`          | Obligatorio                                                                                             |

## 2. Escenarios probados con el servicio real

| Escenario          | Cómo lo provoqué                                               | Qué vio la persona                                                                | Línea de la bitácora                                            | Captura                                     | Prueba del kit que lo cubre               |
|--------------------|----------------------------------------------------------------|-----------------------------------------------------------------------------------|-----------------------------------------------------------------|---------------------------------------------|-------------------------------------------|
| Éxito              | Busqué `chicken` en la app                                     | Encabezado "Mostrando N de M recetas · Rápidas: X" y tarjetas de recetas          | `→ GET /recipes/search`<br>`← 200 GET /recipes/search (894 ms)` | [01_exito.png](capturas/01_exito.png)       | `etapa4_viewmodel_test.dart`: "Inicial → Cargando → Listas, con exactamente dos avisos"; `etapa5_vistas_test.dart`: "texto + botón → indicador y botón apagado → tarjetas" |
| Vacío              | Busqué `zzzz`                                                  | `No encontramos recetas para "zzzz".`                                             | `→ GET /recipes/search`<br>`← 200 GET /recipes/search (336 ms)` | [02_vacio.png](capturas/02_vacio.png)       | `etapa3_datos_test.dart`: "200 sin resultados → página vacía"; `etapa4_viewmodel_test.dart`: "sin resultados → Vacias, recordando qué se buscó"                                |
| Error del servidor | Cambio temporal A: un interceptor cambia la ruta a `/http/503` | `El recetario no está disponible (503). Intenta más tarde.` y botón Reintentar    | `→ GET /recipes`<br>`✗ badResponse 503 GET /http/503 (835 ms)`  | [03_servidor.png](capturas/03_servidor.png) | `etapa3_datos_test.dart`: "503 → ErrorDelServidor(503)"                                |
| Sin red            | Desactivé el Wi-Fi del celular y busqué                        | `Sin conexión. Revisa tu red e intenta de nuevo.` y botón Reintentar              | `→ GET /recipes`<br>`✗ connectionError GET /recipes (216 ms)`   | [04_sin_red.png](capturas/04_sin_red.png)   | `etapa3_datos_test.dart`: "sin red → SinConexion"                               |
| Tiempo agotado     | Cambio temporal B: `delay=5000` en la query y timeouts de 2 s  | `El recetario tardó demasiado en responder. Intenta de nuevo.` y botón Reintentar | `→ GET /recipes`<br>`✗ receiveTimeout GET /recipes (2426 ms)`   | [05_timeout.png](capturas/05_timeout.png)   | `etapa3_datos_test.dart`: "receiveTimeout → TiempoAgotado"                               |

## 3. Preguntas de reflexión

1. **¿En qué se diferencian el escenario "Error del servidor" y "Sin red" desde el punto de vista de
   HTTP?**
   En el error del servidor sí hubo una conversación HTTP: el servidor recibió la petición y
   contestó con un código de estado (503). Dio lo registra como `badResponse` y `traducirError` lo
   convierte en `ErrorDelServidor(503)`. Sin red, la petición nunca llegó al servidor, así que no
   existe respuesta ni código de estado. Dio lo registra como `connectionError` y se traduce a
   `SinConexion`. Se nota en la bitácora: el primero trae el código `503` y el segundo no trae
   ninguno.

2. **¿Por qué "Vacío" no es un error?**
   Porque el servidor respondió correctamente, con un `200`, como se ve en la bitácora. La petición
   se entendió y se atendió bien: simplemente no hay recetas que coincidan, y `"recipes": []` es una
   respuesta válida. Por eso la app lo trata como un estado normal (`RecetasVacias`) con un mensaje
   informativo, y no como una falla.

3. **La búsqueda de la persona viaja en la query. ¿Por qué tu bitácora no la escribe?**
   Porque lo que la persona escribe es información suya, y los registros pueden compartirse o ser
   leídos por otras personas. Por eso la bitácora solo registra método, ruta (`options.path`),
   código, tipo de error y tiempo. La ruta no incluye la query, que sí aparecería con `options.uri`.
   En el escenario 5 se comprueba: la petición llevaba `delay=5000` y la bitácora no lo muestra.

4. **Si DummyJSON cambiara `rating` por `score`, ¿qué archivos tendrías que modificar y por qué solo
   esos?**
   Solo `lib/datos/recetas_json.dart`, que es el único lugar donde aparece el texto `'rating'`. El
   dominio, el ViewModel y las vistas dependen del campo `calificacion` de `Receta`, no del formato
   del JSON, así que no se enteran del cambio. Esa es la función de separar la conversión del JSON
   en la capa de datos.