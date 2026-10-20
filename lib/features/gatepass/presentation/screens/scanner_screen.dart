import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/enums.dart';
import '../../domain/pass_model.dart';
import 'pass_verification_screen.dart';

class ScannerScreen extends StatelessWidget {
  const ScannerScreen({super.key});

  void _simulateSuccessfulScan(BuildContext context) {
    final mockScannedPass = PassModel(
      id: 'pass_999',
      studentUid: '23F06012',
      studentName: 'Gursajanpreet Singh',
      roomNumber: '101',
      type: PassType.gatepass,
      status: PassStatus.approved,
      reason: 'Going to the market for groceries',
      requestedOutTime: DateTime.now().subtract(const Duration(minutes: 5)),
      expectedInTime: DateTime.now().add(const Duration(hours: 2)),
    );

    // Uses pushReplacement so this scanner screen is removed from the back-stack
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => PassVerificationScreen(pass: mockScannedPass)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Clean white background
      appBar: AppBar(
        title: const Text('Scan QR Code', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        elevation: 0,
      ),
      body: Center( // Perfectly centers everything vertically and horizontally
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Scanning the QR...',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            const SizedBox(height: 40),

            // Scanner Frame & Laser
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.primary, width: 4),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(color: AppColors.primary.withOpacity(0.15), blurRadius: 30, spreadRadius: 10),
                      ]
                  ),
                ),
                // Simulated Scanning Laser Line
                Container(
                  width: 240,
                  height: 3,
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    boxShadow: [
                      BoxShadow(color: Colors.redAccent, blurRadius: 10, spreadRadius: 2)
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            const Text(
              'Align the student\'s QR code within the frame.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
            const SizedBox(height: 60),

            // Override Button
            ElevatedButton.icon(
              onPressed: () => _simulateSuccessfulScan(context),
              icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
              label: const Text('Simulate Successful Scan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}