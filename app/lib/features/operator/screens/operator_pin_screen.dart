import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../events/providers/demo_event_provider.dart';
import '../models/operator.dart';
import '../providers/operator_controller.dart';

class OperatorPinScreen extends ConsumerStatefulWidget {
  const OperatorPinScreen({super.key});

  @override
  ConsumerState<OperatorPinScreen> createState() => _OperatorPinScreenState();
}

class _OperatorPinScreenState extends ConsumerState<OperatorPinScreen> {
  final _pinController = TextEditingController();
  String? _message;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final operators = ref.watch(demoOperatorsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Operator')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _pinController,
                    decoration: const InputDecoration(
                      labelText: 'Operator PIN',
                      prefixIcon: Icon(Icons.pin),
                    ),
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    onSubmitted: (_) => _submit(operators),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    icon: const Icon(Icons.login),
                    label: const Text('Continue'),
                    onPressed: () => _submit(operators),
                  ),
                  if (_message != null) ...[
                    const SizedBox(height: 16),
                    Text(_message!, textAlign: TextAlign.center),
                  ],
                  const Spacer(),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final operator in operators)
                        ActionChip(
                          avatar: const Icon(Icons.badge, size: 18),
                          label: Text('${operator.pin} ${operator.name}'),
                          onPressed: () {
                            _pinController.text = operator.pin;
                            _submit(operators);
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submit(List<Operator> operators) {
    final success = ref.read(operatorSessionProvider.notifier).loginWithPin(
          pin: _pinController.text,
          operators: operators,
        );

    if (success) {
      context.go('/operator/scan');
    } else {
      setState(() => _message = 'Unknown operator PIN.');
    }
  }
}
