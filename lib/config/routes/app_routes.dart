import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ufin_admin_system/core/providers/auth_provider.dart';
import 'package:ufin_admin_system/features/auth/presentation/pages/login_page.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/admin_shell.dart';

// Routes
class AppRoutes {
  static const login = '/login';
  static const admin = '/admin';
  static const home = '/';
}

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: authState.isAuthenticated
        ? AppRoutes.admin
        : AppRoutes.login,
    redirect: (context, state) {
      final isAuth = authState.isAuthenticated;
      final isAuthPage = state.matchedLocation == AppRoutes.login;

      if (!isAuth && !isAuthPage) {
        return AppRoutes.login;
      }

      if (isAuth && isAuthPage) {
        return AppRoutes.admin;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.admin,
        builder: (context, state) => const AdminShell(),
      ),
    ],
  );
});
