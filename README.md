# Metro Rail Ticketing Flutter Mobile App

A modern, feature-rich mobile application for metro rail ticket booking and management, built with Flutter. This app provides a seamless user experience for planning metro journeys, purchasing tickets, managing balance, and generating QR codes for hassle-free travel.

## Backend API Repository
**Node.js Backend:** https://github.com/shamim-42/metro-rail-ticketing-nodejs-backend

## 🚀 Features

### 🎫 Core Functionality
- **Digital Ticketing**: Purchase and manage metro tickets digitally
- **QR Code Generation**: Generate QR codes for contactless ticket validation
- **Trip Planning**: Smart route planning with fare calculation
- **Real-time Balance**: Wallet integration with instant balance updates
- **Journey History**: Complete trip history and expense tracking
- **Station Management**: Comprehensive station information and navigation

### 👤 User Experience
- **Secure Authentication**: JWT-based login and registration
- **Profile Management**: User profile with personalized initials display
- **Balance Top-up**: Multiple payment methods for wallet recharge
- **Intuitive UI**: Modern Material Design with smooth animations
- **Responsive Design**: Optimized for various screen sizes
- **Offline Support**: Core features available without internet

### 🛠️ Admin Features
- **Station Management**: Add, edit, and manage metro stations
- **Fare Management**: Dynamic fare configuration and updates
- **User Analytics**: Comprehensive user statistics and reporting
- **System Administration**: Complete admin dashboard functionality

## 🏗️ Architecture & Tech Stack

### **Framework & Language**
- **Flutter** (3.x) - Cross-platform mobile development
- **Dart** (3.x) - Programming language

### **State Management**
- **BLoC Pattern** - Predictable state management
- **flutter_bloc** - BLoC library implementation
- **Equatable** - Value equality comparisons

### **Networking & API**
- **Dio** - HTTP client for API calls
- **JSON Serialization** - Model-based data handling
- **JWT Authentication** - Secure token-based auth

### **UI & Design**
- **Material Design 3** - Modern UI components
- **Custom Widgets** - Reusable UI components
- **Responsive Layout** - Adaptive design patterns
- **Animation** - Smooth transitions and micro-interactions

### **Core Features Implementation**
- **QR Code Generation** - `qr_flutter` package
- **Image Handling** - `image_gallery_saver` for QR downloads
- **Permissions** - `permission_handler` for device access
- **Local Storage** - `shared_preferences` for token storage
- **Date/Time** - Smart date formatting and relative time display

## 📋 Prerequisites

- **Flutter SDK** (3.10.0 or higher)
- **Dart SDK** (3.0.0 or higher)
- **Android Studio** / **VS Code** (with Flutter extensions)
- **iOS development**: Xcode (for iOS builds)
- **Android development**: Android SDK

## 🛠️ Installation & Setup

