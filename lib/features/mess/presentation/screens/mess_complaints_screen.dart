import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';

// --- MODELS ---
enum ComplaintStatus { open, inProgress, solved }

class MessComplaint {
  final String id;
  final String studentName;
  final String title;
  final String description;
  final bool isPrivate;
  final int upvotes;
  final String date;
  ComplaintStatus status;
  String? adminReply;

  MessComplaint({
    required this.id,
    required this.studentName,
    required this.title,
    required this.description,
    required this.isPrivate,
    required this.upvotes,
    required this.date,
    this.status = ComplaintStatus.open,
    this.adminReply,
  });
}

class MessComplaintsScreen extends ConsumerStatefulWidget {
  const MessComplaintsScreen({super.key});

  @override
  ConsumerState<MessComplaintsScreen> createState() => _MessComplaintsScreenState();
}

class _MessComplaintsScreenState extends ConsumerState<MessComplaintsScreen> {
  // --- STATE ---
  List<MessComplaint> _complaints = [];

  // Filters
  String _statusFilter = 'All'; // All, Open, In Progress, Solved
  String _sortBy = 'Most Recent'; // Most Recent, Top Rated (Upvotes)

  // Inline Reply Tracking
  String? _activeReplyId;
  final TextEditingController _replyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _complaints = _generateMockComplaints();
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  // --- FILTER & SORT LOGIC ---
  List<MessComplaint> get _processedComplaints {
    List<MessComplaint> filtered = _complaints.where((c) {
      if (_statusFilter == 'All') return true;
      if (_statusFilter == 'Open') return c.status == ComplaintStatus.open;
      if (_statusFilter == 'In Progress') return c.status == ComplaintStatus.inProgress;
      if (_statusFilter == 'Solved') return c.status == ComplaintStatus.solved;
      return true;
    }).toList();

    if (_sortBy == 'Top Rated') {
      filtered.sort((a, b) => b.upvotes.compareTo(a.upvotes));
    } else {
      filtered.sort((a, b) => b.id.compareTo(a.id));
    }

    return filtered;
  }

  // --- ACTIONS ---

  void _progressStatus(MessComplaint complaint) {
    setState(() {
      if (complaint.status == ComplaintStatus.open) {
        complaint.status = ComplaintStatus.inProgress;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Marked as In Progress'), backgroundColor: AppColors.warning));
      } else if (complaint.status == ComplaintStatus.inProgress) {
        complaint.status = ComplaintStatus.solved;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Marked as Solved!'), backgroundColor: AppColors.success));
      }
    });
  }

  void _toggleReplyField(MessComplaint complaint) {
    setState(() {
      if (_activeReplyId == complaint.id) {
        // Close it if already open
        _activeReplyId = null;
      } else {
        // Open it and pre-fill existing reply if any
        _activeReplyId = complaint.id;
        _replyController.text = complaint.adminReply ?? '';
      }
    });
  }

