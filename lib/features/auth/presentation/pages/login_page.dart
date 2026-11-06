import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ufin_admin_system/config/routes/app_routes.dart';
import 'package:ufin_admin_system/core/providers/auth_provider.dart';
import 'package:ufin_admin_system/core/widgets/widgets.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordFocus = FocusNode();
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    // Dev convenience only; kDebugMode is const so release builds strip it.
    _usernameController = TextEditingController(
      text: kDebugMode ? 'systemadmin' : '',
    );
    _passwordController = TextEditingController(
      text: kDebugMode ? '123456@ufin#2025' : '',
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _submit() {
    final auth = ref.read(authStateProvider);
    if (auth.isLoading) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    TextInput.finishAutofillContext();
    FocusScope.of(context).unfocus();
    ref
        .read(authStateProvider.notifier)
        .login(_usernameController.text.trim(), _passwordController.text);
  }

  void _clearErrorOnEdit() {
    if (ref.read(authStateProvider).error != null) {
      ref.read(authStateProvider.notifier).clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateProvider);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    ref.listen(authStateProvider, (previous, next) {
      if (next.isAuthenticated && previous?.isAuthenticated != true) {
        context.go(AppRoutes.admin);
      }
    });

    final error = auth.isLoading ? null : auth.error;
    final isWide = MediaQuery.sizeOf(context).width >= 960;

    final form = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 380),
      child: Form(
        key: _formKey,
        child: AutofillGroup(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!isWide) ...[
                const Align(
                  alignment: Alignment.centerLeft,
                  child: AppLogo(size: 44),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
              Text(
                context.tr(AuthText.welcome),
                style: textTheme.headlineMedium,
              ),
              const SizedBox(height: 6),
              Text(
                context.tr(AuthText.subtitle),
                style: textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AnimatedSize(
                duration: const Duration(milliseconds: 180),
                child: error == null
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                        child: _ErrorBanner(message: friendlyError(error)),
                      ),
              ),
              _FieldLabel(context.tr(AuthText.username)),
              TextFormField(
                controller: _usernameController,
                enabled: !auth.isLoading,
                autofillHints: const [AutofillHints.username],
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.text,
                autocorrect: false,
                decoration: InputDecoration(
                  hintText: context.tr(AuthText.usernameHint),
                  prefixIcon: const Icon(
                    Icons.person_outline_rounded,
                    size: 20,
                  ),
                ),
                onChanged: (_) => _clearErrorOnEdit(),
                onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? context.tr(AuthText.usernameRequired)
                    : null,
              ),
              const SizedBox(height: AppSpacing.lg),
              _FieldLabel(context.tr(AuthText.password)),
              TextFormField(
                controller: _passwordController,
                focusNode: _passwordFocus,
                enabled: !auth.isLoading,
                obscureText: _obscure,
                autofillHints: const [AutofillHints.password],
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  hintText: context.tr(AuthText.passwordHint),
                  prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                  suffixIcon: IconButton(
                    tooltip: context.tr(
                      _obscure ? AuthText.showPassword : AuthText.hidePassword,
                    ),
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                onChanged: (_) => _clearErrorOnEdit(),
                onFieldSubmitted: (_) => _submit(),
                validator: (v) => (v == null || v.isEmpty)
                    ? context.tr(AuthText.passwordRequired)
                    : null,
              ),
              const SizedBox(height: AppSpacing.xl),
              FilledButton(
                onPressed: auth.isLoading ? null : _submit,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: auth.isLoading
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(context.tr(AuthText.signingIn)),
                        ],
                      )
                    : Text(context.tr(AuthText.signIn)),
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Icon(
                    Icons.shield_outlined,
                    size: 14,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      context.tr(AuthText.restricted),
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    final formPane = SafeArea(
      child: Column(
        children: [
          // Language and theme are reachable before signing in.
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 12, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                LanguageToggle(),
                SizedBox(width: 4),
                ThemeModeButton(),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 16, 28, 40),
                child: form,
              ),
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      body: isWide
          ? Row(
              children: [
                const Expanded(flex: 5, child: _BrandPanel()),
                Expanded(
                  flex: 6,
                  child: ColoredBox(color: scheme.surface, child: formPane),
                ),
              ],
            )
          : formPane,
    );
  }
}

/// Left half of the wide login layout: brand, one-line pitch, highlights.
class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final text = context.text;
    final points = [
      (Icons.verified_outlined, AuthText.heroPoint1),
      (Icons.account_balance_wallet_outlined, AuthText.heroPoint2),
      (Icons.rocket_launch_outlined, AuthText.heroPoint3),
    ];
    return Container(
      color: scheme.surfaceContainerLowest,
      padding: const EdgeInsets.fromLTRB(56, 48, 56, 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AppLogo(size: 36),
              const SizedBox(width: 12),
              Text(context.tr(NavText.appName), style: text.titleMedium),
            ],
          ),
          const Spacer(),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.tr(AuthText.heroTitle), style: text.displaySmall),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  context.tr(AuthText.heroBody),
                  style: text.bodyLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                for (final (icon, label) in points)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: scheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Icon(icon, size: 17, color: scheme.primary),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            context.tr(label),
                            style: text.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const Spacer(flex: 2),
          Text(
            '© ${DateTime.now().year} UFin',
            style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: scheme.errorContainer,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.error_outline_rounded, size: 18, color: scheme.error),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: scheme.onErrorContainer, height: 1.35),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
