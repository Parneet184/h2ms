import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/data/auth_repository.dart';
import 'package:flutter/material.dart';

enum MorningStatus { onTime, late, inHostel, leave, notApplicable }
enum EveningStatus { present, absent }

class DailyAttendance {
  final DateTime date;
  final MorningStatus morningStatus;
  final EveningStatus eveningStatus;

  DailyAttendance({
    required this.date,
    required this.morningStatus,
    required this.eveningStatus,
  });

  factory DailyAttendance.fromJson(Map<String, dynamic> json) {
    return DailyAttendance(
      date: DateTime.parse(json['date']),
      morningStatus: MorningStatus.values.firstWhere(
            (e) => e.name.toLowerCase() == (json['morning_status'] ?? '').toString().toLowerCase(),
        orElse: () => MorningStatus.onTime,
      ),
      eveningStatus: EveningStatus.values.firstWhere(
            (e) => e.name.toLowerCase() == (json['evening_status'] ?? '').toString().toLowerCase(),
        orElse: () => EveningStatus.present,
      ),
    );
  }

  // Visual helper color for calendar grids
  get calendarColor {
    switch (morningStatus) {
      case MorningStatus.onTime: return const Color(0xFF4CAF50); // Green
      case MorningStatus.late: return const Color(0xFFFF9800); // Orange
      case MorningStatus.inHostel: return const Color(0xFFE53935); // Red
      case MorningStatus.leave: return const Color(0xFFFFC107); // Amber
      case MorningStatus.notApplicable: return const Color(0xFF9E9E9E); // Grey
    }
  }

  get dayType => morningStatus;
}

// State provider for student monthly view
final selectedMonthProvider = StateProvider<DateTime>((ref) => DateTime.now());

// Stream provider for student monthly attendance records
final monthlyAttendanceProvider = StreamProvider.autoDispose<List<DailyAttendance>>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  final user = supabase.auth.currentUser;
  final selectedMonth = ref.watch(selectedMonthProvider);

  if (user == null) return Stream.value([]);

  final startDate = DateTime(selectedMonth.year, selectedMonth.month, 1).toIso8601String();
  final endDate = DateTime(selectedMonth.year, selectedMonth.month + 1, 0).toIso8601String();

  return supabase
      .from('daily_attendance')
      .stream(primaryKey: ['id'])
      .eq('student_id', user.id)
      .map((data) {
    return data
        .map((json) => DailyAttendance.fromJson(json))
        .where((record) => record.date.isAfter(DateTime.parse(startDate).subtract(const Duration(days: 1))) &&
        record.date.isBefore(DateTime.parse(endDate).add(const Duration(days: 1))))
        .toList();
  });
});