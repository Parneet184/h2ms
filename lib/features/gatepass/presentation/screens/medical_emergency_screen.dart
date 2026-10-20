import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../warden/application/sos_providers.dart';
import '../../../warden/domain/sos_alert_model.dart';

class MedicalEmergencyScreen extends ConsumerStatefulWidget {
  const MedicalEmergencyScreen({super.key});

  @override
  ConsumerState<MedicalEmergencyScreen> createState() => _MedicalEmergencyScreenState();
}

class _MedicalEmergencyScreenState extends ConsumerState<MedicalEmergencyScreen> {
  final _uidController = TextEditingController();
  final _detailsController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isSearching = false;
  bool _studentFound = false;
  String _mockName = '';
  String _mockRoom = '';

  @override
  void dispose() {
    _uidController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  void _searchStudent() {
    if (_uidController.text.trim().isEmpty) return;

    setState(() {
      _isSearching = true;
      _studentFound = false;
    });

    // Fast network lookup simulation (can be linked to your user repository search)
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _isSearching = false;
          _studentFound = true;
          _mockName = 'Student ${_uidController.text.toUpperCase()}';
          _mockRoom = '101'; // Mock or fetched room number
        });
      }
    });
  }

  Future<void> _dispatchAlert() async {
    if (_formKey.currentState!.validate()) {
      if (!_studentFound) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please look up a student first.'), backgroundColor: AppColors.error),
        );
        return;
      }

      try {
        // Create live SOS model payload for Supabase
        final newAlert = SosAlertModel(
          id: '', // Supabase generates UUID
          type: SosType.medical,
          title: 'Medical Emergency: $_mockName',
          description: _detailsController.text.trim(),
          location: 'Room $_mockRoom',
          reportedBy: 'Security Guard',
          reportedAt: DateTime.now(),
          contactNumber: _uidController.text.trim(),
          status: SosStatus.active,
        );

        // Insert into Supabase table via repository
        await ref.read(sosRepositoryProvider).createAlert(newAlert);

        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.warning_rounded, color: AppColors.error, size: 32),
                  SizedBox(width: 8),
                  Text('ALERT DISPATCHED', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                ],
              ),
              content: Text('Warden and Medical Officer have been notified immediately about $_mockName in Room $_mockRoom.'),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Go back to Guard Dashboard
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                  child: const Text('Understood', style: TextStyle(color: Colors.white)),
                )
              ],
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to dispatch alert: $e'), backgroundColor: AppColors.error),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Emergency'),
        backgroundColor: AppColors.error,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Emergency Contacts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildCallButton('Ambulance', Icons.local_hospital, Colors.red.shade700)),
                const SizedBox(width: 12),
                Expanded(child: _buildCallButton('Duty Doctor', Icons.medical_services, Colors.blue.shade700)),
                const SizedBox(width: 12),
                Expanded(child: _buildCallButton('Warden', Icons.admin_panel_settings, AppColors.warning)),
              ],
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 24),
            const Text('Dispatch SOS Alert', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.error)),
            const SizedBox(height: 8),
            const Text('Instantly notify administration about an injured or sick student.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _uidController,
                          decoration: InputDecoration(
                            hintText: 'Enter Student UID or Room No.',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: AppColors.surface,
                            prefixIcon: const Icon(Icons.badge, color: AppColors.textSecondary),
                          ),
                          onChanged: (val) {
                            if (_studentFound) setState(() => _studentFound = false);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isSearching ? null : _searchStudent,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _isSearching
                              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('Find', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_studentFound)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.person, color: AppColors.error, size: 28),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_mockName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text('Room $_mockRoom', style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _detailsController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Describe the situation briefly (e.g., Fainted, severe stomach pain, bleeding...)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: AppColors.surface,
                    ),
                    validator: (value) => (value == null || value.trim().isEmpty) ? 'Please provide a brief description' : null,
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton.icon(
                      onPressed: _dispatchAlert,
                      icon: const Icon(Icons.campaign, color: Colors.white, size: 28),
                      label: const Text('DISPATCH SOS', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                        shadowColor: AppColors.error.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallButton(String label, IconData icon, Color color) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Calling $label...')));
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          border: Border.all(color: color.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}