import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../application/mess_providers.dart';

// Mock model for student feedback comments
class StudentFeedback {
  final String studentName;
  final String meal;
  final double rating;
  final String comment;
  final String date;

  StudentFeedback(this.studentName, this.meal, this.rating, this.comment, this.date);
}

class RatingsFeedbackScreen extends ConsumerStatefulWidget {
  const RatingsFeedbackScreen({super.key});

  @override
  ConsumerState<RatingsFeedbackScreen> createState() => _RatingsFeedbackScreenState();
}

class _RatingsFeedbackScreenState extends ConsumerState<RatingsFeedbackScreen> {
  // --- FILTER STATE ---
  String _selectedMealFilter = 'All'; // 'All', 'Breakfast', 'Lunch', 'Snacks', 'Dinner'
  String _selectedRatingFilter = 'All'; // 'All', 'Positive (4-5)', 'Critical (1-3)'
  String _sortBy = 'Newest'; // 'Newest', 'Highest Rating', 'Lowest Rating'

  late List<StudentFeedback> _allComments;

  @override
  void initState() {
    super.initState();
    _allComments = _generateMockFeedback();
  }

  // --- FILTER LOGIC ---
  List<StudentFeedback> get _filteredAndSortedComments {
    // 1. Filter
    List<StudentFeedback> filtered = _allComments.where((comment) {
      bool matchesMeal = _selectedMealFilter == 'All' || comment.meal == _selectedMealFilter;
      bool matchesRating = true;
      if (_selectedRatingFilter == 'Positive (4-5)') matchesRating = comment.rating >= 4.0;
      if (_selectedRatingFilter == 'Critical (1-3)') matchesRating = comment.rating < 4.0;

      return matchesMeal && matchesRating;
    }).toList();

    // 2. Sort
    if (_sortBy == 'Highest Rating') {
      filtered.sort((a, b) => b.rating.compareTo(a.rating));
    } else if (_sortBy == 'Lowest Rating') {
      filtered.sort((a, b) => a.rating.compareTo(b.rating));
    }
    // If 'Newest', we leave it in the default mock order for this example

    return filtered;
  }

  // --- BOTTOM SHEET UI ---
  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        // StatefulBuilder allows the bottom sheet to update its own UI (like toggling chips)
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Filter Feedback', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 16),