  void _postReply(MessComplaint complaint) {
    if (_replyController.text.trim().isEmpty) return;

    setState(() {
      complaint.adminReply = _replyController.text.trim();
      // Auto-update status to In Progress if it was Open and we replied
      if (complaint.status == ComplaintStatus.open) {
        complaint.status = ComplaintStatus.inProgress;
      }
      _activeReplyId = null; // Close the inline field
    });

    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reply posted successfully'), backgroundColor: AppColors.primary)
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Filter & Sort', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const Divider(height: 32),

                  const Text('Status', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['All', 'Open', 'In Progress', 'Solved'].map((status) {
                      return ChoiceChip(
                        label: Text(status),
                        selected: _statusFilter == status,
                        selectedColor: AppColors.primaryLight.withOpacity(0.3),
                        onSelected: (selected) {
                          setSheetState(() => _statusFilter = status);
                          setState(() {});
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  const Text('Sort By', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['Most Recent', 'Top Rated'].map((sort) {
                      return ChoiceChip(
                        label: Text(sort),
                        selected: _sortBy == sort,
                        selectedColor: Colors.grey.shade300,
                        onSelected: (selected) {
                          setSheetState(() => _sortBy = sort);
                          setState(() {});
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --- UI BUILDER ---

  @override
  Widget build(BuildContext context) {
    final displayedComplaints = _processedComplaints;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Complaints'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_statusFilter != 'All' || _sortBy != 'Most Recent')
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: AppColors.primaryLight.withOpacity(0.2),
              child: Text(
                'Showing: $_statusFilter • Sorted by: $_sortBy',
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),

          Expanded(
            child: displayedComplaints.isEmpty
                ? const Center(child: Text('No complaints found.', style: TextStyle(color: AppColors.textSecondary)))
                : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: displayedComplaints.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return _buildComplaintCard(displayedComplaints[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintCard(MessComplaint complaint) {
    Color statusColor;
    String statusText;
    switch (complaint.status) {
      case ComplaintStatus.open:
        statusColor = AppColors.error;
        statusText = 'OPEN';
        break;
      case ComplaintStatus.inProgress:
        statusColor = AppColors.warning;
        statusText = 'IN PROGRESS';
        break;
      case ComplaintStatus.solved:
        statusColor = AppColors.success;
        statusText = 'SOLVED';
        break;
    }

    final bool isReplying = _activeReplyId == complaint.id;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER: Badges & Upvotes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 10)),
                    ),
                    const SizedBox(width: 8),
                    if (complaint.isPrivate)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
                        child: const Row(
                          children: [
                            Icon(Icons.lock, size: 12, color: AppColors.textSecondary),
                            SizedBox(width: 4),
                            Text('PRIVATE', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 10)),
                          ],
                        ),
                      ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.thumb_up_alt_outlined, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text('${complaint.upvotes}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                  ],
                )
              ],
            ),
            const SizedBox(height: 12),

            // CONTENT
            Text(complaint.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            Text(complaint.description, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4)),
            const SizedBox(height: 12),

            // USER INFO
            Row(
              children: [
                const Icon(Icons.person, size: 14, color: AppColors.primary),
                const SizedBox(width: 4),
                Text('${complaint.isPrivate ? "Anonymous" : complaint.studentName} • ${complaint.date}', style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w500)),
              ],
            ),

            // EXISTING ADMIN REPLY
            if (complaint.adminReply != null && complaint.adminReply!.isNotEmpty && !isReplying) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.admin_panel_settings, size: 16, color: AppColors.success),
                        const SizedBox(width: 4),
                        Text('Mess Incharge Reply ${complaint.isPrivate ? "(Private)" : ""}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.success)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(complaint.adminReply!, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                  ],
                ),
              )
            ],

            const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider()),

            // --- INLINE REPLY OR ACTION BUTTONS ---
            if (isReplying)
              _buildInlineReplyUI(complaint)
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _toggleReplyField(complaint),
                      icon: Icon(complaint.adminReply == null || complaint.adminReply!.isEmpty ? Icons.reply : Icons.edit, size: 18),
                      label: Text(complaint.adminReply == null || complaint.adminReply!.isEmpty ? 'Reply' : 'Edit Reply'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),

                  // SMART STATUS BUTTON (Hidden if already solved)
                  if (complaint.status != ComplaintStatus.solved) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _progressStatus(complaint),
                        icon: Icon(complaint.status == ComplaintStatus.open ? Icons.pending_actions : Icons.check_circle, color: Colors.white, size: 18),
                        label: Text(complaint.status == ComplaintStatus.open ? 'Mark In Progress' : 'Mark Solved', style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: complaint.status == ComplaintStatus.open ? AppColors.warning : AppColors.success,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ]
                ],
              ),
          ],
        ),
      ),
    );
  }

  // Extracts the inline text field UI to keep the build method clean
  Widget _buildInlineReplyUI(MessComplaint complaint) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(complaint.isPrivate ? Icons.lock : Icons.public, color: AppColors.primary, size: 16),
              const SizedBox(width: 8),
              Text(
                  complaint.isPrivate ? 'Replying Privately to Anonymous...' : 'Replying Publicly...',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13)
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _replyController,
            autofocus: true, // Automatically pops open the keyboard
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Type your official response here...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => _toggleReplyField(complaint),
                child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _postReply(complaint),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Post Reply', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          )
        ],
      ),
    );
  }

  // --- MOCK DATA ---
  List<MessComplaint> _generateMockComplaints() {
    return [
      MessComplaint(
        id: '4',
        studentName: 'Aarav Sharma',
        title: 'Water cooler on Ground Floor is leaking',
        description: 'The tap on the left side of the ground floor water cooler is broken and continuously dripping water. It is creating a puddle.',
        isPrivate: false,
        upvotes: 45,
        date: 'Today, 10:00 AM',
        status: ComplaintStatus.open,
      ),
      MessComplaint(
        id: '3',
        studentName: 'Gursajanpreet Singh',
        title: 'Need more plates during dinner rush',
        description: 'Between 8:00 PM and 8:30 PM, we always run out of plates and have to wait 10 minutes for washed plates to arrive.',
        isPrivate: false,
        upvotes: 112,
        date: 'Yesterday',
        status: ComplaintStatus.inProgress,
        adminReply: 'We have ordered 100 new steel plates. They will arrive by next week. Until then, kitchen staff has been instructed to wash plates faster during peak hours.',
      ),
      MessComplaint(
        id: '2',
        studentName: 'Neha Gupta',
        title: 'Stomach ache after eating yesterday\'s lunch',
        description: 'I think the paneer yesterday was spoiled. Me and my roommate both have an upset stomach today.',
        isPrivate: true, // PRIVATE COMPLAINT
        upvotes: 0,
        date: 'Monday',
        status: ComplaintStatus.open,
      ),
      MessComplaint(
        id: '1',
        studentName: 'Vikram Singh',
        title: 'Flies in the dining hall',
        description: 'There are a lot of flies near the dustbin area. Need pest control or better closed bins.',
        isPrivate: false,
        upvotes: 89,
        date: 'Last Friday',
        status: ComplaintStatus.solved,
        adminReply: 'Pest control was conducted on Sunday. We have also replaced the open bins with pedal-operated closed bins.',
      ),
    ];
  }
}