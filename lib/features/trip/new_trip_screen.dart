import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/trip_bloc.dart';
import 'bloc/trip_event.dart';
import 'bloc/trip_state.dart';
import '../../shared/models/station_model.dart';
import '../../shared/widgets/custom_back_button.dart';
import '../../shared/widgets/status_bar.dart';
import '../../shared/services/navigation_service.dart';
import '../profile/bloc/user_bloc.dart';
import '../profile/bloc/user_event.dart';
import 'qr_code_screen.dart';

class NewTripScreen extends StatefulWidget {
  const NewTripScreen({super.key});

  @override
  State<NewTripScreen> createState() => _NewTripScreenState();
}

class _NewTripScreenState extends State<NewTripScreen> {
  String? _fromStation;
  String? _toStation;
  String? _fromStationId;
  String? _toStationId;
  int _numberOfPassengers = 1;
  int? _calculatedFare;

  @override
  void initState() {
    super.initState();
    // We'll load stations when the BLoC is created
  }

  void _calculateFare() {
    if (_fromStationId != null && _toStationId != null) {
      print(
          '🎯 Calculating fare for station IDs: $_fromStationId to $_toStationId');
      context.read<TripBloc>().add(CalculateFare(
            fromStationId: _fromStationId!,
            toStationId: _toStationId!,
          ));
    } else {
      print('⚠️ Station IDs not available for fare calculation');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both stations first'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _createTrip() {
    if (_fromStation == null || _toStation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both stations'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_calculatedFare == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please calculate fare first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    context.read<TripBloc>().add(CreateTrip(
          boardingStation: _fromStationId!,
          dropStation: _toStationId!,
          numberOfPassengers: _numberOfPassengers,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = TripBloc();
        // Load all stations when BLoC is created
        bloc.add(LoadAllStations());
        return bloc;
      },
      child: _NewTripScreenContent(
        fromStation: _fromStation,
        toStation: _toStation,
        fromStationId: _fromStationId,
        toStationId: _toStationId,
        numberOfPassengers: _numberOfPassengers,
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
        onPassengersChanged: (val) {
          setState(() {
            _numberOfPassengers = val;
            _calculatedFare = null;
          });
        },
        onFareCalculated: (fare) {
          print('💰 onFareCalculated callback called with fare: ৳$fare');
          setState(() {
            _calculatedFare = fare;
            print('💰 _calculatedFare state updated to: ৳$_calculatedFare');
          });
        },
      ),
    );
  }
}

class _NewTripScreenContent extends StatefulWidget {
  final String? fromStation;
  final String? toStation;
  final String? fromStationId;
  final String? toStationId;
  final int numberOfPassengers;
  final int? calculatedFare;
  final Function(String?) onFromStationChanged;
  final Function(String?) onToStationChanged;
  final Function(String?) onFromStationIdChanged;
  final Function(String?) onToStationIdChanged;
  final Function(int) onPassengersChanged;
  final Function(int) onFareCalculated;

  const _NewTripScreenContent({
    required this.fromStation,
    required this.toStation,
    required this.fromStationId,
    required this.toStationId,
    required this.numberOfPassengers,
    required this.calculatedFare,
    required this.onFromStationChanged,
    required this.onToStationChanged,
    required this.onFromStationIdChanged,
    required this.onToStationIdChanged,
    required this.onPassengersChanged,
    required this.onFareCalculated,
  });

  @override
  State<_NewTripScreenContent> createState() => _NewTripScreenContentState();
}

class _NewTripScreenContentState extends State<_NewTripScreenContent> {
  // Helper method to extract stations from various state types
  List<StationModel> _getStationsFromState(TripState state) {
    if (state is StationsLoaded) {
      return state.stations;
    } else if (state is StationsAndHistoryLoaded) {
      return state.stations;
    } else if (state is StationsAndFareLoaded) {
      return state.stations;
    } else if (state is StationsHistoryAndFareLoaded) {
      return state.stations;
    } else if (state is StationsAndFaresLoaded) {
      return state.stations;
    } else if (state is TripFailureWithStations) {
      return state.stations;
    } else if (state is TripCreatedWithStations) {
      return state.stations;
    }
    return [];
  }

