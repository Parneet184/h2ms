import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/data/auth_repository.dart';

// --- PRODUCTION ATTENDANCE MODEL ---
class AttendanceStudent {
  final String id; // Matches 'uid' from the users table
  final String name;
  final String uid;
  final String roomNumber;

  String morningStatus;
  String eveningStatus;
  final bool isLeaveAutoFilled;

  AttendanceStudent({
    required this.id,
    required this.name,
    required this.uid,
    required this.roomNumber,
    this.morningStatus = 'in_hostel',
    this.eveningStatus = 'present',
    this.isLeaveAutoFilled = false,
  }) {
    if (isLeaveAutoFilled) {
      morningStatus = 'on_leave';
      eveningStatus = 'on_leave';
    }
  }
}

class MarkAttendanceScreen extends ConsumerStatefulWidget {
  const MarkAttendanceScreen({super.key});

  @override
  ConsumerState<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends ConsumerState<MarkAttendanceScreen> {
  late String _currentDateString;
  late DateTime _selectedDate;
  late String _currentSlot;

  bool _isLoading = true;
  Map<String, List<AttendanceStudent>> _groupedStudents = {};

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _currentDateString = DateFormat('EEEE, MMM d, yyyy').format(_selectedDate);
    _initializeTimeAndSlot();
    _fetchStudentsAndLeavesFromSupabase();
  }

  void _initializeTimeAndSlot() {
    final now = DateTime.now();
    final isWeekend = now.weekday == DateTime.saturday || now.weekday == DateTime.sunday;
    if (isWeekend) {
      _currentSlot = 'Evening';
    } else {
      _currentSlot = now.hour < 12 ? 'Morning' : 'Evening';
    }
  }

