import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'shared/services/navigation_service.dart';
import 'core/config/env_config.dart';
import 'features/splash/splash_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/home/home_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/history/history_screen.dart';
import 'features/payment/topup_screen.dart';
import 'features/payment/bloc/topup_bloc.dart';
import 'features/card/card_details_screen.dart';
import 'features/trip/new_trip_screen.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_state.dart';
import 'features/trip/bloc/trip_bloc.dart';
import 'features/trip/bloc/trip_event.dart';
import 'features/profile/bloc/user_bloc.dart';
import 'features/profile/bloc/user_event.dart';
import 'shared/services/token_service.dart';
import 'features/admin/station_management_screen.dart';
import 'features/admin/fare_management_screen.dart';
import 'shared/widgets/app_layout.dart';

void main() async {
  // Initialize Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize environment variables
  await EnvConfig.initialize();

  // Initialize SharedPreferences
  await SharedPreferences.getInstance();

  // Initialize navigation service
  NavigationService().initialize();
  runApp(const MyApp());
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const AppLayout(
        child: HomeScreen(),
      ),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const AppLayout(
        child: ProfileScreen(),
      ),
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const AppLayout(
        child: HistoryScreen(),
      ),
    ),
    GoRoute(
      path: '/topup',
      builder: (context, state) => AppLayout(
        child: BlocProvider(
          create: (context) => TopUpBloc(),
          child: const TopUpScreen(),
        ),
      ),
    ),
    GoRoute(
      path: '/card_details',
      builder: (context, state) => const AppLayout(
        showBottomNav: false,
        child: CardDetailsScreen(),
      ),
    ),
    // Admin Routes
    GoRoute(
      path: '/admin/stations',
      builder: (context, state) => const AppLayout(
        child: StationManagementScreen(),
      ),
    ),
    GoRoute(
      path: '/admin/fares',
      builder: (context, state) => const AppLayout(
        child: FareManagementScreen(),
      ),
    ),
    GoRoute(
      path: '/new_trip',
      builder: (context, state) => const AppLayout(
        child: NewTripScreen(),
      ),
    ),
  ],
  redirect: (context, state) {
    // Add current route to navigation history
    NavigationService().addToHistory(state.uri.path);
    return null;
  },
);

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late TripBloc _tripBloc;
  late UserBloc _userBloc;
  late AuthBloc _authBloc;

  @override
  void initState() {
    super.initState();
    _authBloc = AuthBloc();
    _tripBloc = TripBloc();
    _userBloc = UserBloc();

    // Check if user is already logged in and preload data
    _initializeAppData();
  }

  Future<void> _initializeAppData() async {
    try {
      final token = await TokenService.getToken();
      if (token != null) {
        print('🎯 User already logged in, preloading stations...');
        // User is already logged in, preload stations
        _tripBloc.add(LoadAllStations());
        _userBloc.add(LoadUserProfile());
      } else {
        print('🎯 No saved token found, skipping station preload');
      }
    } catch (e) {
      print('❌ Error checking saved token: $e');
    }
  }

  @override
  void dispose() {
    _authBloc.close();
    _tripBloc.close();
    _userBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Global Auth BLoC
        BlocProvider<AuthBloc>.value(value: _authBloc),
        // Global Trip BLoC - This will persist station data
        BlocProvider<TripBloc>.value(value: _tripBloc),
        // Global User BLoC
        BlocProvider<UserBloc>.value(value: _userBloc),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, authState) {
          // Listen for successful authentication and preload data
          if (authState is AuthSuccess) {
            print('🎯 Auth successful! Preloading app data...');
            // Preload stations immediately after login
            _tripBloc.add(LoadAllStations());
            // Preload user profile
            _userBloc.add(LoadUserProfile());
          }
        },
        child: MaterialApp.router(
          title: 'Smart Rapid Pass',
          theme: AppTheme.lightTheme,
          routerConfig: _router,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
