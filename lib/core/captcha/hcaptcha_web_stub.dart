// Stub used on non-web platforms. The real implementation lives in
// hcaptcha_web.dart and is only imported when `dart:js_interop` is
// available (i.e. on Flutter web). On mobile we never reach the render
// path because [HCaptchaWidget] switches to [HCaptchaMobile] via
// [kIsWeb], so this stub is never instantiated.

import 'package:flutter/material.dart';

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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.onError?.call('hcaptcha_web_unsupported_platform');
    });
  }

  void clearToken() {}
  void reset() {}
  void execute() {}

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

