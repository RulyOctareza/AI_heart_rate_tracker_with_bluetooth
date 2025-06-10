import 'package:go_router/go_router.dart';
import 'presentation/scanner_page.dart';
import 'presentation/monitor_page.dart';
import 'presentation/history_page.dart';

class AppRouter {
  static GoRouter router(void Function() toggleTheme) => GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => ScannerPage(onToggleTheme: toggleTheme),
      ),
      GoRoute(
        path: '/monitor',
        builder: (context, state) => const MonitorPage(),
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) => const HistoryPage(),
      ),
    ],
  );
}
