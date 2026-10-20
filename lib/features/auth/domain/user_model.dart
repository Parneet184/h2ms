import '../../../core/constants/enums.dart';

class UserModel {
  // 1. Core / Admin Uploaded (Read-Only for Student)
  final String uid;
  final String name;
  final UserRole role;
  final String department;
  final String course;
  final String mobileNumber;
  final String fatherName;
  final String fatherMobileNumber;
  final String motherName;
  final String motherMobileNumber;
  final HostelType hostelName;

  // 2. Warden Controlled (Read-Only for Student)
  final String roomNumber;

  // 3. Student Controlled (Editable)
  final String homeAddress;

  UserModel({
    required this.uid,
    required this.name,
    required this.role,
    this.department = '',
    this.course = '',
    this.mobileNumber = '',
    this.fatherName = '',
    this.fatherMobileNumber = '',
    this.motherName = '',
    this.motherMobileNumber = '',
    this.hostelName = HostelType.none,
    this.roomNumber = 'Unassigned',
    this.homeAddress = '',
  });

  // copyWith allows us to update just the address without overwriting everything else
  UserModel copyWith({
    String? homeAddress,
    String? roomNumber,
  }) {
    return UserModel(
      uid: uid,
      name: name,
      role: role,
      department: department,
      course: course,
      mobileNumber: mobileNumber,
      fatherName: fatherName,
      fatherMobileNumber: fatherMobileNumber,
      motherName: motherName,
      motherMobileNumber: motherMobileNumber,
      hostelName: hostelName,
      roomNumber: roomNumber ?? this.roomNumber,
      homeAddress: homeAddress ?? this.homeAddress,
    );
  }
}