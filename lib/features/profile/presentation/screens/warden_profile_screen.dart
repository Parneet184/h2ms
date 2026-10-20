import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../auth/application/auth_provider.dart';
import '../../../auth/presentation/change_password_screen.dart';

class WardenProfileScreen extends ConsumerWidget {
  const WardenProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the current logged-in user (The Warden)
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Warden Profile'),
        elevation: 0,
        backgroundColor: AppColors.primary,
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // --- 1. PROFILE PICTURE & HEADER ---
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: const CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.primaryLight,
                child: Icon(Icons.admin_panel_settings, size: 50, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user?.name.toUpperCase() ?? 'WARDEN NAME',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary, letterSpacing: 0.5),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'EID: ${user?.uid ?? 'N/A'}',
                style: const TextStyle(fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 32),

            // --- 2. ASSIGNMENT DETAILS ---
            _buildInfoCard(
              title: 'Hostel Assignment',
              icon: Icons.apartment,
              children: [
                _buildInfoRow('Assigned Hostel', user?.hostelName.name.toUpperCase() ?? 'N/A'),
                const Divider(height: 24),
                _buildInfoRow('Role', 'Chief Warden'),
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
                _buildInfoRow('Official Email', '${user?.uid.toLowerCase()}@university.edu'),
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

                  // 2. GoRouter will instantly pop this screen and send the user to /login
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

  // --- UI HELPERS ---

  Widget _buildInfoCard({required String title, required IconData icon, required List<Widget> children}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(icon, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
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
          child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
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