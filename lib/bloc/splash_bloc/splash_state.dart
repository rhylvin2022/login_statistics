part of 'splash_bloc.dart';

@immutable
abstract class SplashState extends Equatable {}

class SplashStateInitial extends SplashState {
  @override
  List<Object?> get props => [];
}

class GetSplashFail extends SplashState {
  GetSplashFail(this.errorObject);
  final Object errorObject;

  @override
  List<Object?> get props => [errorObject];
}
