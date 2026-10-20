import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/enums.dart';
import '../../../gatepass/data/pass_repository.dart';

class GatepassDetailScreen extends ConsumerStatefulWidget {
  final dynamic gatepass; // Accepts WardenGatepassModel or PassModel safely

  const GatepassDetailScreen({super.key, required this.gatepass});

  @override
  ConsumerState<GatepassDetailScreen> createState() => _GatepassDetailScreenState();
}

class _GatepassDetailScreenState extends ConsumerState<GatepassDetailScreen> {

  void _simulateCall() {
    final contactNumber = widget.gatepass.contact ?? 'N/A';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Dialing ${widget.gatepass.studentName}... ($contactNumber)'), backgroundColor: Colors.teal),
    );
  }

  Future<void> _approve() async {
    try {
      await ref.read(passRepositoryProvider).updatePassStatus(widget.gatepass.id, PassStatus.approved);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gatepass Approved!'), backgroundColor: AppColors.success)
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
      }
    }
  }

  void _reject() {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reject Gatepass', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Please provide a reason for the student:', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              TextField(
                controller: reasonController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'e.g., Return time is too late',
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

                try {
                  await ref.read(passRepositoryProvider).updatePassStatus(widget.gatepass.id, PassStatus.rejected);

                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Gatepass Rejected: ${reasonController.text}'), backgroundColor: AppColors.error)
                    );
                    Navigator.pop(context);
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
                  }
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
    final gp = widget.gatepass;

    // Safely extract properties handling WardenGatepassModel naming conventions
    final displayContact = gp.contact ?? 'N/A';
    final displayRoom = gp.roomNumber ?? 'Unassigned';
    final displayUid = gp.uid ?? gp.studentUid ?? 'N/A';
    final displayDestination = gp.destination ?? gp.reason ?? 'N/A';
    final displayOutDate = gp.outDate ?? 'N/A';
    final displayOutTime = gp.outTime ?? 'N/A';
    final displayExpectedInTime = gp.expectedInTime ?? 'N/A';
    final displayReason = gp.reason ?? gp.destination ?? 'N/A';

    return Scaffold(
      appBar: AppBar(title: const Text('Gatepass Details')),
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
                  backgroundColor: AppColors.primaryLight.withValues(alpha: 0.2),
                  child: const Icon(Icons.person, size: 30, color: AppColors.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(gp.studentName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      Text('UID: $displayUid', style: const TextStyle(fontSize: 16, color: AppColors.textSecondary)),
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
                  _buildDetailItem('Room Number', displayRoom, Icons.door_front_door_outlined),
                  const Divider(height: 24),
                  _buildDetailItem('Destination', displayDestination, Icons.location_on_outlined),
                  const Divider(height: 24),
                  _buildDetailItem('Out Date', displayOutDate, Icons.calendar_today_outlined),
                  const Divider(height: 24),
                  _buildDetailItem('Out Time', displayOutTime, Icons.flight_takeoff),
                  const Divider(height: 24),
                  _buildDetailItem('Expected In Time', displayExpectedInTime, Icons.flight_land),
                  const Divider(height: 24),
                  _buildDetailItem('Reason', displayReason, Icons.info_outline),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Contact Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Student Contact', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      Text(displayContact, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  OutlinedButton.icon(
                    onPressed: _simulateCall,
                    icon: const Icon(Icons.call, size: 18, color: Colors.teal),
                    label: const Text('Call', style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.teal)),
                  )
                ],
              ),
            ),
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
                    onPressed: _reject,
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
                    onPressed: _approve,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('APPROVE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            ],
          ),
        ),
      ],
    );
  }
}