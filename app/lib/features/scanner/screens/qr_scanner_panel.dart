import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerPanel extends StatefulWidget {
  const QrScannerPanel({
    required this.onPayload,
    required this.manualLabel,
    super.key,
  });

  final ValueChanged<String> onPayload;
  final String manualLabel;

  @override
  State<QrScannerPanel> createState() => _QrScannerPanelState();
}

class _QrScannerPanelState extends State<QrScannerPanel> {
  final _manualController = TextEditingController();

  @override
  void dispose() {
    _manualController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: MobileScanner(
              onDetect: (capture) {
                for (final barcode in capture.barcodes) {
                  final rawValue = barcode.rawValue;
                  if (rawValue != null && rawValue.isNotEmpty) {
                    widget.onPayload(rawValue);
                    return;
                  }
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _manualController,
          minLines: 2,
          maxLines: 5,
          decoration: InputDecoration(
            labelText: widget.manualLabel,
            suffixIcon: IconButton(
              tooltip: 'Submit payload',
              icon: const Icon(Icons.arrow_forward),
              onPressed: () => widget.onPayload(_manualController.text),
            ),
          ),
        ),
      ],
    );
  }
}
