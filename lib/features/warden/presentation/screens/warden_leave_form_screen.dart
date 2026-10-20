import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/enums.dart';
import '../../../gatepass/application/pass_providers.dart';
import '../../../gatepass/domain/pass_model.dart';
import 'leave_form_detail_screen.dart';

// --- ENHANCED LEAVE MODEL ---
class WardenLeaveFormModel {
  final String id;
  final String studentName;
  final String uid;
  final String roomNumber;
  final String department;
  final String leaveType;
  final String outDate;
  final String outTime;
  final String expectedInDate;
  final String expectedInTime;
  final String reason;
  final String address;
  final String studentContact;
  final String fatherName;
  final String fatherContact;
  final String motherName;
  final String motherContact;
  final String status;

  WardenLeaveFormModel({
    required this.id, required this.studentName, required this.uid, required this.roomNumber,
    required this.department, required this.leaveType, required this.outDate, required this.outTime,
    required this.expectedInDate, required this.expectedInTime, required this.reason, required this.address,
    required this.studentContact, required this.fatherName, required this.fatherContact,
    required this.motherName, required this.motherContact, required this.status,
  });

  // Factory to map a backend PassModel (specifically of type leave) to the WardenLeaveFormModel UI structure
  factory WardenLeaveFormModel.fromPassModel(PassModel pass) {
    // Extract reason & address if formatted together, or split if needed
    return WardenLeaveFormModel(
      id: pass.id,
      studentName: pass.studentName,
      uid: pass.studentUid,
      roomNumber: pass.roomNumber,
      department: 'B.Tech CSE', // Default or fetch from profile if stored
      leaveType: pass.type == PassType.leave ? 'Home Leave' : 'Gatepass',
      outDate: _formatDate(pass.requestedOutTime),
      outTime: _formatTime(pass.requestedOutTime),
      expectedInDate: _formatDate(pass.expectedInTime),
      expectedInTime: _formatTime(pass.expectedInTime),
      reason: pass.reason,
      address: 'N/A', // Can be parsed from reason if saved together
      studentContact: 'N/A',
      fatherName: 'Parent/Guardian',
      fatherContact: 'N/A',
      motherName: 'N/A',
      motherContact: 'N/A',
      status: pass.status.name.toLowerCase(),
    );
  }

  static String _formatDate(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  static String _formatTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}

class WardenLeaveFormScreen extends ConsumerStatefulWidget {
  const WardenLeaveFormScreen({super.key});

  @override
  ConsumerState<WardenLeaveFormScreen> createState() => _WardenLeaveFormScreenState();
}

class _WardenLeaveFormScreenState extends ConsumerState<WardenLeaveFormScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

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

  Future<void> _openDetail(WardenLeaveFormModel leaveForm) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LeaveFormDetailScreen(leaveForm: leaveForm)),
    );
    // Realtime streams will handle UI refresh automatically upon pop!
  }

  @override
  Widget build(BuildContext context) {
    // Watch real Supabase live streams
    final pendingAsync = ref.watch(pendingPassesProvider);
    final approvedAsync = ref.watch(approvedPassesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Leave Forms'),
        backgroundColor: Colors.deepOrange,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: 'Pending (${pendingAsync.value?.where((p) => p.type == PassType.leave).length ?? 0})'),
            const Tab(text: 'Approved (Last 7 Days)'),
          ],
        ),
      ),
      backgroundColor: Colors.grey.shade50,
      body: TabBarView(
        controller: _tabController,
        children: [
          // --- PENDING LEAVES TAB ---
          pendingAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
            data: (passes) {
              // Explicitly filter for BOTH leave type AND pending status
              final pendingLeaves = passes
                  .where((p) => p.type == PassType.leave && p.status == PassStatus.pending)
                  .map((p) => WardenLeaveFormModel.fromPassModel(p))
                  .toList();

              if (pendingLeaves.isEmpty) {
                return _buildEmptyState('No pending leave forms', Icons.inbox_outlined);
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: pendingLeaves.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) => _buildEnhancedCard(pendingLeaves[index], true),
              );
            },
          ),

          // --- APPROVED LEAVES TAB ---
          approvedAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
            data: (passes) {
              // Explicitly filter for BOTH leave type AND approved status
              final approvedLeaves = passes
                  .where((p) => p.type == PassType.leave && p.status == PassStatus.approved)
                  .map((p) => WardenLeaveFormModel.fromPassModel(p))
                  .toList();

              if (approvedLeaves.isEmpty) {
                return _buildEmptyState('No recent approvals', Icons.history);
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: approvedLeaves.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) => _buildEnhancedCard(approvedLeaves[index], false),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(fontSize: 16, color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildEnhancedCard(WardenLeaveFormModel form, bool isPending) {
    final accentColor = isPending ? Colors.deepOrange : AppColors.success;
    final statusText = isPending ? 'PENDING' : 'APPROVED';

    return InkWell(
      onTap: isPending ? () => _openDetail(form) : null,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(border: Border(left: BorderSide(color: accentColor, width: 6))),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(form.studentName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          Text('UID: ${form.uid} • Room: ${form.roomNumber}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: accentColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                      child: Text(statusText, style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 11)),
                    ),
                  ],
                ),
                const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.flight_takeoff, size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 6),
                          Expanded(child: Text('${form.outDate}, ${form.outTime}', style: TextStyle(color: Colors.grey.shade800, fontSize: 13), overflow: TextOverflow.ellipsis)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.flight_land, size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 6),
                          Expanded(child: Text('${form.expectedInDate}, ${form.expectedInTime}', style: TextStyle(color: Colors.grey.shade800, fontSize: 13), overflow: TextOverflow.ellipsis)),
                        ],
                      ),
                    ),
                  ],
                ),
                if (isPending) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4)),
                        child: Text(form.leaveType.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                      ),
                      const Row(
                        children: [
                          Text('Tap to review', style: TextStyle(color: Colors.deepOrange, fontSize: 13, fontWeight: FontWeight.bold)),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward_ios, size: 12, color: Colors.deepOrange),
                        ],
                      ),
                    ],
                  )
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}