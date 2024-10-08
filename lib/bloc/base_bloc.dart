import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:login_statistics/bloc/poker_bloc/poker_bloc.dart';
import 'package:login_statistics/bloc/splash_bloc/splash_bloc.dart';

class BaseBlocProvider extends StatelessWidget {
  final Widget child;
  const BaseBlocProvider({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
        providers: [
          BlocProvider<SplashBloc>(
            create: (BuildContext context) => SplashBloc(),
          ),
          BlocProvider<PokerBloc>(
            create: (BuildContext context) => PokerBloc(),
          ),
        ],
        child: child,
      );
}
