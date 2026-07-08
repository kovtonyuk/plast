import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/app_constants.dart';
import '../../features/admin_activities/presentation/admin_activities_page.dart';
import '../../features/admin_activities/presentation/admin_activity_form_page.dart';
import '../../features/plast_activities/presentation/plast_activities_page.dart';
import '../../features/plast_activities/presentation/plast_activity_form_page.dart';
import '../../features/first_unit/presentation/first_unit_page.dart';
import '../../features/first_unit/presentation/first_unit_form_page.dart';
import '../../features/first_unit/presentation/first_unit_members_page.dart';
import '../../features/first_unit/presentation/first_unit_rules_page.dart';
import '../../features/link_courier/presentation/link_courier_page.dart';
import '../../features/link_courier/presentation/link_courier_form_page.dart';
import '../../features/your_kurin/presentation/your_kurin_page.dart';
import '../../features/your_kurin/presentation/your_kurin_form_page.dart';
import '../../features/camps/presentation/camp_info_page.dart';
import '../../features/meetup_info/presentation/meetup_info_page.dart';
import '../../features/auth/presentation/auth_page.dart';
import '../../features/auth/presentation/email_verification_page.dart';
import '../../features/auth/presentation/password_recovery_page.dart';
import '../../features/calendar/presentation/calendar_page.dart';
import '../../features/camps/presentation/camps_page.dart';
import '../../features/events/presentation/add_event_page.dart';
import '../../features/events/presentation/events_list_page.dart';
import '../../features/goals/presentation/goals_page.dart';
import '../../shared/models/admin_activity_model.dart';
import '../../shared/models/plast_activity_model.dart';
import '../../shared/models/first_unit_model.dart';
import '../../shared/models/link_courier_model.dart';
import '../../shared/models/your_kurin_model.dart';
import '../../shared/models/goal_model.dart';
import '../../features/goals/presentation/goal_form_page.dart';
import '../../features/profile/presentation/profile_page.dart';
import '../../features/settings/presentation/settings_page.dart';
import '../../features/useful_info/presentation/useful_info_page.dart';
import '../../features/trainings/presentation/training_info_page.dart';
import '../../features/trainings/presentation/trainings_page.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/models/event_model.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

