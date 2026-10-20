import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/menu_model.dart';

// --- TODAY'S QUICK MENU ---
// A simple provider holding today's menu for quick access
final todayMenuProvider = Provider<MenuModel>((ref) {
  return MenuModel(
    date: 'Monday, 16 Feb',
    breakfast: 'Aloo Paratha, Curd, Pickle, Tea / Coffee',
    lunch: 'Rajma Masala, Jeera Rice, Roti, Mix Veg, Salad',
    dinner: 'Dal Makhani, Shahi Paneer, Roti, Gulab Jamun',
  );
});

// --- EDITABLE WEEKLY MENU STATE NOTIFIER ---
// This allows the Mess Incharge to update the menu dynamically
class WeeklyMenuNotifier extends StateNotifier<List<DayMenuModel>> {
  WeeklyMenuNotifier() : super(_initialMenu);

  // Function to update a specific day's menu
  void updateDayMenu(int dayOfWeek, String breakfast, String lunch, String snacks, String dinner) {
    state = [
      for (final day in state)
        if (day.dayOfWeek == dayOfWeek)
          DayMenuModel(
            dayName: day.dayName,
            dayOfWeek: day.dayOfWeek,
            breakfast: breakfast,
            lunch: lunch,
            snacks: snacks,
            dinner: dinner,
            breakfastRating: day.breakfastRating,
            lunchRating: day.lunchRating,
            snacksRating: day.snacksRating,
            dinnerRating: day.dinnerRating,
            totalReviews: day.totalReviews,
          )
        else
          day
    ];
  }

  static final List<DayMenuModel> _initialMenu = [
    DayMenuModel(
      dayName: 'Monday', dayOfWeek: 1,
      breakfast: 'Aloo Paratha, White Butter, Curd, Tea/Coffee',
      lunch: 'Rajma Masala, Jeera Rice, Roti, Mix Veg, Salad',
      snacks: 'Samosa, Green Chutney, Tea',
      dinner: 'Dal Makhani, Shahi Paneer, Roti, Gulab Jamun',
      breakfastRating: 4.8, lunchRating: 4.2, snacksRating: 4.5, dinnerRating: 4.6, totalReviews: 412,
    ),
    DayMenuModel(
      dayName: 'Tuesday', dayOfWeek: 2,
      breakfast: 'Poha, Jalebi, Sev, Tea/Coffee',
      lunch: 'Kadi Pakora, Plain Rice, Roti, Aloo Gobi, Salad',
      snacks: 'Bread Pakora, Ketchup, Tea',
      dinner: 'Mix Dal, Matar Paneer, Roti, Kheer',
      breakfastRating: 3.9, lunchRating: 3.5, snacksRating: 4.0, dinnerRating: 3.8, totalReviews: 389,
    ),
    DayMenuModel(
      dayName: 'Wednesday', dayOfWeek: 3,
      breakfast: 'Idli, Sambar, Coconut Chutney, Tea/Coffee',
      lunch: 'Chole, Bhature, Plain Rice, Roti, Salad',
      snacks: 'Macaroni, Tea',
      dinner: 'Yellow Dal Tadka, Aloo Shimla Mirch, Roti, Ice Cream',
      breakfastRating: 3.2, lunchRating: 4.7, snacksRating: 2.8, dinnerRating: 3.5, totalReviews: 450,
    ),
    DayMenuModel(
      dayName: 'Thursday', dayOfWeek: 4,
      breakfast: 'Puri Sabzi, Pickle, Tea/Coffee',
      lunch: 'Dal Panchmel, Rice, Roti, Bhindi Masala, Salad',
      snacks: 'Patties, Tea',
      dinner: 'Kala Chana, Paneer Bhurji, Roti, Custard',
      breakfastRating: 4.1, lunchRating: 3.0, snacksRating: 4.2, dinnerRating: 4.0, totalReviews: 375,
    ),
    DayMenuModel(
      dayName: 'Friday', dayOfWeek: 5,
      breakfast: 'Upma, Coconut Chutney, Tea/Coffee',
      lunch: 'Dal Fry, Rice, Roti, Soyabean Sabzi, Salad',
      snacks: 'Maggi, Tea',
      dinner: 'Arhar Dal, Egg Curry / Paneer Butter Masala, Roti, Fruit',
      breakfastRating: 2.5, lunchRating: 3.4, snacksRating: 4.9, dinnerRating: 4.3, totalReviews: 420,
    ),
    DayMenuModel(
      dayName: 'Saturday', dayOfWeek: 6,
      breakfast: 'Bread Omelette / Veg Sandwich, Tea/Coffee',
      lunch: 'Puri, Aloo Sabzi, Boondi Raita, Salad',
      snacks: 'Biscuits, Rusk, Tea',
      dinner: 'Dal Makhani, Mix Veg, Roti, Jalebi',
      breakfastRating: 4.0, lunchRating: 4.4, snacksRating: 3.1, dinnerRating: 4.5, totalReviews: 290,
    ),
    DayMenuModel(
      dayName: 'Sunday', dayOfWeek: 7,
      breakfast: 'Masala Dosa, Sambar, Chutney, Tea/Coffee',
      lunch: 'Veg Biryani, Raita, Papad, Salad',
      snacks: 'Namkeen, Tea',
      dinner: 'Chana Dal, Palak Paneer, Roti, Hot Milk',
      breakfastRating: 4.6, lunchRating: 4.8, snacksRating: 2.5, dinnerRating: 3.9, totalReviews: 310,
    ),
  ];
}

final weeklyMenuProvider = StateNotifierProvider<WeeklyMenuNotifier, List<DayMenuModel>>((ref) {
  return WeeklyMenuNotifier();
});


// --- STUDENT RATING SUBMISSION LOGIC ---

class MealRating {
  final int stars;
  final String feedback;

  MealRating({this.stars = 0, this.feedback = ''});

  MealRating copyWith({int? stars, String? feedback}) {
    return MealRating(
      stars: stars ?? this.stars,
      feedback: feedback ?? this.feedback,
    );
  }
}

class DailyRatingsNotifier extends StateNotifier<Map<String, MealRating>> {
  DailyRatingsNotifier() : super({
    'Breakfast': MealRating(),
    'Lunch': MealRating(),
    'Snacks': MealRating(),
    'Dinner': MealRating(),
  });

  void updateRating(String meal, int stars) {
    state = {
      ...state,
      meal: state[meal]!.copyWith(stars: stars),
    };
  }

  void updateFeedback(String meal, String feedback) {
    state = {
      ...state,
      meal: state[meal]!.copyWith(feedback: feedback),
    };
  }

  void submitAll() {
    // In a real app, this sends the data to Supabase/Backend.
    // For now, we just clear the state after successful submission.
    state = {
      'Breakfast': MealRating(),
      'Lunch': MealRating(),
      'Snacks': MealRating(),
      'Dinner': MealRating(),
    };
  }
}

final dailyRatingsProvider = StateNotifierProvider<DailyRatingsNotifier, Map<String, MealRating>>((ref) {
  return DailyRatingsNotifier();
});