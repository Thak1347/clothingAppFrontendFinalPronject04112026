import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../controllers/receipt_controller.dart';

class ReceiptActionButtons extends StatelessWidget {
  const ReceiptActionButtons({
    required this.orderId,
    required this.controller,
    super.key,
  });

  final int orderId;
  final ReceiptController controller;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) => Obx(() {
        final busy = controller.isGenerating.value;
        final compact = constraints.maxWidth < 380;
        final actions = <Widget>[
          FilledButton.icon(
            onPressed: busy ? null : () => _preview(),
            icon: const Icon(Icons.visibility_outlined),
            label: const Text('Preview Receipt'),
          ),
          OutlinedButton.icon(
            onPressed: busy ? null : () => _download(),
            icon: const Icon(Icons.download_outlined),
            label: const Text('Download Receipt'),
          ),
          OutlinedButton.icon(
            onPressed: busy ? null : () => _share(),
            icon: const Icon(Icons.share_outlined),
            label: const Text('Share Receipt'),
          ),
          TextButton.icon(
            onPressed: busy ? null : () => _regenerate(),
            icon: const Icon(Icons.refresh),
            label: const Text('Regenerate Receipt'),
          ),
        ];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (busy) ...[
              const LinearProgressIndicator(),
              const SizedBox(height: 8),
              const Text('Preparing your receipt…'),
              const SizedBox(height: 12),
            ],
            if (compact)
              ...actions.map((action) => Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: action,
                  ))
            else ...[
              Row(
                children: [
                  Expanded(child: actions[0]),
                  const SizedBox(width: 10),
                  Expanded(child: actions[1]),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: actions[2]),
                  const SizedBox(width: 10),
                  Expanded(child: actions[3]),
                ],
              ),
            ],
          ],
        );
      }),
      );

  Future<void> _preview() async {
    try {
      final file = await controller.generatePdf(orderId);
      final bytes = await file.readAsBytes();
      await Printing.layoutPdf(
        name: _fileName(file),
        onLayout: (_) async => Uint8List.fromList(bytes),
      );
    } catch (error) {
      _showError(error);
    }
  }

  Future<void> _download() async {
    try {
      final file = await controller.generatePdf(orderId);
      Get.snackbar(
        'Receipt saved',
        'The PDF is saved in app storage at ${file.path}.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      _showError(error);
    }
  }

  Future<void> _share() async {
    try {
      final file = await controller.generatePdf(orderId);
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Receipt for order $orderId',
      );
      Get.snackbar(
        'Receipt ready',
        'The share sheet has been opened.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      _showError(error);
    }
  }

  Future<void> _regenerate() async {
    try {
      await controller.generatePdf(orderId, force: true);
      Get.snackbar(
        'Receipt regenerated',
        'The latest receipt PDF is ready.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      _showError(error);
    }
  }

  void _showError(Object error) {
    final message = controller.error.value.isNotEmpty
        ? controller.error.value
        : error is FileSystemException
            ? 'The receipt file could not be opened or saved.'
            : 'Unable to prepare the receipt. Please try again.';
    Get.snackbar(
      'Receipt unavailable',
      message,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  String _fileName(File file) => file.uri.pathSegments.last;
}
