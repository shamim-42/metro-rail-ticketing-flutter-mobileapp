import 'package:dio/dio.dart';
import '../../core/config/env_config.dart';

class AuthApiService {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: EnvConfig.apiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Content-Type': 'application/json'},
  ));

  static Future<Response> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  }) {
    return _dio.post('/auth/register', data: {
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'password': password,
    });
  }

  static Future<Response> login({
    required String email,
    required String password,
  }) {
    return _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
  }
}