                  // 1. MEAL FILTER
                  const Text('Meal Time', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['All', 'Breakfast', 'Lunch', 'Snacks', 'Dinner'].map((meal) {
                      final isSelected = _selectedMealFilter == meal;
                      return ChoiceChip(
                        label: Text(meal),
                        selected: isSelected,
                        selectedColor: AppColors.primaryLight.withOpacity(0.3),
                        onSelected: (selected) {
                          setSheetState(() => _selectedMealFilter = meal);
                          setState(() {}); // Update main screen
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // 2. RATING FILTER
                  const Text('Rating Type', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['All', 'Positive (4-5)', 'Critical (1-3)'].map((rating) {
                      final isSelected = _selectedRatingFilter == rating;
                      return ChoiceChip(
                        label: Text(rating),
                        selected: isSelected,
                        selectedColor: AppColors.warning.withOpacity(0.3),
                        onSelected: (selected) {
                          setSheetState(() => _selectedRatingFilter = rating);
                          setState(() {});
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // 3. SORT BY
                  const Text('Sort By', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['Newest', 'Highest Rating', 'Lowest Rating'].map((sort) {
                      final isSelected = _sortBy == sort;
                      return ChoiceChip(
                        label: Text(sort),
                        selected: isSelected,
                        selectedColor: Colors.grey.shade300,
                        onSelected: (selected) {
                          setSheetState(() => _sortBy = sort);
                          setState(() {});
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),

                  // RESET BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () {
                        setSheetState(() {
                          _selectedMealFilter = 'All';
                          _selectedRatingFilter = 'All';
                          _sortBy = 'Newest';
                        });
                        setState(() {});
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Reset All Filters', style: TextStyle(color: AppColors.textSecondary)),
                    ),
                  ),
                  const SizedBox(height: 16), // Padding for bottom screen edge
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final weeklyMenu = ref.watch(weeklyMenuProvider);
    final currentDayOfWeek = DateTime.now().weekday;
    final todayMenu = weeklyMenu.firstWhere(
          (day) => day.dayOfWeek == currentDayOfWeek,
      orElse: () => weeklyMenu.first,
    );

    final displayedComments = _filteredAndSortedComments;

    // Check if any filter is active to show a visual indicator
    final bool isFilterActive = _selectedMealFilter != 'All' || _selectedRatingFilter != 'All' || _sortBy != 'Newest';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ratings & Feedback'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. OVERALL SUMMARY BANNER ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Row(
                children: [
                  const Column(
                    children: [
                      Text('4.1', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white, height: 1.0)),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          Icon(Icons.star_half, color: Colors.amber, size: 16),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Weekly Average', style: TextStyle(color: Colors.white70, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text('Based on ${todayMenu.totalReviews + 1240} total student reviews this week.', style: const TextStyle(color: Colors.white, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // --- 2. TODAY'S MEAL BREAKDOWN ---
            Text('Today\'s Performance (${todayMenu.dayName})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildMealStatCard('Breakfast', todayMenu.breakfastRating)),
                const SizedBox(width: 12),
                Expanded(child: _buildMealStatCard('Lunch', todayMenu.lunchRating)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildMealStatCard('Snacks', todayMenu.snacksRating)),
                const SizedBox(width: 12),
                Expanded(child: _buildMealStatCard('Dinner', todayMenu.dinnerRating)),
              ],
            ),
            const SizedBox(height: 32),

            // --- 3. RECENT COMMENTS FEED (WITH FILTER TOGGLE) ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Recent Comments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                TextButton.icon(
                  onPressed: _showFilterSheet,
                  icon: Icon(
                      isFilterActive ? Icons.filter_alt : Icons.filter_list,
                      size: 18,
                      color: isFilterActive ? AppColors.primary : AppColors.textSecondary
                  ),
                  label: Text(
                    isFilterActive ? 'Filtered' : 'Filter',
                    style: TextStyle(color: isFilterActive ? AppColors.primary : AppColors.textSecondary, fontWeight: isFilterActive ? FontWeight.bold : FontWeight.normal),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Show empty state if filters are too strict
            if (displayedComments.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.search_off, size: 48, color: AppColors.textSecondary),
                    SizedBox(height: 16),
                    Text('No feedback matches your filters.', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: displayedComments.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  return _buildFeedbackCard(displayedComments[index]);
                },
              ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildMealStatCard(String mealName, double rating) {
    final color = _getRatingColor(rating);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(mealName, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.star, color: color, size: 24),
              const SizedBox(width: 8),
              Text(
                rating.toStringAsFixed(1),
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color, height: 1.0),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard(StudentFeedback feedback) {
    final color = _getRatingColor(feedback.rating);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.primaryLight.withOpacity(0.2),
                      child: const Icon(Icons.person, size: 18, color: AppColors.primary),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(feedback.studentName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        Text('${feedback.meal} • ${feedback.date}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.star, size: 14, color: color),
                      const SizedBox(width: 4),
                      Text(feedback.rating.toStringAsFixed(1), style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(feedback.comment, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.4)),
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

  // --- MOCK DATA ---
  List<StudentFeedback> _generateMockFeedback() {
    return [
      StudentFeedback('Gursajanpreet Singh', 'Lunch', 4.5, 'Chole Bhature was excellent today! Better than last week.', 'Today, 2:15 PM'),
      StudentFeedback('Aarav Sharma', 'Breakfast', 2.0, 'The upma was totally dry and cold. Please improve.', 'Today, 9:30 AM'),
      StudentFeedback('Anonymous', 'Dinner', 4.0, 'Dal makhani is always good. Paneer pieces were a bit less though.', 'Yesterday'),
      StudentFeedback('Vikram Singh', 'Snacks', 1.5, 'Macaroni was completely undercooked and lacked salt.', 'Yesterday'),
      StudentFeedback('Rahul Kumar', 'Lunch', 5.0, 'Perfectly cooked rice and the sabzi was fresh. Good job.', 'Monday'),
      StudentFeedback('Neha Gupta', 'Breakfast', 1.0, 'Bread was stale and the tea had no sugar at all.', 'Monday'), // Extra data to test filters
    ];
  }
}