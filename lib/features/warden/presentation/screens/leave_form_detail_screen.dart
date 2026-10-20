import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/enums.dart';
import '../../../gatepass/data/pass_repository.dart';
import '../../../gatepass/application/pass_providers.dart';
import 'warden_leave_form_screen.dart';

class LeaveFormDetailScreen extends ConsumerStatefulWidget {
  final WardenLeaveFormModel leaveForm;

  const LeaveFormDetailScreen({super.key, required this.leaveForm});

  @override
  ConsumerState<LeaveFormDetailScreen> createState() => _LeaveFormDetailScreenState();
}

class _LeaveFormDetailScreenState extends ConsumerState<LeaveFormDetailScreen> {
  bool _isProcessing = false;

  void _simulateCall(String name, String number) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Dialing $name... ($number)'), backgroundColor: Colors.teal),
    );
  }

  Future<void> _approve() async {
    setState(() => _isProcessing = true);
    try {
      // 1. Update status in Supabase via PassRepository
      await ref.read(passRepositoryProvider).updatePassStatus(widget.leaveForm.id, PassStatus.approved);

      // 2. Invalidate providers to force live UI streams to refresh instantly
      ref.invalidate(pendingPassesProvider);
      ref.invalidate(approvedPassesProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Leave Form Approved!'), backgroundColor: AppColors.success),
        );
        Navigator.pop(context, 'approved');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _reject() async {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reject Leave Form', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Provide a reason for rejecting this leave:', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              TextField(
                controller: reasonController,
                autofocus: true,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'e.g., Parent verification failed',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (reasonController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reason is required to reject.')));
                  return;
                }

                Navigator.pop(context); // Close dialog
                setState(() => _isProcessing = true);

                try {
                  // 1. Update status in Supabase to rejected
                  await ref.read(passRepositoryProvider).updatePassStatus(widget.leaveForm.id, PassStatus.rejected);

                  // 2. Refresh providers
                  ref.invalidate(pendingPassesProvider);

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Leave Rejected: ${reasonController.text}'), backgroundColor: AppColors.error),
                    );
                    Navigator.pop(context, 'rejected');
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
                    );
                  }
                } finally {
                  if (mounted) setState(() => _isProcessing = false);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              child: const Text('Confirm Reject'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final leave = widget.leaveForm;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave Form Details'),
        backgroundColor: Colors.deepOrange,
      ),
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student Header
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.deepOrange.withValues(alpha: 0.1),
                  child: const Icon(Icons.person, size: 30, color: Colors.deepOrange),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(leave.studentName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      Text('UID: ${leave.uid} • ${leave.department}', style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: Colors.deepOrange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                        child: Text(leave.leaveType.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Details Container
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailItem('Room Number', leave.roomNumber, Icons.door_front_door_outlined),
                  const Divider(height: 24),
                  _buildDetailItem('Out Date & Time', '${leave.outDate} at ${leave.outTime}', Icons.flight_takeoff),
                  const Divider(height: 24),
                  _buildDetailItem('Expected In', '${leave.expectedInDate} at ${leave.expectedInTime}', Icons.flight_land),
                  const Divider(height: 24),
                  _buildDetailItem('Address During Leave', leave.address, Icons.home_work_outlined),
                  const Divider(height: 24),
                  _buildDetailItem('Reason', leave.reason, Icons.info_outline),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Verification Contacts
            const Text('Parent Verification Required', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
              child: Column(
                children: [
                  _buildContactRow('Student', leave.studentName, leave.studentContact),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),
                  _buildContactRow('Father', leave.fatherName, leave.fatherContact),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),
                  _buildContactRow('Mother', leave.motherName, leave.motherContact),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 55,
                  child: OutlinedButton(
                    onPressed: _isProcessing ? null : _reject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error, width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('REJECT', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _approve,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isProcessing
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('APPROVE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.deepOrange, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactRow(String relation, String name, String number) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$relation Contact', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              Text('$name ($number)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
        ),
        OutlinedButton.icon(
          onPressed: () => _simulateCall(name, number),
          icon: const Icon(Icons.call, size: 16, color: Colors.teal),
          label: const Text('Call', style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.teal),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        )
      ],
    );
  }
}