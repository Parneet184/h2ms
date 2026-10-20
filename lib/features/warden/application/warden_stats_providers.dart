import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../gatepass/application/pass_providers.dart';
import '../../complaints/application/complaint_providers.dart';
import '../../../../core/constants/enums.dart';

// Live count of pending gatepasses requiring warden review
final pendingGatepassesCountProvider = StreamProvider.autoDispose<int>((ref) {
  final passesAsync = ref.watch(pendingPassesProvider);
  return passesAsync.when(
    data: (passes) => Stream.value(passes.length),
    loading: () => Stream.value(0),
    error: (_, __) => Stream.value(0),
  );
});

// Live count of pending leave forms (uses pendingPassesProvider or returns 0 if managed separately)
final pendingLeaveFormsCountProvider = StreamProvider.autoDispose<int>((ref) {
  final passesAsync = ref.watch(pendingPassesProvider);
  return passesAsync.when(
    data: (passes) => Stream.value(0), // Change this if you have a separate leave model list
    loading: () => Stream.value(0),
    error: (_, __) => Stream.value(0),
  );
});

// Live count of active/unresolved complaints for SOS/Escalations
final activeSosCountProvider = StreamProvider.autoDispose<int>((ref) {
  final complaintsAsync = ref.watch(complaintsStreamProvider);
  return complaintsAsync.when(
    data: (complaints) => Stream.value(complaints.where((c) => c.status == ComplaintStatus.open).length),
    loading: () => Stream.value(0),
    error: (_, __) => Stream.value(0),
  );
});