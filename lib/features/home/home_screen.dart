import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../profile/bloc/user_bloc.dart';
import '../profile/bloc/user_event.dart';
import '../profile/bloc/user_state.dart';
import '../trip/bloc/trip_bloc.dart';
import '../trip/bloc/trip_event.dart';
import '../trip/bloc/trip_state.dart';
import '../trip/qr_code_screen.dart';
import '../../shared/models/station_model.dart';
import '../../shared/models/trip_model.dart';
import '../../shared/models/fare_model.dart';
import '../../shared/services/navigation_service.dart';
import '../../shared/widgets/custom_back_button.dart';

import '../../shared/widgets/error_display.dart';
import '../../shared/utils/api_error_handler.dart';
import '../../shared/utils/user_initials.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _fromStation;
  String? _toStation;
  String? _fromStationId;
  String? _toStationId;
  int? _calculatedFare;

  @override
  void initState() {
    super.initState();
    // Ensure data is loaded when HomeScreen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tripBloc = context.read<TripBloc>();
      final userBloc = context.read<UserBloc>();

      // Load stations if not already loaded
      print(
          '🏠 HomeScreen: Current TripBloc state: ${tripBloc.state.runtimeType}');

      // Check if we need to load stations
      bool needsStationLoad = tripBloc.state is! StationsLoaded &&
          tripBloc.state is! StationsAndHistoryLoaded &&
          tripBloc.state is! StationsAndFareLoaded &&
          tripBloc.state is! StationsHistoryAndFareLoaded;

      if (needsStationLoad) {
        print('🏠 HomeScreen: Stations not loaded, triggering load...');
        tripBloc.add(LoadAllStations());

        // Wait for stations to load before loading trip history
        // This prevents trip history from overwriting the station loading state
        Future.delayed(const Duration(milliseconds: 1000), () {
          print(
              '🏠 HomeScreen: Loading trip history after station load delay...');
          tripBloc.add(LoadTripHistory());
        });
      } else {
        if (tripBloc.state is StationsLoaded) {
          final stationsLoaded = tripBloc.state as StationsLoaded;
          print(
              '🏠 HomeScreen: Stations already loaded (${stationsLoaded.stations.length} stations)');
        } else if (tripBloc.state is StationsAndHistoryLoaded) {
          final stationsAndHistory = tripBloc.state as StationsAndHistoryLoaded;
          print(
              '🏠 HomeScreen: Stations and history already loaded (${stationsAndHistory.stations.length} stations, ${stationsAndHistory.trips.length} trips)');
        } else if (tripBloc.state is StationsAndFareLoaded) {
          final stationsAndFare = tripBloc.state as StationsAndFareLoaded;
          print(
              '🏠 HomeScreen: Stations and fare already loaded (${stationsAndFare.stations.length} stations, fare: \$${stationsAndFare.fare.amount})');
        } else if (tripBloc.state is StationsHistoryAndFareLoaded) {
          final fullState = tripBloc.state as StationsHistoryAndFareLoaded;
          print(
              '🏠 HomeScreen: All data loaded (${fullState.stations.length} stations, ${fullState.trips.length} trips, fare: \$${fullState.fare.amount})');
        }

        // Stations are already loaded, safe to load trip history immediately
        tripBloc.add(LoadTripHistory());
      }

      // Load user profile if not already loaded
      if (userBloc.state is! UserProfileLoaded) {
        print('🏠 HomeScreen: Loading user profile...');
        userBloc.add(LoadUserProfile());
      } else {
        print('🏠 HomeScreen: User profile already loaded');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Use existing global BLoCs - no need to create new ones
        BlocProvider.value(value: context.read<UserBloc>()),
        BlocProvider.value(value: context.read<TripBloc>()),
      ],
      child: _HomeScreenContent(
        fromStation: _fromStation,
        toStation: _toStation,
        fromStationId: _fromStationId,
        toStationId: _toStationId,
        calculatedFare: _calculatedFare,
        onFromStationChanged: (val) {
          setState(() {
            _fromStation = val;
            _calculatedFare = null;
          });
        },
        onToStationChanged: (val) {
          setState(() {
            _toStation = val;
            _calculatedFare = null;
          });
        },
        onFromStationIdChanged: (val) {
          setState(() {
            _fromStationId = val;
          });
        },
        onToStationIdChanged: (val) {
          setState(() {
            _toStationId = val;
          });
        },
        onFareCalculated: (fare) {
          setState(() {
            _calculatedFare = fare;
          });
        },
        onReset: () {
          setState(() {
            _fromStation = null;
            _toStation = null;
            _fromStationId = null;
            _toStationId = null;
            _calculatedFare = null;
          });
        },
      ),
    );
  }
}

