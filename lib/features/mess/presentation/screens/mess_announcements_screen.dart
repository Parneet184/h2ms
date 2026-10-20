import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import 'create_mess_announcement_screen.dart';

// --- ENHANCED MODEL ---
class MessAnnouncement {
  final String id;
  final String title;
  final String content;
  final String date;
  final String audience; // Replaces old 'type' to match Warden logic
  final bool isUrgent;   // Replaces old 'type' to match Warden logic
  final String? attachmentName;

  MessAnnouncement({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.audience,
    this.isUrgent = false,
    this.attachmentName,
  });
}

class MessAnnouncementsScreen extends ConsumerStatefulWidget {
  const MessAnnouncementsScreen({super.key});

  @override
  ConsumerState<MessAnnouncementsScreen> createState() => _MessAnnouncementsScreenState();
}

class _MessAnnouncementsScreenState extends ConsumerState<MessAnnouncementsScreen> {
  List<MessAnnouncement> _announcements = [];

  @override
  void initState() {
    super.initState();
    _announcements = _generateMockAnnouncements();
  }

  void _deleteAnnouncement(String id) {
    setState(() {
      _announcements.removeWhere((a) => a.id == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Announcement deleted'), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mess Announcements'),
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: _announcements.isEmpty
          ? const Center(child: Text('No announcements found.', style: TextStyle(color: AppColors.textSecondary)))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _announcements.length,
        itemBuilder: (context, index) {
          final announcement = _announcements[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: announcement.isUrgent ? AppColors.error.withOpacity(0.5) : Colors.grey.shade300),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Badges & Delete Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: announcement.isUrgent ? AppColors.error.withOpacity(0.1) : AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(announcement.isUrgent ? Icons.warning_amber_rounded : Icons.restaurant,
                                size: 14, color: announcement.isUrgent ? AppColors.error : AppColors.primary),
                            const SizedBox(width: 4),
                            Text(
                                announcement.isUrgent ? 'URGENT: ${announcement.audience.toUpperCase()}' : announcement.audience.toUpperCase(),
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: announcement.isUrgent ? AppColors.error : AppColors.primary)
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                        onPressed: () => _deleteAnnouncement(announcement.id),
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      )
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Title & Date
                  Text(announcement.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text(announcement.date, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 12),

                  // Content
                  Text(announcement.content, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4)),

                  // Attachment
                  if (announcement.attachmentName != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
                      child: Row(
                        children: [
                          const Icon(Icons.picture_as_pdf, size: 20, color: AppColors.error),
                          const SizedBox(width: 8),
                          Expanded(child: Text(announcement.attachmentName!, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
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
      ),

      // --- FLOATING ACTION BUTTON ---
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateMessAnnouncementScreen()));
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Notice', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // --- MOCK DATA ---
  List<MessAnnouncement> _generateMockAnnouncements() {
    return [
      MessAnnouncement(
        id: '1',
        title: 'New Winter Menu Published',
        content: 'Please find attached the official winter menu effective from next Monday. Note the timings have been adjusted.',
        date: 'Today, 8:00 AM',
        audience: 'All Students',
        attachmentName: 'Winter_Menu_2026.pdf',
      ),
      MessAnnouncement(
        id: '2',
        title: 'Water Supply Issue in Kitchen',
        content: 'Lunch preparation is slightly delayed due to a temporary water supply cut. Lunch will be served starting 1:30 PM today.',
        date: 'Yesterday, 11:30 AM',
        audience: 'Boys Hostel', // Targeted specifically at the Boys Mess
        isUrgent: true,          // Flagged as urgent!
      ),
      MessAnnouncement(
        id: '3',
        title: 'Dinner Menu Update',
        content: 'Paneer Butter Masala has been replaced with Kadhai Paneer for tonight\'s dinner due to ingredient availability.',
        date: 'Mar 13, 4:30 PM',
        audience: 'All Students',
      ),
    ];
  }
}