import 'package:hive_flutter/hive_flutter.dart';

import '../constants/storage_keys.dart';

/// Thin wrapper around Hive for local persistence.
class StorageService {
  static late Box _box;

  static Future<void> init() async {
    _box = await Hive.openBox(StorageKeys.boxName);
  }

  // ── Player name ───────────────────────────────────────────────
  static String? getPlayerName() => _box.get(StorageKeys.playerName) as String?;

  static Future<void> setPlayerName(String name) =>
      _box.put(StorageKeys.playerName, name);

  // ── Global last door entry date ───────────────────────────────
  static DateTime? getLastDoorEntryDate() {
    final ms = _box.get(StorageKeys.lastDoorEntryDate) as int?;
    return ms != null ? DateTime.fromMillisecondsSinceEpoch(ms) : null;
  }

  static Future<void> setLastDoorEntryDate(DateTime date) =>
      _box.put(StorageKeys.lastDoorEntryDate, date.millisecondsSinceEpoch);

  // ── Door status ───────────────────────────────────────────────
  static String getDoorStatus(String doorId) =>
      (_box.get('${StorageKeys.doorStatusPrefix}$doorId') as String?) ??
      'locked';

  static Future<void> setDoorStatus(String doorId, String status) =>
      _box.put('${StorageKeys.doorStatusPrefix}$doorId', status);

  // ── Door last attempt date ────────────────────────────────────
  static DateTime? getDoorLastAttemptDate(String doorId) {
    final ms = _box.get('${StorageKeys.doorLastAttemptPrefix}$doorId') as int?;
    return ms != null ? DateTime.fromMillisecondsSinceEpoch(ms) : null;
  }

  static Future<void> setDoorLastAttemptDate(String doorId, DateTime date) =>
      _box.put('${StorageKeys.doorLastAttemptPrefix}$doorId',
          date.millisecondsSinceEpoch);

  // ── Door last success date ────────────────────────────────────
  static DateTime? getDoorLastSuccessDate(String doorId) {
    final ms = _box.get('${StorageKeys.doorLastSuccessPrefix}$doorId') as int?;
    return ms != null ? DateTime.fromMillisecondsSinceEpoch(ms) : null;
  }

  static Future<void> setDoorLastSuccessDate(String doorId, DateTime date) =>
      _box.put('${StorageKeys.doorLastSuccessPrefix}$doorId',
          date.millisecondsSinceEpoch);

  // ── Unlocked hints ────────────────────────────────────────────
  static bool isHintUnlocked(String doorId) =>
      (_box.get('${StorageKeys.unlockedHintsPrefix}$doorId') as bool?) ?? false;

  static Future<void> setHintUnlocked(String doorId) =>
      _box.put('${StorageKeys.unlockedHintsPrefix}$doorId', true);

  // ── Clear all (for testing) ───────────────────────────────────
  static Future<void> clearAll() => _box.clear();

  static const String _welcomeShownKey = 'welcomeShown';

  static bool getWelcomeShown() =>
      (_box.get(_welcomeShownKey) as bool?) ?? false;

  static Future<void> setWelcomeShown(bool value) =>
      _box.put(_welcomeShownKey, value);

  static const String _introShownKey = 'intro_shown';

  static bool getIntroShown() {
    return _box.get(_introShownKey, defaultValue: false) as bool;
  }

  static Future<void> setIntroShown(bool value) async {
    await _box.put(_introShownKey, value);
  }
}