// Create router once outside the widget tree
final _router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/auth',
  refreshListenable: _AuthChangeNotifier(),
  redirect: (context, state) {
    final isLoggedIn = Supabase.instance.client.auth.currentUser != null;
    final isAuthRoute =
        state.matchedLocation == '/auth' ||
        state.matchedLocation == '/auth/recover';

    if (!isLoggedIn && !isAuthRoute) {
      return '/auth';
    }
    if (isLoggedIn && isAuthRoute) {
      return '/calendar';
    }
    return null;
  },
  routes: [
    GoRoute(path: '/auth', builder: (context, state) => const AuthPage()),
    GoRoute(
      path: '/auth/recover',
      builder: (context, state) => const PasswordRecoveryPage(),
    ),
    GoRoute(
      path: '/auth/verify-email',
      builder: (context, state) {
        final email = state.uri.queryParameters['email'] ?? '';
        return EmailVerificationPage(email: email);
      },
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainScaffold(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/calendar',
              builder: (context, state) => const CalendarPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/trainings',
              builder: (context, state) => const TrainingsPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/camps',
              builder: (context, state) => const CampsPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/events',
              builder: (context, state) => const EventsListPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/goals',
              builder: (context, state) => const GoalsPage(),
              routes: [
                GoRoute(
                  path: 'add',
                  builder: (context, state) => const GoalFormPage(),
                ),
                GoRoute(
                  path: 'edit',
                  builder: (context, state) {
                    final extra = state.extra as GoalModel?;
                    return GoalFormPage(goalToEdit: extra);
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    GoRoute(path: '/profile', builder: (context, state) => const ProfilePage()),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      path: '/useful-info',
      builder: (context, state) => const UsefulInfoPage(),
    ),
    GoRoute(
      path: '/training-info',
      builder: (context, state) => const TrainingInfoPage(),
    ),
    GoRoute(
      path: '/camp-info',
      builder: (context, state) => const CampInfoPage(),
    ),
    GoRoute(
      path: '/meetup-info',
      builder: (context, state) => const MeetupInfoPage(),
    ),
    GoRoute(
      path: '/admin-activities',
      builder: (context, state) => const AdminActivitiesPage(),
      routes: [
        GoRoute(
          path: 'add',
          builder: (context, state) => const AdminActivityFormPage(),
        ),
        GoRoute(
          path: 'edit',
          builder: (context, state) {
            final extra = state.extra as AdminActivityModel?;
            return AdminActivityFormPage(activityToEdit: extra);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/plast-activities',
      builder: (context, state) => const PlastActivitiesPage(),
      routes: [
        GoRoute(
          path: 'add',
          builder: (context, state) => const PlastActivityFormPage(),
        ),
        GoRoute(
          path: 'edit',
          builder: (context, state) {
            final extra = state.extra as PlastActivityModel?;
            return PlastActivityFormPage(activityToEdit: extra);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/first-unit',
      builder: (context, state) => const FirstUnitPage(),
      routes: [
        GoRoute(
          path: 'add',
          builder: (context, state) => const FirstUnitFormPage(),
        ),
        GoRoute(
          path: 'edit',
          builder: (context, state) {
            final extra = state.extra as FirstUnitModel?;
            return FirstUnitFormPage(unitToEdit: extra);
          },
        ),
        GoRoute(
          path: ':id/members',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            final name = state.extra as String? ?? '';
            return FirstUnitMembersPage(firstUnitId: id, firstUnitName: name);
          },
        ),
        GoRoute(
          path: ':id/rules',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            final name = state.extra as String? ?? '';
            return FirstUnitRulesPage(firstUnitId: id, firstUnitName: name);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/link-courier',
      builder: (context, state) => const LinkCourierPage(),
      routes: [
        GoRoute(
          path: 'add',
          builder: (context, state) => const LinkCourierFormPage(),
        ),
        GoRoute(
          path: 'edit',
          builder: (context, state) {
            final extra = state.extra as LinkCourierModel?;
            return LinkCourierFormPage(unitToEdit: extra);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/your-kurin',
      builder: (context, state) => const YourKurinPage(),
      routes: [
        GoRoute(
          path: 'add',
          builder: (context, state) => const YourKurinFormPage(),
        ),
        GoRoute(
          path: 'edit',
          builder: (context, state) {
            final extra = state.extra as YourKurinModel?;
            return YourKurinFormPage(unitToEdit: extra);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/events/add',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return AddEventPage(
          initialDate: extra?['date'] as DateTime?,
          initialEventType: extra?['eventType'] as String?,
        );
      },
    ),
    GoRoute(
      path: '/events/edit',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return AddEventPage(eventToEdit: extra['event'] as EventModel);
      },
    ),
  ],
);

// Auth state listener that only fires on actual auth changes
class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier() {
    Supabase.instance.client.auth.onAuthStateChange.listen((_) {
      notifyListeners();
    });
  }
}

GoRouter createRouter() => _router;

class MainScaffold extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainScaffold({super.key, required this.navigationShell});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      // Force reset to first branch on first build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.navigationShell.currentIndex != 0) {
          widget.navigationShell.goBranch(0);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(_getTitle(widget.navigationShell.currentIndex, l10n)),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              key: const Key('drawer_header'),
              decoration: const BoxDecoration(color: Color(0xFF368683)),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Image(
                      key: Key('drawer_logo'),
                      image: AssetImage(AppConstants.logoAssetPath),
                      fit: BoxFit.contain,
                      height: 84,
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              key: const Key('menu_calendar'),
              leading: const Icon(Icons.calendar_today),
              title: Text(l10n.calendar),
              selected: widget.navigationShell.currentIndex == 0,
              onTap: () {
                widget.navigationShell.goBranch(0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              key: const Key('menu_trainings'),
              leading: const Icon(Icons.school),
              title: Text(l10n.trainings),
              selected: widget.navigationShell.currentIndex == 1,
              onTap: () {
                widget.navigationShell.goBranch(1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              key: const Key('menu_camps'),
              leading: const Icon(Icons.park),
              title: Text(l10n.camps),
              selected: widget.navigationShell.currentIndex == 2,
              onTap: () {
                widget.navigationShell.goBranch(2);
                Navigator.pop(context);
              },
            ),
            ListTile(
              key: const Key('menu_events'),
              leading: const Icon(Icons.event),
              title: Text(l10n.events),
              selected: widget.navigationShell.currentIndex == 3,
              onTap: () {
                widget.navigationShell.goBranch(3);
                Navigator.pop(context);
              },
            ),
            ListTile(
              key: const Key('menu_goals'),
              leading: const Icon(Icons.flag),
              title: Text(l10n.goals),
              selected: widget.navigationShell.currentIndex == 4,
              onTap: () {
                widget.navigationShell.goBranch(4);
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              key: const Key('menu_admin_activities'),
              leading: const Icon(Icons.admin_panel_settings),
              title: Text(l10n.adminActivities),
              onTap: () {
                Navigator.pop(context);
                context.push('/admin-activities');
              },
            ),
            ListTile(
              key: const Key('menu_plast_activities'),
              leading: const Icon(Icons.volunteer_activism),
              title: Text(l10n.plastActivities),
              onTap: () {
                Navigator.pop(context);
                context.push('/plast-activities');
              },
            ),
            ListTile(
              key: const Key('menu_first_unit'),
              leading: const Icon(Icons.child_care),
              title: Text(l10n.firstUnit),
              onTap: () {
                Navigator.pop(context);
                context.push('/first-unit');
              },
            ),
            ListTile(
              key: const Key('menu_link_courier'),
              leading: const Icon(Icons.connect_without_contact),
              title: Text(l10n.linkCourier),
              onTap: () {
                Navigator.pop(context);
                context.push('/link-courier');
              },
            ),
            ListTile(
              key: const Key('menu_your_kurin'),
              leading: const Icon(Icons.groups),
              title: Text(l10n.yourKurin),
              onTap: () {
                Navigator.pop(context);
                context.push('/your-kurin');
              },
            ),
            const Divider(),
            ListTile(
              key: const Key('menu_training_info'),
              leading: const Icon(Icons.school),
              title: Text(l10n.trainingInfo),
              onTap: () {
                Navigator.pop(context);
                context.push('/training-info');
              },
            ),
            ListTile(
              key: const Key('menu_camp_info'),
              leading: const Icon(Icons.park),
              title: Text(l10n.campInfo),
              onTap: () {
                Navigator.pop(context);
                context.push('/camp-info');
              },
            ),
            ListTile(
              key: const Key('menu_meetup_info'),
              leading: const Icon(Icons.groups),
              title: Text(l10n.meetupInfo),
              onTap: () {
                Navigator.pop(context);
                context.push('/meetup-info');
              },
            ),
            const Divider(),
            ListTile(
              key: const Key('menu_profile'),
              leading: const Icon(Icons.person),
              title: Text(l10n.profile),
              onTap: () {
                Navigator.pop(context);
                context.push('/profile');
              },
            ),
            ListTile(
              key: const Key('menu_useful_info'),
              leading: const Icon(Icons.info_outline),
              title: Text(l10n.usefulInfo),
              onTap: () {
                Navigator.pop(context);
                context.push('/useful-info');
              },
            ),
            ListTile(
              key: const Key('menu_settings'),
              leading: const Icon(Icons.settings),
              title: Text(l10n.settings),
              onTap: () {
                Navigator.pop(context);
                context.push('/settings');
              },
            ),
          ],
        ),
      ),
      body: widget.navigationShell,
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Key? key,
  }) {
    return ListTile(
      key: key,
      leading: Icon(icon),
      title: Text(label),
      onTap: onTap,
    );
  }

  String _getTitle(int index, AppLocalizations l10n) {
    switch (index) {
      case 0:
        return l10n.calendar;
      case 1:
        return l10n.trainings;
      case 2:
        return l10n.camps;
      case 3:
        return l10n.events;
      case 4:
        return l10n.goals;
      default:
        return l10n.appTitle;
    }
  }
}
