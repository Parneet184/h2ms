import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../auth/application/auth_provider.dart';

class UploadCsvScreen extends ConsumerStatefulWidget {
  const UploadCsvScreen({super.key});

  @override
  ConsumerState<UploadCsvScreen> createState() => _UploadCsvScreenState();
}

class _UploadCsvScreenState extends ConsumerState<UploadCsvScreen> {
  bool _isUploading = false;
  int _uploadedCount = 0;

  // Simulating the file picking and parsing process
  Future<void> _simulateCsvUpload() async {
    setState(() {
      _isUploading = true;
    });

    // Simulate network/parsing delay (3 seconds)
    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      _isUploading = false;
      _uploadedCount = 452; // Dummy number of students parsed
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Success! $_uploadedCount student records imported.'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Control Panel'),
        elevation: 0,
      ),
      drawer: _buildDrawer(context, user?.name ?? 'Super Admin'),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Bulk Onboard Students',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Upload a CSV file to automatically create accounts and assign hostel rooms for the new semester.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 40),

            // The Upload "Dropzone" Area
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.05),
                border: Border.all(
                  color: AppColors.primaryLight.withOpacity(0.5),
                  width: 2,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(
                    _isUploading ? Icons.cloud_sync : Icons.cloud_upload_outlined,
                    size: 80,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  if (_isUploading)
                    const Column(
                      children: [
                        CircularProgressIndicator(color: AppColors.primary),
                        SizedBox(height: 16),
                        Text('Parsing CSV and generating accounts...', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                      ],
                    )
                  else
                    Column(
                      children: [
                        const Text(
                          'Select a .csv file from your device',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Required columns: UID, Name, Email, Room, Block',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _simulateCsvUpload,
                          icon: const Icon(Icons.folder_open, color: Colors.white),
                          label: const Text('Browse Files', style: TextStyle(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            const Spacer(),

            // Statistics / Status Area
            if (_uploadedCount > 0 && !_isUploading)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: AppColors.success),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'System is up to date. $_uploadedCount active students in database.',
                        style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Admin Drawer
  Drawer _buildDrawer(BuildContext context, String name) {
    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, bottom: 20),
            color: AppColors.primary,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.admin_panel_settings, size: 40, color: AppColors.primary),
                ),
                const SizedBox(height: 12),
                Text(
                  name.toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                const Text('System Administrator', style: TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
          ListTile(leading: const Icon(Icons.upload_file), title: const Text('Upload Data'), onTap: () {}),
          ListTile(leading: const Icon(Icons.people), title: const Text('Manage Staff'), onTap: () {}),
          ListTile(leading: const Icon(Icons.settings), title: const Text('System Settings'), onTap: () {}),
          const Divider(),
          ListTile(leading: const Icon(Icons.logout, color: Colors.red), title: const Text('Logout', style: TextStyle(color: Colors.red)), onTap: () {}),
        ],
      ),
    );
  }
}