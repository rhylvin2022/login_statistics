import 'package:flutter/cupertino.dart';

class AlertDialogPopper {
  static const bool _use = true;
  static BuildContext? _dialogContext;
  static bool _enabled = false;

  static void setEnabled() {
    if (_use) {
      _enabled = true;
    }
  }

  static void setDisabled() {
    if (_use) {
      _enabled = false;
      _dialogContext = null;
    }
  }

  static void setDialogContext(BuildContext context) {
    if (_use) {
      _dialogContext = context;
    }
  }

  static void popDialogContext() {
    if (_use) {
      if (_enabled && _dialogContext != null) {
        Navigator.pop(_dialogContext!);
        _enabled = false;
        _dialogContext = null;
      } else {
        _dialogContext = null;
      }
    }
  }
}
