import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ufin_admin_system/core/providers/auth_provider.dart';
import 'package:ufin_admin_system/features/auth/presentation/pages/login_page.dart';
import 'package:ufin_admin_system/features/auth/presentation/pages/register_page.dart';
import 'package:ufin_admin_system/features/subscriptions/presentation/pages/subscriptions_page.dart';

// Routes
class AppRoutes {
  static const login = '/login';
  static const register = '/register';
  static const subscriptions = '/subscriptions';
  static const home = '/';
}

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: authState.isAuthenticated
        ? AppRoutes.subscriptions
        : AppRoutes.login,
    redirect: (context, state) {
      final isAuth = authState.isAuthenticated;
      final isAuthPage =
          state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register;

      if (!isAuth && !isAuthPage) {
        return AppRoutes.login;
      }

      if (isAuth && isAuthPage) {
        return AppRoutes.subscriptions;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.subscriptions,
        builder: (context, state) => const SubscriptionsPage(),
      ),
    ],
  );
});
