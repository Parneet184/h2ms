// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
//
// import '../../../core/constants/app_colors.dart';
// import '../application/auth_provider.dart';
//
// class LoginScreen extends ConsumerStatefulWidget {
//   const LoginScreen({super.key});
//
//   @override
//   ConsumerState<LoginScreen> createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends ConsumerState<LoginScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _uidController = TextEditingController();
//   final _passwordController = TextEditingController();
//
//   bool _isPasswordVisible = false;
//   bool _isLoading = false;
//
//   @override
//   void dispose() {
//     _uidController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _handleLogin() async {
//     if (!_formKey.currentState!.validate()) return;
//
//     setState(() => _isLoading = true);
//
//     final uid = _uidController.text.trim();
//     final password = _passwordController.text.trim();
//
//     // Call the AuthNotifier to attempt login
//     final success = await ref.read(authNotifierProvider.notifier).login(uid, password);
//
//     if (!mounted) return;
//     setState(() => _isLoading = false);
//
//     if (success) {
//       // If successful, GoRouter (in app_router.dart) will automatically
//       // detect the state change in currentUserProvider and redirect the user
//       // to the correct dashboard based on their UserRole!
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Login Successful!'), backgroundColor: AppColors.success),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Invalid UID/EID or Password'), backgroundColor: AppColors.error),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       body: SafeArea(
//         child: Center(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(24.0),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   // --- LOGO & BRANDING ---
//                   Icon(Icons.apartment_rounded, size: 80, color: AppColors.primary),
//                   const SizedBox(height: 24),
//                   const Text(
//                     'University Hub',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textPrimary, letterSpacing: -0.5),
//                   ),
//                   const SizedBox(height: 8),
//                   const Text(
//                     'Hostel & Campus Management',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
//                   ),
//                   const SizedBox(height: 48),
//
//                   // --- LOGIN FORM CARD ---
//                   Container(
//                     padding: const EdgeInsets.all(24),
//                     decoration: BoxDecoration(
//                       color: AppColors.surface,
//                       borderRadius: BorderRadius.circular(24),
//                       boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text('Sign In', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
//                         const SizedBox(height: 24),
//
//                         // UID/EID Field
//                         const Text('UID / EID', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
//                         const SizedBox(height: 8),
//                         TextFormField(
//                           controller: _uidController,
//                           decoration: InputDecoration(
//                             hintText: 'Enter your University ID',
//                             prefixIcon: const Icon(Icons.badge_outlined, color: AppColors.textSecondary),
//                             filled: true,
//                             fillColor: AppColors.background,
//                             border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
//                           ),
//                           validator: (value) => value == null || value.isEmpty ? 'ID is required' : null,
//                         ),
//                         const SizedBox(height: 20),
//
//                         // Password Field
//                         const Text('Password', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
//                         const SizedBox(height: 8),
//                         TextFormField(
//                           controller: _passwordController,
//                           obscureText: !_isPasswordVisible,
//                           decoration: InputDecoration(
//                             hintText: 'Enter your password',
//                             prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textSecondary),
//                             suffixIcon: IconButton(
//                               icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility, color: AppColors.textSecondary),
//                               onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
//                             ),
//                             filled: true,
//                             fillColor: AppColors.background,
//                             border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
//                           ),
//                           validator: (value) => value == null || value.isEmpty ? 'Password is required' : null,
//                         ),
//                         const SizedBox(height: 32),
//
//                         // Login Button
//                         SizedBox(
//                           width: double.infinity,
//                           height: 54,
//                           child: ElevatedButton(
//                             onPressed: _isLoading ? null : _handleLogin,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: AppColors.primary,
//                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                               elevation: 0,
//                             ),
//                             child: _isLoading
//                                 ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
//                                 : const Text('Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 32),
//
//                   // --- CONTACT ADMIN HELP ---
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Icon(Icons.help_outline, size: 16, color: AppColors.textSecondary),
//                       const SizedBox(width: 8),
//                       const Text('Forgot Password? ', style: TextStyle(color: AppColors.textSecondary)),
//                       GestureDetector(
//                         onTap: () {
//                           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please contact the IT Desk at admin@university.edu')));
//                         },
//                         child: const Text('Contact Admin', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/enums.dart';
import '../application/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  // Using email since Supabase defaults to email/password authentication
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // 1. Validate the form fields first
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      // 2. Call the notifier to authenticate via Supabase
      await ref.read(authNotifierProvider.notifier).login(email, password);

      if (!mounted) return;

      // 3. Read the global state to get their role
      final userProfile = ref.read(currentUserProvider);

      // 4. Route them to the correct dashboard based on their role
      if (userProfile?.role == UserRole.warden) {
        context.go('/warden-dashboard');
      } else if (userProfile?.role == UserRole.guard) {
        context.go('/guard-dashboard');
      } else {
        context.go('/student-dashboard');
      }
    } catch (e) {
      // 5. Catch wrong passwords or network errors safely
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- LOGO & BRANDING ---
                  const Icon(Icons.apartment_rounded, size: 80, color: AppColors.primary),
                  const SizedBox(height: 24),
                  const Text(
                    'University Hub',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Hostel & Campus Management',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 48),

                  // --- LOGIN FORM CARD ---
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10)
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                            'Sign In',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)
                        ),
                        const SizedBox(height: 24),

                        // Email Field (Replaced UID for Supabase compatibility)
                        const Text('Email Address', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'Enter your University Email',
                            prefixIcon: const Icon(Icons.email_outlined, color: AppColors.textSecondary),
                            filled: true,
                            fillColor: AppColors.background,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                          validator: (value) => value == null || value.isEmpty ? 'Email is required' : null,
                        ),
                        const SizedBox(height: 20),

                        // Password Field
                        const Text('Password', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            hintText: 'Enter your password',
                            prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textSecondary),
                            suffixIcon: IconButton(
                              icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility, color: AppColors.textSecondary),
                              onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                            ),
                            filled: true,
                            fillColor: AppColors.background,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                          validator: (value) => value == null || value.isEmpty ? 'Password is required' : null,
                        ),
                        const SizedBox(height: 32),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text('Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // --- CONTACT ADMIN HELP ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.help_outline, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      const Text('Forgot Password? ', style: TextStyle(color: AppColors.textSecondary)),
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please contact the IT Desk at admin@university.edu'))
                          );
                        },
                        child: const Text('Contact Admin', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}