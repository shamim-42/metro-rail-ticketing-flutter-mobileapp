import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/foundation.dart' show debugPrint;

class EnvLoader {
  static Map<String, String> _envVars = {};
  static bool _loaded = false;

  static Future<void> load() async {
    if (_loaded) return;

    try {
      // Try to load from .env file in the config directory
      final envFile = File('./lib/core/config/env');
      if (await envFile.exists()) {
        final lines = await envFile.readAsLines();
        debugPrint('🔧 Loading environment from: lib/core/config/env');
        debugPrint('🔧 Environment file lines: $lines');
        for (final line in lines) {
          if (line.trim().isNotEmpty && !line.startsWith('#')) {
            final parts = line.split('=');
            if (parts.length == 2) {
              _envVars[parts[0].trim()] = parts[1].trim();
            }
          }
        }
        debugPrint('✅ Loaded environment variables from lib/core/config/env');
      } else {
        debugPrint('⚠️ lib/core/config/env file not found, using defaults');

        // Fallback: try .env file in project root
        final fallbackEnvFile = File('.env');
        if (await fallbackEnvFile.exists()) {
          final lines = await fallbackEnvFile.readAsLines();
          debugPrint('🔧 Loading fallback from: .env');
          for (final line in lines) {
            if (line.trim().isNotEmpty && !line.startsWith('#')) {
              final parts = line.split('=');
              if (parts.length == 2) {
                _envVars[parts[0].trim()] = parts[1].trim();
              }
            }
          }
          debugPrint('✅ Loaded environment variables from .env file');
        } else {
          debugPrint('⚠️ No environment file found, using defaults');
        }
      }
    } catch (e) {
      debugPrint('❌ Error loading environment file: $e');
    }

    _loaded = true;
  }

  static String get(String key, {String defaultValue = ''}) {
    // First try environment variable (from --dart-define)
    final envValue = String.fromEnvironment(key, defaultValue: '');
    if (envValue.isNotEmpty) {
      return envValue;
    }

    // Then try .env file
    return _envVars[key] ?? defaultValue;
  }

  static bool getBool(String key, {bool defaultValue = false}) {
    final value = get(key, defaultValue: defaultValue.toString());
    return value.toLowerCase() == 'true';
  }
}
