import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../events/providers/demo_event_provider.dart';
import '../../passport/providers/passport_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(demoEventProvider);
    final passport = ref.watch(passportControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Stamp Rally')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: eventAsync.when(
                data: (event) {
                  final progress = passport == null
                      ? 0
                      : passport.completedCountFor(event);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        event.name,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(event.description),
                      const SizedBox(height: 24),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Passport',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text('$progress of ${event.stampsNeeded} stamps'),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      FilledButton.icon(
                        icon: const Icon(Icons.style),
                        label: Text(
                          passport == null ? 'Join Demo Event' : 'Open Passport',
                        ),
                        onPressed: () {
                          ref
                              .read(passportControllerProvider.notifier)
                              .joinEvent(event);
                          context.go('/passport');
                        },
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.badge),
                        label: const Text('Operator Mode'),
                        onPressed: () => context.go('/operator'),
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => Text('Failed to load event: $error'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
