import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:login_statistics/app.dart';
import 'package:login_statistics/bloc/base_bloc.dart';
import 'package:login_statistics/global/app_colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configLoading();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(
      const BaseBlocProvider(
        child: App(),
      ),
    );
  });
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 1000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.white
    ..backgroundColor = Colors.white
    ..indicatorColor = AppColors.primaryColor
    ..textColor = AppColors.primaryColor
    ..maskColor = Colors.blue.withOpacity(0.5)
    ..userInteractions = false
    ..dismissOnTap = false;
}
