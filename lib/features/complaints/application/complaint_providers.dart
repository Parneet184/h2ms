import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/data/auth_repository.dart';
import '../domain/complaint_model.dart';

final complaintRepositoryProvider = Provider<ComplaintRepository>((ref) {
  return ComplaintRepository(ref.watch(supabaseClientProvider));
});

class ComplaintRepository {
  final SupabaseClient _supabase;
  ComplaintRepository(this._supabase);

  Stream<List<ComplaintModel>> streamComplaints() {
    return _supabase
        .from('complaints')
        .stream(primaryKey: ['id'])
        .map((data) {
      final complaints = data.map((json) => ComplaintModel.fromJson(json)).toList();
      complaints.sort((a, b) => b.postedAt.compareTo(a.postedAt));
      return complaints;
    });
  }

  Future<void> createComplaint(ComplaintModel complaint) async {
    await _supabase.from('complaints').insert(complaint.toJson());
  }

  Future<void> updateComplaintStatus(String id, String status, {String? assignedTo}) async {
    final updateData = {'status': status};
    if (assignedTo != null) updateData['assigned_to'] = assignedTo;

    await _supabase
        .from('complaints')
        .update(updateData)
        .eq('id', id);
  }

  Future<void> toggleUpvote(String id, int currentUpvotes, bool currentHasUpvoted) async {
    final newUpvotes = currentHasUpvoted ? currentUpvotes - 1 : currentUpvotes + 1;
    await _supabase.from('complaints').update({
      'upvotes': newUpvotes < 0 ? 0 : newUpvotes,
      'has_upvoted': !currentHasUpvoted,
    }).eq('id', id);
  }
}

final complaintsStreamProvider = StreamProvider.autoDispose<List<ComplaintModel>>((ref) {
  return ref.watch(complaintRepositoryProvider).streamComplaints();
});