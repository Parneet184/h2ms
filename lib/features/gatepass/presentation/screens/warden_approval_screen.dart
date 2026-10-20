// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
//
// import '../../../../core/constants/app_colors.dart';
// import '../../../../core/constants/enums.dart';
// import '../../domain/pass_model.dart';
// import '../../application/pass_providers.dart';
// import '../../data/pass_repository.dart';
//
// class WardenApprovalScreen extends ConsumerWidget {
//   const WardenApprovalScreen({super.key});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // 1. Watch the pending passes from our dummy database
//     final pendingPasses = ref.watch(pendingPassesProvider);
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Pending Approvals'),
//       ),
//       body: pendingPasses.isEmpty
//           ? _buildEmptyState()
//           : ListView.builder(
//         padding: const EdgeInsets.all(16),
//         itemCount: pendingPasses.length,
//         itemBuilder: (context, index) {
//           final pass = pendingPasses[index];
//           return _buildPassCard(context, ref, pass);
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
//           Icon(Icons.check_circle_outline, size: 80, color: AppColors.success.withOpacity(0.5)),
//           const SizedBox(height: 16),
//           const Text(
//             'All caught up!',
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             'No pending gatepasses or leaves.',
//             style: TextStyle(color: AppColors.textSecondary),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildPassCard(BuildContext context, WidgetRef ref, PassModel pass) {
//     // Determine if it's a Gatepass (Short) or Leave (Long)
//     final isLeave = pass.type == PassType.leave;
//
//     return Card(
//       margin: const EdgeInsets.only(bottom: 16),
//       shape: RoundedRectangleBorder(
//         side: BorderSide(
//           color: isLeave ? AppColors.warning.withOpacity(0.5) : AppColors.primaryLight.withOpacity(0.3),
//           width: 1,
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
//             const SizedBox(height: 12),
//
//             // Badge for Pass Type
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//               decoration: BoxDecoration(
//                 color: isLeave ? AppColors.warning.withOpacity(0.2) : AppColors.primaryLight.withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(4),
//               ),
//               child: Text(
//                 isLeave ? 'LONG LEAVE' : 'SHORT GATEPASS',
//                 style: TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.bold,
//                   color: isLeave ? Colors.orange[800] : AppColors.primary,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 12),
//
//             // Details
//             const Text('Reason:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
//             Text(pass.reason, style: const TextStyle(fontSize: 14)),
//             const SizedBox(height: 12),
//
//             Row(
//               children: [
//                 const Icon(Icons.output, size: 16, color: AppColors.textSecondary),
//                 const SizedBox(width: 4),
//                 Text(_formatDateTime(pass.requestedOutTime), style: const TextStyle(fontSize: 13)),
//               ],
//             ),
//             const SizedBox(height: 4),
//             Row(
//               children: [
//                 const Icon(Icons.login, size: 16, color: AppColors.textSecondary),
//                 const SizedBox(width: 4),
//                 Text(_formatDateTime(pass.expectedInTime), style: const TextStyle(fontSize: 13)),
//               ],
//             ),
//             const SizedBox(height: 16),
//             const Divider(height: 1),
//             const SizedBox(height: 12),
//
//             // Action Buttons
//             Row(
//               children: [
//                 Expanded(
//                   child: OutlinedButton.icon(
//                     onPressed: () => _handleAction(context, ref, pass.id, PassStatus.rejected),
//                     icon: const Icon(Icons.close, color: AppColors.error),
//                     label: const Text('Reject', style: TextStyle(color: AppColors.error)),
//                     style: OutlinedButton.styleFrom(
//                       side: const BorderSide(color: AppColors.error),
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     onPressed: () => _handleAction(context, ref, pass.id, PassStatus.approved),
//                     icon: const Icon(Icons.check, color: Colors.white),
//                     label: const Text('Approve'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.success,
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // --- LOGIC METHODS ---
//
//   void _handleAction(BuildContext context, WidgetRef ref, String passId, PassStatus newStatus) {
//     // 1. Update the pass in our dummy database
//     ref.read(passRepositoryProvider).updatePassStatus(passId, newStatus);
//
//     // 2. Force Riverpod to refresh the pending passes list to remove the card from the UI
//     ref.invalidate(pendingPassesProvider);
//
//     // 3. Show feedback
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(newStatus == PassStatus.approved ? 'Pass Approved!' : 'Pass Rejected!'),
//         backgroundColor: newStatus == PassStatus.approved ? AppColors.success : AppColors.error,
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }
//
//   String _formatDateTime(DateTime dt) {
//     final time = TimeOfDay.fromDateTime(dt);
//     final period = time.period == DayPeriod.am ? 'AM' : 'PM';
//     final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
//     final minute = time.minute.toString().padLeft(2, '0');
//     return '${dt.day}/${dt.month} at $hour:$minute $period';
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/enums.dart';
import '../../domain/pass_model.dart';
import '../../application/pass_providers.dart';
import '../../data/pass_repository.dart';

class WardenApprovalScreen extends ConsumerWidget {
  const WardenApprovalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Watch the pending passes (Returns an AsyncValue)
    final pendingPassesAsync = ref.watch(pendingPassesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Approvals'),
      ),
      // 2. Use .when to handle the loading state, the error state, and the final data
      body: pendingPassesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
        data: (pendingPasses) {
          if (pendingPasses.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pendingPasses.length,
            itemBuilder: (context, index) {
              final pass = pendingPasses[index];
              return _buildPassCard(context, ref, pass);
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
          Icon(Icons.check_circle_outline, size: 80, color: AppColors.success.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          const Text(
            'All caught up!',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          const Text(
            'No pending gatepasses or leaves.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildPassCard(BuildContext context, WidgetRef ref, PassModel pass) {
    final isLeave = pass.type == PassType.leave;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: isLeave ? AppColors.warning.withValues(alpha: 0.5) : AppColors.primaryLight.withValues(alpha: 0.3),
          width: 1,
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
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isLeave ? AppColors.warning.withValues(alpha: 0.2) : AppColors.primaryLight.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                isLeave ? 'LONG LEAVE' : 'SHORT GATEPASS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isLeave ? Colors.orange[800] : AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Reason:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            Text(pass.reason, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.output, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(_formatDateTime(pass.requestedOutTime), style: const TextStyle(fontSize: 13)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.login, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(_formatDateTime(pass.expectedInTime), style: const TextStyle(fontSize: 13)),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _handleAction(context, ref, pass.id, PassStatus.rejected),
                    icon: const Icon(Icons.close, color: AppColors.error),
                    label: const Text('Reject', style: TextStyle(color: AppColors.error)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _handleAction(context, ref, pass.id, PassStatus.approved),
                    icon: const Icon(Icons.check, color: Colors.white),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- LOGIC METHODS ---

  void _handleAction(BuildContext context, WidgetRef ref, String passId, PassStatus newStatus) async {
    // We added async/await here since the database call takes time
    try {
      await ref.read(passRepositoryProvider).updatePassStatus(passId, newStatus);
      ref.invalidate(pendingPassesProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(newStatus == PassStatus.approved ? 'Pass Approved!' : 'Pass Rejected!'),
            backgroundColor: newStatus == PassStatus.approved ? AppColors.success : AppColors.error,
            duration: const Duration(seconds: 2),
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
  }

  String _formatDateTime(DateTime dt) {
    final time = TimeOfDay.fromDateTime(dt);
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    return '${dt.day}/${dt.month} at $hour:$minute $period';
  }
}