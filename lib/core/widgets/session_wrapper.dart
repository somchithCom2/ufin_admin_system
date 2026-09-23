import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ufin_admin_system/core/providers/auth_provider.dart';
import 'package:ufin_admin_system/core/widgets/app_ui.dart';

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

/// Splash screen shown during initial authentication check.
///
/// Rendered inside the app's [MaterialApp], so it inherits the theme.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surfaceContainerLowest,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppLogo(size: 64),
            const SizedBox(height: 20),
            Text(
              'UFin Admin',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 6),
            Text(
              'Restoring your session…',
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 28),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.4),
            ),
          ],
        ),
      ),
    );
  }
}

/// Brand mark used on splash, login and the sidebar.
class AppLogo extends StatelessWidget {
  final double size;
  const AppLogo({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primary,
            Color.lerp(scheme.primary, Colors.indigo, 0.5)!,
          ],
        ),
      ),
      child: Icon(
        Icons.admin_panel_settings_rounded,
        color: Colors.white,
        size: size * 0.56,
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
          InitialAvatar(name: authState.username),
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
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
