import 'package:shared_preferences/shared_preferences.dart';

class PrefsStorage {
  final SharedPreferences _prefs;

  PrefsStorage(this._prefs);

  // Initialize this in your main.dart before runApp
  static Future<PrefsStorage> init() async {
    final prefs = await SharedPreferences.getInstance();
    return PrefsStorage(prefs);
  }

  Future<bool> setString(String key, String value) async {
    return await _prefs.setString(key, value);
  }

  String? getString(String key) {
    return _prefs.getString(key);
  }

  Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }
}