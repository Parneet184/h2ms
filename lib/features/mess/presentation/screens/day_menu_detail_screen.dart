import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/menu_model.dart';

class DayMenuDetailScreen extends StatelessWidget {
  final DayMenuModel dayMenu;

  const DayMenuDetailScreen({super.key, required this.dayMenu});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${dayMenu.dayName}\'s Overview'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER ---
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.restaurant_menu, size: 40, color: AppColors.primary),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${dayMenu.dayName} Menu',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Based on ${dayMenu.totalReviews} student reviews',
                    style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // --- MENU & RATING CARDS ---
            _buildMealCard('Breakfast', dayMenu.breakfast, Icons.free_breakfast, dayMenu.breakfastRating),
            _buildMealCard('Lunch', dayMenu.lunch, Icons.lunch_dining, dayMenu.lunchRating),
            _buildMealCard('Snacks', dayMenu.snacks, Icons.emoji_food_beverage, dayMenu.snacksRating),
            _buildMealCard('Dinner', dayMenu.dinner, Icons.dinner_dining, dayMenu.dinnerRating),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMealCard(String mealName, String items, IconData icon, double rating) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 24, color: AppColors.textSecondary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    mealName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                ),
                // Rating Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getRatingColor(rating).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.star, size: 16, color: _getRatingColor(rating)),
                      const SizedBox(width: 4),
                      Text(
                        rating.toStringAsFixed(1),
                        style: TextStyle(fontWeight: FontWeight.bold, color: _getRatingColor(rating)),
                      ),
                    ],
                  ),
                )
              ],
            ),
            const Divider(height: 24),
            Text(
              items,
              style: const TextStyle(fontSize: 15, color: AppColors.textPrimary, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRatingColor(double rating) {
    if (rating >= 4.0) return Colors.green;
    if (rating >= 3.0) return Colors.orange;
    return Colors.red;
  }
}