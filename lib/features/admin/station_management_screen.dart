import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../trip/bloc/trip_bloc.dart';
import '../trip/bloc/trip_event.dart';
import '../trip/bloc/trip_state.dart';
import '../../shared/models/station_model.dart';

import '../../shared/widgets/custom_back_button.dart';
import '../../shared/utils/api_error_handler.dart';
import '../../shared/services/station_api_service.dart';

class StationManagementScreen extends StatefulWidget {
  const StationManagementScreen({super.key});

  @override
  State<StationManagementScreen> createState() =>
      _StationManagementScreenState();
}

class _StationManagementScreenState extends State<StationManagementScreen> {
  @override
  void initState() {
    super.initState();
    // Load stations when screen opens
    context.read<TripBloc>().add(LoadAllStations());
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
                      'Station Management',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ),
                  // Add Station Button
                  ElevatedButton.icon(
                    onPressed: () => _showAddStationDialog(context),
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

            // Stations List
            Expanded(
              child: BlocBuilder<TripBloc, TripState>(
                builder: (context, state) {
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
                          const SizedBox(height: 16),
                          Text(
                            'Failed to load stations',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            ApiErrorHandler.parseError(
                                Exception(state.message)),
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.red.shade600),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              context.read<TripBloc>().add(LoadAllStations());
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

                  // Extract stations from various states
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

                  if (stations == null || stations.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.train,
                            size: 64,
                            color: Color(0xFF7F8C8D),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No stations found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF7F8C8D),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Add your first station to get started',
                            style: TextStyle(
                              color: Color(0xFF7F8C8D),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ListView.builder(
                      itemCount: stations.length,
                      itemBuilder: (context, index) {
                        final station = stations![index];
                        return _buildStationCard(station);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStationCard(StationModel station) {
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
            // Station Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF3498DB).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.train,
                color: Color(0xFF3498DB),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),

            // Station Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    station.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Zone: ${station.zone}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF7F8C8D),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (station.facilities.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Facilities: ${station.facilities.take(2).join(', ')}${station.facilities.length > 2 ? '...' : ''}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF95A5A6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Edit Button
            IconButton(
              onPressed: () => _showEditStationDialog(context, station),
              icon: const Icon(
                Icons.edit,
                color: Color(0xFF27AE60),
                size: 20,
              ),
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFF27AE60).withOpacity(0.1),
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

  void _showAddStationDialog(BuildContext context) {
    _showStationDialog(context, null);
  }

  void _showEditStationDialog(BuildContext context, StationModel station) {
    _showStationDialog(context, station);
  }

  void _showStationDialog(BuildContext context, StationModel? station) {
    final isEdit = station != null;
    final nameController = TextEditingController(text: station?.name ?? '');
    final zoneController = TextEditingController(text: station?.zone ?? '');
    final addressController =
        TextEditingController(text: station?.address ?? '');

    // Form validation state
    final formKey = GlobalKey<FormState>();
    bool isFormValid = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          void validateForm() {
            final isValid = nameController.text.trim().isNotEmpty &&
                zoneController.text.trim().isNotEmpty;
            if (isValid != isFormValid) {
              setState(() {
                isFormValid = isValid;
              });
            }
          }

          return Dialog(
            child: Container(
              width: MediaQuery.of(context).size.width * 1,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEdit ? 'Edit Station' : 'Add New Station',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Form(
                        key: formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildDialogFormField(
                              controller: nameController,
                              label: 'Station Name',
                              icon: Icons.train,
                              isRequired: true,
                              onChanged: (_) => validateForm(),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Station name is required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildDialogFormField(
                              controller: zoneController,
                              label: 'Zone',
                              icon: Icons.map,
                              isRequired: true,
                              onChanged: (_) => validateForm(),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Zone is required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildDialogFormField(
                              controller: addressController,
                              label: 'Address',
                              icon: Icons.location_city,
                              onChanged: (_) => validateForm(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Color(0xFF7F8C8D)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: isFormValid
                            ? () {
                                if (formKey.currentState!.validate()) {
                                  _handleSaveStation(
                                    context,
                                    station,
                                    nameController.text,
                                    zoneController.text,
                                    '', // Empty facilities
                                    addressController.text,
                                    '', // Empty description
                                  );
                                }
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isFormValid
                              ? const Color(0xFF27AE60)
                              : Colors.grey,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(isEdit ? 'Update' : 'Add'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDialogFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isRequired = false,
    int maxLines = 1,
    TextCapitalization textCapitalization = TextCapitalization.none,
    Function(String)? onChanged,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      textCapitalization: textCapitalization,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        labelText: label + (isRequired ? ' *' : ''),
        prefixIcon: Icon(icon, color: const Color(0xFF27AE60)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF27AE60)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  void _handleSaveStation(
    BuildContext context,
    StationModel? station,
    String name,
    String zone,
    String facilities,
    String address,
    String description,
  ) async {
    // Parse facilities
    List<String> facilitiesList = facilities
        .split(',')
        .map((f) => f.trim())
        .where((f) => f.isNotEmpty)
        .toList();

    // Store references before any async operations to avoid ancestor errors
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final tripBloc = context.read<TripBloc>();

    // Close dialog
    navigator.pop();

    // Show loading
    scaffoldMessenger.clearSnackBars(); // Clear any existing snackbars first

    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 16),
            Text(station == null
                ? 'Creating station...'
                : 'Updating station...'),
          ],
        ),
        duration: const Duration(
            seconds: 30), // Shorter duration, will be manually dismissed
        backgroundColor: const Color(0xFF3498DB),
      ),
    );

    try {
      if (station == null) {
        // Create new station
        final generatedCode = _generateStationCode(name);
        print('📝 Creating new station with details:');
        print('   - Name: $name');
        print('   - Code: $generatedCode');
        print('   - Zone: $zone');
        print('   - Address: ${address.trim()}');
        print('   - Description: ${description.trim()}');
        print('   - Facilities: $facilitiesList');

        await StationApiService.createStation(
          name: name,
          code: generatedCode,
          latitude: null, // Backend doesn't require coordinates
          longitude: null, // Backend doesn't require coordinates
          address: address.trim(),
          zone: zone,
          facilities: facilitiesList,
          description: description.trim(),
        );

        // Check if widget is still mounted
        if (!mounted) return;

        // Clear loading and show success
        scaffoldMessenger.clearSnackBars();
        await Future.delayed(const Duration(
            milliseconds: 100)); // Small delay to ensure clearing

        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('✅ Station "$name" created successfully!'),
            backgroundColor: const Color(0xFF27AE60),
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        // Update existing station
        print('📝 Updating station: ${station.id}');
        await StationApiService.updateStation(
          stationId: station.id,
          name: name,
          code: _generateStationCode(name), // Generate code from name
          // latitude: null, // Backend doesn't require coordinates
          // longitude: null, // Backend doesn't require coordinates
          address: address.trim(),
          zone: zone,
          facilities: facilitiesList,
          description: description.trim(),
        );

        // Check if widget is still mounted
        if (!mounted) return;

        // Clear loading and show success
        scaffoldMessenger.clearSnackBars();
        await Future.delayed(const Duration(
            milliseconds: 100)); // Small delay to ensure clearing

        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('✅ Station "$name" updated successfully!'),
            backgroundColor: const Color(0xFF3498DB),
            duration: const Duration(seconds: 3),
          ),
        );
      }

      // Refresh the stations list
      if (mounted) {
        tripBloc.add(LoadAllStations());
      }
    } catch (e) {
      // Check if widget is still mounted
      if (!mounted) return;

      // Clear loading and show error
      scaffoldMessenger.clearSnackBars();
      await Future.delayed(
          const Duration(milliseconds: 100)); // Small delay to ensure clearing

      final errorMessage = ApiErrorHandler.parseError(e);
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('❌ Error: $errorMessage'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );

      print('❌ Station save error: $e');
    }
  }

  /// Generate a station code from the station name
  String _generateStationCode(String name) {
    // Simple code generation: take first letter of each word, max 3 characters
    final words = name.split(' ');
    String code = '';

    for (final word in words) {
      if (word.isNotEmpty && code.length < 3) {
        code += word[0].toUpperCase();
      }
    }

    // If code is too short, pad with letters from the first word
    if (code.length < 2 && words.isNotEmpty) {
      final firstWord = words[0].toUpperCase();
      for (int i = 1; i < firstWord.length && code.length < 3; i++) {
        if (!code.contains(firstWord[i])) {
          code += firstWord[i];
        }
      }
    }

    return code.isNotEmpty ? code : 'STN';
  }
}
