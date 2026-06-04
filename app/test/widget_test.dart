import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stamp_rally/features/passport/models/passport.dart';
import 'package:stamp_rally/features/passport/providers/passport_store.dart';
import 'package:stamp_rally/main.dart';

void main() {
  testWidgets('home screen shows the demo event actions', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          passportStoreProvider.overrideWithValue(_MemoryPassportStore()),
        ],
        child: const StampRallyApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('jPrime 2026 Stamp Rally'), findsOneWidget);
    expect(find.text('Join Demo Event'), findsOneWidget);
    expect(find.text('Operator Mode'), findsOneWidget);
  });
}

class _MemoryPassportStore extends PassportStore {
  Passport? _passport;

  @override
  Passport? load() => _passport;

  @override
  Future<void> save(Passport passport) async {
    _passport = passport;
  }

  @override
  Future<void> clear() async {
    _passport = null;
  }
}
