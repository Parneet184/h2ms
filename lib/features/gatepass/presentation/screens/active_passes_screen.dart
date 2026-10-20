import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/enums.dart';
import '../../../gatepass/application/pass_providers.dart';
import '../../../gatepass/domain/pass_model.dart';
import '../../../gatepass/data/pass_repository.dart';

class ActivePassesScreen extends ConsumerStatefulWidget {
  final bool isLeave;

  const ActivePassesScreen({super.key, required this.isLeave});

  @override
  ConsumerState<ActivePassesScreen> createState() => _ActivePassesScreenState();
}

class _ActivePassesScreenState extends ConsumerState<ActivePassesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String title = widget.isLeave ? 'Active Leave Forms' : 'Active Gatepasses';
    final Color themeColor = widget.isLeave ? AppColors.primaryLight : AppColors.success;

    // 1. Watch the live active passes stream from Supabase
    final activePassesAsync = ref.watch(activePassesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: themeColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Filter / Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: themeColor.withValues(alpha: 0.1),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim().toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search by UID, Name, or Room...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),

          // List of Students currently out (AsyncValue handling)
          Expanded(
            child: activePassesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error loading data: $err', style: const TextStyle(color: AppColors.error))),
              data: (allPasses) {
                // 2. Filter passes by pass type (Leave vs Gatepass)
                final typeFiltered = allPasses.where((pass) {
                  if (widget.isLeave) {
                    return pass.type == PassType.leave;
                  } else {
                    return pass.type == PassType.gatepass;
                  }
                }).toList();

                // 3. Apply search text filtering
                final filteredStudents = typeFiltered.where((pass) {
                  if (_searchQuery.isEmpty) return true;
                  return pass.studentName.toLowerCase().contains(_searchQuery) ||
                      pass.studentUid.toLowerCase().contains(_searchQuery) ||
                      pass.roomNumber.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filteredStudents.isEmpty) {
                  return const Center(
                    child: Text('No active passes found matching your search.', style: TextStyle(color: AppColors.textSecondary)),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredStudents.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final pass = filteredStudents[index];
                    final isOverdue = DateTime.now().isAfter(pass.expectedInTime);

                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: isOverdue ? AppColors.error : Colors.grey.shade300,
                          width: isOverdue ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: themeColor.withValues(alpha: 0.2),
                                  child: Icon(Icons.person, color: themeColor),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(pass.studentName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      Text('UID: ${pass.studentUid} • Room ${pass.roomNumber}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                                    ],
                                  ),
                                ),
                                // Call / Action Button
                                IconButton(
                                  icon: const Icon(Icons.call, color: AppColors.primary),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Calling ${pass.studentName}...')),
                                    );
                                  },
                                )
                              ],
                            ),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildTimeColumn('Out Since', pass.requestedOutTime, Icons.output, AppColors.textSecondary, themeColor),
                                _buildTimeColumn('Expected Return', pass.expectedInTime, Icons.login, isOverdue ? AppColors.error : themeColor, isOverdue ? AppColors.error : themeColor),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Mark Returned Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  try {
                                    await ref.read(passRepositoryProvider).updatePassStatus(pass.id, PassStatus.expired);
                                    ref.invalidate(activePassesProvider);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Student marked as returned successfully!'), backgroundColor: AppColors.success),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
                                      );
                                    }
                                  }
                                },
                                icon: const Icon(Icons.how_to_reg, color: Colors.white, size: 18),
                                label: const Text('Mark Student Returned', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeColumn(String label, DateTime time, IconData icon, Color iconColor, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: iconColor),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          widget.isLeave ? '${time.day}/${time.month} at ${_formatTime(time)}' : _formatTime(time),
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
        ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}