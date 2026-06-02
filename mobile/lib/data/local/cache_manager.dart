import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class CacheManager {
  CacheManager._privateConstructor();

  static final CacheManager instance = CacheManager._privateConstructor();
  SharedPreferences? _preferences;

  Future<void> init() async {
    _preferences ??= await SharedPreferences.getInstance();
  }

  Future<bool> _ensureInitialized() async {
    if (_preferences == null) {
      _preferences = await SharedPreferences.getInstance();
    }
    return _preferences != null;
  }

  Future<bool> saveString(String key, String value) async {
    await _ensureInitialized();
    return _preferences!.setString(key, value);
  }

  Future<String?> getString(String key) async {
    await _ensureInitialized();
    return _preferences!.getString(key);
  }

  Future<bool> saveBool(String key, bool value) async {
    await _ensureInitialized();
    return _preferences!.setBool(key, value);
  }

  Future<bool?> getBool(String key) async {
    await _ensureInitialized();
    return _preferences!.getBool(key);
  }

  Future<bool> saveInt(String key, int value) async {
    await _ensureInitialized();
    return _preferences!.setInt(key, value);
  }

  Future<int?> getInt(String key) async {
    await _ensureInitialized();
    return _preferences!.getInt(key);
  }

  Future<bool> saveDouble(String key, double value) async {
    await _ensureInitialized();
    return _preferences!.setDouble(key, value);
  }

  Future<double?> getDouble(String key) async {
    await _ensureInitialized();
    return _preferences!.getDouble(key);
  }

  Future<bool> saveStringList(String key, List<String> value) async {
    await _ensureInitialized();
    return _preferences!.setStringList(key, value);
  }

  Future<List<String>?> getStringList(String key) async {
    await _ensureInitialized();
    return _preferences!.getStringList(key);
  }

  Future<bool> saveJson(String key, Map<String, dynamic> value) async {
    await _ensureInitialized();
    return _preferences!.setString(key, jsonEncode(value));
  }

  Future<Map<String, dynamic>?> getJson(String key) async {
    await _ensureInitialized();
    final jsonString = _preferences!.getString(key);
    if (jsonString == null || jsonString.isEmpty) {
      return null;
    }

    final decoded = jsonDecode(jsonString);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    return null;
  }

  Future<bool> remove(String key) async {
    await _ensureInitialized();
    return _preferences!.remove(key);
  }

  Future<bool> clear() async {
    await _ensureInitialized();
    return _preferences!.clear();
  }

  Future<bool> containsKey(String key) async {
    await _ensureInitialized();
    return _preferences!.containsKey(key);
  }

  Future<bool> saveCache<T>(String key, T value, {Duration? ttl}) async {
    await _ensureInitialized();
    final payload = <String, dynamic>{
      'data': value,
      if (ttl != null)
        'expiresAt': DateTime.now().add(ttl).toIso8601String(),
    };
    return _preferences!.setString(key, jsonEncode(payload));
  }

  Future<T?> getCache<T>(String key) async {
    await _ensureInitialized();
    final stored = _preferences!.getString(key);
    if (stored == null) return null;

    final decoded = jsonDecode(stored);
    if (decoded is! Map<String, dynamic>) return null;

    final expiresAtString = decoded['expiresAt'] as String?;
    if (expiresAtString != null) {
      final expiresAt = DateTime.tryParse(expiresAtString);
      if (expiresAt != null && DateTime.now().isAfter(expiresAt)) {
        await remove(key);
        return null;
      }
    }

    return decoded['data'] as T?;
  }
}

