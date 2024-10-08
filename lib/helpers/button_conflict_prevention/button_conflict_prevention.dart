import 'dart:async';

/// developed by: Rhylvin March 2024
/// this feature is to prevent buttons, clickable widgets and other
/// interactables to be triggered when an ongoing button was pressed
///
/// to use: use ButtonConflictPrevention.activate to check
/// if we can trigger the functionality
/// sample:
/// onPressed: () {
///   ButtonConflictPrevention.activate(() {
///     onPressed!();
///   });
/// },
class ButtonConflictPrevention {
  ///duration of the prevention
  static const int _durationInMilliseconds = 300;

  ///variable to check if we can interact
  static bool _interactable = true;

  ///activate the prevention: set interactable to false
  ///so that when a button is pressed and the interactable is false
  ///then it will prevent from triggering the actual function
  static void activate(Function function) {
    if (_interactable) {
      _interactable = false;
      _startTimer();
      function();
    }
  }

  ///start the timer for the prevention
  ///will set to true once the duration is done so that
  ///any buttons can be interactable once again.
  static void _startTimer() {
    Timer(const Duration(milliseconds: _durationInMilliseconds), () {
      _interactable = true;
    });
  }
}
