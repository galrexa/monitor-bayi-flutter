// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/router/app_router.dart';
import 'core/services/notification_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');

    // Initialize Notification Service
    await NotificationService.initialize();
    print('✅ Notification service initialized');
  } catch (e) {
    print('⚠️ Initialization error: $e');
    print('📱 App will continue without Firebase features');
  }

  runApp(
    const ProviderScope(
      child: BabyMonitorApp(),
    ),
  );
}

class BabyMonitorApp extends ConsumerWidget {
  const BabyMonitorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Baby Monitor Alarm',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        // Global error handling
        return Builder(
          builder: (context) {
            return child ?? const SizedBox.shrink();
          },
        );
      },
    );
  }
}
