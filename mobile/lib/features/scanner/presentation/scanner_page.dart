import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/ns_error.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  final MobileScannerController _controller = MobileScannerController();
  bool _handled = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    final barcode = capture.barcodes.firstOrNull?.rawValue;
    if (barcode == null || barcode.isEmpty) return;
    _handled = true;
    _controller.stop();
    context.pushReplacement(AppRoutes.productDetailsPath(barcode));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.scannerTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            tooltip: 'Toggle flash',
            onPressed: () => _controller.toggleTorch(),
          ),
        ],
      ),
      body: _error != null
          ? NsError(
              message: _error,
              onRetry: () => setState(() {
                _error = null;
                _handled = false;
                _controller.start();
              }),
            )
          : Stack(
              children: [
                MobileScanner(
                  controller: _controller,
                  onDetect: _onDetect,
                  errorBuilder: (context, error, _) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        setState(() => _error = _cameraError(error));
                      }
                    });
                    return const SizedBox.shrink();
                  },
                ),
                _ScanOverlay(),
              ],
            ),
    );
  }

  String _cameraError(MobileScannerException error) {
    switch (error.errorCode) {
      case MobileScannerErrorCode.permissionDenied:
        return 'Camera permission denied. Please allow camera access in Settings.';
      case MobileScannerErrorCode.unsupported:
        return 'Barcode scanning is not supported on this device.';
      default:
        return 'Camera error: ${error.errorCode.name}';
    }
  }
}

class _ScanOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 1,
          child: Container(color: Colors.black.withValues(alpha: 0.5)),
        ),
        Row(
          children: [
            Expanded(
              flex: 1,
              child: Container(color: Colors.black.withValues(alpha: 0.5)),
            ),
            // Scan window
            Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.primaryLight, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(color: Colors.black.withValues(alpha: 0.5)),
            ),
          ],
        ),
        Expanded(
          flex: 1,
          child: Container(
            color: Colors.black.withValues(alpha: 0.5),
            child: Center(
              child: Text(
                'Point at the barcode',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.white70),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
