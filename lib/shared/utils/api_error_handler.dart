import 'package:dio/dio.dart';

class ApiErrorHandler {
  /// Parses API error response and returns user-friendly message
  static String parseError(dynamic error) {
    if (error is DioException) {
      return _handleDioException(error);
    } else if (error is Exception) {
      return _handleGenericException(error);
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  static String _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection and try again.';

      case DioExceptionType.connectionError:
        return 'Unable to connect to server. Please check your internet connection.';

      case DioExceptionType.badResponse:
        return _handleBadResponse(e);

      case DioExceptionType.cancel:
        return 'Request was cancelled. Please try again.';

      case DioExceptionType.unknown:
        return 'Network error. Please check your connection and try again.';

      default:
        return 'Network error: ${e.message ?? 'Unknown error'}';
    }
  }

  static String _handleBadResponse(DioException e) {
    final statusCode = e.response?.statusCode;
    final responseData = e.response?.data;

    // Try to extract error message from API response
    String? apiMessage;
    if (responseData is Map<String, dynamic>) {
      apiMessage = responseData['message'] as String?;
    }

    switch (statusCode) {
      case 400:
        return apiMessage ??
            'Invalid request. Please check your input and try again.';

      case 401:
        return 'Authentication failed. Please log in again.';

      case 403:
        return 'Access denied. You don\'t have permission to perform this action.';

      case 404:
        if (apiMessage != null) {
          // Parse station not found errors specifically
          if (apiMessage.contains('station') &&
              apiMessage.contains('not found')) {
            return 'Selected station is not available. Please choose a different station.';
          }
          // Parse fare calculation errors
          if (apiMessage.contains('fare') || apiMessage.contains('route')) {
            return 'Unable to calculate fare for the selected route. Please try different stations.';
          }
          return apiMessage;
        }
        return 'The requested resource was not found.';

      case 422:
        return apiMessage ?? 'Invalid data provided. Please check your input.';

      case 429:
        return 'Too many requests. Please wait a moment and try again.';

      case 500:
        return 'Server error. Please try again later.';

      case 502:
      case 503:
      case 504:
        return 'Service temporarily unavailable. Please try again later.';

      default:
        if (apiMessage != null) {
          return apiMessage;
        }
        return 'Request failed with status $statusCode. Please try again.';
    }
  }

  static String _handleGenericException(Exception e) {
    final message = e.toString();

    // Handle specific known exceptions
    if (message.contains('SocketException')) {
      return 'Network connection failed. Please check your internet connection.';
    } else if (message.contains('TimeoutException')) {
      return 'Request timeout. Please try again.';
    } else if (message.contains('FormatException')) {
      return 'Invalid data received. Please try again.';
    } else if (message.contains('No authentication token')) {
      return 'Please log in again to continue.';
    } else {
      // Remove "Exception: " prefix if present
      String cleanMessage = message.replaceFirst('Exception: ', '');
      return cleanMessage.isNotEmpty
          ? cleanMessage
          : 'An error occurred. Please try again.';
    }
  }

  /// Gets the error type for UI display purposes
  static ErrorType getErrorType(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.connectionError:
          return ErrorType.network;

        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          if (statusCode == 401) {
            return ErrorType.authentication;
          } else if (statusCode == 404) {
            return ErrorType.notFound;
          } else if (statusCode != null && statusCode >= 500) {
            return ErrorType.server;
          } else {
            return ErrorType.client;
          }

        default:
          return ErrorType.unknown;
      }
    } else {
      return ErrorType.unknown;
    }
  }
}

enum ErrorType {
  network,
  authentication,
  notFound,
  client,
  server,
  unknown,
}
