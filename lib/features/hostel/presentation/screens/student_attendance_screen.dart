import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../hostel/application/attendance_providers.dart';

class StudentAttendanceScreen extends ConsumerStatefulWidget {
  const StudentAttendanceScreen({super.key});

  @override
  ConsumerState<StudentAttendanceScreen> createState() => _StudentAttendanceScreenState();
}

class _StudentAttendanceScreenState extends ConsumerState<StudentAttendanceScreen> {
  void _changeMonth(int offset) {
    final current = ref.read(selectedMonthProvider);
    ref.read(selectedMonthProvider.notifier).state = DateTime(current.year, current.month + offset, 1);
  }

  @override
  Widget build(BuildContext context) {
    final selectedMonth = ref.watch(selectedMonthProvider);
    final attendanceAsync = ref.watch(monthlyAttendanceProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Attendance'),
        elevation: 0,
      ),
      body: attendanceAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, stack) => Center(child: Text('Error loading attendance: $err', style: const TextStyle(color: AppColors.error))),
        data: (attendanceData) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMonthHeader(selectedMonth),
                  const SizedBox(height: 16),
                  _buildDaysOfWeek(),
                  const SizedBox(height: 8),
                  _buildCalendarGrid(selectedMonth, attendanceData),
                  const SizedBox(height: 24),
                  const Text('Monthly Stats', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 12),
                  _buildStatsGrid(attendanceData),
                  const SizedBox(height: 24),
                  const Text(
                    'Tap any date on the calendar to view morning/evening details.',
                    style: TextStyle(color: AppColors.textSecondary, fontStyle: FontStyle.italic, fontSize: 13),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMonthHeader(DateTime currentMonth) {
    const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_left, color: AppColors.textSecondary, size: 32),
          onPressed: () => _changeMonth(-1),
        ),
        Text(
          '${monthNames[currentMonth.month - 1].toUpperCase()} ${currentMonth.year}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textSecondary, letterSpacing: 1.2),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_right, color: AppColors.textSecondary, size: 32),
          onPressed: () => _changeMonth(1),
        ),
      ],
    );
  }

  Widget _buildDaysOfWeek() {
    const days = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: days.map((day) => Expanded(
        child: Text(
            day,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textPrimary)
        ),
      )).toList(),
    );
  }

  Widget _buildCalendarGrid(DateTime month, List<DailyAttendance> data) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final offset = firstDayOfMonth.weekday == 7 ? 0 : firstDayOfMonth.weekday;
    final totalDaysInMonth = DateTime(month.year, month.month + 1, 0).day;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.1,
      ),
      itemCount: totalDaysInMonth + offset,
      itemBuilder: (context, index) {
        if (index < offset) return const SizedBox.shrink();

        final dayNumber = index - offset + 1;
        final matchingRecords = data.where((d) => d.date.day == dayNumber && d.date.month == month.month && d.date.year == month.year);

        final record = matchingRecords.isNotEmpty ? matchingRecords.first : null;
        final color = record?.calendarColor ?? Colors.grey.shade300;

        return GestureDetector(
          onTap: record != null ? () => _showDayDetails(record) : null,
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 4, offset: const Offset(0, 2))
              ],
            ),
            child: Center(
              child: Text(
                '$dayNumber',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsGrid(List<DailyAttendance> data) {
    int onTime = data.where((d) => d.morningStatus == MorningStatus.onTime).length;
    int late = data.where((d) => d.morningStatus == MorningStatus.late).length;
    int inHostel = data.where((d) => d.morningStatus == MorningStatus.inHostel).length;
    int leaves = data.where((d) => d.morningStatus == MorningStatus.leave).length;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 2.5,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildStatBox('On Time', '$onTime Days', Colors.green, Icons.domain_verification),
        _buildStatBox('Late for Univ', '$late Days', Colors.orange, Icons.timer_off),
        _buildStatBox('Stayed in Hostel', '$inHostel Days', Colors.redAccent, Icons.hotel),
        _buildStatBox('On Leave', '$leaves Days', Colors.amber, Icons.flight_takeoff),
      ],
    );
  }

  Widget _buildStatBox(String title, String count, Color bgColor, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.15),
        border: Border.all(color: bgColor.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: bgColor),
          const SizedBox(width: 8),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: bgColor)),
              Text(count, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            ],
          ),
        ],
      ),
    );
  }

  void _showDayDetails(DailyAttendance record) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${record.date.day}/${record.date.month}/${record.date.year}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: record.calendarColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      record.dayType.name.toUpperCase(),
                      style: TextStyle(fontWeight: FontWeight.bold, color: record.calendarColor),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 24),
              const Text('Morning (9:30 AM Check)', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              Text(
                _getMorningString(record.morningStatus),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              const Divider(height: 32),
              const Text('Evening (9:00 PM Check)', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              Text(
                record.eveningStatus == EveningStatus.present ? 'Present in Hostel' : 'Absent / Not in Hostel',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  String _getMorningString(MorningStatus status) {
    switch (status) {
      case MorningStatus.onTime: return 'Went to University on time';
      case MorningStatus.late: return 'Late (Left after 9:00 AM)';
      case MorningStatus.inHostel: return 'Stayed in Hostel (Absent from Univ)';
      case MorningStatus.leave: return 'Authorized Leave';
      case MorningStatus.notApplicable: return 'No Morning Attendance (Off Day)';
    }
  }
}