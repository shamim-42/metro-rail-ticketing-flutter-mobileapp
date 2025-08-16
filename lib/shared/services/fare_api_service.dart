import 'package:dio/dio.dart';
import '../../core/config/env_config.dart';
import 'token_service.dart';
import '../models/fare_model.dart';

class FareApiService {
  static final Dio _dio = Dio();

  static String get _baseUrl => EnvConfig.apiBaseUrl;

  /// Get all fares
  static Future<List<FareModel>> getAllFares() async {
    try {
      print('📋 Loading all fares...');

      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await _dio.get(
        '$_baseUrl/fares',
        queryParameters: {
          'limit': 1000, // Request a large number to get all fares
          'page': 1,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      print('✅ Fares loaded successfully: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          // For paginated response, data is directly an array of fares
          final faresData = responseData['data'] as List;

          print('📊 Total fares received from API: ${faresData.length}');
          print('📋 Pagination info: ${responseData['pagination']}');

          final faresList = <FareModel>[];
          for (int i = 0; i < faresData.length; i++) {
            try {
              print(
                  '🔄 Processing fare ${i + 1}/${faresData.length}: ${faresData[i]['_id']}');
              final fare = FareModel.fromJson(faresData[i]);
              faresList.add(fare);
              print('✅ Successfully parsed fare ${i + 1}');
            } catch (e) {
              print('❌ Failed to parse fare ${i + 1}: $e');
              print('📋 Problematic fare data: ${faresData[i]}');
              // Don't add this fare to the list, continue with next
            }
          }

          print('📝 Parsed ${faresList.length} fares successfully');
          return faresList;
        } else {
          throw Exception(
              'Invalid response format: ${responseData['message'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception('Failed to load fares: HTTP ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ Failed to load fares (DioException): ${e.message}');
      print('❌ Status Code: ${e.response?.statusCode}');
      print('❌ Response: ${e.response?.data}');

      if (e.response?.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Access denied. Admin privileges required.');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      print('❌ Failed to load fares (General): $e');
      rethrow;
    }
  }

  /// Create a new fare
  static Future<FareModel> createFare({
    required String fromStationId,
    required String toStationId,
    required int fare,
    required double distance,
    required int duration,
  }) async {
    try {
      print('🆕 Creating fare: $fromStationId → $toStationId (৳$fare)');

      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final payload = {
        "fromStation": fromStationId,
        "toStation": toStationId,
        "fare": fare,
        "distance": distance,
        "duration": duration,
      };

      print('📤 Fare creation payload: $payload');

      final response = await _dio.post(
        '$_baseUrl/fares',
        data: payload,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      print('✅ Fare creation response: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final fareData = responseData['data']['fare'];
          return FareModel.fromJson(fareData);
        } else {
          throw Exception(
              'Invalid response format: ${responseData['message'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception('Failed to create fare: HTTP ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ Fare creation failed (DioException): ${e.message}');
      print('❌ Status Code: ${e.response?.statusCode}');
      print('❌ Response: ${e.response?.data}');

      if (e.response?.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Access denied. Admin privileges required.');
      } else if (e.response?.statusCode == 400) {
        final errorMessage = e.response?.data['message'] ?? 'Invalid fare data';
        throw Exception(errorMessage);
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      print('❌ Fare creation failed (General): $e');
      rethrow;
    }
  }

  /// Update an existing fare
  static Future<FareModel> updateFare({
    required String fareId,
    required int fare,
    required double distance,
    required int duration,
  }) async {
    try {
      print('🔄 Updating fare: $fareId');

      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final payload = {
        "fare": fare,
        "distance": distance,
        "duration": duration,
      };

      print('📤 Fare update payload: $payload');

      final response = await _dio.put(
        '$_baseUrl/fares/$fareId',
        data: payload,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      print('✅ Fare update response: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final fareData = responseData['data']['fare'];
          return FareModel.fromJson(fareData);
        } else {
          throw Exception(
              'Invalid response format: ${responseData['message'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception('Failed to update fare: HTTP ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ Fare update failed (DioException): ${e.message}');
      print('❌ Status Code: ${e.response?.statusCode}');
      print('❌ Response: ${e.response?.data}');

      if (e.response?.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Access denied. Admin privileges required.');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Fare not found');
      } else if (e.response?.statusCode == 400) {
        final errorMessage = e.response?.data['message'] ?? 'Invalid fare data';
        throw Exception(errorMessage);
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      print('❌ Fare update failed (General): $e');
      rethrow;
    }
  }
}
