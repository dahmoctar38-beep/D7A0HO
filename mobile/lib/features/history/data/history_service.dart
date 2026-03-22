import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/scan_record.dart';

class HistoryService {
  static const _key = 'scan_history';
  static const _maxRecords = 50;

  Future<List<ScanRecord>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw
        .map((s) => ScanRecord.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.scannedAt.compareTo(a.scannedAt));
  }

  Future<void> add(ScanRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    // Remove duplicate barcode if exists
    final updated = raw
        .where((s) =>
            (jsonDecode(s) as Map<String, dynamic>)['barcode'] != record.barcode)
        .toList();
    updated.insert(0, jsonEncode(record.toJson()));
    if (updated.length > _maxRecords) updated.removeLast();
    await prefs.setStringList(_key, updated);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