  // Helper method to get unique station names
  List<String> _getUniqueStationNames(List<dynamic> stations) {
    return stations.map((station) => station.name.toString()).toSet().toList();
  }

  // Helper method to get station names excluding a specific station
  List<String> _getFilteredStationNames(
      List<dynamic> stations, String? excludeStation) {
    final allStations = _getUniqueStationNames(stations);
    if (excludeStation != null) {
      return allStations.where((station) => station != excludeStation).toList();
    }
    return allStations;
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

  void _calculateFare() {
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both stations first'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _createTrip() {
    if (widget.fromStation == null || widget.toStation == null) {
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
          content: Text('Please calculate fare first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    print('🎯 Creating trip with:');
    print(
        '   - From Station: ${widget.fromStation} (ID: ${widget.fromStationId})');
    print('   - To Station: ${widget.toStation} (ID: ${widget.toStationId})');
    print('   - Passengers: ${widget.numberOfPassengers}');
    print('   - Calculated Fare: ${widget.calculatedFare}');

    // Validate station IDs
    if (widget.fromStationId == null || widget.toStationId == null) {
      print('❌ Station IDs are null!');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Station IDs are missing. Please select stations again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if station IDs look like valid MongoDB ObjectIds (24 character hex strings)
    final fromStationIdValid = widget.fromStationId!.length == 24 &&
        RegExp(r'^[0-9a-fA-F]+$').hasMatch(widget.fromStationId!);
    final toStationIdValid = widget.toStationId!.length == 24 &&
        RegExp(r'^[0-9a-fA-F]+$').hasMatch(widget.toStationId!);

    print('🔍 Station ID validation:');
    print(
        '   - From Station ID valid: $fromStationIdValid (${widget.fromStationId!.length} chars)');
    print(
        '   - To Station ID valid: $toStationIdValid (${widget.toStationId!.length} chars)');

    if (!fromStationIdValid || !toStationIdValid) {
      print('❌ Invalid station ID format!');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid station ID format. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    context.read<TripBloc>().add(CreateTrip(
          boardingStation: widget.fromStationId!,
          dropStation: widget.toStationId!,
          numberOfPassengers: widget.numberOfPassengers,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TripBloc, TripState>(
      listener: (context, state) {
        if (state is TripFailure || state is TripFailureWithStations) {
          String errorMessage = state is TripFailure
              ? state.message
              : (state as TripFailureWithStations).message;

          print('❌ Error state received: $errorMessage');

          // Provide more user-friendly error messages
          if (errorMessage.contains('404')) {
            errorMessage =
                'Fare calculation service not available. Please try again later.';
          } else if (errorMessage.contains('401')) {
            errorMessage = 'Authentication failed. Please login again.';
          } else if (errorMessage.contains('500')) {
            errorMessage = 'Server error. Please try again later.';
          } else if (errorMessage.toLowerCase().contains('network')) {
            errorMessage =
                'Network error. Please check your connection and try again.';
          } else if (errorMessage.toLowerCase().contains('no fare')) {
            errorMessage =
                'No fare found for this route. Please select different stations.';
          }

          print('📱 Showing error message: $errorMessage');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        } else if (state is TripCreated || state is TripCreatedWithStations) {
          // Refresh user profile to update balance after trip creation
          print(
              '💰 Trip created successfully, refreshing user profile to update balance');
          context.read<UserBloc>().add(LoadUserProfile());

          final trip = state is TripCreated
              ? state.trip
              : (state as TripCreatedWithStations).trip;

          // Navigate to QR code screen instead of showing snackbar
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => QRCodeScreen(trip: trip),
            ),
          );
        } else if (state is FareCalculated) {
          print(
              '🎯 FareCalculated state received, fare: ৳${state.fare.amount}');
          widget.onFareCalculated(state.fare.amount);
        } else if (state is StationsAndFareLoaded) {
          print(
              '🎯 StationsAndFareLoaded state received, fare: ৳${state.fare.amount}');
          widget.onFareCalculated(state.fare.amount);
        } else if (state is StationsHistoryAndFareLoaded) {
          print(
              '🎯 StationsHistoryAndFareLoaded state received, fare: ৳${state.fare.amount}');
          widget.onFareCalculated(state.fare.amount);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // Custom Status Bar
              const CustomStatusBar(),

              // Header with back button
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    const CustomBackButton(),
                    const SizedBox(width: 16),
                    const Text(
                      'Plan your Trip',
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
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: BlocBuilder<TripBloc, TripState>(
                    builder: (context, state) {
                      print('🎯 NewTripScreen state: $state');
                      if (state is StationsLoaded) {
                        print(
                            '🏢 Stations loaded: ${state.stations.length} stations');
                        print(
                            '🏢 Station names: ${state.stations.map((s) => s.name).toList()}');
                        print(
                            '🏢 Unique station names: ${state.stations.map((s) => s.name).toSet().toList()}');
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Plan your Trip',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // From Station Dropdown
                          if (state is StationsLoaded ||
                              state is StationsAndHistoryLoaded ||
                              state is StationsAndFareLoaded ||
                              state is StationsHistoryAndFareLoaded ||
                              state is StationsAndFaresLoaded ||
                              state is TripFailureWithStations ||
                              state is TripCreatedWithStations) ...[
                            DropdownButtonFormField<String>(
                              value: widget.fromStation,
                              decoration: const InputDecoration(
                                labelText: 'From Station',
                                border: OutlineInputBorder(),
                                filled: true,
                                fillColor: Color(0xFFF8F9FA),
                              ),
                              items: _getUniqueStationNames(
                                      _getStationsFromState(state))
                                  .map((stationName) => DropdownMenuItem(
                                        value: stationName,
                                        child: Text(stationName),
                                      ))
                                  .toList(),
                              onChanged: (val) {
                                widget.onFromStationChanged(val);

                                // Clear ToStation if it's the same as the new FromStation
                                if (val != null && val == widget.toStation) {
                                  widget.onToStationChanged(null);
                                  widget.onToStationIdChanged(null);
                                  print(
                                      '🔄 Cleared ToStation because it matched new FromStation');
                                }

                                if (val != null) {
                                  final stations = _getStationsFromState(state);
                                  final stationId =
                                      _getStationIdByName(val, stations);
                                  widget.onFromStationIdChanged(stationId);
                                  print(
                                      '📍 Selected from station: $val (ID: $stationId)');
                                } else {
                                  widget.onFromStationIdChanged(null);
                                }
                              },
                            ),
                          ] else if (state is TripLoading) ...[
                            DropdownButtonFormField<String>(
                              value: null,
                              decoration: const InputDecoration(
                                labelText: 'From Station',
                                border: OutlineInputBorder(),
                                filled: true,
                                fillColor: Color(0xFFF8F9FA),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: null,
                                  child: Text('Loading stations...'),
                                )
                              ],
                              onChanged: null,
                            ),
                          ] else if (state is TripFailure) ...[
                            // Error state for station loading
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.error, color: Colors.red.shade600),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Failed to load stations',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.red.shade700,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Please check your connection and try again',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.red.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      context
                                          .read<TripBloc>()
                                          .add(LoadAllStations());
                                    },
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            ),
                          ] else ...[
                            DropdownButtonFormField<String>(
                              value: null,
                              decoration: const InputDecoration(
                                labelText: 'From Station',
                                border: OutlineInputBorder(),
                                filled: true,
                                fillColor: Color(0xFFF8F9FA),
                              ),
                              items: const [],
                              onChanged: null,
                            ),
                          ],
                          const SizedBox(height: 16),

                          // To Station Dropdown
                          if (state is StationsLoaded ||
                              state is StationsAndHistoryLoaded ||
                              state is StationsAndFareLoaded ||
                              state is StationsHistoryAndFareLoaded ||
                              state is StationsAndFaresLoaded ||
                              state is TripFailureWithStations ||
                              state is TripCreatedWithStations) ...[
                            DropdownButtonFormField<String>(
                              value: widget.toStation,
                              decoration: const InputDecoration(
                                labelText: 'To Station',
                                border: OutlineInputBorder(),
                                filled: true,
                                fillColor: Color(0xFFF8F9FA),
                              ),
                              items: _getFilteredStationNames(
                                      _getStationsFromState(state),
                                      widget.fromStation)
                                  .map((stationName) => DropdownMenuItem(
                                        value: stationName,
                                        child: Text(stationName),
                                      ))
                                  .toList(),
                              onChanged: (val) {
                                widget.onToStationChanged(val);
                                if (val != null) {
                                  final stations = _getStationsFromState(state);
                                  final stationId =
                                      _getStationIdByName(val, stations);
                                  widget.onToStationIdChanged(stationId);
                                  print(
                                      '📍 Selected to station: $val (ID: $stationId)');
                                } else {
                                  widget.onToStationIdChanged(null);
                                }
                              },
                            ),
                          ] else if (state is TripLoading) ...[
                            DropdownButtonFormField<String>(
                              value: null,
                              decoration: const InputDecoration(
                                labelText: 'To Station',
                                border: OutlineInputBorder(),
                                filled: true,
                                fillColor: Color(0xFFF8F9FA),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: null,
                                  child: Text('Loading stations...'),
                                )
                              ],
                              onChanged: null,
                            ),
                          ] else if (state is TripFailure) ...[
                            // Error state for station loading
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.error, color: Colors.red.shade600),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Failed to load stations',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.red.shade700,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Please check your connection and try again',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.red.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      context
                                          .read<TripBloc>()
                                          .add(LoadAllStations());
                                    },
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            ),
                          ] else ...[
                            DropdownButtonFormField<String>(
                              value: null,
                              decoration: const InputDecoration(
                                labelText: 'To Station',
                                border: OutlineInputBorder(),
                                filled: true,
                                fillColor: Color(0xFFF8F9FA),
                              ),
                              items: const [],
                              onChanged: null,
                            ),
                          ],
                          const SizedBox(height: 16),

                          // Number of Passengers
                          Row(
                            children: [
                              const Text(
                                'Number of Passengers: ',
                                style: TextStyle(fontSize: 16),
                              ),
                              const SizedBox(width: 16),
                              IconButton(
                                onPressed: () {
                                  if (widget.numberOfPassengers > 1) {
                                    widget.onPassengersChanged(
                                        widget.numberOfPassengers - 1);
                                  }
                                },
                                icon: const Icon(Icons.remove_circle_outline),
                              ),
                              Text(
                                '${widget.numberOfPassengers}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  widget.onPassengersChanged(
                                      widget.numberOfPassengers + 1);
                                },
                                icon: const Icon(Icons.add_circle_outline),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Calculate Fare Button
                          ElevatedButton(
                            onPressed: (widget.fromStationId != null &&
                                    widget.toStationId != null)
                                ? () => _calculateFare()
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF20B2AA),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: state is TripLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Calculate Fare',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 16),

                          // Fare Display
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F9FA),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: widget.calculatedFare != null
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Base fare row
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Base Fare (per person):',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          Text(
                                            '৳${widget.calculatedFare}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      // Total fare row
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Total Fare (${widget.numberOfPassengers} ${widget.numberOfPassengers == 1 ? 'person' : 'people'}):',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            '৳${widget.calculatedFare! * widget.numberOfPassengers}',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF20B2AA),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Calculate fare first',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                          const Spacer(),

                          // Action Buttons
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    NavigationService()
                                        .navigateTo(context, '/home');
                                  },
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    side: const BorderSide(
                                        color: Color(0xFF20B2AA)),
                                  ),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(
                                      color: Color(0xFF20B2AA),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: (widget.calculatedFare != null)
                                      ? () => _createTrip()
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF34495E),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                  ),
                                  child: state is TripLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
                                          'Create Trip',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
