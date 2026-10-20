import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/pass_repository.dart';
import '../domain/pass_model.dart';
import '../../auth/application/auth_provider.dart';

// Notice the added ".autoDispose" on all three!
// 1. Live Stream for Warden's Pending Passes
final pendingPassesProvider = StreamProvider.autoDispose<List<PassModel>>((ref) {
  return ref.watch(passRepositoryProvider).streamPendingPasses();
});

// 2. Live Stream for Guard's Active Passes
final activePassesProvider = StreamProvider.autoDispose<List<PassModel>>((ref) {
  return ref.watch(passRepositoryProvider).streamActivePasses();
});

// 3. Live Stream for Student's Pass History
final studentHistoryProvider = StreamProvider.autoDispose<List<PassModel>>((ref) {
  final user = ref.watch(currentUserProvider);

  if (user == null) return Stream.value(<PassModel>[]);

  return ref.watch(passRepositoryProvider).streamStudentHistory(user.uid);
});

// 4. Live Stream for Warden's Approved Passes
final approvedPassesProvider = StreamProvider.autoDispose<List<PassModel>>((ref) {
  return ref.watch(passRepositoryProvider).streamApprovedPasses();
});