### 1. Clone the Repository
```bash
git clone https://github.com/shamim-42/metro-rail-ticketing-flutter.git
cd metro-rail-ticketing-flutter
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Environment Configuration
Create environment files for different stages:

**Development (.env.development):**
```env
API_BASE_URL=http://localhost:5001/api
APP_NAME=Metro Rail Dev
DEBUG_MODE=true
```

**Production (.env.production):**
```env
API_BASE_URL=https://your-production-api.com/api
APP_NAME=Metro Rail
DEBUG_MODE=false
```

### 4. Run the Application

**Development Mode:**
```bash
flutter run --debug
```

**Release Mode:**
```bash
flutter run --release
```

**Specific Platform:**
```bash
flutter run -d android    # Android
flutter run -d ios        # iOS
```

## 📱 App Screenshots & Features

### Authentication & Profile
- **Login/Register**: Secure user authentication
- **Profile Management**: User details with initials avatar
- **Balance Display**: Real-time wallet balance

### Trip Planning & Booking
- **Station Selection**: From/To station dropdowns with search
- **Fare Calculation**: Dynamic fare calculation with passenger count
- **Base + Total Fare**: Display both per-person and total fares
- **Smart Validation**: Prevent same station selection

### QR Code & Ticketing
- **QR Generation**: Unique QR codes for each trip
- **Download Feature**: Save QR codes to device gallery
- **Trip Details**: Complete journey information on QR screen

### History & Management
- **Trip History**: Chronological journey records
- **Unused Tickets**: Track unexpired tickets
- **Expense Tracking**: Total spending analytics
- **Status Management**: Active, used, expired ticket states

### Admin Dashboard
- **Station CRUD**: Complete station management
- **Fare Management**: Configure routes and pricing
- **User Statistics**: System analytics and reporting

## 🗂️ Project Structure

```
lib/
├── main.dart                          # App entry point
├── features/                          # Feature-based modules
│   ├── auth/                         # Authentication
│   │   ├── bloc/                     # Auth BLoC
│   │   ├── login_screen.dart         # Login UI
│   │   └── register_screen.dart      # Registration UI
│   ├── home/                         # Home dashboard
│   │   ├── home_screen.dart          # Main dashboard
│   │   └── widgets/                  # Home widgets
│   ├── profile/                      # User profile
│   │   ├── bloc/                     # User BLoC
│   │   └── profile_screen.dart       # Profile UI
│   ├── trip/                         # Trip management
│   │   ├── bloc/                     # Trip BLoC
│   │   ├── new_trip_screen.dart      # Trip creation
│   │   └── qr_code_screen.dart       # QR display
│   ├── history/                      # Journey history
│   │   └── history_screen.dart       # Trip history UI
│   ├── payment/                      # Payment system
│   │   ├── bloc/                     # Payment BLoC
│   │   └── topup_screen.dart         # Balance top-up
│   └── admin/                        # Admin features
│       ├── station_management_screen.dart
│       └── fare_management_screen.dart
├── shared/                           # Shared resources
│   ├── models/                       # Data models
│   │   ├── user_model.dart
│   │   ├── trip_model.dart
│   │   ├── station_model.dart
│   │   └── fare_model.dart
│   ├── services/                     # API services
│   │   ├── auth_api_service.dart
│   │   ├── user_api_service.dart
│   │   ├── trip_api_service.dart
│   │   ├── station_api_service.dart
│   │   ├── fare_api_service.dart
│   │   ├── token_service.dart
│   │   └── qr_download_service.dart
│   ├── widgets/                      # Reusable widgets
│   │   └── app_bottom_nav_bar.dart
│   └── utils/                        # Utility functions
│       ├── api_error_handler.dart
│       └── user_initials.dart
└── pubspec.yaml                      # Dependencies
```

## 🔐 Security Features

- **JWT Token Management**: Secure authentication with auto-refresh
- **Input Validation**: Client-side form validation
- **Error Handling**: Comprehensive error management
- **Secure Storage**: Token storage with SharedPreferences
- **API Security**: Protected endpoints with authorization headers
- **Data Sanitization**: Clean data input and output

## 🎨 UI/UX Features

### Design System
- **Material Design 3**: Latest design guidelines
- **Color Scheme**: Consistent brand colors throughout
- **Typography**: Scalable text with proper hierarchy
- **Icons**: Consistent iconography with Material Icons

### User Experience
- **Loading States**: Smooth loading indicators
- **Error States**: User-friendly error messages
- **Empty States**: Helpful empty state illustrations
- **Success Feedback**: Clear success confirmations
- **Navigation**: Intuitive bottom navigation

### Responsive Design
- **Adaptive Layouts**: Works on phones and tablets
- **Safe Areas**: Proper handling of notches and navigation bars
- **Orientation Support**: Portrait and landscape modes
- **Accessibility**: Screen reader support and proper semantics

## 📊 State Management Architecture

### BLoC Pattern Implementation
```dart
// Example BLoC structure
class TripBloc extends Bloc<TripEvent, TripState> {
  // Event handlers
  void _onLoadStations(LoadStations event, Emitter<TripState> emit) async {
    // Handle station loading
  }
  
  void _onCalculateFare(CalculateFare event, Emitter<TripState> emit) async {
    // Handle fare calculation
  }
  
