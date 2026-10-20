class MenuModel {
  final String date;
  final String breakfast;
  final String lunch;
  final String dinner;

  MenuModel({
    required this.date,
    required this.breakfast,
    required this.lunch,
    required this.dinner,
  });
}

class DayMenuModel {
  final String dayName;
  final int dayOfWeek; // 1 = Monday, 7 = Sunday
  final String breakfast;
  final String lunch;
  final String snacks;
  final String dinner;

  // --- NEW: Aggregated Rating Data ---
  final double breakfastRating;
  final double lunchRating;
  final double snacksRating;
  final double dinnerRating;
  final int totalReviews; // How many students rated this day

  DayMenuModel({
    required this.dayName,
    required this.dayOfWeek,
    required this.breakfast,
    required this.lunch,
    required this.snacks,
    required this.dinner,
    this.breakfastRating = 0.0,
    this.lunchRating = 0.0,
    this.snacksRating = 0.0,
    this.dinnerRating = 0.0,
    this.totalReviews = 0,
  });
}