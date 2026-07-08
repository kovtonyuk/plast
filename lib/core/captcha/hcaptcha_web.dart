import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe'; // provides getProperty/callMethod on JSObject.
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

/// Web implementation of the hCaptcha widget. Loads
/// `https://js.hcaptcha.com/1/api.js` on first mount, renders the challenge
/// in a dedicated [web.HTMLDivElement], and bridges the JS callbacks back
/// into Dart.
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
  static const _viewType = 'hcaptcha-web-view';
  static const _containerId = 'hcaptcha-container';
  static const _scriptSrc = 'https://js.hcaptcha.com/1/api.js';

  web.HTMLDivElement? _container;
  String? _widgetId;
  bool _scriptReady = false;
  final List<VoidCallback> _pending = [];

  @override
  void initState() {
    super.initState();
    _ensureScript();
  }

  @override
  void dispose() {
    _teardownWidget();
    super.dispose();
  }

  void _ensureScript() {
    final existing = web.document.querySelector('script[src="$_scriptSrc"]');
    if (existing == null) {
      final script = web.HTMLScriptElement()
        ..src = _scriptSrc
        ..async = true
        ..defer = true;
      script.onload = ((JSAny _) {
        if (!mounted) return;
        setState(() => _scriptReady = true);
        _drainPending();
      }).toJS;
      script.onerror = ((JSAny _) {
        if (!mounted) return;
        widget.onError?.call('Failed to load hCaptcha script');
      }).toJS;
      web.document.head?.appendChild(script);
    } else {
      _waitForGlobal();
    }
  }

  void _waitForGlobal() {
    void check() {
      if (_hasGlobal()) {
        if (!mounted) return;
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
      return hcaptcha != null && !hcaptcha.isUndefined;
    } catch (_) {
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
      ..id = _containerId
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

    final onToken = ((JSString token) {
      if (!mounted) return;
      widget.onToken(token.toDart);
    }).toJS;

    final onExpired = (() {
      if (!mounted) return;
      widget.onError?.call('captcha_expired');
    }).toJS;

    final onErrorCb = ((JSString err) {
      if (!mounted) return;
      widget.onError?.call(err.toDart);
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
        widget.onError?.call('hcaptcha_global_unavailable');
        return;
      }
      final result = hcaptcha.callMethod<JSAny>(
        'render'.toJS,
        container.toJSBox,
        options,
      );
      _widgetId = (result as JSString).toDart;
    } catch (e) {
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
