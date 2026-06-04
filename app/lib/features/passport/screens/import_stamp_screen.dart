import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/utils/qr_validator.dart';
import '../../events/models/event.dart';
import '../../events/providers/demo_event_provider.dart';
import '../../scanner/screens/qr_scanner_panel.dart';
import '../providers/passport_controller.dart';

class ImportStampScreen extends ConsumerStatefulWidget {
  const ImportStampScreen({super.key});

  @override
  ConsumerState<ImportStampScreen> createState() => _ImportStampScreenState();
}

class _ImportStampScreenState extends ConsumerState<ImportStampScreen> {
  bool _handling = false;
  String? _message;

  @override
  Widget build(BuildContext context) {
    final eventAsync = ref.watch(demoEventProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Scan Stamp')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: eventAsync.when(
                data: (event) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: QrScannerPanel(
                          manualLabel: 'Stamp payload',
                          onPayload: (payload) => _handlePayload(event, payload),
                        ),
                      ),
                    ),
                    if (_message != null) ...[
                      const SizedBox(height: 16),
                      Text(_message!, textAlign: TextAlign.center),
                    ],
                  ],
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => Text('Failed to load event: $error'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handlePayload(Event event, String rawPayload) async {
    if (_handling) {
      return;
    }
    _handling = true;

    try {
      final token = QrValidator.parseStampToken(rawPayload.trim());
      final result = await ref.read(passportControllerProvider.notifier).importStamp(
            event: event,
            token: token,
          );

      if (!mounted) {
        return;
      }

      setState(() => _message = result.message);
      if (result.isSuccess) {
        await Future<void>.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          context.go('/passport');
        }
      }
    } on FormatException catch (error) {
      if (mounted) {
        setState(() => _message = error.message);
      }
    } finally {
      _handling = false;
    }
  }
}
