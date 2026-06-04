import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../shared/utils/code_generator.dart';
import '../../../shared/utils/qr_validator.dart';
import '../providers/passport_controller.dart';

class ShowPassportScreen extends ConsumerStatefulWidget {
  const ShowPassportScreen({super.key});

  @override
  ConsumerState<ShowPassportScreen> createState() => _ShowPassportScreenState();
}

class _ShowPassportScreenState extends ConsumerState<ShowPassportScreen> {
  static const _uuid = Uuid();

  late String _displayNonce;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _displayNonce = _uuid.v4();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final passport = ref.watch(passportControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Passport QR')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: passport == null
                  ? const Center(child: Text('No passport found.'))
                  : _PassportQr(
                      eventId: passport.eventId,
                      passportId: passport.id,
                      displayNonce: _displayNonce,
                      onRefresh: () {
                        setState(() {
                          _displayNonce = _uuid.v4();
                        });
                      },
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PassportQr extends StatelessWidget {
  const _PassportQr({
    required this.eventId,
    required this.passportId,
    required this.displayNonce,
    required this.onRefresh,
  });

  final String eventId;
  final String passportId;
  final String displayNonce;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final payload = PassportQrPayload(
      eventId: eventId,
      passportId: passportId,
      displayNonce: displayNonce,
    );
    final code = generateConfirmationCode(
      eventId: eventId,
      passportId: passportId,
      displayNonce: displayNonce,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: QrImageView(
              data: payload.toRawJson(),
              version: QrVersions.auto,
              backgroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          code,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displayMedium,
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          icon: const Icon(Icons.refresh),
          label: const Text('Refresh QR'),
          onPressed: onRefresh,
        ),
      ],
    );
  }
}
