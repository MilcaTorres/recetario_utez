import 'package:dio/dio.dart';
import 'package:recetario_utez/datos/bitacora_interceptor.dart';

const urlDummyJson = 'https://dummyjson.com';

Dio crearDioRecetas({List<Interceptor> interceptores = const []}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: urlDummyJson,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 8),
      responseType: ResponseType.json,
      headers: {'Accept': 'application/json'},
    ),
  );
  dio.interceptors.addAll([BitacoraInterceptor(), ...interceptores]);
  return dio;
}