  Future<void> _fetchStudentsAndLeavesFromSupabase() async {
    setState(() => _isLoading = true);

    try {
      final supabase = ref.read(supabaseClientProvider);

      // 1. Fetch all student profiles using exact columns from your schema: uid, name, room_number, role
      final profilesResponse = await supabase
          .from('users')
          .select('uid, name, room_number')
          .eq('role', 'student');

      // 2. Fetch approved leave passes for the selected date matching schema column 'student_uid' & 'pass_type'
      final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final passesResponse = await supabase
          .from('gatepasses')
          .select('student_uid')
          .eq('pass_type', 'leave') // Corrected from boolean to matching string text
          .eq('status', 'approved')
          .lte('requested_out_time', formattedDate)
          .gte('expected_in_time', formattedDate);

      final List<dynamic> profiles = profilesResponse;
      final List<dynamic> activeLeaves = passesResponse;

      // Extract student UIDs currently on leave matching gatepasses.student_uid
      final Set<String> studentsOnLeaveIds = activeLeaves.map((p) => p['student_uid'].toString()).toSet();

      List<AttendanceStudent> allStudents = profiles.map((json) {
        final id = json['uid'].toString();
        final isOnLeave = studentsOnLeaveIds.contains(id);

        return AttendanceStudent(
          id: id,
          name: json['name'] ?? 'Unknown Student',
          uid: id,
          roomNumber: json['room_number'] ?? 'Unassigned',
          isLeaveAutoFilled: isOnLeave,
        );
      }).toList();

      allStudents.sort((a, b) => a.roomNumber.compareTo(b.roomNumber));

      Map<String, List<AttendanceStudent>> grouped = {};
      for (var student in allStudents) {
        if (!grouped.containsKey(student.roomNumber)) {
          grouped[student.roomNumber] = [];
        }
        grouped[student.roomNumber]!.add(student);
      }

      if (mounted) {
        setState(() {
          _groupedStudents = grouped;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading students: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  void _updateStatus(String roomId, String studentId, String newStatus) {
    setState(() {
      final student = _groupedStudents[roomId]!.firstWhere((s) => s.id == studentId);
      if (_currentSlot == 'Morning') {
        student.morningStatus = newStatus;
      } else {
        student.eveningStatus = newStatus;
      }
    });
  }

  Future<void> _submitAttendance() async {
    Map<String, int> tally = {};

    for (var roomList in _groupedStudents.values) {
      for (var s in roomList) {
        String status = _currentSlot == 'Morning' ? s.morningStatus : s.eveningStatus;
        tally[status] = (tally[status] ?? 0) + 1;
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Attendance', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Slot: $_currentSlot\nDate: $_currentDateString'),
            const Divider(height: 16),
            if (_currentSlot == 'Morning') ...[
              Text('In Hostel (Skipping): ${tally['in_hostel'] ?? 0}', style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
              Text('Gone On Time: ${tally['on_time'] ?? 0}', style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
              Text('Late to Uni: ${tally['late'] ?? 0}', style: const TextStyle(color: AppColors.warning, fontWeight: FontWeight.bold)),
              Text('On Leave: ${tally['on_leave'] ?? 0}', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ] else ...[
              Text('Present: ${tally['present'] ?? 0}', style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
              Text('Absent: ${tally['absent'] ?? 0}', style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
              Text('On Leave: ${tally['on_leave'] ?? 0}', style: const TextStyle(color: AppColors.warning, fontWeight: FontWeight.bold)),
            ]
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Review Again', style: TextStyle(color: AppColors.textSecondary))),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              await _pushAttendanceToSupabase();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Submit to Database'),
          ),
        ],
      ),
    );
  }

  Future<void> _pushAttendanceToSupabase() async {
    try {
      final supabase = ref.read(supabaseClientProvider);
      final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);

      List<Map<String, dynamic>> recordsToUpsert = [];

      for (var roomList in _groupedStudents.values) {
        for (var student in roomList) {
          recordsToUpsert.add({
            'student_id': student.id, // Ensure your daily_attendance table foreign key column matches this name
            'date': formattedDate,
            'morning_status': student.morningStatus,
            'evening_status': student.eveningStatus,
          });
        }
      }

      // Upsert into daily_attendance table matching unique constraint on (student_id, date)
      await supabase.from('daily_attendance').upsert(
        recordsToUpsert,
        onConflict: 'student_id,date',
      );

      if (mounted) {
        Navigator.pop(context); // Return to dashboard
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Attendance Successfully Submitted!'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Submission failed: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mark Attendance'),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _submitAttendance,
            child: const Text('SUBMIT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          )
        ],
      ),
      backgroundColor: Colors.grey.shade50,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
        children: [
          // --- SMART INFO BANNER WITH DROPDOWN ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primary,
              boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 4, offset: const Offset(0, 2))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_currentDateString, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _currentSlot,
                          dropdownColor: AppColors.primary,
                          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          items: ['Morning', 'Evening'].map((String value) {
                            return DropdownMenuItem<String>(value: value, child: Text(value));
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) setState(() => _currentSlot = newValue);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                Icon(_currentSlot == 'Morning' ? Icons.wb_sunny : Icons.nights_stay, color: Colors.white, size: 40),
              ],
            ),
          ),

          // --- ROOM-WISE LIST ---
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: _groupedStudents.keys.length,
              itemBuilder: (context, index) {
                String roomNumber = _groupedStudents.keys.elementAt(index);
                List<AttendanceStudent> studentsInRoom = _groupedStudents[roomNumber]!;

                if (_currentSlot == 'Morning') {
                  studentsInRoom = studentsInRoom.where((s) => !s.isLeaveAutoFilled).toList();
                }

                if (studentsInRoom.isEmpty) return const SizedBox.shrink();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      color: Colors.grey.shade200,
                      child: Text('Room $roomNumber', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade800, fontSize: 14)),
                    ),
                    ...studentsInRoom.map((student) => _buildStudentTile(roomNumber, student)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : _submitAttendance,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.cloud_upload, color: Colors.white),
        label: const Text('Submit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildStudentTile(String roomId, AttendanceStudent student) {
    final currentStatus = _currentSlot == 'Morning' ? student.morningStatus : student.eveningStatus;
    final isEveningLeave = _currentSlot == 'Evening' && student.isLeaveAutoFilled;

    return Container(
      decoration: BoxDecoration(
        color: isEveningLeave ? AppColors.warning.withValues(alpha: 0.05) : Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
          left: isEveningLeave ? const BorderSide(color: AppColors.warning, width: 4) : BorderSide.none,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                student.name,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isEveningLeave ? AppColors.warning : AppColors.textPrimary),
              ),
              if (isEveningLeave) ...[
                const SizedBox(width: 8),
                const Icon(Icons.flight_takeoff, size: 14, color: AppColors.warning),
              ]
            ],
          ),
          Text(student.uid, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          if (isEveningLeave)
            const Text('Officially On Leave', style: TextStyle(fontSize: 11, color: AppColors.warning, fontWeight: FontWeight.bold)),

          const SizedBox(height: 12),

          if (_currentSlot == 'Morning')
            Row(
              children: [
                Expanded(child: _buildOptionBtn(roomId, student.id, currentStatus, 'in_hostel', 'In Hostel', AppColors.error)),
                const SizedBox(width: 8),
                Expanded(child: _buildOptionBtn(roomId, student.id, currentStatus, 'on_time', 'On Time', AppColors.success)),
                const SizedBox(width: 8),
                Expanded(child: _buildOptionBtn(roomId, student.id, currentStatus, 'late', 'Late', AppColors.warning)),
              ],
            )
          else
            Row(
              children: [
                Expanded(child: _buildOptionBtn(roomId, student.id, currentStatus, 'present', 'Present', AppColors.success)),
                const SizedBox(width: 8),
                Expanded(child: _buildOptionBtn(roomId, student.id, currentStatus, 'absent', 'Absent', AppColors.error)),
                const SizedBox(width: 8),
                Expanded(child: _buildOptionBtn(roomId, student.id, currentStatus, 'on_leave', 'Leave', AppColors.warning)),
              ],
            )
        ],
      ),
    );
  }

  Widget _buildOptionBtn(String roomId, String studentId, String currentStatus, String targetStatus, String label, Color activeColor) {
    final isSelected = currentStatus == targetStatus;
    return InkWell(
      onTap: () => _updateStatus(roomId, studentId, targetStatus),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.15) : Colors.grey.shade100,
          border: Border.all(color: isSelected ? activeColor : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? activeColor : Colors.grey.shade500, fontSize: 12),
        ),
      ),
    );
  }
}