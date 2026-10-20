import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'hostel_records_screen.dart';
import 'student_profile_screen.dart';

class RoomDetailsScreen extends StatelessWidget {
  final String roomNumber;
  final List<StudentDirectoryModel> occupants;
  final int totalCapacity; // NEW: Explicitly track how big the room is

  const RoomDetailsScreen({
    super.key,
    required this.roomNumber,
    required this.occupants,
    this.totalCapacity = 2, // Default to 2 for backward compatibility
  });

  @override
  Widget build(BuildContext context) {
    // Determine type based on total capacity, NOT current occupants
    final String roomType = totalCapacity == 1 ? 'Single Seater' : (totalCapacity == 2 ? 'Double Seater' : 'Triple Seater');
    final String occupantType = 'Student';

    return Scaffold(
      appBar: AppBar(
        title: Text('Room $roomNumber'),
        backgroundColor: Colors.indigo,
        elevation: 0,
      ),
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- ROOM OVERVIEW ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.indigo, borderRadius: BorderRadius.circular(16)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Room Category', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text(roomType, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                    child: Text(occupantType.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- CURRENT OCCUPANTS ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Current Occupants', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                // FIXED: Now displays correct capacity (e.g., 1 / 2)
                Text('${occupants.length} / $totalCapacity', style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),

            occupants.isEmpty
                ? Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.success.withOpacity(0.3))),
              child: const Column(
                children: [
                  Icon(Icons.check_circle_outline, color: AppColors.success, size: 32),
                  SizedBox(height: 8),
                  Text('Room is fully vacant and ready to be assigned.', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
                ],
              ),
            )
                : Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: occupants.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final student = occupants[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.indigo.withOpacity(0.1),
                      child: const Icon(Icons.person, color: Colors.indigo),
                    ),
                    title: Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('UID: ${student.uid}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => StudentProfileScreen(student: student)));
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 32),

            // --- FURNITURE & ASSETS ---
            const Text('Room Inventory (Assets)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
              child: Column(
                children: [
                  // FIXED: Asset count is based on Total Capacity, not Occupants
                  _buildAssetRow(Icons.bed, 'Beds (Iron)', totalCapacity),
                  const Divider(height: 24),
                  _buildAssetRow(Icons.desk, 'Study Tables', totalCapacity),
                  const Divider(height: 24),
                  _buildAssetRow(Icons.chair_alt, 'Study Chairs', totalCapacity),
                  const Divider(height: 24),
                  _buildAssetRow(Icons.door_sliding, 'Almirahs', totalCapacity),
                  const Divider(height: 24),
                  _buildAssetRow(Icons.mode_fan_off, 'Ceiling Fans', 1),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetRow(IconData icon, String label, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.grey.shade600, size: 20),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 15)),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
          child: Text('Qty: $count', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
        )
      ],
    );
  }
}