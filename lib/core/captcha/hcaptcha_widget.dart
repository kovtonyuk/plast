import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'hcaptcha_mobile.dart';
import 'hcaptcha_web_stub.dart'
    if (dart.library.js_interop) 'hcaptcha_web.dart';

/// Public hCaptcha widget used by the auth flow.
///
/// The widget dispatches to a web (Chrome) or mobile (iOS/Android) backend
/// based on [kIsWeb]. Both backends produce a single-use token via the
/// [onToken] callback, and notify about expiry/errors via [onError].
///
/// The host page drives the widget through a [GlobalKey] using
/// [HCaptchaWidgetState.consumeToken] (one-shot read) and
/// [HCaptchaWidgetState.reset] (force a fresh challenge).
class HCaptchaWidget extends StatefulWidget {
  const HCaptchaWidget({
    super.key,
    required this.siteKey,
    required this.onToken,
    this.onError,
  });

  /// hCaptcha site key (public). Configure the matching secret key in the
  /// Supabase Dashboard (Authentication → Bot Protection).
  final String siteKey;

  /// Called once when the user solves the captcha and a fresh token is
  /// available. The token is single-use and must be passed to Supabase on
  /// the same submit attempt.
  final void Function(String token) onToken;

  /// Called when the captcha expires, errors out, or fails to render.
  /// The host should typically display a generic error and call [reset].
  final void Function(String error)? onError;

  @override
  State<HCaptchaWidget> createState() => HCaptchaWidgetState();
}

class HCaptchaWidgetState extends State<HCaptchaWidget> {
  String? _token;
  // Set to true after `consumeToken` reads `_token`. While true, any
  // further hCaptcha callback that delivers the same token is dropped —
  // hCaptcha sometimes re-fires its callback on focus/auto-refresh and
  // we must not let that re-populate a spent token. Reset by `reset()`.
  bool _consumed = false;
  // Filled whenever `execute()` is awaiting a fresh token. Resolved by
  // the next [onToken] callback. Only one execution may be in flight at
  // a time — hCaptcha serialises its callbacks anyway.
  Completer<String>? _pendingExecute;

  // Platform-specific controllers. Only one is active at a time.
  final _webKey = GlobalKey<HCaptchaWebState>();
  final _mobileKey = GlobalKey<HCaptchaMobileState>();

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return HCaptchaWeb(
        key: _webKey,
        siteKey: widget.siteKey,
        onToken: _onToken,
        onError: widget.onError,
      );
    }
    return HCaptchaMobile(
      key: _mobileKey,
      siteKey: widget.siteKey,
      onToken: _onToken,
      onError: widget.onError,
    );
  }

  void _onToken(String token) {
    // Drop the callback if the previous token was already consumed.
    // Without this, hCaptcha's re-fires of the same token (which it
    // does for focus/auto-refresh events) would re-populate `_token`
    // and the next submit would re-send an already-used token.
    if (_consumed) {
      // Still resolve any pending execute() so the submit doesn't hang.
      if (_pendingExecute != null && !_pendingExecute!.isCompleted) {
        _pendingExecute!.complete(token);
      }
      return;
    }
    setState(() => _token = token);
    widget.onToken(token);
    _pendingExecute?.complete(token);
  }

  /// Returns the current cached token (if any) and marks it consumed.
  /// Does not request a fresh token — use [executeAndConsume] when
  /// you want to guarantee a fresh value (recommended for submits).
  String? consumeToken() {
    final t = _token;
    _token = null;
    _consumed = true;
    if (kIsWeb) {
      _webKey.currentState?.clearToken();
    } else {
      _mobileKey.currentState?.clearToken();
    }
    return t;
  }

  /// Asks hCaptcha to (re-)issue a token right now and returns the
  /// fresh value once the JS callback fires. Use this from submit
  /// handlers — it guarantees the returned token has not been sent
  /// to Supabase before, even if the widget had a stale `_token`.
  ///
  /// On web, hCaptcha's `execute(widgetId)` is incompatible with
  /// dart:js_interop on the minified hCaptcha build (TypeError
  /// "minified:yq is not a subtype of Object"), so this method
  /// falls back to reset() and waits for the user to re-solve the
  /// challenge. The first submit is satisfied with the cached token
  /// via [consumeToken] — the parent must call executeAndConsume
  /// only when the first attempt failed with "already-seen-response".
  Future<String?> executeAndConsume() async {
    // First attempt: take the cached token, if any. The caller gates
    // on _captchaSolved which is set in the onToken callback, so by
    // the time we reach here the user has already solved the
    // challenge. consumeToken() reads _token once and clears it.
    final cached = _token;
    if (cached != null && cached.isNotEmpty) {
      _consumed = true;
      _token = null;
      return cached;
    }
    // No cached token. This can happen on the very first submit
    // when the user pressed "Register" before the onToken callback
    // had a chance to fire (race) or after a previous submit that
    // cleared it. Wait for the next onToken.
    _pendingExecute = Completer<String>();
    final token = await _pendingExecute!.future
        .timeout(const Duration(seconds: 60), onTimeout: () {
      _pendingExecute = null;
      return '';
    });
    _pendingExecute = null;
    if (token.isEmpty) return null;
    _consumed = true;
    return token;
  }

  /// Forces a fresh challenge. The cached token (if any) is discarded,
  /// the consumed flag is reset so the next callback is accepted, and
  /// the captcha widget re-renders empty.
  void reset() {
    _consumed = false;
    if (_pendingExecute != null && !_pendingExecute!.isCompleted) {
      _pendingExecute!.complete('');
    }
    _pendingExecute = null;
    setState(() => _token = null);
    if (kIsWeb) {
      _webKey.currentState?.reset();
    } else {
      _mobileKey.currentState?.reset();
    }
  }
}