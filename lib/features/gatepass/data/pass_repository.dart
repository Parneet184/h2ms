import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart'; // For debugPrint
import '../domain/pass_model.dart';
import '../../../core/constants/enums.dart';
import '../../auth/data/auth_repository.dart'; // To access the Supabase client

final passRepositoryProvider = Provider<PassRepository>((ref) {
  return PassRepository(ref.watch(supabaseClientProvider));
});

class PassRepository {
  final SupabaseClient _supabase;

  PassRepository(this._supabase);

  // --- PRIVATE HELPER: ENRICH PASSES WITH LIVE USER DATA FROM DB ---
  Future<List<PassModel>> _enrichAndMapPasses(List<Map<String, dynamic>> passData) async {
    try {
      // Fetch the latest user directory from the users table (single source of truth)
      final usersResponse = await _supabase.from('users').select();

      // Build a fast lookup map: { 'uid_123': { 'room_number': '...', 'mobile_number': '...' } }
      final Map<String, dynamic> userMap = {
        for (var u in usersResponse) u['uid']: u
      };

      return passData.map((passJson) {
        final uid = passJson['student_uid'];
        final userInfo = userMap[uid] as Map<String, dynamic>?;

        // ADD THESE PRINT STATEMENTS:
        debugPrint('--- DEBUG MAPPING FOR UID: $uid ---');
        debugPrint('Found User Row: $userInfo');
        debugPrint('Extracted mobile_number: ${userInfo?['mobile_number']}');

        // Inject live database profile info, targeting 'mobile_number' explicitly
        final enrichedJson = {
          ...passJson,
          'room_number': userInfo?['room_number'] ?? passJson['room_number'] ?? 'Unassigned',
          'contact': userInfo?['mobile_number'] ?? passJson['contact'] ?? 'N/A',
        };

        return _mapToPassModel(enrichedJson);
      }).toList();
    } catch (e) {
      debugPrint('Error enriching passes with user data: $e');
      // Fallback to raw mapping if the users fetch encounters an issue
      return passData.map((json) => _mapToPassModel(json)).toList();
    }
  }

  // --- METHODS FOR THE WARDEN ---

  Stream<List<PassModel>> streamPendingPasses() {
    return _supabase
        .from('gatepasses')
        .stream(primaryKey: ['id'])
        .eq('status', PassStatus.pending.toString().split('.').last)
        .asyncMap((data) => _enrichAndMapPasses(data))
        .map((passes) {
      // Sort in Dart: Newest passes at the top
      passes.sort((a, b) => b.requestedOutTime.compareTo(a.requestedOutTime));
      return passes;
    });
  }

  Future<void> updatePassStatus(String passId, PassStatus newStatus) async {
    try {
      final response = await _supabase
          .from('gatepasses')
          .update({'status': newStatus.toString().split('.').last.toLowerCase()})
          .eq('id', passId.toString())
          .select();

      if (response.isEmpty) {
        throw Exception('Supabase blocked the update! Please check your RLS policies.');
      }
    } catch (e) {
      debugPrint('Error updating pass status: $e');
      rethrow;
    }
  }

  // --- STREAM FOR APPROVED PASSES ---
  Stream<List<PassModel>> streamApprovedPasses() {
    return _supabase
        .from('gatepasses')
        .stream(primaryKey: ['id'])
        .asyncMap((data) async {
      // Filter safely in Dart to catch 'approved'
      final filteredData = data.where((json) {
        final status = json['status']?.toString().toLowerCase() ?? '';
        return status == 'approved';
      }).toList();
      return await _enrichAndMapPasses(filteredData);
    })
        .map((passes) {
      // Sort in Dart: Newest approvals at the top
      passes.sort((a, b) => b.requestedOutTime.compareTo(a.requestedOutTime));
      return passes;
    });
  }

  // --- METHODS FOR THE GUARD ---

  Stream<List<PassModel>> streamActivePasses() {
    return _supabase
        .from('gatepasses')
        .stream(primaryKey: ['id'])
        .asyncMap((data) async {
      // Filter safely in Dart to catch 'active' or 'approved' passes
      final filtered = data.where((json) {
        final status = json['status']?.toString().toLowerCase() ?? '';
        return status == 'active' || status == 'approved';
      }).toList();
      return await _enrichAndMapPasses(filtered);
    })
        .map((passes) {
      // Sort in Dart: Oldest passes at the top (most overdue)
      passes.sort((a, b) => a.expectedInTime.compareTo(b.expectedInTime));
      return passes;
    });
  }

  // --- METHODS FOR THE STUDENT ---

  Stream<List<PassModel>> streamStudentHistory(String uid) {
    return _supabase
        .from('gatepasses')
        .stream(primaryKey: ['id'])
        .eq('student_uid', uid)
        .asyncMap((data) => _enrichAndMapPasses(data))
        .map((passes) {
      passes.sort((a, b) => b.requestedOutTime.compareTo(a.requestedOutTime));
      return passes;
    });
  }

  Future<void> createNewPass(PassModel newPass) async {
    try {
      await _supabase.from('gatepasses').insert({
        'student_uid': newPass.studentUid,
        'student_name': newPass.studentName,
        'room_number': newPass.roomNumber,
        'pass_type': newPass.type.toString().split('.').last,
        'status': PassStatus.pending.toString().split('.').last, // Always starts pending
        'reason': newPass.reason,
        'requested_out_time': newPass.requestedOutTime.toIso8601String(),
        'expected_in_time': newPass.expectedInTime.toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error creating pass: $e');
      rethrow;
    }
  }

  // --- HELPER TO CONVERT SUPABASE JSON TO DART MODEL ---

  PassModel _mapToPassModel(Map<String, dynamic> data) {
    PassType getType(String typeStr) {
      return PassType.values.firstWhere(
            (e) => e.toString().split('.').last.toLowerCase() == typeStr.toLowerCase(),
        orElse: () => PassType.gatepass,
      );
    }

    PassStatus getStatus(String statusStr) {
      return PassStatus.values.firstWhere(
            (e) => e.toString().split('.').last.toLowerCase() == statusStr.toLowerCase(),
        orElse: () => PassStatus.pending,
      );
    }

    return PassModel(
      id: data['id']?.toString() ?? '',
      studentUid: data['student_uid'] ?? '',
      studentName: data['student_name'] ?? '',
      roomNumber: data['room_number'] ?? 'Unassigned',
      contact: data['contact'] ?? 'N/A',
      type: getType(data['pass_type'] ?? 'gatepass'),
      status: getStatus(data['status'] ?? 'pending'),
      reason: data['reason'] ?? '',
      requestedOutTime: data['requested_out_time'] != null ? DateTime.parse(data['requested_out_time']).toLocal() : DateTime.now(),
      expectedInTime: data['expected_in_time'] != null ? DateTime.parse(data['expected_in_time']).toLocal() : DateTime.now(),
      actualOutTime: data['actual_out_time'] != null ? DateTime.parse(data['actual_out_time']).toLocal() : null,
      actualInTime: data['actual_in_time'] != null ? DateTime.parse(data['actual_in_time']).toLocal() : null,
    );
  }
}