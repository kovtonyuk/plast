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
    setState(() => _token = token);
    widget.onToken(token);
  }

  /// Returns the current token and clears it. Returns null if the user
  /// has not solved the captcha since the last reset.
  String? consumeToken() {
    final t = _token;
    _token = null;
    if (kIsWeb) {
      _webKey.currentState?.clearToken();
    } else {
      _mobileKey.currentState?.clearToken();
    }
    return t;
  }

  /// Forces a fresh challenge. The cached token (if any) is discarded and
  /// the captcha widget re-renders empty.
  void reset() {
    setState(() => _token = null);
    if (kIsWeb) {
      _webKey.currentState?.reset();
    } else {
      _mobileKey.currentState?.reset();
    }
  }
}
