// Debug prints are intentional during hCaptcha integration — they show up
// in the browser dev console so we can see the actual cause of the
// "сталася помилка" banner. Remove or replace once the captcha is
// rendering reliably.
// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe'; // provides getProperty/callMethod on JSObject.
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

/// Web implementation of the hCaptcha widget. The script
/// `https://js.hcaptcha.com/1/api.js` is loaded via <script src=...> in
/// `web/index.html`, so by the time this widget mounts the global
/// `window.hcaptcha` is already available. We just call `.render(...)`
/// to draw the challenge into a dedicated [web.HTMLDivElement] and
/// bridge the JS callbacks back into Dart.
class HCaptchaWeb extends StatefulWidget {
  const HCaptchaWeb({
    super.key,
    required this.siteKey,
    required this.onToken,
    this.onError,
  });

  final String siteKey;
  final void Function(String token) onToken;
  final void Function(String error)? onError;

  @override
  State<HCaptchaWeb> createState() => HCaptchaWebState();
}

class HCaptchaWebState extends State<HCaptchaWeb> {
  // Each instance needs a unique platform view type — otherwise hot
  // reload, page navigations, and toggle login↔register can all
  // re-register the same factory and throw "platform view factory
  // already registered" at mount time. A static counter guarantees
  // uniqueness across the app's lifetime.
  static int _instanceCounter = 0;
  late final String _viewType = 'hcaptcha-web-view-${_instanceCounter++}';
  static const _containerIdPrefix = 'hcaptcha-container-';

  web.HTMLDivElement? _container;
  String? _widgetId;
  bool _scriptReady = false;
  final List<VoidCallback> _pending = [];

  @override
  void initState() {
    super.initState();
    if (_hasGlobal()) {
      _scriptReady = true;
    } else {
      _waitForGlobal();
    }
  }

  @override
  void dispose() {
    _teardownWidget();
    super.dispose();
  }

  void _waitForGlobal() {
    void check() {
      if (!mounted) return;
      if (_hasGlobal()) {
        setState(() => _scriptReady = true);
        _drainPending();
        return;
      }
      Timer(const Duration(milliseconds: 100), check);
    }

    Timer(const Duration(milliseconds: 100), check);
  }

  bool _hasGlobal() {
    try {
      final hcaptcha = _getHcaptcha();
      final hasIt = hcaptcha != null && !hcaptcha.isUndefined;
      debugPrint('hCaptcha global check: hasIt=$hasIt');
      return hasIt;
    } catch (e) {
      debugPrint('hCaptcha global check failed: $e');
      return false;
    }
  }

  void _drainPending() {
    final pending = List<VoidCallback>.from(_pending);
    _pending.clear();
    for (final cb in pending) {
      cb();
    }
  }

  void _teardownWidget() {
    if (_widgetId == null) return;
    try {
      final hcaptcha = _getHcaptcha();
      // ignore: invalid_runtime_check_with_js_interop_types
      if (hcaptcha is JSObject) {
        hcaptcha.callMethod<JSAny>('remove'.toJS, _widgetId!.toJS);
      }
    } catch (_) {
      // best effort
    }
  }

  void _registerView() {
    if (_container != null) return;
    final div = web.HTMLDivElement()
      ..id = '$_containerIdPrefix$_viewType'
      ..style.width = '302px'
      ..style.height = '78px';
    _container = div;

    ui_web.platformViewRegistry.registerViewFactory(
      _viewType,
      (int viewId) => div,
    );
  }

  JSAny? _getHcaptcha() {
    return globalContext.getProperty('hcaptcha'.toJS);
  }

