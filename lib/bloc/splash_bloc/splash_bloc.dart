// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

part 'splash_event.dart';

part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc() : super(SplashStateInitial());

  @override
  Stream<SplashState> mapEventToState(SplashEvent event) async* {
    if (event is GetSplash) {
      yield* _onGetFee(event);
    }
  }

  Stream<SplashState> _onGetFee(GetSplash event) async* {
    // try {
    //   final response = await splashRepo.getSplashRequest(event.request);
    //   yield GetSplashSuccess(response);
    // } catch (e) {
    //   yield GetSplashFail(e);
    // }
  }

  @override
  Future<void> close() {
    // TODO: implement close
    return super.close();
  }
}
