import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';
import 'core/constants/app_keys.dart';

void main() async {
  // Ensure Flutter is initialized before running async backend code
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the Supabase client
  await Supabase.initialize(
    url: AppKeys.supabaseUrl,
    publishableKey: AppKeys.supabaseAnonKey, // FIX: Changed anonKey to publishableKey
  );

  runApp(
    const ProviderScope(
      child: UniversityApp(),
    ),
  );
}

class UniversityApp extends ConsumerWidget {
  const UniversityApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the router provider
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'University Hub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}