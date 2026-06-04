import 'package:flutter_test/flutter_test.dart';
import 'package:stamp_rally/shared/utils/code_generator.dart';

void main() {
  test('confirmation code is stable inside the same time window', () {
    final now = DateTime.utc(2026, 6, 4, 10, 15, 12);

    final first = generateConfirmationCode(
      eventId: 'event-1',
      passportId: 'passport-1',
      displayNonce: 'nonce-1',
      now: now,
    );
    final second = generateConfirmationCode(
      eventId: 'event-1',
      passportId: 'passport-1',
      displayNonce: 'nonce-1',
      now: now.add(const Duration(seconds: 10)),
    );

    expect(first, second);
    expect(first, hasLength(4));
  });

  test('confirmation code changes with nonce', () {
    final now = DateTime.utc(2026, 6, 4, 10, 15);

    final first = generateConfirmationCode(
      eventId: 'event-1',
      passportId: 'passport-1',
      displayNonce: 'nonce-1',
      now: now,
    );
    final second = generateConfirmationCode(
      eventId: 'event-1',
      passportId: 'passport-1',
      displayNonce: 'nonce-2',
      now: now,
    );

    expect(first, isNot(second));
  });
}
