import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../application/complaint_providers.dart';
import '../../domain/complaint_model.dart';

class ComplaintTitleWithVotes extends ConsumerWidget {
  final ComplaintModel complaint;

  const ComplaintTitleWithVotes({
    super.key,
    required this.complaint,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Upvote Column ---
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                complaint.isPrivate ? Icons.lock : Icons.keyboard_arrow_up,
                size: complaint.isPrivate ? 20 : 28,
                color: complaint.isPrivate
                    ? Colors.grey
                    : (complaint.hasUpvoted ? Colors.green : AppColors.textSecondary),
              ),
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
              onPressed: complaint.isPrivate
                  ? null
                  : () {
                ref.read(complaintRepositoryProvider).toggleUpvote(
                  complaint.id,
                  complaint.upvotes,
                  complaint.hasUpvoted,
                );
              },
            ),
            const SizedBox(height: 2),
            Text(
              complaint.isPrivate ? 'Priv' : '${complaint.upvotes}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: complaint.hasUpvoted ? Colors.green : AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),

        // --- Title & Metadata ---
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                complaint.title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${complaint.authorName} • Room ${complaint.roomNumber}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}