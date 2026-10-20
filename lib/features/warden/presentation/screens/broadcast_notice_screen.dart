import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../notices/application/notice_providers.dart';
import '../../../notices/domain/notice_model.dart';
import 'create_warden_notice_screen.dart';

class BroadcastNoticeScreen extends ConsumerStatefulWidget {
  const BroadcastNoticeScreen({super.key});

  @override
  ConsumerState<BroadcastNoticeScreen> createState() => _BroadcastNoticeScreenState();
}

class _BroadcastNoticeScreenState extends ConsumerState<BroadcastNoticeScreen> {
  bool _isDeleting = false;

  Future<void> _deleteNotice(String id) async {
    setState(() => _isDeleting = true);
    try {
      await ref.read(noticeRepositoryProvider).deleteNotice(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notice deleted successfully'), backgroundColor: AppColors.error),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting notice: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final noticesAsync = ref.watch(noticesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Broadcasts & Notices'),
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: noticesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading notices: $err', style: const TextStyle(color: AppColors.error))),
        data: (notices) {
          if (notices.isEmpty) {
            return const Center(child: Text('No announcements found.', style: TextStyle(color: AppColors.textSecondary)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notices.length,
            itemBuilder: (context, index) {
              final notice = notices[index];
              // You can encode audience/urgency in fullDescription or store them as custom metadata.
              // For now, we check tags or treat standard fields cleanly.
              final bool isUrgent = notice.title.toLowerCase().contains('urgent');

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: isUrgent ? AppColors.error.withValues(alpha: 0.5) : Colors.grey.shade300),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isUrgent ? AppColors.error.withValues(alpha: 0.1) : AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(isUrgent ? Icons.warning_amber_rounded : Icons.campaign,
                                    size: 14, color: isUrgent ? AppColors.error : AppColors.primary),
                                const SizedBox(width: 4),
                                Text(
                                  isUrgent ? 'URGENT NOTICE' : 'HOSTEL ANNOUNCEMENT',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isUrgent ? AppColors.error : AppColors.primary),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                            onPressed: _isDeleting ? null : () => _deleteNotice(notice.id),
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                          )
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(notice.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      const SizedBox(height: 4),
                      Text('Posted by ${notice.postedBy}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 12),
                      Text(notice.fullDescription, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4)),
                      if (notice.hasAttachment && notice.attachmentName != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
                          child: Row(
                            children: [
                              const Icon(Icons.picture_as_pdf, size: 20, color: AppColors.error),
                              const SizedBox(width: 8),
                              Expanded(child: Text(notice.attachmentName!, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                              const SizedBox(width: 8),
                              const Icon(Icons.download, size: 16, color: AppColors.textSecondary),
                            ],
                          ),
                        )
                      ]
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateWardenNoticeScreen()));
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Notice', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}