// import 'package:flutter/material.dart';
// import '../../../../core/constants/app_colors.dart';
// import '../domain/notice_model.dart';
//
// class NoticeDetailScreen extends StatelessWidget {
//   final NoticeModel notice;
//
//   const NoticeDetailScreen({super.key, required this.notice});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Notice Details'),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // 1. Header Info
//             Text(
//               notice.title,
//               style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
//             ),
//             const SizedBox(height: 16),
//
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: AppColors.background,
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: Colors.grey.shade300),
//               ),
//               child: Column(
//                 children: [
//                   _buildInfoRow(Icons.person, 'Posted By:', notice.postedBy),
//                   const Divider(height: 16),
//                   _buildInfoRow(Icons.calendar_today, 'Date:', _formatDate(notice.postedAt)),
//                   const Divider(height: 16),
//                   _buildInfoRow(Icons.access_time, 'Time:', _formatTime(notice.postedAt)),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 24),
//
//             // 2. Full Description
//             const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
//             const SizedBox(height: 12),
//             Text(
//               notice.fullDescription,
//               style: const TextStyle(fontSize: 15, color: AppColors.textPrimary, height: 1.5),
//             ),
//             const SizedBox(height: 32),
//
//             // 3. Document Attachment (If any)
//             if (notice.hasAttachment) ...[
//               const Text('Attachments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
//               const SizedBox(height: 12),
//               Container(
//                 decoration: BoxDecoration(
//                   border: Border.all(color: AppColors.primaryLight.withOpacity(0.5)),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Column(
//                   children: [
//                     // Simulated PDF Preview Area
//                     Container(
//                       height: 120,
//                       width: double.infinity,
//                       decoration: BoxDecoration(
//                         color: Colors.grey.shade100,
//                         borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
//                       ),
//                       child: const Center(
//                         child: Icon(Icons.picture_as_pdf, size: 48, color: Colors.redAccent),
//                       ),
//                     ),
//                     const Divider(height: 1),
//                     // File Name & Download Button
//                     Padding(
//                       padding: const EdgeInsets.all(12.0),
//                       child: Row(
//                         children: [
//                           Expanded(
//                             child: Text(
//                               notice.attachmentName ?? 'Document.pdf',
//                               style: const TextStyle(fontWeight: FontWeight.bold),
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                           ElevatedButton.icon(
//                             onPressed: () {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(
//                                     content: Text('Downloading PDF...'),
//                                     backgroundColor: AppColors.primary
//                                 ),
//                               );
//                             },
//                             icon: const Icon(Icons.download, size: 18, color: Colors.white),
//                             label: const Text('Download'),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: AppColors.primary,
//                               padding: const EdgeInsets.symmetric(horizontal: 16),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//             const SizedBox(height: 40),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildInfoRow(IconData icon, String label, String value) {
//     return Row(
//       children: [
//         Icon(icon, size: 18, color: AppColors.textSecondary),
//         const SizedBox(width: 8),
//         Text(label, style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
//         const SizedBox(width: 8),
//         Expanded(
//           child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary), textAlign: TextAlign.right),
//         ),
//       ],
//     );
//   }
//
//   String _formatDate(DateTime dt) {
//     return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
//   }
//
//   String _formatTime(DateTime dt) {
//     final time = TimeOfDay.fromDateTime(dt);
//     final period = time.period == DayPeriod.am ? 'AM' : 'PM';
//     final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
//     final minute = time.minute.toString().padLeft(2, '0');
//     return '$hour:$minute $period';
//   }
// }

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../domain/notice_model.dart';

class NoticeDetailScreen extends StatelessWidget {
  final NoticeModel notice;

  const NoticeDetailScreen({super.key, required this.notice});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notice Details'),
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Info
            Text(
              notice.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.2),
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _buildInfoRow(Icons.person_outline, 'Posted By:', notice.postedBy),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(height: 1)),
                  _buildInfoRow(Icons.calendar_today_outlined, 'Date:', _formatDate(notice.postedAt)),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(height: 1)),
                  _buildInfoRow(Icons.access_time_outlined, 'Time:', _formatTime(notice.postedAt)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 2. Full Description
            const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            Text(
              notice.fullDescription,
              style: const TextStyle(fontSize: 15, color: AppColors.textPrimary, height: 1.6),
            ),
            const SizedBox(height: 32),

            // 3. Document Attachment (If any)
            if (notice.hasAttachment) ...[
              const Text('Attachments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Container(
                      height: 100,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                      ),
                      child: const Center(
                        child: Icon(Icons.picture_as_pdf, size: 42, color: Colors.redAccent),
                      ),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              notice.attachmentName ?? 'Document.pdf',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Downloading document...'),
                                    backgroundColor: AppColors.primary
                                ),
                              );
                            },
                            icon: const Icon(Icons.download, size: 16, color: Colors.white),
                            label: const Text('Download'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500, fontSize: 13)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 13), textAlign: TextAlign.right),
        ),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  String _formatTime(DateTime dt) {
    final time = TimeOfDay.fromDateTime(dt);
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }
}