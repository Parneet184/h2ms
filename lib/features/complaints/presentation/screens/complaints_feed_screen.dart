import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'new_complaint_screen.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/enums.dart';
import '../../../auth/application/auth_provider.dart';
import '../../application/complaint_providers.dart';
import '../../domain/complaint_model.dart';


class ComplaintsFeedScreen extends ConsumerStatefulWidget {
  final bool isMessIssue;

  const ComplaintsFeedScreen({super.key, required this.isMessIssue});

  @override
  ConsumerState<ComplaintsFeedScreen> createState() => _ComplaintsFeedScreenState();
}

class _ComplaintsFeedScreenState extends ConsumerState<ComplaintsFeedScreen> {
  ComplaintStatus? _statusFilter;
  String _sortMode = 'recent';

  @override
  Widget build(BuildContext context) {
    final complaintsAsync = ref.watch(complaintsStreamProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.isMessIssue ? 'Mess Issues' : 'Hostel Complaints'),
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
            tabs: [
              Tab(text: 'Public Feed'),
              Tab(text: 'My Complaints'),
            ],
          ),
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.sort, size: 20, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      DropdownButton<String>(
                        value: _sortMode,
                        underline: const SizedBox(),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 14),
                        items: const [
                          DropdownMenuItem(value: 'recent', child: Text('Most Recent')),
                          DropdownMenuItem(value: 'top', child: Text('Top Rated')),
                        ],
                        onChanged: (val) => setState(() => _sortMode = val!),
                      ),
                    ],
                  ),
                  PopupMenuButton<ComplaintStatus?>(
                    icon: const Icon(Icons.filter_list, color: AppColors.textSecondary),
                    tooltip: 'Filter by Status',
                    onSelected: (val) => setState(() => _statusFilter = val),
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: null, child: Text('All Statuses')),
                      const PopupMenuItem(value: ComplaintStatus.open, child: Text('Open')),
                      const PopupMenuItem(value: ComplaintStatus.inProgress, child: Text('In Progress')),
                      const PopupMenuItem(value: ComplaintStatus.resolved, child: Text('Resolved')),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: complaintsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: AppColors.error))),
                data: (allComplaints) => TabBarView(
                  children: [
                    _buildComplaintList(allComplaints, isMyComplaintsTab: false),
                    _buildComplaintList(allComplaints, isMyComplaintsTab: true),
                  ],
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NewComplaintScreen(isMessIssue: widget.isMessIssue)),
            );
          },
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('New Issue', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildComplaintList(List<ComplaintModel> allComplaints, {required bool isMyComplaintsTab}) {
    final currentUser = ref.watch(currentUserProvider);

    List<ComplaintModel> filteredList = allComplaints.where((c) {
      bool isThisMessCategory = (c.category == ComplaintCategory.foodQuality ||
          c.category == ComplaintCategory.staffBehavior ||
          c.category == ComplaintCategory.messCleanliness);

      if (widget.isMessIssue && !isThisMessCategory && c.category != ComplaintCategory.other) return false;
      if (!widget.isMessIssue && isThisMessCategory) return false;

      if (isMyComplaintsTab) {
        if (c.authorUid != currentUser?.uid) return false;
      } else {
        if (c.isPrivate && c.authorUid != currentUser?.uid) return false;
      }

      if (_statusFilter != null && c.status != _statusFilter) return false;

      return true;
    }).toList();

    if (_sortMode == 'recent') {
      filteredList.sort((a, b) => b.postedAt.compareTo(a.postedAt));
    } else if (_sortMode == 'top') {
      filteredList.sort((a, b) => b.upvotes.compareTo(a.upvotes));
    }

    if (filteredList.isEmpty) {
      return Center(
        child: Text(
          isMyComplaintsTab ? 'You haven\'t posted any issues yet.' : 'No public issues found.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        return _buildComplaintCard(context, ref, filteredList[index]);
      },
    );
  }

  Widget _buildComplaintCard(BuildContext context, WidgetRef ref, ComplaintModel complaint) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade300)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                IconButton(
                  icon: Icon(
                    complaint.isPrivate ? Icons.lock : Icons.keyboard_arrow_up,
                    size: complaint.isPrivate ? 22 : 32,
                    color: complaint.isPrivate ? Colors.grey : (complaint.hasUpvoted ? Colors.green : AppColors.textSecondary),
                  ),
                  onPressed: () {
                    if (!complaint.isPrivate) {
                      ref.read(complaintRepositoryProvider).toggleUpvote(complaint.id, complaint.upvotes, complaint.hasUpvoted);
                    }
                  },
                ),
                Text(
                  complaint.isPrivate ? 'Priv' : '${complaint.upvotes}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: complaint.hasUpvoted ? Colors.green : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(complaint.status).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          complaint.status.name.toUpperCase(),
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _getStatusColor(complaint.status)),
                        ),
                      ),
                      Text(
                        _getTimeAgo(complaint.postedAt),
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    complaint.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    complaint.description,
                    style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(complaint.isPrivate ? Icons.lock : Icons.public, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        '${complaint.authorName} • Room ${complaint.roomNumber}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  if (complaint.assignedTo != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Assigned to: ${complaint.assignedTo}',
                      style: const TextStyle(fontSize: 11, color: Colors.indigo, fontWeight: FontWeight.bold),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(ComplaintStatus status) {
    if (status == ComplaintStatus.open) return AppColors.error;
    if (status == ComplaintStatus.inProgress) return AppColors.warning;
    return AppColors.success;
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 0) return '${difference.inDays}d ago';
    if (difference.inHours > 0) return '${difference.inHours}h ago';
    if (difference.inMinutes > 0) return '${difference.inMinutes}m ago';
    return 'Just now';
  }
}