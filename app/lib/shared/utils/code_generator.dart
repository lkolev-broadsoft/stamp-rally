import 'dart:convert';

import 'package:crypto/crypto.dart';

const confirmationCodeLifetime = Duration(seconds: 30);

String generateConfirmationCode({
  required String eventId,
  required String passportId,
  required String displayNonce,
  DateTime? now,
}) {
  final timestamp = now ?? DateTime.now().toUtc();
  final timeWindow =
      timestamp.millisecondsSinceEpoch ~/ confirmationCodeLifetime.inMilliseconds;
  final payload = '$eventId|$passportId|$displayNonce|$timeWindow';
  final digest = sha256.convert(utf8.encode(payload)).bytes;
  final value = ((digest[0] << 24) |
          (digest[1] << 16) |
          (digest[2] << 8) |
          digest[3]) &
      0x7fffffff;

  return (value % 10000).toString().padLeft(4, '0');
}
