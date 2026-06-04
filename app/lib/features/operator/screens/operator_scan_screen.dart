import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/utils/qr_validator.dart';
import '../../events/models/event.dart';
import '../../events/providers/demo_event_provider.dart';
import '../../scanner/screens/qr_scanner_panel.dart';
import '../providers/operator_controller.dart';

class OperatorScanScreen extends ConsumerStatefulWidget {
  const OperatorScanScreen({super.key});

  @override
  ConsumerState<OperatorScanScreen> createState() => _OperatorScanScreenState();
}

class _OperatorScanScreenState extends ConsumerState<OperatorScanScreen> {
  bool _handling = false;
  String? _message;

  @override
  Widget build(BuildContext context) {
    final eventAsync = ref.watch(demoEventProvider);
    final session = ref.watch(operatorSessionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Scan Passport')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: eventAsync.when(
                data: (event) {
                  final operator = session.operator;
                  if (operator == null) {
                    return _MissingOperator(onBack: () => context.go('/operator'));
                  }

                  final checkpoint = event.checkpointById(operator.checkpointId);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        checkpoint?.name ?? operator.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: SingleChildScrollView(
                          child: QrScannerPanel(
                            manualLabel: 'Passport payload',
                            onPayload: (payload) => _handlePayload(event, payload),
                          ),
                        ),
                      ),
                      if (_message != null) ...[
                        const SizedBox(height: 16),
                        Text(_message!, textAlign: TextAlign.center),
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

  void _handlePayload(Event event, String rawPayload) {
    if (_handling) {
      return;
    }
    _handling = true;

    try {
      final payload = QrValidator.parsePassport(rawPayload.trim());
      final accepted = ref
          .read(operatorSessionProvider.notifier)
          .acceptPassportPayload(event: event, payload: payload);

      if (accepted) {
        context.go('/operator/issue');
        return;
      }

      final session = ref.read(operatorSessionProvider);
      setState(() => _message = session.errorMessage);
    } on FormatException catch (error) {
      setState(() => _message = error.message);
    } finally {
      _handling = false;
    }
  }
}

class _MissingOperator extends StatelessWidget {
  const _MissingOperator({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Operator session not found.', textAlign: TextAlign.center),
        const SizedBox(height: 16),
        FilledButton.icon(
          icon: const Icon(Icons.login),
          label: const Text('Enter PIN'),
          onPressed: onBack,
        ),
      ],
    );
  }
}
