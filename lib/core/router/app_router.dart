import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/parent/screens/parent_dashboard.dart';
import '../../features/caretaker/screens/caretaker_dashboard.dart';
// ignore: unused_import
import '../../features/admin/screens/admin_dashboard.dart';
import '../../features/shared/models/app_user.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isLoading = authState.isLoading;

      // Show loading while checking auth state
      if (isLoading) return null;

      // Redirect to login if not authenticated
      if (!isAuthenticated) {
        return '/login';
      }

      // Redirect to role-specific dashboard
      if (state.matchedLocation == '/' || state.matchedLocation == '/login') {
        switch (authState.appUser?.role) {
          case UserRole.parent:
            return '/parent';
          case UserRole.caretaker:
            return '/caretaker';
          case UserRole.admin:
            return '/admin';
          default:
            return '/login';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/parent',
        builder: (context, state) => const ParentDashboard(),
      ),
      GoRoute(
        path: '/caretaker',
        builder: (context, state) => const CaretakerDashboard(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboard(),
      ),
    ],
  );
});

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.baby_changing_station,
              size: 80,
              color: Color(0xFF2196F3),
            ),
            SizedBox(height: 16),
            Text(
              'Baby Monitor Alarm',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2196F3),
              ),
            ),
            SizedBox(height: 32),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
