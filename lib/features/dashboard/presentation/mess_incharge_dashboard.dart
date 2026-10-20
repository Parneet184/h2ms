import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../auth/application/auth_provider.dart';
import '../../profile/presentation/screens/mess_profile_screen.dart';
import '../../mess/presentation/screens/manage_menu_list_screen.dart';
import '../../mess/presentation/screens/ratings_feedback_screen.dart';
import '../../mess/presentation/screens/mess_complaints_screen.dart';
import '../../mess/presentation/screens/mess_announcements_screen.dart';

class MessInchargeDashboard extends ConsumerWidget {
  const MessInchargeDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mess Administration'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // --- ROUTE TO MESS PROFILE ---
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MessProfileScreen()),
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
            // --- PROFILE HEADER ---
            Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.soup_kitchen, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${user?.name ?? 'Incharge'}',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const Text(
                        'Chief Mess Administrator',
                        style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // --- 1. LIVE HEADCOUNT CARD (Tied to Attendance/Leave) ---
            const Text('Today\'s Expected Headcount', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            _buildLiveHeadcountCard(),

            const SizedBox(height: 32),
            const Text('Mess Operations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 16),

            // --- 2. OPERATIONS GRID ---
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.0,
              children: [
                _buildGridCard(
                  context,
                  title: 'Manage\nMenu',
                  icon: Icons.restaurant_menu,
                  color: AppColors.primary,
                  onTap: () {
                    // --- ROUTE TO MANAGE MENU LIST ---
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ManageMenuListScreen()),
                    );
                  },
                ),
                _buildGridCard(
                  context,
                  title: 'Ratings &\nFeedback',
                  icon: Icons.star_rate,
                  color: AppColors.warning,
                  onTap: () {
                    // --- ROUTE TO RATINGS SCREEN ---
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RatingsFeedbackScreen()),
                    );
                  },
                ),
                _buildGridCard(
                  context,
                  title: 'Student\nComplaints',
                  icon: Icons.report_problem,
                  color: AppColors.error,
                  badgeCount: '2', // Mock unresolved complaints
                  onTap: () {
                    // --- ROUTE TO COMPLAINTS SCREEN ---
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MessComplaintsScreen()),
                    );
                  },
                ),
                _buildGridCard(
                  context,
                  title: 'Mess\nAnnouncements',
                  icon: Icons.campaign,
                  color: AppColors.success,
                  onTap: () {
                    // --- ROUTE TO ANNOUNCEMENTS SCREEN ---
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MessAnnouncementsScreen()),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildLiveHeadcountCard() {
    // In a real app, these numbers would be fetched from the Attendance & Leave providers
    const int totalBoys = 420;
    const int totalGirls = 315;
    const int totalExpected = totalBoys + totalGirls;
    const int studentsOnLeave = 45; // Students who have approved active leaves

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Meals to Prepare', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  SizedBox(height: 4),
                  Text('$totalExpected', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold, height: 1.0)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    const Icon(Icons.flight_takeoff, color: Colors.white, size: 14),
                    const SizedBox(width: 6),
                    Text('$studentsOnLeave on leave', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              )
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Divider(color: Colors.white30, height: 1),
          ),
          Row(
            children: [
              Expanded(child: _buildHeadcountStat('Boys Hostel', totalBoys, Icons.man)),
              Container(width: 1, height: 40, color: Colors.white30),
              Expanded(child: _buildHeadcountStat('Girls Hostel', totalGirls, Icons.woman)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeadcountStat(String label, int count, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white70, size: 16),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 4),
        Text('$count', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
      ],
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