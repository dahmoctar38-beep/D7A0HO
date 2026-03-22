import '../domain/scanner_service.dart';

/// Cycles through known mock barcodes on each call.
/// Replace with real MobileScannerService in Cycle 2.
class MockScannerService implements ScannerService {
  static const _barcodes = [
    '6281006530015', // Almarai Milk
    '6281034000011', // Chips Oman
    '5449000000996', // Coca-Cola
    '6221012850014', // Quaker Oats
    '8712100325977', // Snickers
  ];
  int _index = 0;

  @override
  Future<String?> scan() async {
    await Future.delayed(const Duration(milliseconds: 400));
    final barcode = _barcodes[_index % _barcodes.length];
    _index++;
    return barcode;
  }
}
