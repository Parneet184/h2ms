import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../application/room_info_providers.dart';
import '../../domain/room_info_model.dart';

class RoomInfoScreen extends ConsumerWidget {
  const RoomInfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fetch the room data from the provider
    final roomData = ref.watch(roomInfoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Room Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. ROOM HEADER ---
            _buildRoomHeader(roomData),
            const SizedBox(height: 32),

            // --- 2. ROOMMATES SECTION ---
            const Text(
              'My Roommates',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            if (roomData.roommates.isEmpty)
              const Text('You have no roommates assigned yet.', style: TextStyle(color: AppColors.textSecondary))
            else
              ...roomData.roommates.map((roommate) => _buildRoommateCard(roommate)),
            const SizedBox(height: 32),

            // --- 3. FURNITURE INVENTORY SECTION ---
            const Text(
              'Furniture Inventory',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            const Text(
              'Official inventory allocated to this room. Report missing items to the warden.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            _buildFurnitureGrid(roomData.furniture),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- UI BUILDER METHODS ---

  Widget _buildRoomHeader(RoomInfoModel room) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.meeting_room, size: 48, color: Colors.white),
          const SizedBox(height: 8),
          Text(
            'Room ${room.roomNumber}',
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // AC / Non-AC Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(room.isAC ? Icons.ac_unit : Icons.thermostat, size: 16, color: Colors.white),
                    const SizedBox(width: 6),
                    Text(
                      room.isAC ? 'AC Room' : 'Non-AC Room',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Capacity Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.group, size: 16, color: Colors.white),
                    const SizedBox(width: 6),
                    Text(
                      '${room.capacity} Seater',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildRoommateCard(RoommateModel roommate) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primaryLight.withOpacity(0.2),
              child: const Icon(Icons.person, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    roommate.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${roommate.uid} • ${roommate.department}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            // Contact Button
            IconButton(
              icon: const Icon(Icons.phone, color: AppColors.success),
              onPressed: () {
                // In a real app, this would launch the phone dialer
                debugPrint('Calling ${roommate.contact}...');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFurnitureGrid(RoomFurniture furniture) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 2.0,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildFurnitureItem('Beds', furniture.beds, Icons.bed),
        _buildFurnitureItem('Tables', furniture.tables, Icons.desk),
        _buildFurnitureItem('Chairs', furniture.chairs, Icons.chair),
        _buildFurnitureItem('Almirahs', furniture.almirahs, Icons.door_sliding),
      ],
    );
  }

  Widget _buildFurnitureItem(String name, int count, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28, color: AppColors.textSecondary),
          const SizedBox(width: 16),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                count.toString(),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              Text(
                name,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}