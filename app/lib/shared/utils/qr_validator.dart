import 'dart:convert';

import 'stamp_token.dart';

class PassportQrPayload {
  const PassportQrPayload({
    required this.eventId,
    required this.passportId,
    required this.displayNonce,
  });

  final String eventId;
  final String passportId;
  final String displayNonce;

  static const type = 'passport';

  Map<String, Object?> toJson() {
    return {
      'app': StampToken.appId,
      'version': StampToken.version,
      'type': type,
      'passportId': passportId,
      'eventId': eventId,
      'displayNonce': displayNonce,
    };
  }

  String toRawJson() => jsonEncode(toJson());

  factory PassportQrPayload.fromRawJson(String rawJson) {
    final json = QrValidator.decode(rawJson);
    QrValidator.requireEnvelope(json, type);

    return PassportQrPayload(
      eventId: json['eventId']! as String,
      passportId: json['passportId']! as String,
      displayNonce: json['displayNonce']! as String,
    );
  }
}

class QrValidator {
  const QrValidator._();

  static Map<String, Object?> decode(String rawJson) {
    final decoded = jsonDecode(rawJson);
    if (decoded is! Map) {
      throw const FormatException('QR payload must be a JSON object.');
    }
    return Map<String, Object?>.from(decoded);
  }

  static void requireEnvelope(
    Map<String, Object?> json,
    String expectedType,
  ) {
    if (json['app'] != StampToken.appId ||
        json['version'] != StampToken.version ||
        json['type'] != expectedType) {
      throw const FormatException(
        'QR payload is not a compatible Stamp Rally payload.',
      );
    }
  }

  static PassportQrPayload parsePassport(String rawJson) {
    return PassportQrPayload.fromRawJson(rawJson);
  }

  static StampToken parseStampToken(String rawJson) {
    return StampToken.fromRawJson(rawJson);
  }
}
