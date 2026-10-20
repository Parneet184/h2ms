import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../auth/application/auth_provider.dart';
import '../../gatepass/presentation/screens/request_pass_screen.dart';
import '../../hostel/presentation/screens/student_attendance_screen.dart';
import '../../mess/presentation/screens/daily_menu_screen.dart';
import '../../complaints/presentation/screens/complaints_feed_screen.dart';
import '../../profile/presentation/screens/student_profile_screen.dart';
import '../../auth/presentation/change_password_screen.dart';
import '../../gatepass/presentation/screens/gatepass_request_screen.dart';
import '../../gatepass/presentation/screens/leave_request_screen.dart';
import '../../notices/presentation/notices_list_screen.dart';
import '../../visitors/presentation/visitors_list_screen.dart';
import '../../hostel/presentation/screens/room_info_screen.dart';
import '../../mess/presentation/screens/weekly_menu_screen.dart';
import '../../hostel/presentation/screens/room_change_request_screen.dart';

class StudentDashboard extends ConsumerWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('University Hub'),
        elevation: 0,
      ),
      drawer: _buildDrawer(context, ref, user?.name ?? 'Student'),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- PREMIUM PROFILE HEADER ---
            _buildProfileHeader(
              name: user?.name ?? 'Student',
              uid: user?.uid ?? 'N/A',
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // --- QUICK ACTIONS CARD ---
                  _buildCategoryCard(
                    title: 'Quick Actions',
                    items: [
                      _GridItemData(icon: Icons.qr_code_scanner, label: 'Gatepass', screen: const GatepassRequestScreen()),
                      _GridItemData(icon: Icons.edit_document, label: 'Apply Leave', screen: const LeaveRequestScreen()),
                      _GridItemData(icon: Icons.campaign, label: 'Notices', screen: const NoticesListScreen()),
                    ],
                  ),

                  // --- HOSTEL SERVICES CARD ---
                  _buildCategoryCard(
                    title: 'Hostel Services',
                    items: [
                      _GridItemData(icon: Icons.calendar_today, label: 'Attendance', screen: const StudentAttendanceScreen()),
                      _GridItemData(icon: Icons.report_problem, label: 'Complaints', screen: const ComplaintsFeedScreen(isMessIssue: false)),
                      _GridItemData(icon: Icons.people_alt, label: 'Visitors', screen: const VisitorsListScreen()),
                      _GridItemData(icon: Icons.meeting_room, label: 'Room Info', screen: const RoomInfoScreen()),
                      _GridItemData(icon: Icons.swap_horiz, label: 'Change Room', screen: const RoomChangeRequestScreen()),
                    ],
                  ),

                  // --- MESS SERVICES CARD ---
                  _buildCategoryCard(
                    title: 'Mess Services',
                    items: [
                      _GridItemData(icon: Icons.restaurant_menu, label: 'Today\'s Menu', screen: const WeeklyMenuScreen()),
                      _GridItemData(icon: Icons.star_rate, label: 'Rate Food', screen: const DailyMenuScreen()),
                      _GridItemData(icon: Icons.feedback, label: 'Mess Issues', screen: const ComplaintsFeedScreen(isMessIssue: true)),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildProfileHeader({required String name, required String uid}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const CircleAvatar(
              radius: 32,
              backgroundColor: AppColors.primaryLight,
              child: Icon(Icons.person, size: 36, color: Colors.white),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Welcome back,', style: TextStyle(color: Colors.white70, fontSize: 14)),
                Text(
                  name.toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                  child: Text('UID: $uid', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard({required String title, required List<_GridItemData> items}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,         // Back to 4 columns!
              crossAxisSpacing: 10,      // Spacing between columns
              mainAxisSpacing: 16,       // Spacing between rows
              childAspectRatio: 0.82,    // CRUCIAL FIX: Taller aspect ratio prevents text squishing
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  if (item.screen != null) {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => item.screen!));
                  }
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Icon in a premium rounded-rectangle box
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(item.icon, size: 26, color: AppColors.primary),
                    ),
                    const SizedBox(height: 8),
                    // Centered Text
                    Text(
                      item.label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 11, // Smaller font for 4 columns
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          height: 1.2
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context, WidgetRef ref, String name) {
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
                  child: Icon(Icons.person, size: 40, color: AppColors.primary),
                ),
                const SizedBox(height: 12),
                Text(
                  name.toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const StudentProfileScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.vpn_key_outlined),
            title: const Text('Change Password'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangePasswordScreen()));
            },
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.pop(context);
              ref.read(authNotifierProvider.notifier).logout();
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// Clean data model binding the label directly to the target screen
class _GridItemData {
  final IconData icon;
  final String label;
  final Widget? screen;

  _GridItemData({required this.icon, required this.label, this.screen});
}