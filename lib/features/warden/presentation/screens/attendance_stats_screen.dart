import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/data/auth_repository.dart';

class DailyAttendanceStats {
  final DateTime date;
  final int totalStudents;
  final int totalOnLeave;
  final int morningInHostel;
  final int morningOnTime;
  final int morningLate;
  final int eveningPresent;
  final int eveningAbsent;

  DailyAttendanceStats({
    required this.date,
    required this.totalStudents,
    required this.totalOnLeave,
    required this.morningInHostel,
    required this.morningOnTime,
    required this.morningLate,
    required this.eveningPresent,
    required this.eveningAbsent,
  });

  int get totalPresentInHostel => eveningPresent;
}

class WardenAttendanceStatsScreen extends ConsumerStatefulWidget {
  const WardenAttendanceStatsScreen({super.key});

  @override
  ConsumerState<WardenAttendanceStatsScreen> createState() => _WardenAttendanceStatsScreenState();
}

class _WardenAttendanceStatsScreenState extends ConsumerState<WardenAttendanceStatsScreen> {
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;
  DailyAttendanceStats? _currentStats;

  @override
  void initState() {
    super.initState();
    _fetchStatsForDate(_selectedDate);
  }

  Future<void> _fetchStatsForDate(DateTime date) async {
    setState(() {
      _selectedDate = date;
      _isLoading = true;
    });

    try {
      final supabase = ref.read(supabaseClientProvider);
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);

      // Dynamically fetch total registered students count from database
      final countResponse = await supabase
          .from('users')
          .select('uid')
          .eq('role', 'student');
      int totalStudents = (countResponse as List).length;

      final response = await supabase
          .from('daily_attendance')
          .select()
          .eq('date', formattedDate);

      final List data = response;

      int leave = data.where((d) => d['morning_status'] == 'on_leave' || d['morning_status'] == 'leave').length;
      int morningInHostel = data.where((d) => d['morning_status'] == 'in_hostel').length;
      int morningOnTime = data.where((d) => d['morning_status'] == 'on_time').length;
      int morningLate = data.where((d) => d['morning_status'] == 'late').length;
      int eveningPresent = data.where((d) => d['evening_status'] == 'present').length;
      int eveningAbsent = data.where((d) => d['evening_status'] == 'absent').length;

      if (mounted) {
        setState(() {
          _currentStats = DailyAttendanceStats(
            date: date,
            totalStudents: totalStudents,
            totalOnLeave: leave,
            morningInHostel: morningInHostel,
            morningOnTime: morningOnTime,
            morningLate: morningLate,
            eveningPresent: eveningPresent > 0 ? eveningPresent : (totalStudents - leave - eveningAbsent),
            eveningAbsent: eveningAbsent,
          );
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _changeDate(int days) {
    _fetchStatsForDate(_selectedDate.add(Duration(days: days)));
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2025),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      _fetchStatsForDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isToday = DateFormat('yyyy-MM-dd').format(_selectedDate) == DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Stats'),
        elevation: 0,
      ),
      backgroundColor: Colors.grey.shade50,
      body: _isLoading || _currentStats == null
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, color: AppColors.primary),
                    onPressed: () => _changeDate(-1),
                  ),
                  InkWell(
                    onTap: _pickDate,
                    child: Column(
                      children: [
                        Text(
                          isToday ? 'TODAY' : DateFormat('EEEE').format(_selectedDate).toUpperCase(),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                        ),
                        Text(
                          DateFormat('MMM d, yyyy').format(_selectedDate),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.chevron_right, color: isToday ? Colors.grey.shade300 : AppColors.primary),
                    onPressed: isToday ? null : () => _changeDate(1),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Daily Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: AppColors.success, borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.business, color: Colors.white70, size: 28),
                        const SizedBox(height: 12),
                        const Text('Present in Hostel', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                        Text(
                          '${_currentStats!.totalPresentInHostel}',
                          style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, height: 1.1),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: AppColors.warning, borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.flight_takeoff, color: Colors.white70, size: 28),
                        const SizedBox(height: 12),
                        const Text('Approved Leave', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                        Text(
                          '${_currentStats!.totalOnLeave}',
                          style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, height: 1.1),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text('Morning Slot Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _buildStatRow('In Hostel (Skipped Classes)', _currentStats!.morningInHostel, Icons.bed, Colors.grey.shade700),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),
                  _buildStatRow('Gone to University (On Time)', _currentStats!.morningOnTime, Icons.check_circle, AppColors.success),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),
                  _buildStatRow('Late to University', _currentStats!.morningLate, Icons.warning_rounded, AppColors.warning),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text('Evening Slot (Night Roll Call)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _buildStatRow('Present (In Rooms)', _currentStats!.eveningPresent, Icons.how_to_reg, AppColors.success),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),
                  _buildStatRow('Absent (Defaulters)', _currentStats!.eveningAbsent, Icons.cancel, AppColors.error),
                ],
              ),
            ),
            if (_currentStats!.eveningAbsent > 0) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.error),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${_currentStats!.eveningAbsent} students were marked absent. Please check SOS / Escalations.',
                        style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, int count, IconData icon, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          ],
        ),
        Text('$count', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}