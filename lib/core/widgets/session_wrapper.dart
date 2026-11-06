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
            const AppLogo(size: 56),
            const SizedBox(height: 20),
            Text(
              context.tr(NavText.appName),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              context.tr(AuthText.restoring),
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: 120,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: const LinearProgressIndicator(minHeight: 3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Brand mark used on splash, login and the sidebar: a "U" monogram on the
/// brand color. Drawn with text so it stays crisp at any size.
class AppLogo extends StatelessWidget {
  final double size;
  const AppLogo({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.3),
        color: scheme.primary,
      ),
      child: Text(
        'U',
        textScaler: TextScaler.noScaling,
        style: TextStyle(
          color: scheme.onPrimary,
          fontSize: size * 0.52,
          fontWeight: FontWeight.w800,
          height: 1,
          letterSpacing: -0.5,
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
          const Scaffold(body: Center(child: _UnauthorizedText()));
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
                  authState.username ?? context.tr(NavText.admin),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  context.tr(NavText.administrator),
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

class _UnauthorizedText extends StatelessWidget {
  const _UnauthorizedText();

  @override
  Widget build(BuildContext context) => Text(context.tr(AuthText.unauthorized));
}
