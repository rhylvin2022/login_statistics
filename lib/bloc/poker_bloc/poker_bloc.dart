// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

part 'poker_event.dart';

part 'poker_state.dart';

class PokerBloc extends Bloc<PokerEvent, PokerState> {
  PokerBloc() : super(PokerStateInitial());

  @override
  Stream<PokerState> mapEventToState(PokerEvent event) async* {
    if (event is SelectCard) {
      yield* _onSelectCard(event);
    } else if (event is ResetSelectCard) {
      yield ResetSelectedCard();
    } else if (event is SetTarget) {
      yield* _onSetTarget(event);
    } else if (event is DeleteCard) {
      yield* _onDeleteCard(event);
    }
  }

  Stream<PokerState> _onSelectCard(SelectCard event) async* {
    yield CardSelected(event.id);
  }

  Stream<PokerState> _onSetTarget(SetTarget event) async* {
    yield TargetSet(event.id);
  }

  Stream<PokerState> _onDeleteCard(DeleteCard event) async* {
    yield CardDeleted(event.id);
  }

  @override
  Future<void> close() {
    // TODO: implement close
    return super.close();
  }
}
