import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // kReleaseMode
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static final ApiClient _i = ApiClient._internal();
  factory ApiClient() => _i;

  late final Dio dio;

  ApiClient._internal() {
    // Choix auto: si tu oublies --dart-define, prod → Render, dev → localhost
    final base = const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: kReleaseMode
          ? 'https://payment-api-th2k.onrender.com/api'
          : 'http://127.0.0.1:8000/api',
    );

    // On évite les doubles slash si jamais on met un chemin commençant par "/"
    final normalizedBase = base.endsWith('/')
        ? base.substring(0, base.length - 1)
        : base;

    dio = Dio(BaseOptions(
      baseUrl: normalizedBase,
      headers: {'Accept': 'application/json'},
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
      // Optionnel: traite 4xx comme réponse (pas exception Dio)
      // validateStatus: (s) => s != null && s < 500,
    ));

    _attachInterceptors();
  }

  void _attachInterceptors() {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (e, handler) async {
        if (e.response?.statusCode == 401) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('token');
          // TODO: ici tu peux naviguer vers l'écran de login si tu as un router
        }
        handler.next(e);
      },
    ));

    if (!kReleaseMode) {
      dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: false),
      );
    }
  }
}
