import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:screenshot/screenshot.dart';

class QRDownloadService {
  static Future<void> downloadQRCode({
    required String tripCode,
    required String fromStation,
    required String toStation,
    required int fare,
    required int totalAmount,
    required int passengers,
    required String status,
  }) async {
    try {
      // Request appropriate permissions based on Android version
      bool permissionGranted = false;

      // For Android 13+ (API 33+), use READ_MEDIA_IMAGES
      if (await Permission.photos.status.isGranted) {
        permissionGranted = true;
      } else {
        final photosStatus = await Permission.photos.request();
        permissionGranted = photosStatus.isGranted;
      }

      // Fallback to storage permission for older Android versions
      if (!permissionGranted) {
        if (await Permission.storage.status.isGranted) {
          permissionGranted = true;
        } else {
          final storageStatus = await Permission.storage.request();
          permissionGranted = storageStatus.isGranted;
        }
      }

      if (!permissionGranted) {
        throw Exception(
            'Storage permission is required to save the QR code. Please grant permission in Settings.');
      }

      // Create the QR code widget with proper layout
      final qrWidget = _buildQRCodeWidget(
        tripCode: tripCode,
        fromStation: fromStation,
        toStation: toStation,
        fare: fare,
        totalAmount: totalAmount,
        passengers: passengers,
        status: status,
      );

      // Use screenshot package to capture the widget
      final screenshotController = ScreenshotController();
      final imageBytes = await screenshotController.captureFromWidget(
        qrWidget,
        delay: const Duration(milliseconds: 10),
        pixelRatio: 3.0,
      );

      // Save to gallery
      final result = await ImageGallerySaver.saveImage(
        imageBytes,
        quality: 100,
        name:
            'metro_ticket_${tripCode}_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (result['isSuccess'] == true) {
        print('✅ QR code saved successfully: ${result['filePath']}');
      } else {
        final errorMessage = result['errorMessage'] ?? 'Unknown error occurred';
        throw Exception('Failed to save QR code to gallery: $errorMessage');
      }
    } catch (e) {
      print('❌ Error downloading QR code: $e');

      // Provide more specific error messages
      String errorMessage = 'Failed to download QR code';
      if (e.toString().contains('permission')) {
        errorMessage =
            'Permission denied. Please grant storage permission in Settings.';
      } else if (e.toString().contains('gallery')) {
        errorMessage =
            'Failed to save to gallery. Please check your device storage.';
      } else if (e.toString().contains('screenshot')) {
        errorMessage = 'Failed to generate QR code image.';
      }

      throw Exception(errorMessage);
    }
  }

  static Widget _buildQRCodeWidget({
    required String tripCode,
    required String fromStation,
    required String toStation,
    required int fare,
    required int totalAmount,
    required int passengers,
    required String status,
  }) {
    return Container(
      width: 400,
      height: 600,
      color: Colors.white,
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Header
          const Text(
            'Rapid Metro Pass Ticket',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),

          // Trip details card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: [
                _buildDetailRow('From', fromStation),
                const SizedBox(height: 8),
                _buildDetailRow('To', toStation),
                const SizedBox(height: 8),
                _buildDetailRow('Passengers', '$passengers'),
                const SizedBox(height: 8),
                _buildDetailRow('Fare per Person', '৳$fare'),
                const SizedBox(height: 8),
                _buildDetailRow('Total Amount', '৳$totalAmount'),
                const SizedBox(height: 8),
                _buildDetailRow('Status', status.toUpperCase()),
              ],
            ),
          ),
          const SizedBox(height: 30),

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
                QrImageView(
                  data: tripCode,
                  version: QrVersions.auto,
                  size: 200.0,
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF2C3E50),
                ),
                const SizedBox(height: 16),
                Text(
                  'Trip Code: $tripCode',
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
          const SizedBox(height: 20),

          // Subtitle
          const Text(
            'Scan this code in the metro station to visit',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  static Widget _buildDetailRow(String label, String value) {
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
