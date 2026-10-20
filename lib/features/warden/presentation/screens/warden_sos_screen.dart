import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/sos_alert_model.dart';
import '../../application/sos_providers.dart';

class WardenSosScreen extends ConsumerWidget {
  const WardenSosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(sosStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SOS & Escalations'),
        backgroundColor: AppColors.error,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: alertsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.error)),
        error: (err, stack) => Center(child: Text('Error loading alerts: $err', style: const TextStyle(color: AppColors.error))),
        data: (alerts) {
          final activeAlerts = alerts.where((a) => a.status != SosStatus.resolved).toList();
          final resolvedAlerts = alerts.where((a) => a.status == SosStatus.resolved).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusHeader(context, activeAlerts.length),
                const SizedBox(height: 24),
                const Text('Action Required', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 12),
                if (activeAlerts.isEmpty)
                  _buildEmptyState()
                else
                  ...activeAlerts.map((alert) => _buildAlertCard(context, ref, alert)),
                const SizedBox(height: 32),
                if (resolvedAlerts.isNotEmpty) ...[
                  const Text('Recently Resolved', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 12),
                  ...resolvedAlerts.map((alert) => _buildAlertCard(context, ref, alert)),
                ]
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusHeader(BuildContext context, int activeCount) {
    final isClear = activeCount == 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isClear ? AppColors.success : AppColors.error,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isClear ? AppColors.success : AppColors.error).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        children: [
          Icon(isClear ? Icons.check_circle_outline : Icons.warning_amber_rounded, size: 48, color: Colors.white),
          const SizedBox(height: 12),
          Text(
            isClear ? 'All Clear' : '$activeCount Active Emergencies',
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            isClear ? 'No pending SOS alerts or escalations.' : 'Immediate warden intervention required!',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.shield_outlined, size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('No Active Alerts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildAlertCard(BuildContext context, WidgetRef ref, SosAlertModel alert) {
    final isResolved = alert.status == SosStatus.resolved;
    final isAcknowledged = alert.status == SosStatus.acknowledged;

    Color cardBorderColor = isResolved ? Colors.grey.shade300 : (isAcknowledged ? AppColors.warning : AppColors.error);
    Color iconBgColor = isResolved ? Colors.grey.shade100 : (isAcknowledged ? AppColors.warning.withValues(alpha: 0.1) : AppColors.error.withValues(alpha: 0.1));
    Color iconColor = isResolved ? Colors.grey.shade500 : (isAcknowledged ? AppColors.warning : AppColors.error);

    IconData getIcon() {
      switch (alert.type) {
        case SosType.medical: return Icons.medical_services;
        case SosType.missingStudent: return Icons.person_off;
        case SosType.fire: return Icons.local_fire_department;
        case SosType.security: return Icons.security;
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isResolved ? 0 : 4,
      shadowColor: isResolved ? Colors.transparent : cardBorderColor.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: cardBorderColor, width: isResolved ? 1 : 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
                  child: Icon(getIcon(), color: iconColor, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(alert.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(alert.location, style: TextStyle(fontSize: 13, color: Colors.grey.shade700, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ],
                  ),
                ),
                Text(
                  _getTimeAgo(alert.reportedAt),
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isResolved ? Colors.grey : AppColors.error),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Text(alert.description, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.record_voice_over, size: 14, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text('Reported by: ${alert.reportedBy}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
                ],
              ),
            ),
            if (!isResolved) ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  if (alert.contactNumber != null)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Dialing ${alert.reportedBy}... (${alert.contactNumber})'), backgroundColor: Colors.teal),
                          );
                        },
                        icon: const Icon(Icons.call, size: 18, color: Colors.teal),
                        label: const Text('Call', style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: Colors.teal),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  if (alert.contactNumber != null) const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () async {
                        final nextStatus = alert.status == SosStatus.active ? SosStatus.acknowledged : SosStatus.resolved;
                        await ref.read(sosRepositoryProvider).updateAlertStatus(alert.id, nextStatus);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(nextStatus == SosStatus.acknowledged ? 'Alert Acknowledged.' : 'Emergency Resolved.'),
                              backgroundColor: nextStatus == SosStatus.acknowledged ? AppColors.warning : AppColors.success,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: alert.status == SosStatus.active ? AppColors.warning : AppColors.success,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Text(
                        alert.status == SosStatus.active ? 'Acknowledge' : 'Mark Resolved',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ),
                ],
              )
            ]
          ],
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}