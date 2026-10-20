// import '../domain/user_model.dart';
// import '../../../core/constants/enums.dart';
//
// class AuthRepository {
//   // Start with no one logged in
//   UserModel? _currentUser;
//
//   UserModel? getCurrentUser() => _currentUser;
//
//   // --- MOCK LOGIN LOGIC ---
//   Future<UserModel?> login(String uid, String password) async {
//     // Simulate network delay
//     await Future.delayed(const Duration(seconds: 1));
//
//     // 1. MOCK WARDEN LOGIN
//     if (uid.toUpperCase() == 'W123' && password == 'password') {
//       _currentUser = UserModel(
//         uid: 'W123',
//         name: 'Dr. Rajendra Prasad',
//         role: UserRole.warden,
//         mobileNumber: '9988776655',
//         hostelName: HostelType.boys,
//       );
//       return _currentUser;
//     }
//
//     // 2. MOCK STUDENT LOGIN
//     if (uid.toUpperCase() == 'S123' && password == 'password') {
//       _currentUser = UserModel(
//         uid: 'S123',
//         name: 'Gursajanpreet Singh',
//         role: UserRole.student,
//         department: 'Computer Science',
//         course: 'B.Tech CSE',
//         mobileNumber: '9876543210',
//         hostelName: HostelType.boys,
//         roomNumber: '101',
//       );
//       return _currentUser;
//     }
//
//     // 3. MOCK GUARD LOGIN
//     if (uid.toUpperCase() == 'G123' && password == 'password') {
//       _currentUser = UserModel(
//         uid: 'G123',
//         name: 'Ramesh Singh',
//         role: UserRole.guard,
//         mobileNumber: '9876543299',
//         hostelName: HostelType.boys,
//       );
//       return _currentUser;
//     }
//
//     // 4. MOCK MESS INCHARGE LOGIN
//     if (uid.toUpperCase() == 'M123' && password == 'password') {
//       _currentUser = UserModel(
//         uid: 'M123',
//         name: 'Sanjeev Kapoor',
//         role: UserRole.messIncharge,
//         mobileNumber: '9876543210',
//         hostelName: HostelType.boys,
//       );
//       return _currentUser;
//     }
//
//     // Invalid credentials
//     return null;
//   }
//
//   void logout() {
//     _currentUser = null;
//   }
//
//   // --- KEEPS YOUR EXISTING PASSWORD/PROFILE LOGIC WORKING ---
//   void updateHomeAddress(String newAddress) {
//     if (_currentUser != null) {
//       _currentUser = _currentUser!.copyWith(homeAddress: newAddress);
//     }
//   }
//
//   bool changePassword(String currentPassword, String newPassword) {
//     // Mocking success
//     return true;
//   }
// }

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart'; // For debugPrint
import '../domain/user_model.dart';
import '../../../core/constants/enums.dart';

// Provide the Supabase Client globally
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// Provide the AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(supabaseClientProvider));
});

class AuthRepository {
  final SupabaseClient _supabase;

  AuthRepository(this._supabase);

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  User? get currentUser => _supabase.auth.currentUser;

  /// Sign in with Email and Password
  Future<void> signIn(String email, String password) async {
    try {
      await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('An unexpected error occurred during login.');
    }
  }

  /// Fetch the custom user profile from our 'users' table
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final data = await _supabase
          .from('users')
          .select()
          .eq('uid', uid)
          .single();

      return _mapToUserModel(data);
    } catch (e) {
      debugPrint('Error fetching user profile: $e'); // Fixes the avoid_print warning
      return null;
    }
  }

  /// Update user password
  Future<void> changePassword(String newPassword) async {
    await _supabase.auth.updateUser(UserAttributes(password: newPassword));
  }

  /// Update home address in the database
  Future<void> updateHomeAddress(String uid, String newAddress) async {
    await _supabase.from('users').update({'home_address': newAddress}).eq('uid', uid);
  }

  /// Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // --- Helper to map Supabase JSON to your Dart Model ---
  UserModel _mapToUserModel(Map<String, dynamic> data) {
    UserRole getRole(String roleStr) {
      return UserRole.values.firstWhere(
            (e) => e.toString().split('.').last.toLowerCase() == roleStr.toLowerCase(),
        orElse: () => UserRole.student,
      );
    }

    HostelType getHostel(String hostelStr) {
      return HostelType.values.firstWhere(
            (e) => e.toString().split('.').last.toLowerCase() == hostelStr.toLowerCase(),
        orElse: () => HostelType.none,
      );
    }

    return UserModel(
      uid: data['uid'],
      name: data['name'],
      role: getRole(data['role']),
      department: data['department'] ?? '',
      course: data['course'] ?? '',
      mobileNumber: data['mobile_number'] ?? '',
      fatherName: data['father_name'] ?? '',
      fatherMobileNumber: data['father_mobile_number'] ?? '',
      motherName: data['mother_name'] ?? '',
      motherMobileNumber: data['mother_mobile_number'] ?? '',
      hostelName: getHostel(data['hostel_name']),
      roomNumber: data['room_number'] ?? 'Unassigned',
      homeAddress: data['home_address'] ?? '',
    );
  }
}