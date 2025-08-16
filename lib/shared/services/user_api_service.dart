import 'package:dio/dio.dart';
import 'token_service.dart';
import '../../core/config/env_config.dart';

class UserApiService {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: EnvConfig.apiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Content-Type': 'application/json'},
  ));

  // Get user profile
  static Future<Response> getProfile() async {
    final token = await _getAuthToken();
    return _dio.get('/users/profile',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ));
  }

  // Update user profile
  static Future<Response> updateProfile({
    required String fullName,
    String? email,
    String? phoneNumber,
  }) async {
    final token = await _getAuthToken();
    return _dio.put(
      '/users/profile',
      data: {
        'fullName': fullName,
        if (email != null) 'email': email,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
      },
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );
  }

  // Deposit money
  static Future<Response> depositMoney(int amount,
      {String paymentMethod = 'cash'}) async {
    print(
        '💰 UserApiService: depositMoney called with amount: $amount, paymentMethod: $paymentMethod');
    final token = await _getAuthToken();
    print('💰 UserApiService: Got token: ${token != null ? "Yes" : "No"}');

    final payload = {
      'amount': amount,
      'paymentMethod': paymentMethod,
    };
    print(
        '💰 UserApiService: Making API call to /users/deposit with payload: $payload');

    try {
      final response = await _dio.post(
        '/users/deposit',
        data: payload,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      print(
          '💰 UserApiService: API call successful, status: ${response.statusCode}');
      print('💰 UserApiService: Response data: ${response.data}');
      return response;
    } catch (e) {
      print('❌ UserApiService: API call failed with error: $e');
      rethrow;
    }
  }

  // Get user statistics
  static Future<Response> getStatistics() async {
    final token = await _getAuthToken();
    return _dio.get('/users/statistics',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ));
  }

  // Helper method to get auth token
  static Future<String> _getAuthToken() async {
    final token = await TokenService.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }
    return token;
  }
}
