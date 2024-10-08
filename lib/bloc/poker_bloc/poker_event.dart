part of 'poker_bloc.dart';

@immutable
abstract class PokerEvent {}

class SelectCard extends PokerEvent {
  final String id;
  SelectCard(this.id);
}

class ResetSelectCard extends PokerEvent {}

class SetTarget extends PokerEvent {
  final int id;
  SetTarget(this.id);
}

class DeleteCard extends PokerEvent {
  final String id;
  DeleteCard(this.id);
}
