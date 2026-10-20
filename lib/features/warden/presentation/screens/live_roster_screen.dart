import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

// --- ROSTER MODEL ---
enum RosterType { gatepass, leave }

class RosterStudent {
  final String id;
  final String name;
  final String uid;
  final String roomNumber;
  final String outTime;
  final String expectedInTime;
  final String destination;
  final String contact;
  final RosterType type;
  final bool isOverdue;

  RosterStudent({
    required this.id, required this.name, required this.uid, required this.roomNumber,
    required this.outTime, required this.expectedInTime, required this.destination,
    required this.contact, required this.type, this.isOverdue = false,
  });
}

class LiveRosterScreen extends StatefulWidget {
  const LiveRosterScreen({super.key});

  @override
  State<LiveRosterScreen> createState() => _LiveRosterScreenState();
}

class _LiveRosterScreenState extends State<LiveRosterScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<RosterStudent> _activeStudents;

  final String _currentHostelCurfew = "08:30 PM";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _activeStudents = _getMockRoster();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _callStudent(String name, String number) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Dialing $name... ($number)'), backgroundColor: Colors.teal),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gatepassStudents = _activeStudents.where((s) => s.type == RosterType.gatepass).toList();
    final leaveStudents = _activeStudents.where((s) => s.type == RosterType.leave).toList();
    final overdueCount = _activeStudents.where((s) => s.isOverdue).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Roster'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: [
            // The counts are kept here where they belong functionally
            Tab(text: 'On Gatepass (${gatepassStudents.length})'),
            Tab(text: 'On Leave (${leaveStudents.length})'),
          ],
        ),
      ),
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          // --- STREAMLINED COMMAND BANNER ---
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary,
              boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.radar, color: Colors.white, size: 24),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Total Students Outside', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                            Text('${_activeStudents.length}', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, height: 1.2)),
                          ],
                        ),
                      ],
                    ),
                    if (overdueCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 16),
                            const SizedBox(width: 6),
                            Text('$overdueCount OVERDUE', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                          ],
                        ),
                      )
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Divider(color: Colors.white30, height: 1),
                ),
                Row(
                  children: [
                    const Icon(Icons.schedule, size: 14, color: Colors.white70),
                    const SizedBox(width: 6),
                    Text(
                      'Hostel Curfew is actively set to $_currentHostelCurfew',
                      style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // --- LIST VIEW ---
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // GATEPASS TAB
                gatepassStudents.isEmpty
                    ? _buildEmptyState('No students currently out on Gatepass', Icons.directions_run)
                    : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: gatepassStudents.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => _buildRosterCard(gatepassStudents[index]),
                ),

                // LEAVE TAB
                leaveStudents.isEmpty
                    ? _buildEmptyState('No students currently out on Leave', Icons.flight_takeoff)
                    : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: leaveStudents.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => _buildRosterCard(leaveStudents[index]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(fontSize: 15, color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildRosterCard(RosterStudent student) {
    final Color accentColor = student.isOverdue ? AppColors.error : (student.type == RosterType.gatepass ? AppColors.warning : Colors.deepOrange);
    final Color bgColor = student.isOverdue ? AppColors.error.withOpacity(0.05) : Colors.white;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: student.isOverdue ? AppColors.error.withOpacity(0.5) : Colors.grey.shade200),
      ),
      color: bgColor,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(border: Border(left: BorderSide(color: accentColor, width: 6))),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(student.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                            if (student.isOverdue) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(4)),
                                child: const Text('LATE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                              )
                            ]
                          ],
                        ),
                        Text('Room: ${student.roomNumber} • UID: ${student.uid}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.call, color: Colors.teal),
                    onPressed: () => _callStudent(student.name, student.contact),
                    style: IconButton.styleFrom(backgroundColor: Colors.teal.withOpacity(0.1)),
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),

              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(student.type == RosterType.gatepass ? Icons.directions_run : Icons.flight_takeoff, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 6),
                        Expanded(child: Text('Out: ${student.outTime}', style: TextStyle(color: Colors.grey.shade800, fontSize: 13), overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Icon(student.type == RosterType.gatepass ? Icons.home : Icons.flight_land, size: 16, color: student.isOverdue ? AppColors.error : Colors.grey.shade600),
                        const SizedBox(width: 6),
                        Expanded(child: Text('In: ${student.expectedInTime}', style: TextStyle(color: student.isOverdue ? AppColors.error : Colors.grey.shade800, fontSize: 13, fontWeight: student.isOverdue ? FontWeight.bold : FontWeight.normal), overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 6),
                  Expanded(child: Text('Destination: ${student.destination}', style: TextStyle(color: Colors.grey.shade800, fontSize: 13))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- MOCK DATA ---
  List<RosterStudent> _getMockRoster() {
    return [
      RosterStudent(id: 'r1', name: 'Aarav Sharma', uid: '237106010', roomNumber: 'B-302', outTime: 'Today, 05:00 PM', expectedInTime: 'Today, 07:00 PM', destination: 'Sadar Bazaar', contact: '9876543210', type: RosterType.gatepass, isOverdue: false),
      RosterStudent(id: 'r2', name: 'Vikram Singh', uid: '237106045', roomNumber: 'A-105', outTime: 'Today, 04:30 PM', expectedInTime: 'Today, 09:00 PM', destination: 'Sector 14 Fitness', contact: '9988776655', type: RosterType.gatepass, isOverdue: true),
      RosterStudent(id: 'r3', name: 'Gursajanpreet Singh', uid: '237106013', roomNumber: 'B-201', outTime: '24 Feb, 08:00 AM', expectedInTime: '28 Feb, 06:00 PM', destination: 'House 42, Model Town, Jalandhar', contact: '9123456780', type: RosterType.leave, isOverdue: false),
    ];
  }
}