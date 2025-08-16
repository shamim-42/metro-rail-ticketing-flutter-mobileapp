import 'env_loader.dart';
import 'package:flutter/foundation.dart';

class EnvConfig {
  static bool _initialized = false;

  // Initialize environment variables
  static Future<void> initialize() async {
    if (!_initialized) {
      await EnvLoader.load();
      _initialized = true;

      // Debug logging to show current mode
      print('🔧 Environment Configuration:');
      print('   - kDebugMode: $kDebugMode');
      print('   - kReleaseMode: $kReleaseMode');
      print('   - API Base URL: $apiBaseUrl');
      print('   - Environment: $environment');
    }
  }

  // API Configuration
  static String get apiBaseUrl {
    // Use different URLs for debug vs release
    if (kDebugMode) {
      // Debug mode: Use local development server
      return EnvLoader.get(
        'API_BASE_URL',
        defaultValue: 'http://10.0.2.2:5001/api', // Local development
      );
    } else {
      // Release mode: Use production server
      return EnvLoader.get(
        'API_BASE_URL',
        defaultValue:
            'https://z382ffuop3.execute-api.ap-southeast-1.amazonaws.com/dev/api', // Production
      );
    }
  }

  // App Configuration
  static String get appName => EnvLoader.get(
        'APP_NAME',
        defaultValue: 'Metro Rapid Pass',
      );

  static String get appVersion => EnvLoader.get(
        'APP_VERSION',
        defaultValue: '1.0.0',
      );

  // Environment
  static String get environment => EnvLoader.get(
        'ENVIRONMENT',
        defaultValue: kDebugMode ? 'development' : 'production',
      );

  // Debug mode
  static bool get isDebug => EnvLoader.getBool(
        'DEBUG',
        defaultValue: kDebugMode,
      );
}
