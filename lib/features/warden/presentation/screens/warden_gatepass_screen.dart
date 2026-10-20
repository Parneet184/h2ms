import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/enums.dart';

// CORRECTED PATHS: Stepping out to the 'features' folder first, then into 'gatepass'
import '../../../gatepass/application/pass_providers.dart';
import '../../../gatepass/domain/pass_model.dart';
import 'gatepass_detail_screen.dart';

// --- ENHANCED MODEL (Kept intact so GatepassDetailScreen doesn't break) ---
class WardenGatepassModel {
  final String id;
  final String studentName;
  final String uid;
  final String roomNumber;
  final String reason;
  final String destination;
  final String outDate;
  final String outTime;
  final String expectedInTime;
  final String contact;
  final String status;

  WardenGatepassModel({
    required this.id, required this.studentName, required this.uid, required this.roomNumber,
    required this.reason, required this.destination, required this.outDate,
    required this.outTime, required this.expectedInTime, required this.contact, required this.status
  });
}

class WardenGatepassScreen extends ConsumerStatefulWidget {
  const WardenGatepassScreen({super.key});

  @override
  ConsumerState<WardenGatepassScreen> createState() => _WardenGatepassScreenState();
}

class _WardenGatepassScreenState extends ConsumerState<WardenGatepassScreen> with SingleTickerProviderStateMixin {
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

  // --- MAPPER: Converts Supabase PassModel to your UI Model ---
  // --- MAPPER: Converts Supabase PassModel to your UI Model ---
  WardenGatepassModel _mapToUIModel(PassModel pass) {
    // Convert UTC times from database to local device time
    final localOutTime = pass.requestedOutTime.toLocal();
    final localInTime = pass.expectedInTime.toLocal();

    return WardenGatepassModel(
      id: pass.id,
      studentName: pass.studentName,
      uid: pass.studentUid,
      roomNumber: pass.roomNumber,
      reason: pass.reason,
      // Defaulting destination based on pass type since we combined them
      destination: pass.type == PassType.leave ? 'Home/Out of Station' : 'Local Campus/Market',
      outDate: _formatDate(localOutTime),
      outTime: _formatTime(localOutTime),
      expectedInTime: '${_formatDate(localInTime)}, ${_formatTime(localInTime)}', // Added date + time for clarity on return
      contact: 'N/A', // Can be updated later when added to database
      status: pass.status.name,
    );
  }

  Future<void> _openDetail(WardenGatepassModel gatepass) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GatepassDetailScreen(gatepass: gatepass)),
    );
    // Notice we deleted the setState() logic here!
    // Supabase Realtime Streams will update the list automatically.
  }

  @override
  Widget build(BuildContext context) {
    // 1. Watch both the pending and approved streams from Supabase
    final pendingAsync = ref.watch(pendingPassesProvider);
    final approvedAsync = ref.watch(approvedPassesProvider); // <-- Changed to approvedPassesProvider

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Gatepasses'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: 'Pending (${pendingAsync.value?.length ?? 0})'),
            Tab(text: 'Approved (${approvedAsync.value?.length ?? 0})'), // <-- Updated tab title count
          ],
        ),
      ),
      backgroundColor: Colors.grey.shade50,
      body: TabBarView(
        controller: _tabController,
        children: [
          // --- TAB 1: PENDING PASSES ---
          pendingAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (passes) {
                if (passes.isEmpty) return _buildEmptyState('No pending gatepasses', Icons.inbox_outlined);

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: passes.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final uiModel = _mapToUIModel(passes[index]);
                    return _buildEnhancedCard(uiModel, true);
                  },
                );
              }
          ),

          // --- TAB 2: APPROVED PASSES ---
          approvedAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (passes) {
                if (passes.isEmpty) return _buildEmptyState('No recent approvals', Icons.history);

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: passes.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final uiModel = _mapToUIModel(passes[index]);
                    return _buildEnhancedCard(uiModel, false); // false means green/approved badge styling
                  },
                );
              }
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

  Widget _buildEnhancedCard(WardenGatepassModel gp, bool isPending) {
    final accentColor = isPending ? AppColors.warning : AppColors.success;
    final statusText = isPending ? 'PENDING' : 'APPROVED';

    return InkWell(
      onTap: isPending ? () => _openDetail(gp) : null,
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
                          Text(gp.studentName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          Text('UID: ${gp.uid} • Room: ${gp.roomNumber}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
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
                          Icon(Icons.location_on_outlined, size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 6),
                          Expanded(child: Text(gp.destination, style: TextStyle(color: Colors.grey.shade800, fontSize: 13), overflow: TextOverflow.ellipsis)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.schedule_outlined, size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 6),
                          Expanded(child: Text('${gp.outDate}, ${gp.outTime}', style: TextStyle(color: Colors.grey.shade800, fontSize: 13), overflow: TextOverflow.ellipsis)),
                        ],
                      ),
                    ),
                  ],
                ),
                if (isPending) ...[
                  const SizedBox(height: 16),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('Tap to review', style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.bold)),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.primary),
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

  // --- TIME FORMATTING HELPERS ---
  String _formatDate(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}