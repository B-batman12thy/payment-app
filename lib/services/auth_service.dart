import 'package:dio/dio.dart';
import '../api/api_client.dart';

class AuthService {
  final Dio _dio = ApiClient().dio;

  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final res = await _dio.post('/auth/register', data: {
      'name': name, 'email': email, 'password': password,
    });
    return Map<String, dynamic>.from(res.data);
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await _dio.post('/auth/login', data: {
      'email': email, 'password': password,
    });
    return Map<String, dynamic>.from(res.data);
  }

  Future<Map<String, dynamic>> me() async {
    final res = await _dio.get('/auth/me');
    return Map<String, dynamic>.from(res.data['user']);
  }

  Future<void> logout() async {
    await _dio.post('/auth/logout');
  }
}
