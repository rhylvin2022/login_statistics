import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:login_statistics/global/app_colors.dart';
import 'package:login_statistics/helpers/beamer/base_route_delegate.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {}

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        theme: ThemeData(
          highlightColor: AppColors.appPrimaryColorLight,
          primaryColor: AppColors.primaryColor,
          scaffoldBackgroundColor: AppColors.appPrimaryColor,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              shape: const StadiumBorder(),
              maximumSize: const Size(double.infinity, 56),
              minimumSize: const Size(double.infinity, 56),
            ),
          ),
        ),
        debugShowCheckedModeBanner: false,
        supportedLocales: const [
          Locale('en', 'US'),
          // Locale('si', 'LK'),
          // Locale('ta', 'IN'),
        ],
        builder: EasyLoading.init(builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              boldText: false,
              textScaler: const TextScaler.linear(1.0),
            ),
            child: child!,
          );
        }),
        routeInformationParser: BeamerParser(),
        routerDelegate: BaseRoutesDelegate.baseRouteDelegate,
        backButtonDispatcher: BeamerBackButtonDispatcher(
            delegate: BaseRoutesDelegate.baseRouteDelegate),
      );
}
