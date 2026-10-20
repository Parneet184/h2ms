import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/enums.dart';

// Mock model for overdue students (Parent phone removed)
class OverdueStudent {
  final String id;
  final String name;
  final String uid;
  final String room;
  final PassType type;
  final DateTime expectedInTime;
  final String studentPhone;

  OverdueStudent({
    required this.id,
    required this.name,
    required this.uid,
    required this.room,
    required this.type,
    required this.expectedInTime,
    required this.studentPhone,
  });
}

class OverdueStudentsScreen extends StatefulWidget {
  const OverdueStudentsScreen({super.key});

  @override
  State<OverdueStudentsScreen> createState() => _OverdueStudentsScreenState();
}

class _OverdueStudentsScreenState extends State<OverdueStudentsScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<OverdueStudent> _allOverdue = [];
  List<OverdueStudent> _filteredOverdue = [];

  @override
  void initState() {
    super.initState();
    _fetchAndFilterOverdueStudents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- LOGIC: Filter for Current Day & Gatepass Only ---
  void _fetchAndFilterOverdueStudents() {
    final allMockData = _generateMockOverdueStudents();
    final now = DateTime.now();

    _allOverdue = allMockData.where((student) {
      // 1. Must be a Gatepass (No Leave Forms)
      bool isGatepass = student.type == PassType.gatepass;

      // 2. Must be from the Current Day
      bool isToday = student.expectedInTime.year == now.year &&
          student.expectedInTime.month == now.month &&
          student.expectedInTime.day == now.day;

      return isGatepass && isToday;
    }).toList();

    _filteredOverdue = _allOverdue;
  }

  void _filterStudents(String query) {
    if (query.trim().isEmpty) {
      setState(() => _filteredOverdue = _allOverdue);
    } else {
      setState(() {
        _filteredOverdue = _allOverdue.where((student) {
          final q = query.toLowerCase();
          return student.name.toLowerCase().contains(q) ||
              student.uid.toLowerCase().contains(q) ||
              student.room.toLowerCase().contains(q);
        }).toList();
      });
    }
  }

  void _alertWarden(OverdueStudent student) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Alert sent to Warden for ${student.name}.'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _getOverdueDurationString(DateTime expectedTime) {
    final difference = DateTime.now().difference(expectedTime);
    if (difference.inHours > 0) {
      return '${difference.inHours} hrs, ${difference.inMinutes % 60} mins late';
    } else {
      return '${difference.inMinutes} mins late';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Today\'s Overdue Gatepasses'),
        backgroundColor: AppColors.error,
        foregroundColor: Colors.white,
        titleSpacing: 0,
      ),
      body: Column(
        children: [
          // --- WARNING BANNER ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            color: AppColors.error.withOpacity(0.1),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: AppColors.error),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Showing students who missed their gatepass return time today. Contact the student or alert the Warden.',
                    style: TextStyle(color: AppColors.error.withOpacity(0.8), fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),

          // --- SEARCH BAR ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterStudents,
              decoration: InputDecoration(
                hintText: 'Search UID, Name, or Room...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _filterStudents('');
                  },
                )
                    : null,
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),

          // --- OVERDUE LIST ---
          Expanded(
            child: _filteredOverdue.isEmpty
                ? const Center(
              child: Text('No overdue gatepasses today. Everyone is accounted for!', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
            )
                : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _filteredOverdue.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final student = _filteredOverdue[index];

                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: AppColors.error.withOpacity(0.5), width: 1.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColors.error.withOpacity(0.1),
                              child: const Icon(Icons.person, color: AppColors.error),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  Text('UID: ${student.uid} • Room ${student.room}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // --- OVERDUE METRIC ---
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Due Time (Today)', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                  Text(
                                    _formatTime(student.expectedInTime),
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text('Status', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                  Text(
                                    _getOverdueDurationString(student.expectedInTime),
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.error),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // --- ACTION BUTTONS (Updated) ---
                        Row(
                          children: [
                            // Call Student Button
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Calling Student: ${student.studentPhone}')));
                                },
                                icon: const Icon(Icons.phone, size: 18),
                                label: const Text('Call Student', style: TextStyle(fontSize: 14)),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  side: const BorderSide(color: AppColors.primary),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Escalate Button
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _alertWarden(student),
                                icon: const Icon(Icons.campaign, size: 18, color: Colors.white),
                                label: const Text('Alert Warden', style: TextStyle(fontSize: 14, color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.error,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  elevation: 0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  // --- MOCK DATA GENERATOR ---
  List<OverdueStudent> _generateMockOverdueStudents() {
    final now = DateTime.now();
    return [
      // 1. Valid: Gatepass and Today
      OverdueStudent(
        id: '1',
        name: 'Arjun Das',
        uid: '24F0012',
        room: '108',
        type: PassType.gatepass,
        expectedInTime: now.subtract(const Duration(hours: 2, minutes: 15)),
        studentPhone: '+91 9876543210',
      ),
      // 2. Will be filtered out: It is a Leave Form
      OverdueStudent(
        id: '2',
        name: 'Amit Kumar',
        uid: '23F0199',
        room: '110',
        type: PassType.leave,
        expectedInTime: now.subtract(const Duration(days: 1, hours: 5)),
        studentPhone: '+91 9123456780',
      ),
      // 3. Valid: Gatepass and Today
      OverdueStudent(
        id: '3',
        name: 'Rohan Gupta',
        uid: '22F8022',
        room: '302',
        type: PassType.gatepass,
        expectedInTime: now.subtract(const Duration(minutes: 45)),
        studentPhone: '+91 9000011111',
      ),
      // 4. Will be filtered out: Yesterday's gatepass
      OverdueStudent(
        id: '4',
        name: 'Late Student',
        uid: '21F9999',
        room: '101',
        type: PassType.gatepass,
        expectedInTime: now.subtract(const Duration(days: 1, minutes: 10)),
        studentPhone: '+91 9999900000',
      )
    ];
  }
}