import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../auth/application/auth_provider.dart';
import '../../gatepass/presentation/screens/scanner_screen.dart';
import '../../gatepass/presentation/screens/manual_entry_screen.dart';
import '../../gatepass/presentation/screens/active_passes_screen.dart';
import '../../gatepass/presentation/screens/overdue_students_screen.dart';
import '../../gatepass/presentation/screens/medical_emergency_screen.dart'; // Adjusted path to match your setup
import '../../profile/presentation/screens/guard_profile_screen.dart';

class GuardDashboard extends ConsumerWidget {
  const GuardDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Post'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const GuardProfileScreen()));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- GUARD PROFILE HEADER (Static, non-clickable) ---
            Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.security, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Officer ${user?.name.split(' ')[0] ?? 'Guard'}',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      Text(
                        'ID: ${user?.uid} • Main Gate',
                        style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // --- PRIMARY ENTRY/EXIT CONTROLS ---
            Row(
              children: [
                Expanded(
                  child: _buildPrimaryButton(
                      context, 'Scan QR', Icons.qr_code_scanner, AppColors.primary,
                          () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ScannerScreen()))
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildPrimaryButton(
                      context, 'Manual Entry', Icons.keyboard, AppColors.warning,
                          () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ManualEntryScreen()))
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text('Monitoring Dashboard', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 16),

            // --- MONITORING GRID ---
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.0,
                children: [
                  _buildGridCard(
                    context, title: 'Active\nGatepasses', icon: Icons.directions_run, color: AppColors.success, badgeCount: '42',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ActivePassesScreen(isLeave: false))),
                  ),
                  _buildGridCard(
                    context, title: 'Active\nLeave Forms', icon: Icons.flight_takeoff, color: AppColors.primaryLight, badgeCount: '15',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ActivePassesScreen(isLeave: true))),
                  ),
                  _buildGridCard(
                    context, title: 'Overdue\nStudents', icon: Icons.warning_amber_rounded, color: AppColors.warning, badgeCount: '3',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const OverdueStudentsScreen())),
                  ),
                  _buildGridCard(
                    context, title: 'Medical\nEmergency', icon: Icons.medical_services, color: AppColors.error,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MedicalEmergencyScreen())),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white),
      label: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildGridCard(BuildContext context, {required String title, required IconData icon, required Color color, required VoidCallback onTap, String? badgeCount}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          border: Border.all(color: color.withOpacity(0.4)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 40, color: color),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color, height: 1.2),
                  ),
                ],
              ),
            ),
            if (badgeCount != null)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
                  child: Text(badgeCount, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}