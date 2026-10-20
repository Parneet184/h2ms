import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../application/mess_providers.dart';
import 'edit_day_menu_screen.dart';

class ManageMenuListScreen extends ConsumerWidget {
  const ManageMenuListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the live menu data
    final weeklyMenu = ref.watch(weeklyMenuProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Weekly Menu'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: weeklyMenu.length,
        itemBuilder: (context, index) {
          final dayMenu = weeklyMenu[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 0,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit_calendar, color: AppColors.primary),
              ),
              title: Text(dayMenu.dayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              subtitle: const Text('Tap to edit breakfast, lunch, snacks, dinner'),
              trailing: const Icon(Icons.edit, color: AppColors.textSecondary),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditDayMenuScreen(dayMenu: dayMenu)),
                );
              },
            ),
          );
        },
      ),
    );
  }
}