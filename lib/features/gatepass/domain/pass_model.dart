// import '../../../core/constants/enums.dart';
//
// class PassModel {
//   final String id;
//   final String studentUid;
//   final String studentName;
//   final String roomNumber; // Crucial for the Warden's view
//   final PassType type;
//   final PassStatus status;
//   final String reason;
//   final DateTime requestedOutTime;
//   final DateTime expectedInTime;
//   final DateTime? actualOutTime; // Null until the Guard scans them out
//   final DateTime? actualInTime;  // Null until the Guard scans them in
//
//   PassModel({
//     required this.id,
//     required this.studentUid,
//     required this.studentName,
//     required this.roomNumber,
//     required this.type,
//     required this.status,
//     required this.reason,
//     required this.requestedOutTime,
//     required this.expectedInTime,
//     this.actualOutTime,
//     this.actualInTime,
//   });
//
//   // A helper method to quickly copy and update a pass (e.g., when Warden approves it)
//   PassModel copyWith({
//     PassStatus? status,
//     DateTime? actualOutTime,
//     DateTime? actualInTime,
//   }) {
//     return PassModel(
//       id: id,
//       studentUid: studentUid,
//       studentName: studentName,
//       roomNumber: roomNumber,
//       type: type,
//       status: status ?? this.status,
//       reason: reason,
//       requestedOutTime: requestedOutTime,
//       expectedInTime: expectedInTime,
//       actualOutTime: actualOutTime ?? this.actualOutTime,
//       actualInTime: actualInTime ?? this.actualInTime,
//     );
//   }
// }

import '../../../core/constants/enums.dart';

class PassModel {
  final String id;
  final String studentUid;
  final String studentName;
  final String roomNumber; // Crucial for the Warden's view
  final String contact;
  final PassType type;
  final PassStatus status;
  final String reason;
  final DateTime requestedOutTime;
  final DateTime expectedInTime;
  final DateTime? actualOutTime; // Null until the Guard scans them out
  final DateTime? actualInTime;  // Null until the Guard scans them in

  PassModel({
    required this.id,
    required this.studentUid,
    required this.studentName,
    required this.roomNumber,
    this.contact = 'N/A',
    required this.type,
    required this.status,
    required this.reason,
    required this.requestedOutTime,
    required this.expectedInTime,
    this.actualOutTime,
    this.actualInTime,
  });

  // --- MAP CONVERSION FOR SUPABASE ---

  factory PassModel.fromMap(Map<String, dynamic> map) {
    return PassModel(
      id: map['id']?.toString() ?? '',
      studentUid: map['student_uid'] ?? '',
      studentName: map['student_name'] ?? '',
      roomNumber: map['room_number'] ?? 'Unassigned',
      contact: map['contact'] ?? 'N/A',
      type: PassType.values.byName(map['type'] ?? 'gatepass'),
      status: PassStatus.values.byName(map['status'] ?? 'pending'),
      reason: map['reason'] ?? '',
      requestedOutTime: DateTime.parse(map['requested_out_time']),
      expectedInTime: DateTime.parse(map['expected_in_time']),
      actualOutTime: map['actual_out_time'] != null ? DateTime.parse(map['actual_out_time']) : null,
      actualInTime: map['actual_in_time'] != null ? DateTime.parse(map['actual_in_time']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id.isNotEmpty) 'id': id, // Omit if empty so Supabase auto-generates UUID
      'student_uid': studentUid,
      'student_name': studentName,
      'room_number': roomNumber,
      'contact': contact,
      'type': type.name,
      'status': status.name,
      'reason': reason,
      'requested_out_time': requestedOutTime.toIso8601String(),
      'expected_in_time': expectedInTime.toIso8601String(),
      'actual_out_time': actualOutTime?.toIso8601String(),
      'actual_in_time': actualInTime?.toIso8601String(),
    };
  }

  // A helper method to quickly copy and update a pass (e.g., when Warden approves it)
  PassModel copyWith({
    PassStatus? status,
    DateTime? actualOutTime,
    DateTime? actualInTime,
  }) {
    return PassModel(
      id: id,
      studentUid: studentUid,
      studentName: studentName,
      roomNumber: roomNumber,
      contact: contact,
      type: type,
      status: status ?? this.status,
      reason: reason,
      requestedOutTime: requestedOutTime,
      expectedInTime: expectedInTime,
      actualOutTime: actualOutTime ?? this.actualOutTime,
      actualInTime: actualInTime ?? this.actualInTime,
    );
  }
}