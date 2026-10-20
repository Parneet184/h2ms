import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';
import '../domain/user_model.dart';

// 1. The Notifier that handles state changes (Login/Logout)
class AuthNotifier extends StateNotifier<UserModel?> {
  final AuthRepository _repository;

  // We start with a null state, and immediately check if Supabase
  // remembers a logged-in user from a previous session.
  AuthNotifier(this._repository) : super(null) {
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    final sessionUser = _repository.currentUser;
    if (sessionUser != null) {
      state = await _repository.getUserProfile(sessionUser.id);
    }
  }

  // Calls the repo and updates the state if successful
  // Note: Changed 'uid' parameter to 'email' since Supabase uses email to log in
  Future<bool> login(String email, String password) async {
    try {
      // 1. Authenticate with Supabase
      await _repository.signIn(email, password);

      // 2. Fetch the newly logged-in user's role/details from our database
      final sessionUser = _repository.currentUser;
      if (sessionUser != null) {
        state = await _repository.getUserProfile(sessionUser.id); // Triggers UI updates
        return true;
      }
      return false;
    } catch (e) {
      // Rethrow so your UI's try/catch block can show the Snackbar error!
      rethrow;
    }
  }

  Future<void> logout() async {
    await _repository.signOut();
    state = null; // Clear the state, kicking them back to the login screen
  }
}

// 2. The Provider that caused the error is now fixed!
// It correctly watches the authRepositoryProvider we made earlier.
final authNotifierProvider = StateNotifierProvider<AuthNotifier, UserModel?>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

// 3. Expose current user for easy reading in the UI (keeps your old code working)
final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authNotifierProvider);
});