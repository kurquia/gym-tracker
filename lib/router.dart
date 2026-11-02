// The address of every screen: the five tabs and the full-screen pages.

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'features/exercises/body_model/body_3d_screen.dart';
import 'features/exercises/exercise_detail_screen.dart';
import 'features/exercises/exercise_edit_screen.dart';
import 'features/exercises/exercise_picker_screen.dart';
import 'features/exercises/exercises_screen.dart';
import 'features/record/record_screen.dart';
import 'features/routines/routine_edit_screen.dart';
import 'features/routines/routines_screen.dart';
import 'features/settings/backup_screen.dart';
import 'features/settings/dates_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/settings/units_screen.dart';
import 'features/settings/workout_settings_screen.dart';
import 'features/statistics/statistics_screen.dart';
import 'features/statistics/workout_log_screen.dart';
import 'shared/widgets/app_shell.dart';

/// Whether a 3D page opens on the back (`?view=back`) or the front.
bool _backView(GoRouterState state) =>
    state.uri.queryParameters['view'] == 'back';

int _id(GoRouterState state) => int.parse(state.pathParameters['id']!);

/// Full-screen pages (editors, pickers) go on the root navigator, above the tab bar.
GoRouter buildRouter() {
  final rootKey = GlobalKey<NavigatorState>();
  return GoRouter(
    navigatorKey: rootKey,
    initialLocation: '/record',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/routines',
                builder: (_, _) => const RoutinesScreen(),
                routes: [
                  GoRoute(
                    path: 'new',
                    parentNavigatorKey: rootKey,
                    builder: (_, _) => const RoutineEditScreen(),
                  ),
                  GoRoute(
                    path: ':id',
                    parentNavigatorKey: rootKey,
                    builder: (_, state) =>
                        RoutineEditScreen(routineId: _id(state)),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/statistics',
                builder: (_, _) => const StatisticsScreen(),
                routes: [
                  GoRoute(
                    path: 'workout/:id',
                    builder: (_, state) =>
                        WorkoutLogScreen(sessionId: _id(state)),
                    routes: [
                      GoRoute(
                        path: '3d',
                        parentNavigatorKey: rootKey,
                        builder: (_, state) => Body3dScreen.workout(
                          sessionId: _id(state),
                          back: _backView(state),
                        ),
                      ),
                      GoRoute(
                        path: 'exercise/:exerciseId/3d',
                        parentNavigatorKey: rootKey,
                        builder: (_, state) => Body3dScreen.exercise(
                          exerciseId: int.parse(
                            state.pathParameters['exerciseId']!,
                          ),
                          back: _backView(state),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/record', builder: (_, _) => const RecordScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/exercises',
                builder: (_, _) => const ExercisesScreen(),
                routes: [
                  GoRoute(
                    path: 'pick',
                    parentNavigatorKey: rootKey,
                    builder: (_, state) => ExercisePickerScreen(
                      alreadyAdded: state.extra as Set<int>? ?? const {},
                    ),
                  ),
                  GoRoute(
                    path: 'new',
                    parentNavigatorKey: rootKey,
                    builder: (_, state) => ExerciseEditScreen(
                      initialName: state.extra as String? ?? '',
                    ),
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (_, state) =>
                        ExerciseDetailScreen(exerciseId: _id(state)),
                    routes: [
                      GoRoute(
                        path: 'edit',
                        parentNavigatorKey: rootKey,
                        builder: (_, state) =>
                            ExerciseEditScreen(exerciseId: _id(state)),
                      ),
                      GoRoute(
                        path: '3d',
                        parentNavigatorKey: rootKey,
                        builder: (_, state) => Body3dScreen.exercise(
                          exerciseId: _id(state),
                          back: _backView(state),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (_, _) => const SettingsScreen(),
                routes: [
                  GoRoute(
                    path: 'units',
                    builder: (_, _) => const UnitsScreen(),
                  ),
                  GoRoute(
                    path: 'dates',
                    builder: (_, _) => const DatesScreen(),
                  ),
                  GoRoute(
                    path: 'workout',
                    builder: (_, _) => const WorkoutSettingsScreen(),
                  ),
                  GoRoute(
                    path: 'backup',
                    builder: (_, _) => const BackupScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
