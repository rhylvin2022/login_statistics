import 'package:beamer/beamer.dart';
import 'package:login_statistics/global/navigation_routes.dart';
import 'package:login_statistics/pages/select/select_page.dart';

class Route {
  static final route = BeamerDelegate(
    initialPath: NavigationRoutes.select,
    notFoundPage: BeamPage.notFound,
    transitionDelegate: const ReverseTransitionDelegate(),
    locationBuilder: RoutesLocationBuilder(routes: {
      NavigationRoutes.select: (context, state, data) => const SelectPage(),
      //
      // ///texas Holdem Poker
      // NavigationRoutes.texasHoldem: (context, state, data) =>
      //     const TexasHoldemPage(),
      // NavigationRoutes.texasHoldemResult: (context, state, data) =>
      //     TexasHoldemResultPage(args: data as PokerArguments),
      // NavigationRoutes.texasHoldemGenerator: (context, state, data) =>
      //     const TexasHoldemGeneratorPage(),
      // NavigationRoutes.texasHoldemGeneratorResult: (context, state, data) =>
      //     TexasHoldemResultPage(args: data as PokerArguments),
      //
      // ///plo
      // NavigationRoutes.plo: (context, state, data) => const PLOPage(),
      // NavigationRoutes.ploResult: (context, state, data) =>
      //     PLOResultPage(args: data as PokerArguments),
      // NavigationRoutes.ploGenerator: (context, state, data) =>
      //     const PLOGeneratorPage(),
      // NavigationRoutes.ploGeneratorResult: (context, state, data) =>
      //     PLOResultPage(args: data as PokerArguments),
    }),
  );
}
