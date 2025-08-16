import 'package:dio/dio.dart';
import '../../core/config/env_config.dart';
import 'token_service.dart';
import '../models/station_model.dart';

class StationApiService {
  static final Dio _dio = Dio();

  static String get _baseUrl => EnvConfig.apiBaseUrl;

  /// Create a new station
  static Future<StationModel> createStation({
    required String name,
    required String code,
    double? latitude,
    double? longitude,
    required String address,
    required String zone,
    required List<String> facilities,
    required String description,
  }) async {
    try {
      print('🏗️ Creating station: $name ($code)');

      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      print('🔑 Token found: ${token.substring(0, 20)}...');
      print('🔑 Token length: ${token.length}');
      print('🔑 Token starts with Bearer?: ${token.startsWith('Bearer')}');
      print('🌐 API Base URL: $_baseUrl');

      final payload = {
        "name": name,
        "code": code,
        "address": address,
        "zone": zone,
        "facilities": facilities,
        "description": description,
      };

      // Only add coordinates if provided
      if (latitude != null && longitude != null) {
        payload["latitude"] = latitude;
        payload["longitude"] = longitude;
      }

      print('📤 Station creation payload: $payload');
      print('📤 Full API URL: $_baseUrl/stations');

      final authHeader = token.startsWith('Bearer ') ? token : 'Bearer $token';
      print('🔑 Authorization header: ${authHeader.substring(0, 20)}...');

      final response = await _dio.post(
        '$_baseUrl/stations',
        data: payload,
        options: Options(
          headers: {
            'Authorization': authHeader,
            'Content-Type': 'application/json',
          },
        ),
      );

      print('✅ Station creation response: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final stationData = responseData['data']['station'];

          // Convert API response to StationModel format
          final stationModelData = {
            '_id': stationData['_id'],
            'name': stationData['name'],
            'zone': stationData['zone'],
            'facilities': List<String>.from(stationData['facilities'] ?? []),
            'location': _parseLocationData(stationData['location']),
          };

          print('🔄 Converted station data: $stationModelData');
          return StationModel.fromJson(stationModelData);
        } else {
          throw Exception(
              'Invalid response format: ${responseData['message'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception(
            'Failed to create station: HTTP ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ Station creation failed (DioException): ${e.message}');
      print('❌ Status Code: ${e.response?.statusCode}');
      print('❌ Request URL: ${e.requestOptions.uri}');
      print('❌ Request Headers: ${e.requestOptions.headers}');
      print('❌ Request Data: ${e.requestOptions.data}');

      if (e.response != null) {
        print('❌ Response data: ${e.response?.data}');
        print('❌ Response headers: ${e.response?.headers}');

        // Try to extract meaningful error message
        String errorMessage = 'Station creation failed';
        if (e.response?.data is Map) {
          final responseData = e.response?.data as Map;
          errorMessage =
              responseData['message'] ?? responseData['error'] ?? errorMessage;
        } else if (e.response?.data is String) {
          errorMessage = e.response?.data as String;
        }
        throw Exception(errorMessage);
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      print('❌ Station creation failed (General): $e');
      rethrow;
    }
  }

  /// Update an existing station
  static Future<StationModel> updateStation({
    required String stationId,
    required String name,
    required String code,
    // required double latitude,
    // required double longitude,
    required String address,
    required String zone,
    required List<String> facilities,
    required String description,
  }) async {
    try {
      print('🔄 Updating station: $stationId');

      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final payload = {
        "name": name,
        "code": code,
        // "latitude": latitude,
        // "longitude": longitude,
        "address": address,
        "zone": zone,
        "facilities": facilities,
        "description": description,
      };

      print('📤 Station update payload: $payload');

      final response = await _dio.put(
        '$_baseUrl/stations/$stationId',
        data: payload,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      print('✅ Station update response: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final stationData = responseData['data']['station'];

          // Convert API response to StationModel format
          final stationModelData = {
            '_id': stationData['_id'],
            'name': stationData['name'],
            'zone': stationData['zone'],
            'facilities': List<String>.from(stationData['facilities'] ?? []),
            'location': _parseLocationData(stationData['location']),
          };

          return StationModel.fromJson(stationModelData);
        } else {
          throw Exception(
              'Invalid response format: ${responseData['message'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception(
            'Failed to update station: HTTP ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ Station update failed (DioException): ${e.message}');
      if (e.response != null) {
        print('❌ Response data: ${e.response?.data}');
        final errorMessage =
            e.response?.data['message'] ?? 'Station update failed';
        throw Exception(errorMessage);
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      print('❌ Station update failed (General): $e');
      rethrow;
    }
  }

  /// Delete a station
  static Future<bool> deleteStation(String stationId) async {
    try {
      print('🗑️ Deleting station: $stationId');

      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await _dio.delete(
        '$_baseUrl/stations/$stationId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print('✅ Station deletion response: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data;
        return responseData['success'] == true;
      } else {
        throw Exception(
            'Failed to delete station: HTTP ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ Station deletion failed (DioException): ${e.message}');
      if (e.response != null) {
        print('❌ Response data: ${e.response?.data}');
        final errorMessage =
            e.response?.data['message'] ?? 'Station deletion failed';
        throw Exception(errorMessage);
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      print('❌ Station deletion failed (General): $e');
      rethrow;
    }
  }

  /// Helper method to safely parse location data from API response
  static Map<String, double> _parseLocationData(dynamic locationData) {
    try {
      if (locationData == null) {
        print('📍 Location data is null, returning empty location');
        return <String, double>{};
      }

      if (locationData is Map<String, dynamic>) {
        // Handle GeoJSON format: { type: "Point", coordinates: [lng, lat] }
        if (locationData['coordinates'] is List) {
          final coordinates = locationData['coordinates'] as List;
          if (coordinates.length >= 2) {
            return {
              'lng': (coordinates[0] as num).toDouble(), // longitude
              'lat': (coordinates[1] as num).toDouble(), // latitude
            };
          }
        }

        // Handle direct lat/lng format: { lat: 23.456, lng: 90.123 }
        if (locationData['lat'] != null && locationData['lng'] != null) {
          return {
            'lat': (locationData['lat'] as num).toDouble(),
            'lng': (locationData['lng'] as num).toDouble(),
          };
        }
      }

      print('📍 Unable to parse location data: $locationData');
      return <String, double>{};
    } catch (e) {
      print('❌ Error parsing location data: $e');
      return <String, double>{};
    }
  }
}
