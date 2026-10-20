// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../domain/notice_model.dart';
//
// // Provider that supplies the list of notices sorted by date (newest first)
// final noticesProvider = Provider<List<NoticeModel>>((ref) {
//   final now = DateTime.now();
//
//   final notices = [
//     NoticeModel(
//       id: 'n1',
//       title: 'Hostel Fee Submission Deadline',
//       shortDescription: 'Final reminder for the submission of even semester hostel fees.',
//       fullDescription: 'This is a final reminder that the deadline for submitting the hostel accommodation and mess fees for the current even semester is strictly the end of this week. Students who fail to submit the fees will incur a late fine of ₹500 per day. Please ensure all dues are cleared via the online portal. Attached is the fee structure for your reference.',
//       postedBy: 'DSW (Dean of Student Welfare)',
//       postedAt: now.subtract(const Duration(hours: 5)), // Today
//       hasAttachment: true,
//       attachmentName: 'Fee_Structure_Even_Sem.pdf',
//     ),
//     NoticeModel(
//       id: 'n2',
//       title: 'Scheduled Power Outage in Block A',
//       shortDescription: 'Power will be cut in Block A for maintenance on Sunday.',
//       fullDescription: 'Please be informed that there will be a scheduled power outage in Boys Hostel Block A this Sunday from 10:00 AM to 02:00 PM. The maintenance team will be upgrading the main electrical panel. Backup generators will only supply power to the common areas and corridors. Please charge your devices accordingly.',
//       postedBy: 'Chief Warden',
//       postedAt: now.subtract(const Duration(days: 2)),
//     ),
//     NoticeModel(
//       id: 'n3',
//       title: 'Registration for Inter-Hostel Sports',
//       shortDescription: 'Sign up for the upcoming inter-hostel cricket and badminton tournaments.',
//       fullDescription: 'The annual inter-hostel sports meet is scheduled for next month. We are currently accepting registrations for Cricket, Badminton, and Table Tennis. Interested students should form their teams and register using the attached form. Submit the filled form to your respective block wardens by Friday.',
//       postedBy: 'Sports Committee',
//       postedAt: now.subtract(const Duration(days: 12)),
//       hasAttachment: true,
//       attachmentName: 'Sports_Registration_Form.pdf',
//     ),
//   ];
//
//   // Ensure they are sorted from newest to oldest
//   notices.sort((a, b) => b.postedAt.compareTo(a.postedAt));
//   return notices;
// });

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/data/auth_repository.dart';
import '../domain/notice_model.dart';

// Repository Provider for Notice Board
final noticeRepositoryProvider = Provider<NoticeRepository>((ref) {
  return NoticeRepository(ref.watch(supabaseClientProvider));
});


class NoticeRepository {
  final SupabaseClient _supabase;
  NoticeRepository(this._supabase);

  // Live Stream of Notices from Supabase
  Stream<List<NoticeModel>> streamNotices() {
    return _supabase
        .from('notices')
        .stream(primaryKey: ['id'])
        .map((data) {
      final notices = data.map((json) => NoticeModel.fromJson(json)).toList();
      // Sort newest first
      notices.sort((a, b) => b.postedAt.compareTo(a.postedAt));
      return notices;
    });
  }

  // Method for Wardens to broadcast a new notice
  Future<void> createNotice(NoticeModel notice) async {
    await _supabase.from('notices').insert(notice.toJson());
  }

  // Method to delete a notice by its ID
  Future<void> deleteNotice(String id) async {
    await _supabase.from('notices').delete().eq('id', id);
  }

}

// Stream Provider consumed by the UI
final noticesStreamProvider = StreamProvider.autoDispose<List<NoticeModel>>((ref) {
  final repository = ref.watch(noticeRepositoryProvider);
  return repository.streamNotices();
});

