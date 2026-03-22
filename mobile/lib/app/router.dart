import 'package:go_router/go_router.dart';
import '../core/constants/app_constants.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/home/presentation/home_page.dart';
import '../features/history/presentation/history_page.dart';
import '../features/favorites/presentation/favorites_page.dart';
import '../features/profile/presentation/profile_page.dart';
import '../features/scanner/presentation/scanner_page.dart';
import '../features/product_details/presentation/product_details_page.dart';
import '../features/ai_analysis/presentation/ai_analysis_page.dart';
import 'shell/main_shell.dart';

final appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    // Auth
    GoRoute(
      path: AppRoutes.login,
      builder: (context, _) => const LoginPage(),
    ),

    // Main shell with bottom nav (4 tabs)
    StatefulShellRoute.indexedStack(
      builder: (context, _, shell) => MainShell(navigationShell: shell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, _) => const HomePage(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: AppRoutes.history,
            builder: (context, _) => const HistoryPage(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: AppRoutes.favorites,
            builder: (context, _) => const FavoritesPage(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: AppRoutes.profile,
            builder: (context, _) => const ProfilePage(),
          ),
        ]),
      ],
    ),

    // Full-screen flows (no bottom nav)
    GoRoute(
      path: AppRoutes.scanner,
      builder: (context, _) => const ScannerPage(),
    ),
    GoRoute(
      path: AppRoutes.productDetails,
      builder: (_, state) => ProductDetailsPage(
        barcode: state.pathParameters['barcode']!,
      ),
    ),
    GoRoute(
      path: AppRoutes.aiAnalysis,
      builder: (_, state) => AiAnalysisPage(
        barcode: state.pathParameters['barcode']!,
      ),
    ),
  ],
);
