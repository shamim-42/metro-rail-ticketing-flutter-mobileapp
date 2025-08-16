import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/custom_back_button.dart';
import '../../shared/widgets/status_bar.dart';
import '../../shared/services/navigation_service.dart';
import '../../shared/services/qr_download_service.dart';
import '../../shared/models/trip_model.dart';
import '../../shared/widgets/app_bottom_nav_bar.dart';

class QRCodeScreen extends StatelessWidget {
  final TripModel trip;

  const QRCodeScreen({
    super.key,
    required this.trip,
  });

  @override
  Widget build(BuildContext context) {
    // Debug logging
    print('🎯 QRCodeScreen - Trip data:');
    print('   - Trip Code: ${trip.tripCode}');
    print('   - From: ${trip.boardingStationName} (${trip.boardingStation})');
    print('   - To: ${trip.dropStationName} (${trip.dropStation})');
    print('   - Fare: ${trip.fare}');
    print('   - Total Amount: ${trip.totalAmount}');
    print('   - Passengers: ${trip.numberOfPassengers}');
    print('   - Status: ${trip.status}');
    print('   - Payment Status: ${trip.paymentStatus}');

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const AppBottomNavBar(currentRoute: '/home'),
      body: SafeArea(
        child: Column(
          children: [
            // Custom Status Bar
            const CustomStatusBar(),

            // Header with back button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  const CustomBackButton(),
                  const SizedBox(width: 16),
                  const Text(
                    'Trip QR Code',
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
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Success message
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E8),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade300),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Trip Created Successfully!',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Trip Code: ${trip.tripCode}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF2C3E50),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Trip details
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Trip Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildDetailRow(
                              'From',
                              trip.boardingStationName.isNotEmpty
                                  ? trip.boardingStationName
                                  : 'Unknown Station'),
                          const SizedBox(height: 8),
                          _buildDetailRow(
                              'To',
                              trip.dropStationName.isNotEmpty
                                  ? trip.dropStationName
                                  : 'Unknown Station'),
                          const SizedBox(height: 8),
                          _buildDetailRow(
                              'Passengers', '${trip.numberOfPassengers}'),
                          const SizedBox(height: 8),
                          _buildDetailRow('Fare per Person', '\৳${trip.fare}'),
                          const SizedBox(height: 8),
                          _buildDetailRow(
                              'Total Amount', '\৳${trip.totalAmount}'),
                          const SizedBox(height: 8),
                          _buildDetailRow('Status', trip.status.toUpperCase())
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // QR Code
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade200,
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Scan this QR Code',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Show this to the metro staff',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 20),
                          QrImageView(
                            data: trip.tripCode,
                            version: QrVersions.auto,
                            size: 200.0,
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF2C3E50),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Trip Code: ${trip.tripCode}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF2C3E50),
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              // Pop back to the previous screen (home screen)
                              Navigator.of(context).pop();
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(color: Color(0xFF20B2AA)),
                            ),
                            child: const Text(
                              'Return Home',
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
                            onPressed: () async {
                              try {
                                // Show loading indicator
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Row(
                                      children: [
                                        SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white),
                                          ),
                                        ),
                                        SizedBox(width: 16),
                                        Text('Downloading QR Code...'),
                                      ],
                                    ),
                                    backgroundColor: Color(0xFF20B2AA),
                                    duration: Duration(seconds: 2),
                                  ),
                                );

                                // Download the QR code
                                await QRDownloadService.downloadQRCode(
                                  tripCode: trip.tripCode,
                                  fromStation:
                                      trip.boardingStationName.isNotEmpty
                                          ? trip.boardingStationName
                                          : 'Unknown Station',
                                  toStation: trip.dropStationName.isNotEmpty
                                      ? trip.dropStationName
                                      : 'Unknown Station',
                                  fare: trip.fare,
                                  totalAmount: trip.totalAmount,
                                  passengers: trip.numberOfPassengers,
                                  status: trip.status,
                                );

                                // Show success message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'QR Code downloaded successfully!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } catch (e) {
                                // Show error message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Failed to download QR Code: ${e.toString()}'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF34495E),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text(
                              'Download QR Code',
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2C3E50),
          ),
        ),
      ],
    );
  }
}
