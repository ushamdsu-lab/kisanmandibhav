import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/shell_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/mandi/mandi_screen.dart';
import '../screens/mausam/mausam_screen.dart';
import '../screens/kheti/kheti_screen.dart';
import '../screens/kheti/crop_detail_screen.dart';
import '../screens/kheti/calculator_screen.dart';
import '../screens/kheti/farm_khata_screen.dart';
import '../screens/kheti/dairy_tracker_screen.dart';
import '../screens/yojna/yojna_screen.dart';
import '../screens/yojna/scheme_detail_screen.dart';
import '../screens/crop_doctor/crop_doctor_screen.dart';
import '../screens/kheti/crop_calendar_screen.dart';
import '../screens/kheti/kisan_directory_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => ShellScreen(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: DashboardScreen(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/mandi',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: MandiScreen(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/mausam',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: MausamScreen(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/kheti',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: KhetiScreen(),
              ),
              routes: [
                GoRoute(
                  path: 'crop/:cropId',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => CropDetailScreen(
                    cropId: state.pathParameters['cropId']!,
                  ),
                ),
                GoRoute(
                  path: 'calculator',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const CalculatorScreen(),
                ),
                GoRoute(
                  path: 'doctor',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const CropDoctorScreen(),
                ),
                GoRoute(
                  path: 'khata',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const FarmKhataScreen(),
                ),
                GoRoute(
                  path: 'dairy',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const DairyTrackerScreen(),
                ),
                GoRoute(
                  path: 'calendar',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const CropCalendarScreen(),
                ),
                GoRoute(
                  path: 'directory',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const KisanDirectoryScreen(),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/yojna',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: YojnaScreen(),
              ),
              routes: [
                GoRoute(
                  path: 'detail/:schemeId',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => SchemeDetailScreen(
                    schemeId: state.pathParameters['schemeId']!,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/calculator',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const CalculatorScreen(),
    ),
    GoRoute(
      path: '/crop-doctor',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const CropDoctorScreen(),
    ),
    GoRoute(
      path: '/farm-khata',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const FarmKhataScreen(),
    ),
    GoRoute(
      path: '/dairy-tracker',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const DairyTrackerScreen(),
    ),
    GoRoute(
      path: '/schemes',
      redirect: (_, _) => '/yojna',
    ),
  ],
);
