import 'package:flutter/foundation.dart';

class EventChangeNotifier extends ChangeNotifier {
  static final EventChangeNotifier _instance = EventChangeNotifier._internal();
  factory EventChangeNotifier() => _instance;
  EventChangeNotifier._internal();

  int _version = 0;
  int get version => _version;

  void notifyEventChanged() {
    _version++;
    notifyListeners();
  }
}
