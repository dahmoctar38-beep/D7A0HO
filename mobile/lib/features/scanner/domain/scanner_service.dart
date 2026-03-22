abstract class ScannerService {
  /// Returns a barcode string, or null if scan was cancelled.
  Future<String?> scan();
}
