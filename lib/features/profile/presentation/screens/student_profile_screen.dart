import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/data/auth_repository.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/enums.dart';
import '../../../auth/application/auth_provider.dart';

class StudentProfileScreen extends ConsumerStatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  ConsumerState<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends ConsumerState<StudentProfileScreen> {
  final _addressController = TextEditingController();
  bool _isEditingAddress = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill the address controller when the screen loads
    final user = ref.read(currentUserProvider);
    if (user != null) {
      _addressController.text = user.homeAddress;
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  void _saveAddress() async {
    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Address cannot be empty'), backgroundColor: AppColors.error),
      );
      return;
    }

    // Grab the current user to get their UID
    final user = ref.read(currentUserProvider);

    if (user != null) {
      try {
        // 1. Update the database repository (Passing BOTH uid and the new address)
        await ref.read(authRepositoryProvider).updateHomeAddress(
            user.uid,
            _addressController.text.trim()
        );

        // 2. Invalidate the provider so the app globally updates with the new address
        ref.invalidate(currentUserProvider);

        if (mounted) {
          setState(() {
            _isEditingAddress = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Home address updated successfully!'), backgroundColor: AppColors.success),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update: $e'), backgroundColor: AppColors.error),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 1. Profile Header
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.person, size: 60, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Text(user.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  Text('UID: ${user.uid}', style: const TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 2. Academic Details (Read-Only)
            _buildSectionHeader('Academic Details', Icons.school),
            _buildDataCard([
              _buildDataRow('Course', user.course),
              _buildDataRow('Department', user.department),
            ]),

            // 3. Hostel Details (Read-Only)
            _buildSectionHeader('Hostel Allocation', Icons.meeting_room),
            _buildDataCard([
              _buildDataRow('Hostel', user.hostelName == HostelType.boys ? 'Boys Hostel' : 'Girls Hostel'),
              _buildDataRow('Room Number', user.roomNumber, highlight: true),
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text('* Room assignments are managed by the Warden.', style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontStyle: FontStyle.italic)),
              ),
            ]),

            // 4. Contact Details (Read-Only)
            _buildSectionHeader('Contact Details', Icons.phone),
            _buildDataCard([
              _buildDataRow('Student Mobile', '+91 ${user.mobileNumber}'),
              const Divider(),
              _buildDataRow('Father\'s Name', user.fatherName),
              _buildDataRow('Father\'s Mobile', '+91 ${user.fatherMobileNumber}'),
              const Divider(),
              _buildDataRow('Mother\'s Name', user.motherName),
              _buildDataRow('Mother\'s Mobile', '+91 ${user.motherMobileNumber}'),
            ]),

            // 5. Home Address (Editable)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionHeader('Home Address', Icons.home),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _isEditingAddress = !_isEditingAddress;
                    });
                  },
                  icon: Icon(_isEditingAddress ? Icons.close : Icons.edit, size: 18),
                  label: Text(_isEditingAddress ? 'Cancel' : 'Edit'),
                )
              ],
            ),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: _isEditingAddress ? AppColors.primary : Colors.grey.shade300),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextField(
                      controller: _addressController,
                      enabled: _isEditingAddress,
                      maxLines: 3,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter your full permanent address...',
                        fillColor: _isEditingAddress ? Colors.grey.shade50 : Colors.transparent,
                        filled: true,
                      ),
                    ),
                    if (_isEditingAddress) ...[
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _saveAddress,
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                        child: const Text('Save Address'),
                      ),
                    ]
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- UI HELPERS ---

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildDataCard(List<Widget> children) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontWeight: highlight ? FontWeight.bold : FontWeight.w500,
                color: highlight ? AppColors.primary : AppColors.textPrimary,
                fontSize: 14,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}