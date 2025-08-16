# Environment Configuration

This Flutter app uses environment variables to manage API endpoints and configuration.

## Environment Files

- `.env` - Main environment file (gitignored for security)
- `env.development` - For local development (uses localhost API)
- `env.production` - For production (uses AWS Lambda API)

## Current Configuration

### Development (Local)
- API Base URL: `http://10.0.2.2:5001/api`
- Used for local development with backend running on localhost

### Production (AWS Lambda)
- API Base URL: `https://z382ffuop3.execute-api.ap-southeast-1.amazonaws.com/dev/api`
- Used for production deployment

## Setup

1. **Create `.env` file** in the project root:
   ```bash
   # API Configuration
   API_BASE_URL=https://write_the_api_base_url_here.com
   
   # App Configuration
   APP_NAME="Metro Rapid Pass"
   APP_VERSION=1.0.0
   ENVIRONMENT=production
   DEBUG=false
   ```

2. **The `.env` file is gitignored** for security

## How to Use

### For Development
```bash
flutterv319 run --dart-define=ENVIRONMENT=development
```

### For Production
```bash
flutterv319 run --dart-define=ENVIRONMENT=production
```

### Custom API URL
```bash
flutterv319 run --dart-define=API_BASE_URL=https://your-custom-api.com/api
```

## Environment Variables

The app uses these environment variables:

- `API_BASE_URL` - Base URL for all API calls
- `APP_NAME` - Application name
- `APP_VERSION` - Application version
- `ENVIRONMENT` - Current environment (development/production)
- `DEBUG` - Debug mode flag

## Code Usage

All API services now use `EnvConfig.apiBaseUrl` instead of hardcoded URLs:

```dart
import '../../core/config/env_config.dart';

// In API services
static final Dio _dio = Dio(BaseOptions(
  baseUrl: EnvConfig.apiBaseUrl,
  // ... other options
));
```

## Switching Environments

To switch between development and production:

1. **Development (Local Backend):**
   ```bash
   flutterv319 run --dart-define=ENVIRONMENT=development
   ```

2. **Production (AWS Lambda):**
   ```bash
   flutterv319 run --dart-define=ENVIRONMENT=production
   ```

The `EnvConfig` class will automatically use the appropriate base URL based on the environment. 