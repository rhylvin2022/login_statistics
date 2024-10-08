import 'package:beamer/beamer.dart';
import 'package:login_statistics/global/navigation_routes.dart';
import 'package:login_statistics/helpers/beamer/beamer_location.dart';

class BaseRoutesDelegate {
  static final baseRouteDelegate = BeamerDelegate(
    guards: [
      /// Guard /login by beaming to /dashboard if the user is authenticated:
      BeamGuard(
        pathPatterns: [NavigationRoutes.select],
        check: (context, state) =>
            // context.read<AuthenticationBloc>().isAuthenticated(),
            true,
        beamToNamed: (_, __) => NavigationRoutes.splash,
      ),

      BeamGuard(
        pathPatterns: ['${NavigationRoutes.select}/*'],
        check: (context, state) =>
            // !context.read<AuthenticationBloc>().isAuthenticated(),
            true,
        beamToNamed: (_, __) => NavigationRoutes.splash,
      ),

      BeamGuard(
        pathPatterns: [NavigationRoutes.splash],
        check: (context, state) =>
            // !context.read<AuthenticationBloc>().isAuthenticated(),
            true,
        beamToNamed: (_, __) => NavigationRoutes.select,
      ),
    ],
    initialPath: NavigationRoutes.splash,
    locationBuilder: (routeInformation, _) =>
        BeamerBaseLocations(routeInformation),
  );
}
