import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/data/auth_repository.dart';
import '../domain/sos_alert_model.dart';

final sosRepositoryProvider = Provider<SosRepository>((ref) {
  return SosRepository(ref.watch(supabaseClientProvider));
});

class SosRepository {
  final SupabaseClient _supabase;
  SosRepository(this._supabase);

  // Live stream of all SOS alerts
  Stream<List<SosAlertModel>> streamAlerts() {
    return _supabase
        .from('sos_alerts')
        .stream(primaryKey: ['id'])
        .map((data) {
      final alerts = data.map((json) => SosAlertModel.fromJson(json)).toList();
      alerts.sort((a, b) => b.reportedAt.compareTo(a.reportedAt));
      return alerts;
    });
  }

  // Update status (e.g., Acknowledge or Resolve)
  Future<void> updateAlertStatus(String id, SosStatus newStatus) async {
    await _supabase
        .from('sos_alerts')
        .update({'status': newStatus.name})
        .eq('id', id);
  }

  // Insert a new SOS alert (Triggered from Guard / Emergency Screen)
  Future<void> createAlert(SosAlertModel alert) async {
    await _supabase.from('sos_alerts').insert(alert.toJson());
  }
}

final sosStreamProvider = StreamProvider.autoDispose<List<SosAlertModel>>((ref) {
  return ref.watch(sosRepositoryProvider).streamAlerts();
});