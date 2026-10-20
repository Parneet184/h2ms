import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../auth/application/auth_provider.dart';
import '../../../auth/presentation/change_password_screen.dart';

class GuardProfileScreen extends ConsumerWidget {
  const GuardProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fetch current logged-in user details
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // --- 1. PROFILE PICTURE & HEADER ---
            const CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.security, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              user?.name ?? 'Security Officer',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              'Guard ID: ${user?.uid ?? 'N/A'}',
              style: const TextStyle(fontSize: 16, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 32),

            // --- 2. ASSIGNMENT DETAILS ---
            _buildInfoCard(
              title: 'Duty Assignment',
              icon: Icons.shield_outlined,
              children: [
                _buildInfoRow('Assigned Post', '${user?.hostelName.name.toUpperCase() ?? 'HOSTEL'} Gate'),
                const Divider(height: 24),
                _buildInfoRow('Shift Timings', '08:00 AM - 08:00 PM'),
              ],
            ),
            const SizedBox(height: 16),

            // --- 3. CONTACT DETAILS ---
            _buildInfoCard(
              title: 'Contact Information',
              icon: Icons.contact_phone_outlined,
              children: [
                _buildInfoRow('Mobile Number', user?.mobileNumber ?? 'N/A'),
                const Divider(height: 24),
                _buildInfoRow('Emergency Intercom', 'Ext: 402'),
              ],
            ),
            const SizedBox(height: 32),

            // --- 4. ACTIONS ---
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangePasswordScreen()));
                },
                icon: const Icon(Icons.vpn_key_outlined, color: AppColors.primary),
                label: const Text('Change Password', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: AppColors.primary.withOpacity(0.5)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- THE WORKING LOGOUT BUTTON ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // 1. Tell Riverpod to destroy the session!
                  ref.read(authNotifierProvider.notifier).logout();

                  // 2. GoRouter will instantly intercept the state change and route to /login
                },
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text('Logout Securely', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- UI HELPERS (Preserved from your original design) ---

  Widget _buildInfoCard({required String title, required IconData icon, required List<Widget> children}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              ],
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}