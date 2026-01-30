import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ufin_admin_system/config/routes/app_routes.dart';
import 'package:ufin_admin_system/core/providers/auth_provider.dart';

class SubscriptionsPage extends ConsumerWidget {
  const SubscriptionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscriptions'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authStateProvider.notifier).logout();
              context.go(AppRoutes.login);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to Subscriptions',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User Information',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Text('Email: ${authState.email ?? "N/A"}'),
                    const SizedBox(height: 8),
                    Text('User ID: ${authState.userId ?? "N/A"}'),
                    const SizedBox(height: 8),
                    Text(
                      'Status: ${authState.isAuthenticated ? "Authenticated" : "Not Authenticated"}',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Your Subscriptions',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildSubscriptionCard(
                    context,
                    title: 'Premium Plan',
                    price: '\$9.99',
                    description: 'Monthly subscription',
                    features: ['Feature 1', 'Feature 2', 'Feature 3'],
                  ),
                  const SizedBox(height: 16),
                  _buildSubscriptionCard(
                    context,
                    title: 'Pro Plan',
                    price: '\$19.99',
                    description: 'Monthly subscription',
                    features: [
                      'Feature 1',
                      'Feature 2',
                      'Feature 3',
                      'Feature 4',
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionCard(
    BuildContext context, {
    required String title,
    required String price,
    required String description,
    required List<String> features,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                Text(price, style: Theme.of(context).textTheme.headlineSmall),
              ],
            ),
            const SizedBox(height: 12),
            ...features
                .map(
                  (feature) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 16,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(feature),
                      ],
                    ),
                  ),
                )
                .toList(),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Subscribe Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
