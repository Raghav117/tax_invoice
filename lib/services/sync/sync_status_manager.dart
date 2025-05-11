import 'package:shared_preferences/shared_preferences.dart';

class SyncStatusManager {
  static const _lastSyncKey = 'last_sync_timestamp';
  static const _needsSyncKey = 'needs_sync';

  static Future<void> markSyncNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_needsSyncKey, true);
  }

  static Future<void> markSyncCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_needsSyncKey, false);
    await prefs.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
  }

  static Future<bool> needsSync() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_needsSyncKey) ?? false;
  }

  static Future<DateTime?> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_lastSyncKey);
    return timestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(timestamp)
        : null;
  }
}
