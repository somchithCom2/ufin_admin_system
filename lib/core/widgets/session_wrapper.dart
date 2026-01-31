import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ufin_admin_system/core/providers/auth_provider.dart';

/// Session wrapper that handles authentication state and shows appropriate UI
class SessionWrapper extends ConsumerWidget {
  final Widget child;
  final Widget? loadingWidget;

  const SessionWrapper({super.key, required this.child, this.loadingWidget});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    // Show loading screen while checking authentication
    if (authState.isInitializing) {
      return loadingWidget ?? const SplashScreen();
    }

    return child;
  }
}

/// Splash screen shown during initial authentication check
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withValues(alpha: 0.8),
              ],
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo/Icon
                Icon(Icons.admin_panel_settings, size: 80, color: Colors.white),
                SizedBox(height: 24),
                // App Name
                Text(
                  'UFin Admin System',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Loading...',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
                SizedBox(height: 32),
                // Loading indicator
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A widget that requires authentication to be displayed
class AuthGuard extends ConsumerWidget {
  final Widget child;
  final Widget? unauthorizedWidget;

  const AuthGuard({super.key, required this.child, this.unauthorizedWidget});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    if (!authState.isAuthenticated) {
      return unauthorizedWidget ??
          const Scaffold(
            body: Center(child: Text('Unauthorized. Please login.')),
          );
    }

    return child;
  }
}

/// A widget that shows user session info
class SessionInfo extends ConsumerWidget {
  const SessionInfo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    if (!authState.isAuthenticated) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor,
            child: Text(
              authState.username?.isNotEmpty == true
                  ? authState.username![0].toUpperCase()
                  : 'A',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  authState.username ?? 'Admin',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Administrator',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