  void _onCreateTrip(CreateTrip event, Emitter<TripState> emit) async {
    // Handle trip creation
  }
}
```

### State Types
- **Loading States**: Show progress indicators
- **Success States**: Display data with UI updates
- **Error States**: Handle failures gracefully
- **Empty States**: Manage no-data scenarios

## 📱 Platform Support

### Android
- **Minimum SDK**: API 21 (Android 5.0)
- **Target SDK**: API 34 (Android 14)
- **Architecture**: ARM64, ARMv7

### iOS
- **Minimum Version**: iOS 12.0
- **Architecture**: ARM64
- **Deployment Target**: iOS 12.0+

## 🧪 Testing

### Unit Tests
```bash
flutter test
```

### Widget Tests
```bash
flutter test test/widget_test/
```

### Integration Tests
```bash
flutter test integration_test/
```

## 🚀 Build & Deployment

### Development Build
```bash
flutter build apk --debug           # Android debug
flutter build ios --debug           # iOS debug
```

### Production Build
```bash
flutter build apk --release         # Android release
flutter build ios --release         # iOS release
flutter build appbundle            # Android App Bundle
```

### Code Signing (iOS)
1. Configure signing certificates in Xcode
2. Set up provisioning profiles
3. Build with release configuration

## 📦 Dependencies

### Core Dependencies
```yaml
dependencies:
  flutter: sdk: flutter
  flutter_bloc: ^8.1.3              # State management
  dio: ^5.3.2                       # HTTP client
  shared_preferences: ^2.2.2        # Local storage
  qr_flutter: ^4.1.0               # QR code generation
  image_gallery_saver: ^2.0.3      # Image saving
  permission_handler: ^11.0.1      # Permissions
  equatable: ^2.0.5                # Value equality
```

### Development Dependencies
```yaml
dev_dependencies:
  flutter_test: sdk: flutter
  flutter_lints: ^2.0.0            # Linting rules
  build_runner: ^2.4.7             # Code generation
```

## 🔧 Development Scripts

### Useful Commands
```bash
# Clean and get dependencies
flutter clean && flutter pub get

# Generate code (if using code generation)
flutter packages pub run build_runner build

# Analyze code quality
flutter analyze

# Format code
flutter format .

# Check for outdated dependencies
flutter pub outdated
```

## 🌐 Environment Management

### Multiple Environments
- **Development**: Local API, debug features enabled
- **Staging**: Test API, production-like features
- **Production**: Live API, optimized performance

### Configuration
Create environment-specific configuration files and load them based on build flavor.

## 🤝 Contributing

### Development Workflow
1. **Fork** the repository
2. **Create** a feature branch: `git checkout -b feature/amazing-feature`
3. **Commit** your changes: `git commit -m 'Add amazing feature'`
4. **Push** to the branch: `git push origin feature/amazing-feature`
5. **Submit** a pull request

### Code Standards
- Follow **Dart/Flutter** style guidelines
- Use **meaningful** variable and function names
- Add **comments** for complex logic
- Write **tests** for new features
- Ensure **responsive** design principles

### Pull Request Guidelines
- Clear description of changes
- Screenshots for UI changes
- Test coverage for new features
- Updated documentation if needed

## 📋 Roadmap

### Phase 1 (Current)
- ✅ Core ticketing functionality
- ✅ User authentication and profiles
- ✅ QR code generation and download
- ✅ Trip history and management
- ✅ Admin dashboard features

### Phase 2 (Planned)
- 🔄 Push notifications for trip updates
- 🔄 Offline mode for core features
- 🔄 Multiple payment gateway integration
- 🔄 Real-time train tracking
- 🔄 Social features and trip sharing

### Phase 3 (Future)
- 🔄 Apple Pay / Google Pay integration
- 🔄 Loyalty program and rewards
- 🔄 Multi-language support
- 🔄 Accessibility improvements
- 🔄 Wear OS / watchOS companion

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support & Contact

- **Issues**: GitHub Issues for bug reports and feature requests
- **Documentation**: Comprehensive inline documentation
- **API Documentation**: Backend repository documentation

## 🏆 Acknowledgments

- **Flutter Team** for the amazing framework
- **Material Design** for UI/UX guidelines
- **BLoC Library** for state management patterns
- **Open Source Community** for various packages used

---

**Built with ❤️ using Flutter for efficient metro rail transportation**