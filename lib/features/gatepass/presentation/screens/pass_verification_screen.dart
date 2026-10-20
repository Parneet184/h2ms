import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/enums.dart';
import '../../domain/pass_model.dart';

class PassVerificationScreen extends StatelessWidget {
  final PassModel pass;

  const PassVerificationScreen({super.key, required this.pass});

  @override
  Widget build(BuildContext context) {
    final bool isCheckingOut = pass.status == PassStatus.approved;
    final bool isCheckingIn = pass.status == PassStatus.active;
    final bool isInvalid = !isCheckingOut && !isCheckingIn;

    // We now use Green (success) for everything unless it is invalid (error/red).
    final Color statusColor = isInvalid ? AppColors.error : AppColors.success;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pass Verification'),
        backgroundColor: statusColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // --- 1. STATUS BANNER ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: statusColor, width: 2),
              ),
              child: Column(
                children: [
                  Icon(
                    isInvalid ? Icons.cancel : Icons.check_circle,
                    size: 48,
                    color: statusColor,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isInvalid
                        ? 'INVALID OR EXPIRED PASS'
                        : (isCheckingOut ? 'VALID: READY FOR DEPARTURE' : 'VALID: READY FOR RETURN'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // --- 2. STUDENT PROFILE ---
            const CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(pass.studentName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text('UID: ${pass.studentUid} • Room ${pass.roomNumber}', style: const TextStyle(fontSize: 16, color: AppColors.textSecondary)),
            const SizedBox(height: 32),

            // --- 3. PASS DETAILS ---
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Pass Type', pass.type.name.toUpperCase()),
                    const Divider(height: 24),
                    _buildDetailRow('Reason', pass.reason),
                    const Divider(height: 24),
                    _buildDetailRow('Requested Out', _formatDateTime(pass.requestedOutTime)),
                    const Divider(height: 24),
                    _buildDetailRow('Expected In', _formatDateTime(pass.expectedInTime)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            // --- 4. ACTION BUTTON ---
            if (!isInvalid)
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isCheckingOut ? 'Student Checked OUT successfully!' : 'Student Checked IN successfully!'),
                        backgroundColor: AppColors.success,
                      ),
                    );

                    // FIXED: Because we used pushReplacement earlier, popping ONCE takes us back to the Dashboard!
                    Navigator.pop(context);
                  },
                  icon: Icon(isCheckingOut ? Icons.output : Icons.login, color: Colors.white, size: 28),
                  label: Text(
                    isCheckingOut ? 'CONFIRM CHECK-OUT' : 'CONFIRM CHECK-IN',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success, // Changed to solid Green
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
        ),
        Expanded(
          flex: 3,
          child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary), textAlign: TextAlign.right),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dt) {
    final time = TimeOfDay.fromDateTime(dt);
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    return '${dt.day}/${dt.month} at $hour:$minute $period';
  }
}