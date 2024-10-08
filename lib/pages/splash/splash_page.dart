import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:login_statistics/global/navigation_routes.dart';
import 'package:login_statistics/helpers/base_view/base_view.dart';

class SplashPage extends BaseView {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    goToSelectPage();
  }

  @override
  Widget build(BuildContext context) => Container(
        color: Colors.black,
      );

  void goToSelectPage() {
    Future.delayed(const Duration(seconds: 1)).then((value) {
      context.beamToNamed(NavigationRoutes.select);
    });
  }
}
