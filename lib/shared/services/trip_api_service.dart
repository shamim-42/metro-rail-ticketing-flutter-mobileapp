import 'package:dio/dio.dart';
import 'token_service.dart';
import '../../core/config/env_config.dart';

class TripApiService {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: EnvConfig.apiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Content-Type': 'application/json'},
  ));

  // Create a new trip
  static Future<Response> createTrip({
    required String boardingStation,
    required String dropStation,
    required int numberOfPassengers,
  }) async {
    final token = await _getAuthToken();
    print('🚀 Creating trip with data:');
    print('   - From Station ID: $boardingStation');
    print('   - To Station ID: $dropStation');
    print('   - Passengers: $numberOfPassengers');

    final requestData = {
      'fromStation': boardingStation,
      'toStation': dropStation,
      'numberOfPassengers': numberOfPassengers,
      'paymentMethod': 'balance', // Add the required payment method
    };

    print('📤 Request data: $requestData');
    print('🔑 Token: ${token.substring(0, 20)}...');

    try {
      // First, let's test if the backend is reachable
      print('🔍 Testing backend connectivity...');
      final testResponse = await _dio.get(
        '/trips/history',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      print('✅ Backend is reachable: ${testResponse.statusCode}');

      final response = await _dio.post(
        '/trips',
        data: requestData,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      print('✅ Trip creation successful: ${response.statusCode}');
      print('📊 Response data: ${response.data}');
      return response;
    } catch (e) {
      print('❌ Trip creation failed: $e');
      if (e is DioException) {
        print('❌ Response status: ${e.response?.statusCode}');
        print('❌ Response data: ${e.response?.data}');
        print('❌ Response headers: ${e.response?.headers}');
      }
      rethrow;
    }
  }

  // Use a trip with trip code
  static Future<Response> useTrip(String tripCode) async {
    final token = await _getAuthToken();
    return _dio.post('/trips/use/$tripCode',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ));
  }

  // Get trip history
  static Future<Response> getTripHistory() async {
    final token = await _getAuthToken();
    return _dio.get('/trips/history',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ));
  }

  // Get unused trips
  static Future<Response> getUnusedTrips() async {
    final token = await _getAuthToken();
    return _dio.get('/trips/unused',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ));
  }

  // Get all stations
  static Future<Response> getAllStations() async {
    int retryCount = 0;
    const maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        print('🚀 Attempt ${retryCount + 1}/$maxRetries: Fetching stations...');

        // Check if we can get a token
        String? token;
        try {
          token = await _getAuthToken();
          print('🔍 Token available: ${token.substring(0, 20)}...');
        } catch (tokenError) {
          print('⚠️ No auth token available: $tokenError');
        }

        // Try with authentication first if token is available
        if (token != null) {
          try {
            final response = await _dio.get('/stations',
                options: Options(
                  headers: {'Authorization': 'Bearer $token'},
                  sendTimeout: const Duration(seconds: 15),
                  receiveTimeout: const Duration(seconds: 15),
                ));
            print(
                '✅ Stations API response (with auth): ${response.statusCode}');

            // Validate response structure
            if (response.data == null) {
              throw Exception('Null response data');
            }

            // Check if it's a successful response with expected structure
            if (response.data is Map && response.data['success'] == true) {
              print('📊 Stations data: ${response.data}');
              return response;
            } else {
              throw Exception('Invalid response structure: ${response.data}');
            }
          } catch (authError) {
            print('⚠️ Auth request failed: $authError');
            // Fall through to try without auth
          }
        }

        // Try without authentication (stations might be public)
        print('🔄 Trying to fetch stations without authentication...');
        final response = await _dio.get('/stations',
            options: Options(
              sendTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
            ));
        print('✅ Stations API response (without auth): ${response.statusCode}');

        // Validate response structure
        if (response.data == null) {
          throw Exception('Null response data');
        }

        print('📊 Stations data: ${response.data}');
        return response;
      } catch (e) {
        retryCount++;
        print('❌ Attempt ${retryCount} failed: $e');

        if (retryCount >= maxRetries) {
          print('❌ All $maxRetries attempts failed');

          // Provide more specific error messages
          if (e is DioException) {
            switch (e.type) {
              case DioExceptionType.connectionTimeout:
              case DioExceptionType.sendTimeout:
              case DioExceptionType.receiveTimeout:
                throw Exception(
                    'Connection timeout. Please check your internet connection.');
              case DioExceptionType.connectionError:
                throw Exception(
                    'Unable to connect to server. Please check your internet connection.');
              case DioExceptionType.badResponse:
                final statusCode = e.response?.statusCode;
                if (statusCode == 401) {
                  throw Exception(
                      'Authentication failed. Please log in again.');
                } else if (statusCode == 404) {
                  throw Exception(
                      'Stations endpoint not found. Please contact support.');
                } else if (statusCode! >= 500) {
                  throw Exception(
                      'Server error ($statusCode). Please try again later.');
                } else {
                  throw Exception('Request failed with status $statusCode');
                }
              default:
                throw Exception('Network error: ${e.message}');
            }
          } else {
            throw Exception('Error fetching stations: $e');
          }
        } else {
          // Wait before retrying
          await Future.delayed(Duration(seconds: retryCount * 2));
          print('🔄 Retrying in ${retryCount * 2} seconds...');
        }
      }
    }

    throw Exception('Max retries exceeded');
  }

  // Get stations by zone
  static Future<Response> getStationsByZone(String zone) async {
    final token = await _getAuthToken();
    return _dio.get('/stations/zone/$zone',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ));
  }

  // Get fare between stations
  static Future<Response> getFareBetweenStations({
    required String fromStationId,
    required String toStationId,
  }) async {
    try {
      final token = await _getAuthToken();
      print(
          '💰 Calculating fare from station ID $fromStationId to $toStationId');
      print('🔑 Using token: ${token.substring(0, 20)}...');

      // Use the correct endpoint with station IDs as query parameters
      final response = await _dio.get('/fares/in-between',
          queryParameters: {
            'fromStationId': fromStationId,
            'toStationId': toStationId,
          },
          options: Options(
            headers: {'Authorization': 'Bearer $token'},
          ));
      print('✅ Fare API response: ${response.statusCode}');
      print('📊 Fare data: ${response.data}');
      return response;
    } catch (e) {
      print('❌ Error calculating fare: $e');
      if (e is DioException) {
        print('❌ DioException details:');
        print('   Status: ${e.response?.statusCode}');
        print('   Data: ${e.response?.data}');
        print('   Type: ${e.type}');
      }
      rethrow;
    }
  }

  // Helper method to get auth token
  static Future<String> _getAuthToken() async {
    final token = await TokenService.getToken();
    print('🔑 Token retrieved: ${token != null ? 'Yes' : 'No'}');
    if (token == null) {
      throw Exception('No authentication token found');
    }
    return token;
  }
}
