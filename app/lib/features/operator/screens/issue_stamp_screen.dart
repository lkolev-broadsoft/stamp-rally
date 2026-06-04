import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../events/providers/demo_event_provider.dart';
import '../providers/operator_controller.dart';

class IssueStampScreen extends ConsumerStatefulWidget {
  const IssueStampScreen({super.key});

  @override
  ConsumerState<IssueStampScreen> createState() => _IssueStampScreenState();
}

class _IssueStampScreenState extends ConsumerState<IssueStampScreen> {
  bool _issuing = false;

  @override
  Widget build(BuildContext context) {
    final eventAsync = ref.watch(demoEventProvider);
    final session = ref.watch(operatorSessionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Issue Stamp')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: eventAsync.when(
                data: (event) {
                  final operator = session.operator;
                  final passportPayload = session.passportPayload;
                  if (operator == null || passportPayload == null) {
                    return _MissingScan(onBack: () => context.go('/operator'));
                  }

                  final token = session.issuedToken;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        session.confirmationCode ?? '----',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        passportPayload.passportId,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 24),
                      if (token == null)
                        FilledButton.icon(
                          icon: _issuing
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.verified),
                          label: const Text('Issue Stamp'),
                          onPressed: _issuing
                              ? null
                              : () async {
                                  setState(() => _issuing = true);
                                  await ref
                                      .read(operatorSessionProvider.notifier)
                                      .issueStamp(event: event);
                                  if (mounted) {
                                    setState(() => _issuing = false);
                                  }
                                },
                        )
                      else ...[
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: QrImageView(
                              data: token.toRawJson(),
                              version: QrVersions.auto,
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SelectableText(
                          token.toRawJson(),
                          maxLines: 4,
                        ),
                        const Spacer(),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.qr_code_scanner),
                          label: const Text('Scan Next Passport'),
                          onPressed: () {
                            ref
                                .read(operatorSessionProvider.notifier)
                                .clearIssuedStamp();
                            context.go('/operator/scan');
                          },
                        ),
                      ],
                      if (session.errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          session.errorMessage!,
                          textAlign: TextAlign.center,
                        ),
                      ],
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

class _MissingScan extends StatelessWidget {
  const _MissingScan({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Passport scan not found.', textAlign: TextAlign.center),
        const SizedBox(height: 16),
        FilledButton.icon(
          icon: const Icon(Icons.qr_code_scanner),
          label: const Text('Scan Passport'),
          onPressed: onBack,
        ),
      ],
    );
  }
}
