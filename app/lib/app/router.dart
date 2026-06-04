import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/home/screens/home_screen.dart';
import '../features/operator/screens/issue_stamp_screen.dart';
import '../features/operator/screens/operator_pin_screen.dart';
import '../features/operator/screens/operator_scan_screen.dart';
import '../features/passport/screens/import_stamp_screen.dart';
import '../features/passport/screens/passport_screen.dart';
import '../features/passport/screens/show_passport_screen.dart';
import '../features/prize/screens/prize_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/passport',
        builder: (context, state) => const PassportScreen(),
      ),
      GoRoute(
        path: '/passport/show',
        builder: (context, state) => const ShowPassportScreen(),
      ),
      GoRoute(
        path: '/passport/import',
        builder: (context, state) => const ImportStampScreen(),
      ),
      GoRoute(
        path: '/operator',
        builder: (context, state) => const OperatorPinScreen(),
      ),
      GoRoute(
        path: '/operator/scan',
        builder: (context, state) => const OperatorScanScreen(),
      ),
      GoRoute(
        path: '/operator/issue',
        builder: (context, state) => const IssueStampScreen(),
      ),
      GoRoute(
        path: '/prize',
        builder: (context, state) => const PrizeScreen(),
      ),
    ],
  );
});
