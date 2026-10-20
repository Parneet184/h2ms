import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/enums.dart';
import '../../auth/application/auth_provider.dart';
import '../../profile/presentation/screens/warden_profile_screen.dart';
import '../../warden/presentation/screens/warden_gatepass_screen.dart';
import '../../warden/presentation/screens/warden_leave_form_screen.dart';
import '../../warden/presentation/screens/live_roster_screen.dart';
import '../../warden/presentation/screens/mark_attendance_screen.dart';
import '../../warden/presentation/screens/attendance_stats_screen.dart';
import '../../warden/presentation/screens/hostel_records_screen.dart';
import '../../warden/presentation/screens/hostel_stats_screen.dart';
import '../../warden/presentation/screens/inventory_manager_screen.dart';
import '../../warden/presentation/screens/hostel_complaints_screen.dart';
import '../../warden/presentation/screens/broadcast_notice_screen.dart';
import '../../warden/presentation/screens/edit_rules_screen.dart';
import '../../warden/presentation/screens/warden_sos_screen.dart';
import '../../warden/application/warden_stats_providers.dart';

class WardenDashboard extends ConsumerWidget {
  const WardenDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isBoysHostel = user?.hostelName == HostelType.boys;
    final hostelLabel = isBoysHostel ? "Boys Hostel" : "Girls Hostel";

    // Watch live operational counts from Supabase
    final gatepassAsync = ref.watch(pendingGatepassesCountProvider);
    final leaveAsync = ref.watch(pendingLeaveFormsCountProvider);
    final sosAsync = ref.watch(activeSosCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Warden Command Center'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WardenProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. WARDEN HEADER ---
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: isBoysHostel ? AppColors.primary : Colors.pink.shade400,
                  child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? 'Warden',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      Text(
                        'Chief Warden • $hostelLabel',
                        style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // --- 2. URGENT ACTIONS (Red/Orange) ---
            _buildSectionHeader('Action Required'),
            const SizedBox(height: 12),

            // SOS Full Width Banner with Live Count
            sosAsync.when(
              data: (sosCount) => InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const WardenSosScreen()),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.error, width: 2),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_rounded, color: AppColors.error, size: 32),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('SOS / Overdue Escalations', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 16)),
                            Text('$sosCount Open Issues require immediate attention', style: const TextStyle(color: AppColors.error, fontSize: 13)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: AppColors.error),
                    ],
                  ),
                ),
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 12),

            // Gatepass & Leave Form Cards with Live Counts
            Row(
              children: [
                Expanded(
                  child: gatepassAsync.when(
                    data: (count) => _buildUrgentCard(
                      context,
                      title: 'Gatepasses',
                      count: count.toString(),
                      icon: Icons.directions_run,
                      color: AppColors.warning,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const WardenGatepassScreen()),
                        );
                      },
                    ),
                    loading: () => _buildUrgentCard(context, title: 'Gatepasses', count: '...', icon: Icons.directions_run, color: AppColors.warning, onTap: () {}),
                    error: (_, __) => _buildUrgentCard(context, title: 'Gatepasses', count: '!', icon: Icons.directions_run, color: AppColors.warning, onTap: () {}),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: leaveAsync.when(
                    data: (count) => _buildUrgentCard(
                      context,
                      title: 'Leave Forms',
                      count: count.toString(),
                      icon: Icons.flight_takeoff,
                      color: Colors.deepOrange,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const WardenLeaveFormScreen()),
                        );
                      },
                    ),
                    loading: () => _buildUrgentCard(context, title: 'Leave Forms', count: '...', icon: Icons.flight_takeoff, color: Colors.deepOrange, onTap: () {}),
                    error: (_, __) => _buildUrgentCard(context, title: 'Leave Forms', count: '!', icon: Icons.flight_takeoff, color: Colors.deepOrange, onTap: () {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // --- 3. STUDENT TRACKING (Daily Operations) ---
            _buildSectionHeader('Daily Tracking & Attendance'),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
              children: [
                _buildGridCard(context, 'Live Roster\n(Out/Leave)', Icons.radar, AppColors.primary, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LiveRosterScreen()),
                  );
                }),
                _buildGridCard(context, 'Mark\nAttendance', Icons.how_to_reg, AppColors.success, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MarkAttendanceScreen()),
                  );
                }),
                _buildGridCard(context, 'Attendance\nStats', Icons.analytics, AppColors.primaryLight, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const WardenAttendanceStatsScreen()),
                  );
                }),
              ],
            ),
            const SizedBox(height: 32),

            // --- 4. HOSTEL MANAGEMENT ---
            _buildSectionHeader('Hostel & Asset Management'),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
              children: [
                _buildGridCard(context, 'Hostel\nRecords', Icons.folder_shared, Colors.indigo, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HostelRecordsScreen()),
                  );
                }),
                _buildGridCard(context, 'Hostel\nStats', Icons.pie_chart, Colors.teal, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HostelStatsScreen()),
                  );
                }),
                _buildGridCard(context, 'Inventory\nManager', Icons.inventory, Colors.brown, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const InventoryManagerScreen()),
                  );
                }),
              ],
            ),
            const SizedBox(height: 32),

            // --- 5. ADMINISTRATION & COMMUNICATION ---
            _buildSectionHeader('Administration & Communication'),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildListTile(context, 'Student Complaints', Icons.report_problem, AppColors.error, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HostelComplaintsScreen()),
                    );
                  }),
                  const Divider(height: 1),
                  _buildListTile(context, 'Broadcast Announcements', Icons.campaign, AppColors.primary, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const BroadcastNoticeScreen()),
                    );
                  }),
                  const Divider(height: 1),
                  _buildListTile(context, 'Edit Rules & Regulations', Icons.gavel, Colors.deepPurple, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const EditRulesScreen()),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- UI HELPERS ---

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary, letterSpacing: 0.5),
    );
  }

  Widget _buildUrgentCard(BuildContext context, {required String title, required String count, required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 28),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
                  child: Text(count, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 15, height: 1.2)),
          ],
        ),
      ),
    );
  }

  Widget _buildGridCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          border: Border.all(color: color.withValues(alpha: 0.2)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
    );
  }
}