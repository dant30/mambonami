import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  SharedPreferences? _preferences;
  static const String _tablePrefix = 'db_table_';

  Future<void> init() async {
    _preferences ??= await SharedPreferences.getInstance();
  }

  Future<bool> _ensureInitialized() async {
    if (_preferences == null) {
      _preferences = await SharedPreferences.getInstance();
    }
    return _preferences != null;
  }

  String _recordKey(String table, String recordId) => '$_tablePrefix$table:$recordId';
  String _indexKey(String table) => '$_tablePrefix${table}_index';

  Future<bool> insertOrUpdateRecord(String table, String recordId, Map<String, dynamic> record, {Duration? ttl}) async {
    await _ensureInitialized();
    final key = _recordKey(table, recordId);
    final payload = <String, dynamic>{'data': record};
    if (ttl != null) {
      payload['expiresAt'] = DateTime.now().add(ttl).toIso8601String();
    }
    final recordJson = jsonEncode(payload);
    final inserted = await _preferences!.setString(key, recordJson);
    if (!inserted) {
      return false;
    }

    final currentIndex = _preferences!.getStringList(_indexKey(table)) ?? <String>[];
    if (!currentIndex.contains(recordId)) {
      currentIndex.add(recordId);
      await _preferences!.setStringList(_indexKey(table), currentIndex);
    }
    return true;
  }

  Future<Map<String, dynamic>?> getRecord(String table, String recordId) async {
    await _ensureInitialized();
    final key = _recordKey(table, recordId);
    final recordString = _preferences!.getString(key);
    if (recordString == null) {
      return null;
    }
    final decoded = jsonDecode(recordString);

    if (decoded is Map<String, dynamic>) {
      // Support wrapped payloads with 'data' and optional 'expiresAt'
      if (decoded.containsKey('data')) {
        final expiresAtString = decoded['expiresAt'] as String?;
        if (expiresAtString != null) {
          final expiresAt = DateTime.tryParse(expiresAtString);
          if (expiresAt != null && DateTime.now().isAfter(expiresAt)) {
            // expired: remove record and update index
            await deleteRecord(table, recordId);
            return null;
          }
        }
        final data = decoded['data'];
        return data is Map<String, dynamic> ? data : null;
      }
      // legacy: stored raw map
      return decoded;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getRecords(String table) async {
    await _ensureInitialized();
    final index = _preferences!.getStringList(_indexKey(table)) ?? <String>[];
    final records = <Map<String, dynamic>>[];

    for (final recordId in index) {
      final record = await getRecord(table, recordId);
      if (record != null) {
        records.add(record);
      }
    }
    return records;
  }

  Future<bool> deleteRecord(String table, String recordId) async {
    await _ensureInitialized();
    final key = _recordKey(table, recordId);
    final removed = await _preferences!.remove(key);
    final currentIndex = _preferences!.getStringList(_indexKey(table)) ?? <String>[];
    if (currentIndex.contains(recordId)) {
      currentIndex.remove(recordId);
      await _preferences!.setStringList(_indexKey(table), currentIndex);
    }
    return removed;
  }

  Future<bool> clearTable(String table) async {
    await _ensureInitialized();
    final index = _preferences!.getStringList(_indexKey(table)) ?? <String>[];
    for (final recordId in index) {
      await _preferences!.remove(_recordKey(table, recordId));
    }
    return _preferences!.remove(_indexKey(table));
  }

  Future<bool> clearAll() async {
    await _ensureInitialized();
    return _preferences!.clear();
  }

  Future<bool> containsRecord(String table, String recordId) async {
    await _ensureInitialized();
    return _preferences!.containsKey(_recordKey(table, recordId));
  }
}

