import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ufin_admin_system/config/routes/app_routes.dart';
import 'package:ufin_admin_system/config/theme/app_theme.dart';
import 'package:ufin_admin_system/core/core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  runApp(const ProviderScope(child: UfinAdminApp()));
}

class UfinAdminApp extends ConsumerWidget {
  const UfinAdminApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final router = ref.watch(goRouterProvider);

    // Show splash screen while initializing
    if (authState.isInitializing) {
      return MaterialApp(
        title: 'UFin Admin System',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
      );
    }

    return MaterialApp.router(
      title: 'UFin Admin System',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
