import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../auth/application/auth_provider.dart';

class RoomChangeRequestScreen extends ConsumerStatefulWidget {
  const RoomChangeRequestScreen({super.key});

  @override
  ConsumerState<RoomChangeRequestScreen> createState() => _RoomChangeRequestScreenState();
}

class _RoomChangeRequestScreenState extends ConsumerState<RoomChangeRequestScreen> {
  final _formKey = GlobalKey<FormState>();

  final _specificRoomController = TextEditingController();
  final _detailsController = TextEditingController();

  String? _selectedReason;
  String _targetRoomPreference = 'any'; // 'any' or 'specific'

  final List<String> _reasons = [
    'Roommate incompatibility',
    'Upgrading to AC room',
    'Downgrading to Non-AC room',
    'Medical reasons',
    'Maintenance issues in current room',
    'Other'
  ];

  @override
  void dispose() {
    _specificRoomController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  void _submitRequest() {
    if (_formKey.currentState!.validate()) {
      if (_selectedReason == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a reason.'), backgroundColor: AppColors.error),
        );
        return;
      }

      if (_targetRoomPreference == 'specific' && _specificRoomController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter the specific room number.'), backgroundColor: AppColors.error),
        );
        return;
      }

      // In a real app, you would send this to Supabase/Backend here.
      // final user = ref.read(currentUserProvider);
      // final requestData = {
      //   'uid': user?.uid,
      //   'currentRoom': user?.roomNumber,
      //   'reason': _selectedReason,
      //   'target': _targetRoomPreference == 'any' ? 'Any' : _specificRoomController.text,
      //   'details': _detailsController.text,
      // };

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Room change request submitted to the Warden.'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Room Change'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. Current Room Info Banner ---
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryLight.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.meeting_room, color: AppColors.primary, size: 28),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Current Allocation', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                          Text('Room ${user?.roomNumber ?? 'Unassigned'}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // --- 2. Reason Dropdown ---
              const Text('Reason for Change', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedReason,
                hint: const Text('Select a primary reason...'),
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: AppColors.surface,
                ),
                items: _reasons.map((reason) {
                  return DropdownMenuItem(value: reason, child: Text(reason));
                }).toList(),
                onChanged: (value) => setState(() => _selectedReason = value),
              ),
              const SizedBox(height: 24),

              // --- 3. Target Room Preference ---
              const Text('Room Preference', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.background,
                ),
                child: Column(
                  children: [
                    RadioListTile<String>(
                      title: const Text('Any available room'),
                      subtitle: const Text('Warden will assign based on availability', style: TextStyle(fontSize: 12)),
                      value: 'any',
                      groupValue: _targetRoomPreference,
                      activeColor: AppColors.primary,
                      onChanged: (value) => setState(() => _targetRoomPreference = value!),
                    ),
                    const Divider(height: 1),
                    RadioListTile<String>(
                      title: const Text('Specific Room'),
                      subtitle: const Text('I have a specific room or block in mind', style: TextStyle(fontSize: 12)),
                      value: 'specific',
                      groupValue: _targetRoomPreference,
                      activeColor: AppColors.primary,
                      onChanged: (value) => setState(() => _targetRoomPreference = value!),
                    ),
                  ],
                ),
              ),

              // Dynamic Field: Only show if they select "Specific Room"
              if (_targetRoomPreference == 'specific') ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _specificRoomController,
                  decoration: InputDecoration(
                    hintText: 'E.g., Room 204, Block B',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: AppColors.surface,
                    prefixIcon: const Icon(Icons.sensor_door, color: AppColors.textSecondary),
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // --- 4. Additional Details ---
              const Text('Additional Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _detailsController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Please explain your situation or list any specific requirements (e.g., ground floor needed due to injury)...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: AppColors.surface,
                ),
                validator: (value) => (value == null || value.trim().length < 10) ? 'Please provide a bit more detail' : null,
              ),
              const SizedBox(height: 40),

              // --- 5. Submit Button ---
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Submit Request', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}