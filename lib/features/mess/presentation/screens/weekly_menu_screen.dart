import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../application/mess_providers.dart';
import 'day_menu_detail_screen.dart';

class WeeklyMenuScreen extends ConsumerWidget {
  const WeeklyMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeklyMenu = ref.watch(weeklyMenuProvider);
    final currentDayOfWeek = DateTime.now().weekday; // 1 = Mon, 7 = Sun

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Mess Menu'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: weeklyMenu.length,
        itemBuilder: (context, index) {
          final dayMenu = weeklyMenu[index];
          final isToday = dayMenu.dayOfWeek == currentDayOfWeek;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: isToday ? 2 : 0,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: isToday ? AppColors.primary : Colors.grey.shade300,
                width: isToday ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                // Navigate to the detailed view with ratings
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DayMenuDetailScreen(dayMenu: dayMenu)),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isToday ? AppColors.primary : AppColors.background,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.calendar_today,
                        color: isToday ? Colors.white : AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dayMenu.dayName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isToday ? AppColors.primary : AppColors.textPrimary,
                            ),
                          ),
                          if (isToday)
                            const Padding(
                              padding: EdgeInsets.only(top: 4.0),
                              child: Text('Today', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
                            ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}