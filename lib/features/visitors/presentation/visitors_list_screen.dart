import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../application/visitor_providers.dart';
import 'visitor_detail_screen.dart';

class VisitorsListScreen extends ConsumerWidget {
  const VisitorsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visitors = ref.watch(visitorsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Visitors'),
      ),
      body: visitors.isEmpty
          ? const Center(child: Text('No visitor records found.', style: TextStyle(color: AppColors.textSecondary)))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: visitors.length,
        itemBuilder: (context, index) {
          final visitor = visitors[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => VisitorDetailScreen(visitor: visitor)),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        visitor.relation.toLowerCase() == 'family' ? Icons.family_restroom : Icons.people,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            visitor.title,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 12, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Text(
                                _formatDate(visitor.visitDate),
                                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                              ),
                              const SizedBox(width: 12),
                              const Icon(Icons.timer, size: 12, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Text(
                                visitor.duration,
                                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }
}