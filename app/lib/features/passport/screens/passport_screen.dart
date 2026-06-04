import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../events/models/event.dart';
import '../../events/providers/demo_event_provider.dart';
import '../models/passport.dart';
import '../providers/passport_controller.dart';

class PassportScreen extends ConsumerWidget {
  const PassportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(demoEventProvider);
    final passport = ref.watch(passportControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Passport')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: eventAsync.when(
                data: (event) {
                  if (passport == null) {
                    return _EmptyPassport(event: event);
                  }

                  return _PassportProgress(event: event, passport: passport);
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

class _EmptyPassport extends ConsumerWidget {
  const _EmptyPassport({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          event.name,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          icon: const Icon(Icons.add_card),
          label: const Text('Join Event'),
          onPressed: () {
            ref.read(passportControllerProvider.notifier).joinEvent(event);
          },
        ),
      ],
    );
  }
}

class _PassportProgress extends StatelessWidget {
  const _PassportProgress({
    required this.event,
    required this.passport,
  });

  final Event event;
  final Passport passport;

  @override
  Widget build(BuildContext context) {
    final completed = passport.completedCountFor(event);
    final unlocked = passport.hasUnlockedPrize(event);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '$completed of ${event.stampsNeeded} stamps',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 220,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.25,
            ),
            itemCount: event.checkpoints.length,
            itemBuilder: (context, index) {
              final checkpoint = event.checkpoints[index];
              final stamped = passport.hasStampFor(checkpoint.id);

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        stamped ? Icons.verified : Icons.radio_button_unchecked,
                        color: stamped
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outline,
                      ),
                      const Spacer(),
                      Text(
                        checkpoint.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        stamped ? 'Stamped' : 'Open',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          icon: const Icon(Icons.qr_code_2),
          label: const Text('Show Passport QR'),
          onPressed: () => context.go('/passport/show'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          icon: const Icon(Icons.qr_code_scanner),
          label: const Text('Scan Stamp QR'),
          onPressed: () => context.go('/passport/import'),
        ),
        if (unlocked) ...[
          const SizedBox(height: 12),
          FilledButton.icon(
            icon: const Icon(Icons.card_giftcard),
            label: const Text('Claim Prize'),
            onPressed: () => context.go('/prize'),
          ),
        ],
      ],
    );
  }
}
