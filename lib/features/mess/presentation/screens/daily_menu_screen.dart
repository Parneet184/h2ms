import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../application/mess_providers.dart';
import '../../domain/menu_model.dart';

class DailyMenuScreen extends ConsumerWidget {
  const DailyMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Fetch Today's Menu
    final currentDayOfWeek = DateTime.now().weekday;
    final weeklyMenu = ref.watch(weeklyMenuProvider);
    final todayMenu = weeklyMenu.firstWhere((day) => day.dayOfWeek == currentDayOfWeek,
        orElse: () => weeklyMenu.first); // Fallback to Monday if something goes wrong

    // 2. Fetch the current rating state
    final ratings = ref.watch(dailyRatingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rate Today\'s Food'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    '${todayMenu.dayName}\'s Menu',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Rate specific meals and leave feedback on individual items.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- MEAL RATING CARDS ---
            _buildMealRatingCard(context, ref, 'Breakfast', todayMenu.breakfast, Icons.free_breakfast, ratings['Breakfast']!),
            _buildMealRatingCard(context, ref, 'Lunch', todayMenu.lunch, Icons.lunch_dining, ratings['Lunch']!),
            _buildMealRatingCard(context, ref, 'Snacks', todayMenu.snacks, Icons.emoji_food_beverage, ratings['Snacks']!),
            _buildMealRatingCard(context, ref, 'Dinner', todayMenu.dinner, Icons.dinner_dining, ratings['Dinner']!),

            const SizedBox(height: 32),

            // --- SUBMIT BUTTON ---
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Verify if at least one meal was rated
                  bool hasRatedSomething = ratings.values.any((r) => r.stars > 0);

                  if (!hasRatedSomething) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please rate at least one meal before submitting.'), backgroundColor: AppColors.error),
                    );
                    return;
                  }

                  // Submit and clear
                  ref.read(dailyRatingsProvider.notifier).submitAll();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Thank you! Your specific feedback has been sent to the Mess Incharge.'), backgroundColor: AppColors.success),
                  );
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.send, color: Colors.white),
                label: const Text('Submit Today\'s Feedback', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- UI HELPER FOR GRANULAR CARDS ---
  Widget _buildMealRatingCard(BuildContext context, WidgetRef ref, String mealName, String items, IconData icon, MealRating ratingState) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Meal Header & Items
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 28, color: AppColors.textSecondary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(mealName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      const SizedBox(height: 4),
                      Text(items, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4)),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Star Rating Row
            const Text('Rate this meal:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: List.generate(5, (index) {
                    return GestureDetector(
                      onTap: () {
                        ref.read(dailyRatingsProvider.notifier).updateRating(mealName, index + 1);
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 4.0),
                        child: Icon(
                          index < ratingState.stars ? Icons.star : Icons.star_border,
                          color: AppColors.warning,
                          size: 32,
                        ),
                      ),
                    );
                  }),
                ),
                // Show a text label depending on the rating
                if (ratingState.stars > 0)
                  Text(
                    _getRatingText(ratingState.stars),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: ratingState.stars >= 4 ? AppColors.success : (ratingState.stars == 3 ? AppColors.warning : AppColors.error)
                    ),
                  ),
              ],
            ),

            // Item-Specific Feedback Input (Expands if a rating is given)
            if (ratingState.stars > 0) ...[
              const SizedBox(height: 16),
              TextField(
                onChanged: (val) {
                  ref.read(dailyRatingsProvider.notifier).updateFeedback(mealName, val);
                },
                decoration: InputDecoration(
                  hintText: 'Any specific item bad/good? (e.g. "Dal was salty")',
                  hintStyle: const TextStyle(fontSize: 13),
                  isDense: true,
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  String _getRatingText(int stars) {
    switch (stars) {
      case 1: return 'Terrible';
      case 2: return 'Bad';
      case 3: return 'Average';
      case 4: return 'Good';
      case 5: return 'Excellent';
      default: return '';
    }
  }
}