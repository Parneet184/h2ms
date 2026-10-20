// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../../../core/constants/app_colors.dart';
// import '../application/notice_providers.dart';
// import 'notice_detail_screen.dart';
//
// class NoticesListScreen extends ConsumerWidget {
//   const NoticesListScreen({super.key});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final notices = ref.watch(noticesProvider);
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Notice Board'),
//       ),
//       body: ListView.builder(
//         padding: const EdgeInsets.all(16),
//         itemCount: notices.length,
//         itemBuilder: (context, index) {
//           final notice = notices[index];
//           return Card(
//             margin: const EdgeInsets.only(bottom: 12),
//             elevation: 1,
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             child: InkWell(
//               borderRadius: BorderRadius.circular(12),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => NoticeDetailScreen(notice: notice)),
//                 );
//               },
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           _getRelativeDate(notice.postedAt),
//                           style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold),
//                         ),
//                         if (notice.hasAttachment)
//                           const Icon(Icons.attachment, size: 16, color: AppColors.textSecondary),
//                       ],
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       notice.title,
//                       style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       notice.shortDescription,
//                       style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   String _getRelativeDate(DateTime dt) {
//     final now = DateTime.now();
//     final difference = now.difference(dt);
//     if (difference.inDays == 0) return 'Today';
//     if (difference.inDays == 1) return 'Yesterday';
//     return '${difference.inDays} days ago';
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../application/notice_providers.dart';
import 'notice_detail_screen.dart';

class NoticesListScreen extends ConsumerWidget {
  const NoticesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noticesAsync = ref.watch(noticesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notice Board'),
      ),
      backgroundColor: AppColors.background,
      body: noticesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text('Error loading notices: $err', style: const TextStyle(color: AppColors.error)),
        ),
        data: (notices) {
          if (notices.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.campaign_outlined, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text('No notices available', style: TextStyle(fontSize: 16, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notices.length,
            itemBuilder: (context, index) {
              final notice = notices[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => NoticeDetailScreen(notice: notice)),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _getRelativeDate(notice.postedAt),
                              style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold),
                            ),
                            if (notice.hasAttachment)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.attachment, size: 14, color: AppColors.primary),
                                    SizedBox(width: 4),
                                    Text('Attachment', style: TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          notice.title,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          notice.shortDescription,
                          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.3),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _getRelativeDate(DateTime dt) {
    final now = DateTime.now();
    final difference = now.difference(dt);
    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    return '${difference.inDays} days ago';
  }
}