import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/enums.dart';
import '../../../complaints/application/complaint_providers.dart';
import '../../../complaints/domain/complaint_model.dart';

class HostelComplaintsScreen extends ConsumerStatefulWidget {
  const HostelComplaintsScreen({super.key});

  @override
  ConsumerState<HostelComplaintsScreen> createState() => _HostelComplaintsScreenState();
}

class _HostelComplaintsScreenState extends ConsumerState<HostelComplaintsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'All'; // Matches lowercase enum names or 'All'

  // Using exact lowercase strings that match ComplaintCategory enum names
  final List<String> _categories = [
    'All', 'electricity', 'plumbing', 'carpentry', 'cleanliness', 'indiscipline', 'foodQuality', 'other'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _assignTechnician(ComplaintModel complaint) {
    final workerController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Assign Technician', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Issue: ${complaint.title}', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text('Enter technician/worker name:', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              TextField(
                controller: workerController,
                decoration: InputDecoration(
                  hintText: 'e.g., Ramu (Electrician)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary))),
            ElevatedButton(
              onPressed: () async {
                if (workerController.text.trim().isEmpty) return;

                await ref.read(complaintRepositoryProvider).updateComplaintStatus(
                  complaint.id,
                  'inProgress',
                  assignedTo: workerController.text.trim(),
                );

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Technician Assigned!'), backgroundColor: AppColors.primary));
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
              child: const Text('Assign'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _markResolved(ComplaintModel complaint) async {
    await ref.read(complaintRepositoryProvider).updateComplaintStatus(
      complaint.id,
      'resolved',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Complaint marked as resolved!'), backgroundColor: AppColors.success));
    }
  }

  String _formatCategoryLabel(String cat) {
    if (cat == 'All') return 'All';
    return cat.replaceAllMapped(RegExp(r'[A-Z]'), (match) => ' ${match.group(0)}').toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final complaintsAsync = ref.watch(complaintsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hostel Complaints'),
        elevation: 0,
        backgroundColor: Colors.indigo,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Resolved'),
          ],
        ),
      ),
      backgroundColor: Colors.grey.shade50,
      body: complaintsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading complaints: $err', style: const TextStyle(color: AppColors.error))),
        data: (complaints) {
          final activeComplaints = complaints.where((c) {
            final isMatchCategory = _selectedCategory == 'All' || c.category.name.toLowerCase() == _selectedCategory.toLowerCase();
            final isActiveStatus = c.status == ComplaintStatus.open || c.status == ComplaintStatus.inProgress;
            return isMatchCategory && isActiveStatus;
          }).toList();

          final resolvedComplaints = complaints.where((c) {
            final isMatchCategory = _selectedCategory == 'All' || c.category.name.toLowerCase() == _selectedCategory.toLowerCase();
            final isResolvedStatus = c.status == ComplaintStatus.resolved;
            return isMatchCategory && isResolvedStatus;
          }).toList();

          return Column(
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: _categories.map((category) {
                      final isSelected = _selectedCategory.toLowerCase() == category.toLowerCase();
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          label: Text(_formatCategoryLabel(category), style: TextStyle(color: isSelected ? Colors.white : AppColors.textPrimary, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 12)),
                          selected: isSelected,
                          onSelected: (bool selected) {
                            setState(() => _selectedCategory = category);
                          },
                          backgroundColor: Colors.grey.shade100,
                          selectedColor: Colors.indigo,
                          checkmarkColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isSelected ? Colors.indigo : Colors.grey.shade300)),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    activeComplaints.isEmpty
                        ? _buildEmptyState('No active complaints found.')
                        : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: activeComplaints.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) => _buildComplaintCard(activeComplaints[index], isActive: true),
                    ),
                    resolvedComplaints.isEmpty
                        ? _buildEmptyState('No resolved complaints found.')
                        : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: resolvedComplaints.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) => _buildComplaintCard(resolvedComplaints[index], isActive: false),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_turned_in, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(fontSize: 16, color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildComplaintCard(ComplaintModel complaint, {required bool isActive}) {
    Color getCategoryColor(ComplaintCategory cat) {
      switch (cat) {
        case ComplaintCategory.electricity: return Colors.orange;
        case ComplaintCategory.plumbing: return Colors.blue;
        case ComplaintCategory.carpentry: return Colors.brown;
        case ComplaintCategory.cleanliness: return Colors.teal;
        case ComplaintCategory.indiscipline: return AppColors.error;
        default: return Colors.purple;
      }
    }

    IconData getCategoryIcon(ComplaintCategory cat) {
      switch (cat) {
        case ComplaintCategory.electricity: return Icons.electrical_services;
        case ComplaintCategory.plumbing: return Icons.plumbing;
        case ComplaintCategory.carpentry: return Icons.handyman;
        case ComplaintCategory.cleanliness: return Icons.cleaning_services;
        case ComplaintCategory.indiscipline: return Icons.gavel;
        default: return Icons.report;
      }
    }

    final catColor = getCategoryColor(complaint.category);
    final categoryNameStr = complaint.category.name.toUpperCase();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade300)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(border: Border(left: BorderSide(color: catColor, width: 6))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey.shade50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(getCategoryIcon(complaint.category), size: 16, color: catColor),
                              const SizedBox(width: 6),
                              Text(categoryNameStr, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: catColor)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(complaint.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        ],
                      ),
                    ),
                    Text(_formatDate(complaint.postedAt), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(complaint.description, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.person_outline, size: 16, color: Colors.indigo),
                        const SizedBox(width: 6),
                        Text(complaint.authorName, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 13)),
                        const SizedBox(width: 12),
                        const Icon(Icons.meeting_room_outlined, size: 16, color: Colors.indigo),
                        const SizedBox(width: 6),
                        Text('Room ${complaint.roomNumber}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              ),
              if (isActive) ...[
                const Divider(height: 1),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: complaint.status == ComplaintStatus.inProgress ? Colors.blue.withValues(alpha: 0.05) : Colors.orange.withValues(alpha: 0.05)),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(complaint.status == ComplaintStatus.inProgress ? Icons.engineering : Icons.pending_actions,
                                size: 18, color: complaint.status == ComplaintStatus.inProgress ? Colors.blue : AppColors.warning),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(complaint.status == ComplaintStatus.inProgress ? 'IN PROGRESS' : 'PENDING',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: complaint.status == ComplaintStatus.inProgress ? Colors.blue : AppColors.warning)),
                                if (complaint.assignedTo != null)
                                  Text('Assigned to: ${complaint.assignedTo}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (complaint.status == ComplaintStatus.open)
                        OutlinedButton(
                          onPressed: () => _assignTechnician(complaint),
                          style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.indigo), padding: const EdgeInsets.symmetric(horizontal: 12), visualDensity: VisualDensity.compact),
                          child: const Text('Assign', style: TextStyle(color: Colors.indigo, fontSize: 12, fontWeight: FontWeight.bold)),
                        )
                      else if (complaint.status == ComplaintStatus.inProgress)
                        ElevatedButton(
                          onPressed: () => _markResolved(complaint),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, padding: const EdgeInsets.symmetric(horizontal: 12), visualDensity: VisualDensity.compact),
                          child: const Text('Resolve', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                )
              ]
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}