import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'room_details_screen.dart';
import 'hostel_records_screen.dart'; // <-- THIS FIXES THE ERROR!

// --- MOCK DATA MODELS ---
class HostelStatsModel {
  final int totalRooms;
  final int totalBeds;
  final int occupiedBeds;

  final int totalStudents;
  final int totalStaff;

  final int oneSeaterCount;
  final int twoSeaterCount;
  final int threeSeaterCount;

  // Vacancy Tracking Lists
  final List<String> fullyEmptyRooms;
  final List<String> oneBedVacantRooms;
  final List<String> twoBedsVacantRooms;

  HostelStatsModel({
    required this.totalRooms,
    required this.totalBeds,
    required this.occupiedBeds,
    required this.totalStudents,
    required this.totalStaff,
    required this.oneSeaterCount,
    required this.twoSeaterCount,
    required this.threeSeaterCount,
    required this.fullyEmptyRooms,
    required this.oneBedVacantRooms,
    required this.twoBedsVacantRooms,
  });

  int get vacantBeds => totalBeds - occupiedBeds;
  double get occupancyRate => occupiedBeds / totalBeds;
}

class HostelStatsScreen extends StatelessWidget {
  const HostelStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Generate Mock Data
    final stats = HostelStatsModel(
      totalRooms: 250,
      totalBeds: 600,
      occupiedBeds: 542, // 530 students + 12 staff
      totalStudents: 530,
      totalStaff: 12,
      oneSeaterCount: 50,
      twoSeaterCount: 100,
      threeSeaterCount: 100,

      // Mock Vacancy Data (Format: Room Number [Total Capacity])
      fullyEmptyRooms: ['A-104 [1 Seater]', 'B-205 [2 Seater]', 'B-208 [2 Seater]', 'C-310 [3 Seater]'],
      oneBedVacantRooms: ['A-102 [2 Seater]', 'B-201 [2 Seater]', 'C-305 [3 Seater]', 'D-412 [3 Seater]', 'D-415 [3 Seater]'],
      twoBedsVacantRooms: ['C-308 [3 Seater]', 'D-401 [3 Seater]'],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hostel Statistics'),
        elevation: 0,
      ),
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. OVERALL OCCUPANCY BANNER ---
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Beds', style: TextStyle(color: Colors.white70, fontSize: 14)),
                          Text('${stats.totalBeds}', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold, height: 1.1)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Occupancy', style: TextStyle(color: Colors.white70, fontSize: 14)),
                          Text('${(stats.occupancyRate * 100).toStringAsFixed(1)}%', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, height: 1.1)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: stats.occupancyRate,
                      minHeight: 12,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMiniStat('Occupied', '${stats.occupiedBeds}', AppColors.success),
                      _buildMiniStat('Vacant', '${stats.vacantBeds}', Colors.white),
                      _buildMiniStat('Total Rooms', '${stats.totalRooms}', Colors.white70),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 32),

            // --- 2. VACANCY TRACKER ---
            const Text('Vacancy Tracker', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            _buildVacancyAccordion(
              context: context,
              title: 'Fully Empty Rooms',
              count: stats.fullyEmptyRooms.length,
              rooms: stats.fullyEmptyRooms,
              iconColor: AppColors.success,
              icon: Icons.meeting_room_outlined,
            ),
            const SizedBox(height: 12),
            _buildVacancyAccordion(
              context: context,
              title: '1 Bed Vacant',
              count: stats.oneBedVacantRooms.length,
              rooms: stats.oneBedVacantRooms,
              iconColor: AppColors.warning,
              icon: Icons.person_add_alt_1_outlined,
            ),
            const SizedBox(height: 12),
            _buildVacancyAccordion(
              context: context,
              title: '2 Beds Vacant',
              count: stats.twoBedsVacantRooms.length,
              rooms: stats.twoBedsVacantRooms,
              iconColor: Colors.deepOrange,
              icon: Icons.group_add_outlined,
            ),
            const SizedBox(height: 32),

            // --- 3. RESIDENT DEMOGRAPHICS ---
            const Text('Resident Demographics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildDemographicCard(title: 'Students', count: stats.totalStudents, icon: Icons.school, color: Colors.indigo),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDemographicCard(title: 'Teachers/Staff', count: stats.totalStaff, icon: Icons.badge, color: Colors.teal),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // --- 4. ROOM CONFIGURATION BREAKDOWN ---
            const Text('Room Configuration', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade300)),
              child: Column(
                children: [
                  _buildRoomConfigRow('Single Seater', stats.oneSeaterCount, Icons.person),
                  const Divider(height: 1),
                  _buildRoomConfigRow('Double Seater', stats.twoSeaterCount, Icons.people),
                  const Divider(height: 1),
                  _buildRoomConfigRow('Triple Seater', stats.threeSeaterCount, Icons.groups),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- UI HELPERS ---

  Widget _buildVacancyAccordion({
    required BuildContext context,
    required String title,
    required int count,
    required List<String> rooms,
    required Color iconColor,
    required IconData icon
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade300)),
      child: ExpansionTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        collapsedBackgroundColor: Colors.white,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
          child: Text('$count Rooms', style: TextStyle(color: iconColor, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: rooms.map((room) {
                // --- CLICKABLE ROOM CHIP ---
                return ActionChip(
                  label: Text(room, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  onPressed: () {
                    // Extract room number and physical capacity
                    String rawRoomNumber = room.split(' ')[0];
                    int capacity = 2; // Default
                    if (room.contains('1 Seater')) capacity = 1;
                    else if (room.contains('2 Seater')) capacity = 2;
                    else if (room.contains('3 Seater')) capacity = 3;

                    // Calculate how many students are STILL in the room
                    int occupantsCount = 0;
                    if (title.contains('Fully Empty')) {
                      occupantsCount = 0;
                    } else if (title.contains('1 Bed Vacant')) {
                      occupantsCount = capacity - 1;
                    } else if (title.contains('2 Beds Vacant')) {
                      occupantsCount = capacity - 2;
                    }

                    // Generate mock data for the existing occupants
                    List<StudentDirectoryModel> mockOccupants = [];
                    for (int i = 0; i < occupantsCount; i++) {
                      mockOccupants.add(StudentDirectoryModel(
                        name: 'Existing Occupant ${i + 1}',
                        uid: '23710600${i + 1}',
                        department: 'B.Tech',
                        roomNumber: rawRoomNumber,
                        contact: '9876543210',
                        parentContact: '9876543211',
                        year: 2,
                      ));
                    }

                    // Route to the Room Details Screen
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RoomDetailsScreen(
                              roomNumber: rawRoomNumber,
                              occupants: mockOccupants,
                              totalCapacity: capacity,
                            )
                        )
                    );
                  },
                );
              }).toList(),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: TextStyle(color: valueColor, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildDemographicCard({required String title, required int count, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text('$count', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, height: 1.1)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildRoomConfigRow(String type, int count, IconData icon) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 24),
              const SizedBox(width: 16),
              Text(type, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(20)),
            child: Text('$count Rooms', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}