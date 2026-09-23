import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ufin_admin_system/config/theme/app_theme.dart';
import 'package:ufin_admin_system/core/services/dio_client.dart';
import 'package:ufin_admin_system/core/widgets/app_ui.dart';

Widget _host(Widget child, {ThemeData? theme}) => MaterialApp(
  theme: theme ?? AppTheme.lightTheme,
  home: Scaffold(body: child),
);

void main() {
  group('friendlyError', () {
    test('strips Dart exception prefixes', () {
      expect(friendlyError(Exception('Shop not found')), 'Shop not found');
      expect(friendlyError(StateError('bad state')), 'bad state');
    });

    test('uses ApiException message verbatim', () {
      expect(
        friendlyError(ApiException(message: 'Plan code already exists')),
        'Plan code already exists',
      );
    });

    test('falls back for null, empty and opaque errors', () {
      const fallback = 'Something went wrong. Please try again.';
      expect(friendlyError(null), fallback);
      expect(friendlyError(''), fallback);
      expect(friendlyError(Object()), fallback);
    });

    test('hides HTML error pages and truncates long text', () {
      expect(
        friendlyError('<html><body>502</body></html>'),
        'Server error. Please try again later.',
      );
      final long = friendlyError('x' * 500);
      expect(long.length, 241);
      expect(long.endsWith('…'), isTrue);
    });
  });

  group('StatusTone.fromStatus', () {
    test('maps backend statuses case- and separator-insensitively', () {
      expect(StatusTone.fromStatus('ACTIVE'), StatusTone.success);
      expect(StatusTone.fromStatus('approved'), StatusTone.success);
      expect(StatusTone.fromStatus('PENDING'), StatusTone.warning);
      expect(StatusTone.fromStatus('expiring-soon'), StatusTone.warning);
      expect(StatusTone.fromStatus('Suspended'), StatusTone.danger);
      expect(StatusTone.fromStatus('REJECTED'), StatusTone.danger);
      expect(StatusTone.fromStatus('expired'), StatusTone.neutral);
      expect(StatusTone.fromStatus('TRIAL'), StatusTone.info);
    });

    test('unknown or null falls back to info', () {
      expect(StatusTone.fromStatus('mystery'), StatusTone.info);
      expect(StatusTone.fromStatus(null), StatusTone.info);
    });
  });

  test('humanize', () {
    expect(humanize('EXPIRING_SOON'), 'Expiring soon');
    expect(humanize('active'), 'Active');
    expect(humanize(''), '');
  });

  group('StatusBadge', () {
    testWidgets('renders humanized label in light and dark themes', (
      tester,
    ) async {
      for (final theme in [AppTheme.lightTheme, AppTheme.darkTheme]) {
        await tester.pumpWidget(
          _host(StatusBadge.fromStatus('GRACE_PERIOD'), theme: theme),
        );
        expect(find.text('Grace period'), findsOneWidget);
      }
    });
  });

  group('AppDialogs', () {
    testWidgets('confirm returns true on confirm and false on cancel', (
      tester,
    ) async {
      bool? result;
      await tester.pumpWidget(
        _host(
          Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await AppDialogs.confirm(
                  context,
                  title: 'Delete?',
                  message: 'Really?',
                  confirmLabel: 'Delete',
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(result, isFalse);

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(result, isTrue);
    });

    testWidgets('confirmWithReason enforces required reason and trims', (
      tester,
    ) async {
      String? result = 'unset';
      await tester.pumpWidget(
        _host(
          Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await AppDialogs.confirmWithReason(
                  context,
                  title: 'Suspend',
                  message: 'Why?',
                  confirmLabel: 'Suspend',
                  reasonRequired: true,
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      // Empty reason blocks submission.
      await tester.tap(find.widgetWithText(FilledButton, 'Suspend'));
      await tester.pumpAndSettle();
      expect(find.text('Please enter a reason'), findsOneWidget);
      expect(result, 'unset');

      await tester.enterText(find.byType(TextField), '  fraud  ');
      await tester.pump();
      expect(find.text('Please enter a reason'), findsNothing);
      await tester.tap(find.widgetWithText(FilledButton, 'Suspend'));
      await tester.pumpAndSettle();
      expect(result, 'fraud');
    });

    testWidgets('confirmWithReason returns null when cancelled', (
      tester,
    ) async {
      String? result = 'unset';
      await tester.pumpWidget(
        _host(
          Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await AppDialogs.confirmWithReason(
                  context,
                  title: 'Suspend',
                  message: 'Why?',
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(result, isNull);
    });
  });

  group('AppFeedback', () {
    testWidgets('replaces the current snackbar instead of queueing', (
      tester,
    ) async {
      late BuildContext ctx;
      await tester.pumpWidget(
        _host(
          Builder(
            builder: (context) {
              ctx = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      AppFeedback.success(ctx, 'First');
      await tester.pump();
      AppFeedback.error(ctx, Exception('Second failed'));
      await tester.pumpAndSettle();

      expect(find.text('First'), findsNothing);
      expect(find.text('Second failed'), findsOneWidget);
    });

    testWidgets('messenger variant works after the caller is gone', (
      tester,
    ) async {
      late ScaffoldMessengerState messenger;
      await tester.pumpWidget(
        _host(
          Builder(
            builder: (context) {
              messenger = ScaffoldMessenger.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      messenger.showSuccess('Saved');
      await tester.pump();
      expect(find.text('Saved'), findsOneWidget);
    });
  });

  group('State views', () {
    testWidgets('AppErrorView shows friendly message and retries', (
      tester,
    ) async {
      var retried = 0;
      await tester.pumpWidget(
        _host(
          AppErrorView(
            error: Exception('Network down'),
            onRetry: () => retried++,
          ),
        ),
      );
      expect(find.text('Network down'), findsOneWidget);
      await tester.tap(find.text('Try again'));
      expect(retried, 1);
    });

    testWidgets('AppEmptyView does not overflow in a short viewport', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const SizedBox(
            height: 120,
            child: AppEmptyView(title: 'No shops', message: 'Try again'),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('No shops'), findsOneWidget);
    });
  });

  group('ContentWidth', () {
    testWidgets('caps width on wide screens and fills narrow ones', (
      tester,
    ) async {
      const key = Key('child');
      Future<Size> childSize(double width) async {
        tester.view.physicalSize = Size(width, 800);
        tester.view.devicePixelRatio = 1;
        await tester.pumpWidget(
          _host(
            const ContentWidth(maxWidth: 600, child: SizedBox.expand(key: key)),
          ),
        );
        return tester.getSize(find.byKey(key));
      }

      addTearDown(tester.view.reset);
      expect((await childSize(1000)).width, 600);
      expect((await childSize(400)).width, 400);
      // Height passes through so Column/Expanded bodies still fill the page.
      expect((await childSize(1000)).height, 800);
    });
  });

  group('AppSearchField', () {
    testWidgets('clear button empties text and resubmits', (tester) async {
      final controller = TextEditingController(text: 'abc');
      addTearDown(controller.dispose);
      final submitted = <String>[];
      await tester.pumpWidget(
        _host(
          AppSearchField(controller: controller, onSubmitted: submitted.add),
        ),
      );
      await tester.tap(find.byTooltip('Clear'));
      await tester.pump();
      expect(controller.text, isEmpty);
      expect(submitted, ['']);
      expect(find.byTooltip('Clear'), findsNothing);
    });
  });

  test('themes build and expose StatusColors', () {
    expect(AppTheme.lightTheme.extension<StatusColors>(), StatusColors.light);
    expect(AppTheme.darkTheme.extension<StatusColors>(), StatusColors.dark);
  });
}