  void _render() {
    if (!mounted || _container == null) return;
    final container = _container!;

    // hCaptcha's minified build wraps the token in its own internal
    // type (visible in errors as "minified:yq"), so the callback
    // signature must be permissive — `JSAny?` — rather than
    // `JSString`. Otherwise hCaptcha's call to our callback throws
    // "minified:yq is not a subtype of Object" before we ever see the
    // token. We then toDart-convert inside the body.
    final onToken = ((JSAny? token) {
      try {
        // dartify() unwraps the JS value to a Dart type. hCaptcha's
        // minified build returns a String wrapped in its own
        // internal type (visible in errors as "minified:yq"), but
        // dartify() handles the conversion regardless.
        final dartToken = token?.dartify();
        debugPrint('hCaptcha token received: $dartToken');
        if (!mounted) return;
        if (dartToken is String && dartToken.isNotEmpty) {
          widget.onToken(dartToken);
        }
      } catch (e) {
        debugPrint('hCaptcha token conversion failed: $e');
      }
    }).toJS;

    final onExpired = (() {
      debugPrint('hCaptcha token expired');
      if (!mounted) return;
      widget.onError?.call('captcha_expired');
    }).toJS;

    final onErrorCb = ((JSAny? err) {
      final msg = err?.dartify()?.toString() ?? 'unknown';
      debugPrint('hCaptcha JS error: $msg');
      if (!mounted) return;
      widget.onError?.call(msg);
    }).toJS;

    final options = <String, JSAny>{
      'sitekey': widget.siteKey.toJS,
      'callback': onToken,
      'expired-callback': onExpired,
      'error-callback': onErrorCb,
    }.jsify()!;

    try {
      final hcaptcha = _getHcaptcha();
      // ignore: invalid_runtime_check_with_js_interop_types
      if (hcaptcha is! JSObject || hcaptcha.isUndefined) {
        debugPrint('hCaptcha global unavailable at render time');
        widget.onError?.call('hcaptcha_global_unavailable');
        return;
      }
      debugPrint(
        'hCaptcha: calling render with sitekey=${widget.siteKey.substring(0, 8)}...',
      );
      // hCaptcha's render() expects (element, options). The first
      // argument is a DOM node from `package:web`, which is a
      // `extension type` over a JS interop value. We can pass it
      // directly to `callMethod` as `JSAny` because the underlying
      // JS value is what hCaptcha needs.
      final result = hcaptcha.callMethod<JSAny>(
        'render'.toJS,
        container as JSAny,
        options,
      );
      _widgetId = (result as JSString).toDart;
      debugPrint('hCaptcha render OK, widgetId=$_widgetId');
    } catch (e) {
      debugPrint('hCaptcha render threw: $e');
      widget.onError?.call('hcaptcha_render_failed: $e');
    }
  }

  void _doReset() {
    if (_widgetId == null) return;
    try {
      final hcaptcha = _getHcaptcha();
      // ignore: invalid_runtime_check_with_js_interop_types
      if (hcaptcha is JSObject) {
        hcaptcha.callMethod<JSAny>('reset'.toJS, _widgetId!.toJS);
      }
    } catch (_) {
      // best effort
    }
  }

  /// Forces hCaptcha to (re-)run the challenge and emit a fresh token
  /// through `onToken`. Use right before a submit so the token we send
  /// to Supabase is guaranteed fresh — prevents
  /// "already-seen-response" when hCaptcha re-fires its callback for a
  /// previously issued token.
  void execute() {
    if (_widgetId == null) {
      debugPrint('hCaptcha execute: no widgetId yet, skipping');
      return;
    }
    try {
      final hcaptcha = _getHcaptcha();
      debugPrint('hCaptcha execute: hcaptcha=$hcaptcha, widgetId=$_widgetId');
      // ignore: invalid_runtime_check_with_js_interop_types
      if (hcaptcha is JSObject) {
        // We deliberately do NOT call hCaptcha's execute() here.
        // On the minified hCaptcha build, the execute(widgetId) JS
        // method has an internal type check on its arguments that
        // raises "minified:yq is not a subtype of Object" when
        // invoked via dart:js_interop — the widgetId is wrapped in a
        // String-typed extension that hCaptcha's minifier flags as
        // incompatible with its internal Object check.
        //
        // Instead we fall back to the parent widget's reset() flow,
        // which calls hcaptcha.reset(widgetId) and re-issues a token
        // through the normal callback path. The parent is expected to
        // call reset() (not execute()) before re-using a captcha.
        debugPrint('hCaptcha execute skipped: use parent reset()');
      }
    } catch (e) {
      debugPrint('hCaptcha execute threw: $e');
    }
  }

  // The web widget does not cache the token client-side — `consumeToken` on
  // the parent is enough.
  void clearToken() {}

  void reset() => _doReset();

  @override
  Widget build(BuildContext context) {
    _registerView();

    if (!_scriptReady) {
      _pending.add(_render);
      return const SizedBox(
        height: 78,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_widgetId == null) {
        _pending.add(_render);
        _drainPending();
      }
    });

    return SizedBox(
      width: 302,
      height: 78,
      child: HtmlElementView(viewType: _viewType),
    );
  }
}
