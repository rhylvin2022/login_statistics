import 'dart:math';

class PlayingCards {
  static List<String> allPlayingCards = [
    's_1',
    's_2',
    's_3',
    's_4',
    's_5',
    's_6',
    's_7',
    's_8',
    's_9',
    's_10',
    's_11',
    's_12',
    's_13',
    'h_1',
    'h_2',
    'h_3',
    'h_4',
    'h_5',
    'h_6',
    'h_7',
    'h_8',
    'h_9',
    'h_10',
    'h_11',
    'h_12',
    'h_13',
    'd_1',
    'd_2',
    'd_3',
    'd_4',
    'd_5',
    'd_6',
    'd_7',
    'd_8',
    'd_9',
    'd_10',
    'd_11',
    'd_12',
    'd_13',
    'c_1',
    'c_2',
    'c_3',
    'c_4',
    'c_5',
    'c_6',
    'c_7',
    'c_8',
    'c_9',
    'c_10',
    'c_11',
    'c_12',
    'c_13',
  ];

  static List<String> allPlayingCardsWithAceHigh = [
    ...allPlayingCards,
    's_14',
    'h_14',
    'd_14',
    'c_14',
  ];

  static List<String> generateUniqueFlop() {
    List<String> flop = [];
    Set<String> uniqueCards = {};
    while (uniqueCards.length < 3) {
      String card = allPlayingCards[Random().nextInt(allPlayingCards.length)];
      if (!uniqueCards.contains(card)) {
        uniqueCards.add(card);
        flop.add(card);
      }
    }
    return flop;
  }

  static String generateUniqueCard(List<String> usedCards) {
    Set uniqueCards = Set.from(allPlayingCards).difference(Set.from(usedCards));
    return uniqueCards.elementAt(Random().nextInt(uniqueCards.length));
  }
}
