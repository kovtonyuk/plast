import 'dart:async';

/// Prevents rapid duplicate invocations of a function.
///
/// Useful for submit buttons that should not fire multiple times while
/// a network request is in flight (e.g. sign-in / sign-up).
class Debouncer {
  Debouncer({this.duration = const Duration(milliseconds: 800)});

  final Duration duration;
  bool _isLocked = false;

  bool get isLocked => _isLocked;

  /// Runs [action] only if not already running. Returns true if executed.
  Future<bool> run(Future<void> Function() action) async {
    if (_isLocked) return false;
    _isLocked = true;
    try {
      await action();
    } finally {
      // Small grace period to absorb double-taps that arrive faster than
      // the network round-trip.
      await Future<void>.delayed(duration);
      _isLocked = false;
    }
    return true;
  }
}
