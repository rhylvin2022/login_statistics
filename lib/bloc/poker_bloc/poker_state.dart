part of 'poker_bloc.dart';

@immutable
abstract class PokerState extends Equatable {}

class PokerStateInitial extends PokerState {
  @override
  List<Object?> get props => [];
}

class GetPokerFail extends PokerState {
  GetPokerFail(this.errorObject);
  final Object errorObject;

  @override
  List<Object?> get props => [errorObject];
}

class CardSelected extends PokerState {
  CardSelected(this.id);
  final String id;

  @override
  List<Object?> get props => [id];
}

class ResetSelectedCard extends PokerState {
  ResetSelectedCard();

  @override
  List<Object?> get props => [];
}

class TargetSet extends PokerState {
  TargetSet(this.id);
  final int id;

  @override
  List<Object?> get props => [id];
}

class CardDeleted extends PokerState {
  CardDeleted(this.id);
  final String id;

  @override
  List<Object?> get props => [id];
}
