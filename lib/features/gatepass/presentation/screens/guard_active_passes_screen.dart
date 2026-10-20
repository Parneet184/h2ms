// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
//
// import '../../data/pass_repository.dart';
// import '../../../../core/constants/app_colors.dart';
// import '../../../../core/constants/enums.dart';
// import '../../domain/pass_model.dart';
// import '../../application/pass_providers.dart';
// import '../../data/pass_repository.dart';
//
// class GuardActivePassesScreen extends ConsumerWidget {
//   const GuardActivePassesScreen({super.key});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // 1. Watch only the ACTIVE passes from the database
//     final activePasses = ref.watch(activePassesProvider);
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Students Currently Out'),
//       ),
//       body: activePasses.isEmpty
//           ? _buildEmptyState()
//           : ListView.builder(
//         padding: const EdgeInsets.all(16),
//         itemCount: activePasses.length,
//         itemBuilder: (context, index) {
//           final pass = activePasses[index];
//           return _buildActivePassCard(context, ref, pass);
//         },
//       ),
//     );
//   }
//
//   // --- UI HELPER METHODS ---
//
//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.shield_outlined, size: 80, color: AppColors.success.withOpacity(0.5)),
//           const SizedBox(height: 16),
//           const Text(
//             'Campus Secure',
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             'All students are currently inside the campus.',
//             style: TextStyle(color: AppColors.textSecondary),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildActivePassCard(BuildContext context, WidgetRef ref, PassModel pass) {
//     // Check if the student is late (Current time is past Expected In Time)
//     final isOverdue = DateTime.now().isAfter(pass.expectedInTime);
//
//     return Card(
//       margin: const EdgeInsets.only(bottom: 16),
//       shape: RoundedRectangleBorder(
//         side: BorderSide(
//           // Red border if they are late, standard blue if they are on time
//           color: isOverdue ? AppColors.error : AppColors.primaryLight.withOpacity(0.3),
//           width: isOverdue ? 2 : 1,
//         ),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Header: Name and Room
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   child: Text(
//                     pass.studentName,
//                     style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
//                   ),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: AppColors.background,
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(
//                     'Room ${pass.roomNumber}',
//                     style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//
//             // Warning Banner if Overdue
//             if (isOverdue)
//               Container(
//                 margin: const EdgeInsets.only(bottom: 12),
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
//                 decoration: BoxDecoration(
//                   color: AppColors.error.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(6),
//                 ),
//                 child: const Row(
//                   children: [
//                     Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 16),
//                     SizedBox(width: 8),
//                     Text('OVERDUE - Student is late!', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 12)),
//                   ],
//                 ),
//               ),
//
//             // Timings Details
//             Row(
//               children: [
//                 const Icon(Icons.directions_walk, size: 16, color: AppColors.textSecondary),
//                 const SizedBox(width: 4),
//                 Text('Went out at: ${_formatTime(pass.actualOutTime ?? pass.requestedOutTime)}', style: const TextStyle(fontSize: 13)),
//               ],
//             ),
//             const SizedBox(height: 4),
//             Row(
//               children: [
//                 Icon(Icons.schedule, size: 16, color: isOverdue ? AppColors.error : AppColors.textSecondary),
//                 const SizedBox(width: 4),
//                 Text(
//                   'Expected back: ${_formatTime(pass.expectedInTime)}',
//                   style: TextStyle(fontSize: 13, color: isOverdue ? AppColors.error : AppColors.textPrimary, fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//
//             // Action Button
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton.icon(
//                 onPressed: () {
//                   // Mark the student as returned!
//                   ref.read(passRepositoryProvider).updatePassStatus(pass.id, PassStatus.expired);
//                   ref.invalidate(activePassesProvider);
//
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       content: Text('Student marked as safely returned.'),
//                       backgroundColor: AppColors.success,
//                       duration: Duration(seconds: 2),
//                     ),
//                   );
//                 },
//                 icon: const Icon(Icons.how_to_reg, color: Colors.white),
//                 label: const Text('Mark Student Returned', style: TextStyle(fontWeight: FontWeight.bold)),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.primary,
//                   padding: const EdgeInsets.symmetric(vertical: 12),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // Helper just for time since guards mostly care about today's hours
//   String _formatTime(DateTime dt) {
//     final time = TimeOfDay.fromDateTime(dt);
//     final period = time.period == DayPeriod.am ? 'AM' : 'PM';
//     final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
//     final minute = time.minute.toString().padLeft(2, '0');
//     return '$hour:$minute $period';
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/enums.dart';
import '../../domain/pass_model.dart';
import '../../application/pass_providers.dart';
import '../../data/pass_repository.dart';

class GuardActivePassesScreen extends ConsumerWidget {
  const GuardActivePassesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Watch only the ACTIVE passes from the database (Returns an AsyncValue)
    final activePassesAsync = ref.watch(activePassesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Students Currently Out'),
      ),
      body: activePassesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (activePasses) {
          if (activePasses.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: activePasses.length,
            itemBuilder: (context, index) {
              final pass = activePasses[index];
              return _buildActivePassCard(context, ref, pass);
            },
          );
        },
      ),
    );
  }

  // --- UI HELPER METHODS ---

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shield_outlined, size: 80, color: AppColors.success.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          const Text(
            'Campus Secure',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          const Text(
            'All students are currently inside the campus.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildActivePassCard(BuildContext context, WidgetRef ref, PassModel pass) {
    final isOverdue = DateTime.now().isAfter(pass.expectedInTime);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: isOverdue ? AppColors.error : AppColors.primaryLight.withValues(alpha: 0.3),
          width: isOverdue ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    pass.studentName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Room ${pass.roomNumber}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (isOverdue)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 16),
                    SizedBox(width: 8),
                    Text('OVERDUE - Student is late!', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ),
            Row(
              children: [
                const Icon(Icons.directions_walk, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text('Went out at: ${_formatTime(pass.actualOutTime ?? pass.requestedOutTime)}', style: const TextStyle(fontSize: 13)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: isOverdue ? AppColors.error : AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  'Expected back: ${_formatTime(pass.expectedInTime)}',
                  style: TextStyle(fontSize: 13, color: isOverdue ? AppColors.error : AppColors.textPrimary, fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  try {
                    await ref.read(passRepositoryProvider).updatePassStatus(pass.id, PassStatus.expired);
                    ref.invalidate(activePassesProvider);

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Student marked as safely returned.'),
                          backgroundColor: AppColors.success,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.how_to_reg, color: Colors.white),
                label: const Text('Mark Student Returned', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final time = TimeOfDay.fromDateTime(dt);
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }
}