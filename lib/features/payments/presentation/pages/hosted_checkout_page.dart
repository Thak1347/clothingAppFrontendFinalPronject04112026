import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../app/theme/app_colors.dart';

/// Alternative flow. The app polls the authenticated Laravel order endpoint;
/// the browser success redirect itself never marks an order paid.
class HostedCheckoutPage extends StatefulWidget {
  const HostedCheckoutPage(
      {super.key, required this.checkoutUrl, required this.pollStatus});
  final String checkoutUrl;
  final Future<String> Function() pollStatus;

  @override
  State<HostedCheckoutPage> createState() => _HostedCheckoutPageState();
}

class _HostedCheckoutPageState extends State<HostedCheckoutPage> {
  late final WebViewController controller;
  bool checking = false;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
          NavigationDelegate(onNavigationRequest: (request) {
        final uri = Uri.tryParse(request.url);
        if (uri != null && uri.scheme.toLowerCase() == 'abamobilebank') {
          unawaited(_openAbaMobile(uri));
          return NavigationDecision.prevent;
        }
        if (request.url.contains('/payments/khqr/success')) {
          _checkStatus();
          return NavigationDecision.prevent;
        }
        return NavigationDecision.navigate;
      }))
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  Future<void> _openAbaMobile(Uri uri) async {
    try {
      final launched =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        _showAbaMobileUnavailable();
      }
    } on Exception catch (exception) {
      FlutterError.reportError(FlutterErrorDetails(exception: exception));
      if (mounted) _showAbaMobileUnavailable();
    }
  }

  void _showAbaMobileUnavailable() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Could not open ABA Mobile. Return to checkout and scan the QR code.',
        ),
      ),
    );
  }

  Future<void> _checkStatus() async {
    setState(() => checking = true);
    final status = await widget.pollStatus();
    if (!mounted) return;
    setState(() => checking = false);
    if (status == 'paid') {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment is not confirmed yet.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('ABA Pay checkout')),
        body: Column(
          children: [
            if (checking)
              const LinearProgressIndicator(
                minHeight: 2,
                color: AppColors.ink,
              ),
            Expanded(child: WebViewWidget(controller: controller)),
          ],
        ),
      );
}
