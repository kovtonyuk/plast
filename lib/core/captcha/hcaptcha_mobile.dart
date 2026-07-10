import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Mobile (iOS/Android) implementation of the hCaptcha widget. Hosts the
/// challenge in a [WebView] that loads a tiny inline HTML page which in
/// turn fetches the official hCaptcha script and renders the widget into
/// a dedicated container div.
class HCaptchaMobile extends StatefulWidget {
  const HCaptchaMobile({
    super.key,
    required this.siteKey,
    required this.onToken,
    this.onError,
  });

  final String siteKey;
  final void Function(String token) onToken;
  final void Function(String error)? onError;

  @override
  State<HCaptchaMobile> createState() => HCaptchaMobileState();
}

class HCaptchaMobileState extends State<HCaptchaMobile> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..addJavaScriptChannel(
        'HCaptchaChannel',
        onMessageReceived: _onChannelMessage,
      )
      ..loadHtmlString(_buildHtml());
  }

  String _buildHtml() {
    // The HTML is intentionally minimal: it loads the official hCaptcha
    // script, renders the widget into #hcap, and forwards events back to
    // Dart via the injected JavaScript channel `HCaptchaChannel`.
    return '''
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<style>
  html, body {
    margin: 0;
    padding: 0;
    background: transparent;
    font-family: -apple-system, BlinkMacSystemFont, sans-serif;
  }
  #hcap {
    width: 302px;
    height: 78px;
    margin: 0 auto;
  }
  .loading, .error {
    display: flex;
    align-items: center;
    justify-content: center;
    height: 78px;
    color: #666;
    font-size: 13px;
  }
  .error { color: #b00020; }
</style>
</head>
<body>
<div id="hcap"><div class="loading">Loading captcha...</div></div>
<script src="https://js.hcaptcha.com/1/api.js" async defer></script>
<script>
  (function () {
    function post(type, value) {
      try {
        HCaptchaChannel.postMessage(JSON.stringify({type: type, value: value || ''}));
      } catch (e) {
        // Channel may be torn down during widget disposal.
      }
    }

    function render() {
      if (typeof hcaptcha === 'undefined' || !hcaptcha.render) {
        setTimeout(render, 100);
        return;
      }
      try {
        var container = document.getElementById('hcap');
        container.innerHTML = '';
        hcaptcha.render(container, {
          sitekey: '${widget.siteKey}',
          callback: function (token) { post('token', token); },
          'expired-callback': function () { post('expired', ''); },
          'error-callback': function (err) { post('error', err || 'unknown'); }
        });
      } catch (e) {
        document.getElementById('hcap').innerHTML =
          '<div class="error">Captcha failed to load</div>';
        post('error', String(e));
      }
    }

    window.addEventListener('load', render);
    // Fallback in case 'load' fired before this listener was attached.
    setTimeout(render, 200);
  })();
</script>
</body>
</html>
''';
  }

  void _onChannelMessage(JavaScriptMessage message) {
    if (!mounted) return;
    try {
      final data = jsonDecode(message.message) as Map<String, dynamic>;
      switch (data['type']) {
        case 'token':
          final token = data['value'] as String? ?? '';
          if (token.isEmpty) {
            widget.onError?.call('empty_token');
          } else {
            widget.onToken(token);
          }
          break;
        case 'expired':
          widget.onError?.call('captcha_expired');
          break;
        case 'error':
          widget.onError?.call(data['value'] as String? ?? 'unknown');
          break;
      }
    } catch (e) {
      widget.onError?.call('channel_parse_error: $e');
    }
  }

  void clearToken() {}

  Future<void> reset() async {
    try {
      await _controller.runJavaScript('hcaptcha.reset()');
    } catch (_) {
      // best effort — falling back to a full reload of the HTML.
      await _controller.loadHtmlString(_buildHtml());
    }
  }

  /// On mobile, hCaptcha runs inside a WebView and tokens are reported
  /// asynchronously via the `HCaptchaChannel` JS bridge. Calling
  /// `hcaptcha.execute()` triggers an immediate token re-issue, so the
  /// next submit gets a fresh value.
  Future<void> execute() async {
    try {
      await _controller.runJavaScript('hcaptcha.execute()');
    } catch (e) {
      // ignore: avoid_print
      print('hCaptcha mobile execute threw: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 302,
      height: 78,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: WebViewWidget(controller: _controller),
      ),
    );
  }
}