class _HomeScreenContent extends StatefulWidget {
  final String? fromStation;
  final String? toStation;
  final String? fromStationId;
  final String? toStationId;
  final int? calculatedFare;
  final Function(String?) onFromStationChanged;
  final Function(String?) onToStationChanged;
  final Function(String?) onFromStationIdChanged;
  final Function(String?) onToStationIdChanged;
  final Function(int) onFareCalculated;
  final VoidCallback onReset;

  const _HomeScreenContent({
    required this.fromStation,
    required this.toStation,
    required this.fromStationId,
    required this.toStationId,
    required this.calculatedFare,
    required this.onFromStationChanged,
    required this.onToStationChanged,
    required this.onFromStationIdChanged,
    required this.onToStationIdChanged,
    required this.onFareCalculated,
    required this.onReset,
  });

  @override
  State<_HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<_HomeScreenContent> {
  // Store last known stations to keep dropdowns visible during fare calculation errors
  List<StationModel>? _lastKnownStations;
  // Helper method to check if stations are loaded
  bool _hasStationsLoaded(TripState state) {
    return state is StationsLoaded ||
        state is StationsAndHistoryLoaded ||
        state is StationsAndFareLoaded ||
        state is StationsHistoryAndFareLoaded ||
        state is TripFailureWithStations ||
        state is TripCreatedWithStations ||
        // Include fare calculation errors if we have last known stations
        (_hasFareCalculationError(state) && _lastKnownStations != null);
  }

  // Helper method to check if there's a fare calculation error
  bool _hasFareCalculationError(TripState state) {
    return state is TripFailureWithStations ||
        (state is TripFailure &&
            (state.message.toLowerCase().contains('fare') ||
                state.message.toLowerCase().contains('no fare') ||
                state.message.toLowerCase().contains('route')));
  }

  // Helper method to get stations from any state
  List<StationModel>? _getStationsFromState(TripState state) {
    List<StationModel>? stations;

    if (state is StationsLoaded) {
      stations = state.stations;
    } else if (state is StationsAndHistoryLoaded) {
      stations = state.stations;
    } else if (state is StationsAndFareLoaded) {
      stations = state.stations;
    } else if (state is StationsHistoryAndFareLoaded) {
      stations = state.stations;
    } else if (state is TripFailureWithStations) {
      stations = state.stations;
    } else if (state is TripCreatedWithStations) {
      stations = state.stations;
    }

    // Update last known stations if we found any
    if (stations != null) {
      _lastKnownStations = stations;
    }

    // Return current stations or fall back to last known stations for fare calculation errors
    return stations ??
        (_hasFareCalculationError(state) ? _lastKnownStations : null);
  }

  // Helper method to get calculated fare from any state
  FareModel? _getFareFromState(TripState state) {
    if (state is FareCalculated) {
      return state.fare;
    } else if (state is StationsAndFareLoaded) {
      return state.fare;
    } else if (state is StationsHistoryAndFareLoaded) {
      return state.fare;
    }
    return null;
  }

  // Helper method to get unique station names
  List<String> _getUniqueStationNames(List<dynamic> stations) {
    return stations.map((station) => station.name.toString()).toSet().toList();
  }

  // Helper method to find station ID by name
  String? _getStationIdByName(String stationName, List<dynamic> stations) {
    try {
      final matches =
          stations.where((station) => station.name == stationName).toList();
      if (matches.isNotEmpty) {
        return matches.first.id;
      }
      return null;
    } catch (e) {
      print('❌ Error finding station ID for $stationName: $e');
      return null;
    }
  }

  // Calculate fare if both stations are selected
  void _calculateFareIfReady() {
    if (widget.fromStationId != null && widget.toStationId != null) {
      print(
          '🎯 Calculating fare for station IDs: ${widget.fromStationId} to ${widget.toStationId}');
      print('🎯 From Station: ${widget.fromStation}');
      print('🎯 To Station: ${widget.toStation}');
      context.read<TripBloc>().add(CalculateFare(
            fromStationId: widget.fromStationId!,
            toStationId: widget.toStationId!,
          ));
    } else {
      print('⚠️ Station IDs not available for fare calculation');
      print('   - From Station ID: ${widget.fromStationId}');
      print('   - To Station ID: ${widget.toStationId}');
    }
  }

  // Manual fare calculation method for the button
  void _calculateFare() {
    if (widget.fromStationId != null && widget.toStationId != null) {
      print('🎯 Manual fare calculation triggered');
      print('🎯 From Station ID: ${widget.fromStationId}');
      print('🎯 To Station ID: ${widget.toStationId}');
      context.read<TripBloc>().add(CalculateFare(
            fromStationId: widget.fromStationId!,
            toStationId: widget.toStationId!,
          ));
    } else {
      print('⚠️ Cannot calculate fare - station IDs missing');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both stations first'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  // Create trip
  void _createTrip() {
    if (widget.fromStationId == null || widget.toStationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both stations'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (widget.calculatedFare == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please wait for fare calculation'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    context.read<TripBloc>().add(CreateTrip(
          boardingStation: widget.fromStationId!,
          dropStation: widget.toStationId!,
          numberOfPassengers: 1,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listener: (context, userState) {
        if (userState is MoneyDeposited) {
          print('💰 Money deposited, new balance: ${userState.newBalance}');
          // Refresh user profile to get updated balance
          context.read<UserBloc>().add(LoadUserProfile());
        }
      },
      child: BlocListener<TripBloc, TripState>(
        listener: (context, tripState) {
          print('🎯 HomeScreen TripBloc state: $tripState');
          if (tripState is TripFailure) {
            print('❌ Trip failure: ${tripState.message}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${tripState.message}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
              ),
            );
          } else if (tripState is StationsLoaded) {
            print(
                '🏢 HomeScreen: Stations loaded successfully: ${tripState.stations.length} stations');
            if (tripState.stations.isNotEmpty) {
              print(
                  '   - First station: ${tripState.stations.first.name} (ID: ${tripState.stations.first.id})');
              print(
                  '   - Last station: ${tripState.stations.last.name} (ID: ${tripState.stations.last.id})');
            }
          } else if (tripState is TripCreated ||
              tripState is TripCreatedWithStations) {
            print('✅ Trip created successfully');
            // Refresh user profile to update balance after trip creation
            print(
                '💰 Refreshing user profile to update balance after trip creation');
            context.read<UserBloc>().add(LoadUserProfile());

            final trip = tripState is TripCreated
                ? tripState.trip
                : (tripState as TripCreatedWithStations).trip;

            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => QRCodeScreen(trip: trip),
              ),
            );
          } else if (tripState is FareCalculated) {
            print('💰 Fare calculated: ${tripState.fare.amount}');
            print('💰 Fare object: ${tripState.fare}');
            widget.onFareCalculated(tripState.fare.amount);
            print('💰 _calculatedFare updated to: ${tripState.fare.amount}');
          } else if (tripState is StationsAndFareLoaded) {
            print(
                '💰 Fare calculated with stations preserved: ${tripState.fare.amount}');
            widget.onFareCalculated(tripState.fare.amount);
            print('💰 _calculatedFare updated to: ${tripState.fare.amount}');
          } else if (tripState is StationsHistoryAndFareLoaded) {
            print(
                '💰 Fare calculated with all data preserved: ${tripState.fare.amount}');
            widget.onFareCalculated(tripState.fare.amount);
            print('💰 _calculatedFare updated to: ${tripState.fare.amount}');
          }
        },
        child: BlocBuilder<UserBloc, UserState>(
          builder: (context, userState) {
            return BlocBuilder<TripBloc, TripState>(
              builder: (context, tripState) {
                return Scaffold(
                  backgroundColor: const Color(0xFFFFF7E9),
                  body: SafeArea(
                    child: Column(
                      children: [
                        // Header with back button
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: Row(
                            children: [
                              const CustomBackButton(),
                              const SizedBox(width: 16),
                              const Text(
                                'Home',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2C3E50),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Main content
                        Expanded(
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Top Card: Balance
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 28,
                                          backgroundColor:
                                              const Color(0xFF20B2AA),
                                          child: userState is UserProfileLoaded
                                              ? Text(
                                                  UserInitials.generate(
                                                      userState.user.fullName),
                                                  style: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                )
                                              : const Icon(
                                                  Icons.person,
                                                  size: 28,
                                                  color: Colors.white,
                                                ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text('Total Balance',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.black54)),
                                              const SizedBox(height: 4),
                                              if (userState
                                                  is UserProfileLoaded) ...[
                                                Builder(
                                                  builder: (context) {
                                                    debugPrint(
                                                        '💰 HomeScreen: Displaying balance from API: ${userState.user.balance.toString()}');
                                                    return Text(
                                                        '\৳${userState.user.balance.toString()}',
                                                        style: const TextStyle(
                                                            fontSize: 28,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold));
                                                  },
                                                )
                                              ] else ...[
                                                Builder(
                                                  builder: (context) {
                                                    debugPrint(
                                                        '💰 HomeScreen: No user data, showing default balance');
                                                    return const Text('\৳0',
                                                        style: TextStyle(
                                                            fontSize: 28,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold));
                                                  },
                                                )
                                              ]
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  // Plan your Trip
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 18),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        const Text('Plan your Trip',
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 16),
                                        // Show error message if fare calculation failed
                                        if (_hasFareCalculationError(
                                            tripState)) ...[
                                          CompactErrorDisplay(
                                            message: tripState
                                                    is TripFailureWithStations
                                                ? tripState.message
                                                : (tripState as TripFailure)
                                                    .message,
                                            onRetry: () {
                                              _calculateFare();
                                            },
                                          ),
                                          const SizedBox(height: 16),
                                        ],
                                        if (_hasStationsLoaded(tripState)) ...[
                                          Builder(
                                            builder: (context) {
                                              final stations =
                                                  _getStationsFromState(
                                                      tripState)!;
                                              return DropdownButtonFormField<
                                                  String>(
                                                value: widget.fromStation,
                                                decoration: InputDecoration(
                                                  filled: true,
                                                  fillColor: Colors.black87,
                                                  labelText: 'From Station',
                                                  labelStyle: const TextStyle(
                                                      color: Colors.white),
                                                  border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8)),
                                                ),
                                                dropdownColor: Colors.black87,
                                                style: const TextStyle(
                                                    color: Colors.white),
                                                items: _getUniqueStationNames(
                                                        stations)
                                                    .map((stationName) =>
                                                        DropdownMenuItem(
                                                          value: stationName,
                                                          child: Text(
                                                              stationName,
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .white)),
                                                        ))
                                                    .toList(),
                                                onChanged: (val) {
                                                  print(
                                                      '📍 From station changed to: $val');
                                                  widget.onFromStationChanged(
                                                      val);
                                                  if (val != null) {
                                                    final stationId =
                                                        _getStationIdByName(
                                                            val, stations);
                                                    print(
                                                        '📍 From station ID: $stationId');
                                                    widget
                                                        .onFromStationIdChanged(
                                                            stationId);
                                                    // Use Future.microtask to ensure state is updated before calculating fare
                                                    Future.microtask(() =>
                                                        _calculateFareIfReady());
                                                  } else {
                                                    widget
                                                        .onFromStationIdChanged(
                                                            null);
                                                  }
                                                },
                                              );
                                            },
                                          ),
                                        ] else if (tripState
                                            is TripFailure) ...[
                                          Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: Colors.red.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                  color: Colors.red.shade300),
                                            ),
                                            child: Column(
                                              children: [
                                                const Icon(Icons.error_outline,
                                                    color: Colors.red,
                                                    size: 32),
                                                const SizedBox(height: 8),
                                                Text(
                                                  'Failed to load stations',
                                                  style: TextStyle(
                                                      color:
                                                          Colors.red.shade700,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  ApiErrorHandler.parseError(
                                                      Exception(
                                                          tripState.message)),
                                                  style: TextStyle(
                                                      color:
                                                          Colors.red.shade600,
                                                      fontSize: 12),
                                                  textAlign: TextAlign.center,
                                                ),
                                                const SizedBox(height: 8),
                                                ElevatedButton.icon(
                                                  onPressed: () {
                                                    print(
                                                        '🔄 Retrying to load stations...');
                                                    context
                                                        .read<TripBloc>()
                                                        .add(LoadAllStations());
                                                  },
                                                  icon: const Icon(
                                                      Icons.refresh,
                                                      size: 16),
                                                  label: const Text('Retry'),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        const Color.fromARGB(
                                                            255, 168, 54, 244),
                                                    foregroundColor:
                                                        Colors.white,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 16,
                                                        vertical: 8),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ] else if (tripState
                                            is TripLoading) ...[
                                          Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                  color: Colors.blue.shade300),
                                            ),
                                            child: const Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                          strokeWidth: 2),
                                                ),
                                                SizedBox(width: 12),
                                                Text('Loading stations...'),
                                              ],
                                            ),
                                          ),
                                        ] else ...[
                                          Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: Colors.orange.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                  color:
                                                      Colors.orange.shade300),
                                            ),
                                            child: const Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.warning_amber,
                                                    color: Colors.orange,
                                                    size: 24),
                                                SizedBox(width: 12),
                                                Text(
                                                  'Stations not loaded yet',
                                                  style: TextStyle(
                                                      color: Colors.orange),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                        const SizedBox(height: 12),
                                        if (_hasStationsLoaded(tripState)) ...[
                                          Builder(
                                            builder: (context) {
                                              final stations =
                                                  _getStationsFromState(
                                                      tripState)!;
                                              return DropdownButtonFormField<
                                                  String>(
                                                value: widget.toStation,
                                                decoration: InputDecoration(
                                                  filled: true,
                                                  fillColor: Colors.black87,
                                                  labelText: 'To Station',
                                                  labelStyle: const TextStyle(
                                                      color: Colors.white),
                                                  border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8)),
                                                ),
                                                dropdownColor: Colors.black87,
                                                style: const TextStyle(
                                                    color: Colors.white),
                                                items: _getUniqueStationNames(
                                                        stations)
                                                    .map((stationName) =>
                                                        DropdownMenuItem(
                                                          value: stationName,
                                                          child: Text(
                                                              stationName,
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .white)),
                                                        ))
                                                    .toList(),
                                                onChanged: (val) {
                                                  print(
                                                      '📍 To station changed to: $val');
                                                  widget
                                                      .onToStationChanged(val);
                                                  if (val != null) {
                                                    final stationId =
                                                        _getStationIdByName(
                                                            val, stations);
                                                    print(
                                                        '📍 To station ID: $stationId');
                                                    widget.onToStationIdChanged(
                                                        stationId);
                                                    // Use Future.microtask to ensure state is updated before calculating fare
                                                    Future.microtask(() =>
                                                        _calculateFareIfReady());
                                                  } else {
                                                    widget.onToStationIdChanged(
                                                        null);
                                                  }
                                                },
                                              );
                                            },
                                          ),
                                        ] else if (tripState
                                            is TripFailure) ...[
                                          Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: Colors.red.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                  color: Colors.red.shade300),
                                            ),
                                            child: Column(
                                              children: [
                                                const Icon(Icons.error_outline,
                                                    color: Colors.red,
                                                    size: 32),
                                                const SizedBox(height: 8),
                                                Text(
                                                  'Failed to load stations',
                                                  style: TextStyle(
                                                      color:
                                                          Colors.red.shade700,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  ApiErrorHandler.parseError(
                                                      Exception(
                                                          tripState.message)),
                                                  style: TextStyle(
                                                      color:
                                                          Colors.red.shade600,
                                                      fontSize: 12),
                                                  textAlign: TextAlign.center,
                                                ),
                                                const SizedBox(height: 8),
                                                ElevatedButton.icon(
                                                  onPressed: () {
                                                    print(
                                                        '🔄 Retrying to load stations...');
                                                    context
                                                        .read<TripBloc>()
                                                        .add(LoadAllStations());
                                                  },
                                                  icon: const Icon(
                                                      Icons.refresh,
                                                      size: 16),
                                                  label: const Text('Retry'),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        const Color.fromARGB(
                                                            255, 168, 54, 244),
                                                    foregroundColor:
                                                        Colors.white,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 16,
                                                        vertical: 8),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ] else if (tripState
                                            is TripLoading) ...[
                                          Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                  color: Colors.blue.shade300),
                                            ),
                                            child: const Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                          strokeWidth: 2),
                                                ),
                                                SizedBox(width: 12),
                                                Text('Loading stations...'),
                                              ],
                                            ),
                                          ),
                                        ] else ...[
                                          Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: Colors.orange.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                  color:
                                                      Colors.orange.shade300),
                                            ),
                                            child: const Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.warning_amber,
                                                    color: Colors.orange,
                                                    size: 24),
                                                SizedBox(width: 12),
                                                Text(
                                                  'Stations not loaded yet',
                                                  style: TextStyle(
                                                      color: Colors.orange),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                        const SizedBox(height: 12),
                                        // Fare Display with Calculate Button (70%:30%)
                                        Row(
                                          children: [
                                            // Fare Display (70% width)
                                            Expanded(
                                              flex: 7,
                                              child: Container(
                                                height: 56, // Fixed height
                                                padding:
                                                    const EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  color: Colors.black87,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  border: Border.all(
                                                      color: Colors.white),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    const Text(
                                                      'Total Fare:',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    Flexible(
                                                      child: Text(
                                                        widget.calculatedFare !=
                                                                null
                                                            ? '\৳${widget.calculatedFare!}'
                                                            : '-',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              widget.calculatedFare !=
                                                                      null
                                                                  ? Colors.green
                                                                  : Colors.grey,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            // Calculate Fare Button (30% width)
                                            Expanded(
                                              flex: 3,
                                              child: SizedBox(
                                                height: 56, // Same fixed height
                                                child: ElevatedButton(
                                                  onPressed:
                                                      (widget.fromStationId !=
                                                                  null &&
                                                              widget.toStationId !=
                                                                  null)
                                                          ? _calculateFare
                                                          : null,
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.black87,
                                                    foregroundColor:
                                                        Colors.white,
                                                    side: const BorderSide(
                                                        color: Colors.white),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8)),
                                                    padding: EdgeInsets
                                                        .zero, // Remove padding to use SizedBox height
                                                  ),
                                                  child: tripState
                                                          is TripLoading
                                                      ? const SizedBox(
                                                          width: 16,
                                                          height: 16,
                                                          child:
                                                              CircularProgressIndicator(
                                                            color: Colors.white,
                                                            strokeWidth: 2,
                                                          ),
                                                        )
                                                      : const Text(
                                                          'Calculate',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        // Submit Button (100% width)
                                        SizedBox(
                                          width: double.infinity,
                                          height: 48,
                                          child: ElevatedButton(
                                            onPressed:
                                                widget.calculatedFare != null
                                                    ? _createTrip
                                                    : null,
                                            child: tripState is TripLoading
                                                ? const SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child:
                                                        CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2,
                                                    ),
                                                  )
                                                : const Text('Submit'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color(0xFF007399),
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8)),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // Quick Actions
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                          color: const Color(0xFF007399)),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16, horizontal: 8),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        _QuickAction(
                                          icon: Icons
                                              .account_balance_wallet_outlined,
                                          label: 'Deposit',
                                          onTap: () => NavigationService()
                                              .navigateTo(context, '/topup'),
                                        ),
                                        _QuickAction(
                                          icon: Icons.navigation_outlined,
                                          label: 'Current Trip',
                                          onTap: () {},
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // Recent History
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 18),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text('Recent History',
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            GestureDetector(
                                              onTap: () => NavigationService()
                                                  .navigateTo(
                                                      context, '/history'),
                                              child: const Text(
                                                'View All',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Color(0xFF20B2AA),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Divider(height: 24),
                                        BlocBuilder<TripBloc, TripState>(
                                          builder: (context, state) {
                                            List<TripModel>? trips;
                                            if (state is TripHistoryLoaded) {
                                              trips = state.trips;
                                            } else if (state
                                                is StationsAndHistoryLoaded) {
                                              trips = state.trips;
                                            } else if (state
                                                is StationsHistoryAndFareLoaded) {
                                              trips = state.trips;
                                            } else if (state
                                                is TripFailureWithStations) {
                                              trips = state.trips;
                                            }

                                            if (trips != null) {
                                              if (trips.isEmpty) {
                                                return const Center(
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.all(20.0),
                                                    child: Text(
                                                      'No recent trips yet',
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFF7F8C8D),
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }
                                              // Show only the most recent 3 trips
                                              final recentTrips =
                                                  trips.take(3).toList();
                                              return Column(
                                                children: recentTrips
                                                    .map((trip) => _HistoryItem(
                                                          icon: trip?.status ==
                                                                  'used'
                                                              ? Icons
                                                                  .check_circle
                                                              : Icons.schedule,
                                                          iconColor:
                                                              trip?.status ==
                                                                      'used'
                                                                  ? Colors.green
                                                                  : Colors
                                                                      .orange,
                                                          title:
                                                              '${trip?.boardingStationName?.isNotEmpty == true ? trip?.boardingStationName : trip?.boardingStation} - ${trip?.dropStationName?.isNotEmpty == true ? trip?.dropStationName : trip?.dropStation}',
                                                          subtitle: _formatDate(
                                                              trip?.createdAt ??
                                                                  DateTime
                                                                      .now()),
                                                          amount:
                                                              '-\৳${trip?.totalAmount ?? 0}',
                                                          amountColor:
                                                              Colors.red,
                                                        ))
                                                    .toList(),
                                              );
                                            } else if (state is TripLoading) {
                                              return const Center(
                                                child: Padding(
                                                  padding: EdgeInsets.all(20.0),
                                                  child:
                                                      CircularProgressIndicator(),
                                                ),
                                              );
                                            } else {
                                              return const Center(
                                                child: Padding(
                                                  padding: EdgeInsets.all(20.0),
                                                  child: Text(
                                                    'Unable to load recent trips',
                                                    style: TextStyle(
                                                      color: Color(0xFF7F8C8D),
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today, ${_formatTime(date)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday, ${_formatTime(date)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago, ${_formatTime(date)}';
    } else {
      return '${date.day}/${date.month}/${date.year}, ${_formatTime(date)}';
    }
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickAction(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(
                  color: const Color(0xFF007399),
                  style: BorderStyle.solid,
                  width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 32, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String amount;
  final Color amountColor;
  const _HistoryItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.amountColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500)),
                Text(subtitle,
                    style:
                        const TextStyle(fontSize: 13, color: Colors.black54)),
              ],
            ),
          ),
          Text(amount,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: amountColor)),
        ],
      ),
    );
  }
}
