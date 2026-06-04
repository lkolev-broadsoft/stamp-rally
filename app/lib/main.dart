import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/router.dart';
import 'app/theme.dart';
import 'features/passport/providers/passport_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  final passportStore = PassportStore();
  await passportStore.open();

  runApp(
    ProviderScope(
      overrides: [
        passportStoreProvider.overrideWithValue(passportStore),
      ],
      child: const StampRallyApp(),
    ),
  );
}

class StampRallyApp extends ConsumerWidget {
  const StampRallyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Stamp Rally',
      debugShowCheckedModeBanner: false,
      theme: buildStampRallyTheme(),
      routerConfig: router,
    );
  }
}
