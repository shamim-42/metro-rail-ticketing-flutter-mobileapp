import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../trip/bloc/trip_bloc.dart';
import '../trip/bloc/trip_event.dart';
import '../trip/bloc/trip_state.dart';
import '../../shared/models/station_model.dart';
import '../../shared/models/fare_model.dart';

import '../../shared/widgets/custom_back_button.dart';

class FareManagementScreen extends StatefulWidget {
  const FareManagementScreen({super.key});

  @override
  State<FareManagementScreen> createState() => _FareManagementScreenState();
}

class _FareManagementScreenState extends State<FareManagementScreen> {
  List<FareModel> fares = [];
  List<StationModel> stations = [];

  @override
  void initState() {
    super.initState();
    // Load stations and fares when screen opens
    _loadData();
  }

  void _loadData() {
    print('🔄 Loading stations and fares...');
    context.read<TripBloc>().add(LoadAllStations());
    context.read<TripBloc>().add(LoadAllFares());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7E9),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  const CustomBackButton(),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Fare Management',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ),
                  // Add Fare Button
                  ElevatedButton.icon(
                    onPressed: () => _showAddFareDialog(context),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF27AE60),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                  ),
                ],
              ),
            ),

            // Fares List
            Expanded(
              child: BlocListener<TripBloc, TripState>(
                listener: (context, state) {
                  print(
                      '🎬 BlocListener - State received: ${state.runtimeType}');

                  // Handle fare creation/update/delete success messages
                  if (state is FareCreated) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Fare created successfully: ${state.fare.fromStation} → ${state.fare.toStation} (৳${state.fare.amount})'),
                        backgroundColor: const Color(0xFF27AE60),
                      ),
                    );
                  } else if (state is FareUpdated) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Fare updated successfully to ৳${state.fare.amount}'),
                        backgroundColor: const Color(0xFF3498DB),
                      ),
                    );
                  } else if (state is TripFailure) {
                    print('❌ TripFailure in fare management: ${state.message}');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${state.message}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: BlocBuilder<TripBloc, TripState>(
                  builder: (context, state) {
                    print(
                        '🎯 FareManagement BlocBuilder - Current state: ${state.runtimeType}');

                    // Extract stations and fares from various states
                    if (state is StationsLoaded) {
                      print(
                          '📍 StationsLoaded: ${state.stations.length} stations');
                      stations = state.stations;
                    } else if (state is StationsAndHistoryLoaded) {
                      print(
                          '📍 StationsAndHistoryLoaded: ${state.stations.length} stations');
                      stations = state.stations;
                    } else if (state is StationsAndFareLoaded) {
                      print(
                          '📍 StationsAndFareLoaded: ${state.stations.length} stations');
                      stations = state.stations;
                    } else if (state is StationsHistoryAndFareLoaded) {
                      print(
                          '📍 StationsHistoryAndFareLoaded: ${state.stations.length} stations');
                      stations = state.stations;
                    } else if (state is StationsAndFaresLoaded) {
                      print(
                          '📍 StationsAndFaresLoaded: ${state.stations.length} stations, ${state.fares.length} fares');
                      stations = state.stations;
                      fares = state.fares;
                    } else if (state is FaresLoaded) {
                      print('💰 FaresLoaded: ${state.fares.length} fares');
                      fares = state.fares;
                    } else if (state is TripFailureWithStations) {
                      print(
                          '❌ TripFailureWithStations: ${state.stations.length} stations');
                      stations = state.stations;
                    }

                    print(
                        '📊 Current state - Stations: ${stations.length}, Fares: ${fares.length}');

                    if (state is TripLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (state is TripFailure) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Failed to load data',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              state.message,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: () {
                                _loadData();
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    if (fares.isEmpty &&
                        !state.runtimeType.toString().contains('Loading')) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.money,
                              size: 64,
                              color: Color(0xFF7F8C8D),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'No fares configured',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF7F8C8D),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Add your first fare to get started',
                              style: TextStyle(
                                color: Color(0xFF7F8C8D),
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: () {
                                print('🔄 Retrying to load fares...');
                                _loadData();
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('Refresh'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF20B2AA),
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    print('🎯 Building ListView with ${fares.length} fares');
                    for (int i = 0; i < fares.length; i++) {
                      print(
                          '📋 Fare ${i + 1}: ${fares[i].fromStation} → ${fares[i].toStation} (৳${fares[i].amount})');
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ListView.builder(
                        itemCount: fares.length,
                        itemBuilder: (context, index) {
                          final fare = fares[index];
                          print(
                              '🔨 Building card for fare ${index + 1}: ${fare.fromStation} → ${fare.toStation}');
                          return _buildFareCard(fare);
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFareCard(FareModel fare) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Fare Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE67E22).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.money,
                color: Color(0xFFE67E22),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),

            // Fare Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          fare.fromStation,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward,
                        color: Color(0xFF7F8C8D),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          fare.toStation,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2C3E50),
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF27AE60).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '৳${fare.amount}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF27AE60),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Edit Button
            IconButton(
              onPressed: () => _showEditFareDialog(context, fare),
              icon: const Icon(
                Icons.edit,
                color: Color(0xFF3498DB),
                size: 20,
              ),
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFF3498DB).withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddFareDialog(BuildContext context) {
    _showFareDialog(context, null);
  }

  void _showEditFareDialog(BuildContext context, FareModel fare) {
    _showFareDialog(context, fare);
  }

  void _showFareDialog(BuildContext context, FareModel? fare) {
    final isEdit = fare != null;
    String? selectedFromStationId;
    String? selectedToStationId;

    // For editing, find station IDs from names
    if (fare != null) {
      selectedFromStationId = stations
          .firstWhere((s) => s.name == fare.fromStation,
              orElse: () => stations.first)
          .id;
      selectedToStationId = stations
          .firstWhere((s) => s.name == fare.toStation,
              orElse: () => stations.first)
          .id;
    }
    final amountController =
        TextEditingController(text: fare?.amount.toString() ?? '');
    final distanceController = TextEditingController(
        text: fare?.distance.toString() ??
            '50.0'); // Use existing or default distance
    final durationController = TextEditingController(
        text: fare?.duration.toString() ??
            '30'); // Use existing or default duration

    // Get available stations for dropdowns
    List<StationModel> availableFromStations = [];
    List<StationModel> availableToStations = [];

    if (!isEdit) {
      // For new fares, exclude stations that already have fares configured
      // Not used anymore but keeping for future reference
      // Set<String> usedFromStationNames = fares.map((f) => f.fromStation).toSet();

      availableFromStations = stations.where((station) {
        // Only show stations that haven't been used as "from" station with all possible "to" stations
        int existingFaresFromThisStation =
            fares.where((f) => f.fromStation == station.name).length;
        return existingFaresFromThisStation <
            (stations.length - 1); // -1 because can't go to same station
      }).toList();
    } else {
      // For editing, show all stations but highlight current selection
      availableFromStations = stations;
      availableToStations =
          stations.where((s) => s.id != selectedFromStationId).toList();
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          // Update available "to" stations when "from" station changes
          if (selectedFromStationId != null && !isEdit) {
            final selectedFromStationName =
                stations.firstWhere((s) => s.id == selectedFromStationId).name;
            Set<String> usedToStationsForFrom = fares
                .where((f) => f.fromStation == selectedFromStationName)
                .map((f) => f.toStation)
                .toSet();

            availableToStations = stations
                .where((station) =>
                    station.id != selectedFromStationId &&
                    !usedToStationsForFrom.contains(station.name))
                .toList();
          }

          return AlertDialog(
            title: Text(isEdit ? 'Edit Fare' : 'Add New Fare'),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            content: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height *
                    0.8, // Max 80% of screen height
                maxWidth: double.maxFinite,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // From Station Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedFromStationId,
                      decoration: InputDecoration(
                        labelText: 'From Station *',
                        prefixIcon:
                            const Icon(Icons.train, color: Color(0xFF27AE60)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFF27AE60)),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      items: availableFromStations.map((station) {
                        return DropdownMenuItem(
                          value: station.id,
                          child: Text(station.name),
                        );
                      }).toList(),
                      onChanged: isEdit
                          ? null
                          : (value) {
                              setDialogState(() {
                                selectedFromStationId = value;
                                selectedToStationId =
                                    null; // Reset to station selection
                              });
                            },
                    ),
                    const SizedBox(height: 12),

                    // To Station Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedToStationId,
                      decoration: InputDecoration(
                        labelText: 'To Station *',
                        prefixIcon:
                            const Icon(Icons.train, color: Color(0xFF27AE60)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFF27AE60)),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      items: availableToStations.map((station) {
                        return DropdownMenuItem(
                          value: station.id,
                          child: Text(station.name),
                        );
                      }).toList(),
                      onChanged: isEdit
                          ? null
                          : (value) {
                              setDialogState(() {
                                selectedToStationId = value;
                              });
                            },
                    ),
                    const SizedBox(height: 12),

                    // Fare Amount Field
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Fare Amount (৳) *',
                        prefixIcon:
                            const Icon(Icons.money, color: Color(0xFF27AE60)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFF27AE60)),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Distance Field
                    TextField(
                      controller: distanceController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Distance (km) *',
                        prefixIcon: const Icon(Icons.straighten,
                            color: Color(0xFF27AE60)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFF27AE60)),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Duration Field
                    TextField(
                      controller: durationController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Duration (minutes) *',
                        prefixIcon:
                            const Icon(Icons.timer, color: Color(0xFF27AE60)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFF27AE60)),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Color(0xFF7F8C8D)),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _handleSaveFare(
                    context,
                    fare,
                    selectedFromStationId,
                    selectedToStationId,
                    amountController.text,
                    distanceController.text,
                    durationController.text,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF27AE60),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(isEdit ? 'Update' : 'Add'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _handleSaveFare(
    BuildContext context,
    FareModel? fare,
    String? fromStationId,
    String? toStationId,
    String amountText,
    String distanceText,
    String durationText,
  ) {
    // Validate required fields
    if (fromStationId == null ||
        toStationId == null ||
        amountText.trim().isEmpty ||
        distanceText.trim().isEmpty ||
        durationText.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All fields are required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final amount = int.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid fare amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final distance = double.tryParse(distanceText);
    if (distance == null || distance <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid distance'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final duration = int.tryParse(durationText);
    if (duration == null || duration <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid duration'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Close dialog
    Navigator.of(context).pop();

    if (fare == null) {
      // Create new fare via API
      context.read<TripBloc>().add(CreateFare(
            fromStationId: fromStationId,
            toStationId: toStationId,
            fare: amount,
            distance: distance,
            duration: duration,
          ));
    } else {
      // Update existing fare via API
      context.read<TripBloc>().add(UpdateFare(
            fareId: fare.id,
            fare: amount,
            distance: distance,
            duration: duration,
          ));
    }
  }
}
