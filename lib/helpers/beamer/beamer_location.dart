import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:login_statistics/global/navigation_routes.dart';
import 'package:login_statistics/helpers/beamer/route/route.dart' as route;
import 'package:login_statistics/pages/splash/splash_page.dart';

class BeamerBaseLocations extends BeamLocation<BeamState> {
  BeamerBaseLocations(RouteInformation routeInformation)
      : super(routeInformation);

  @override
  List<String> get pathPatterns => [
        NavigationRoutes.splash,
        NavigationRoutes.select,
        NavigationRoutes.texasHoldem,
        NavigationRoutes.texasHoldemResult,
        NavigationRoutes.texasHoldemGenerator,
        NavigationRoutes.texasHoldemGeneratorResult,
        NavigationRoutes.plo,
        NavigationRoutes.ploResult,
        NavigationRoutes.ploGenerator,
        NavigationRoutes.ploGeneratorResult,
      ];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    return [
      if (state.uri.pathSegments.contains('splash'))
        const BeamPage(
          key: ValueKey('splash'),
          title: 'Splash',
          child: SplashPage(),
        ),
      if (state.uri.pathSegments.contains('select'))
        BeamPage(
          key: const ValueKey('select'),
          title: 'Select',
          child: PopScope(
            canPop: false,
            child: Beamer(
              routerDelegate: route.Route.route,
            ),
          ),
        ),
    ];
  }
}
