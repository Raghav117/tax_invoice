import 'package:tax_invoice_new/services/auth/sign_in_helper.dart';
import 'package:tax_invoice_new/services/data/database/database_helper.dart';
import 'package:tax_invoice_new/services/drive_manager/drive_manager.dart';
import 'package:tax_invoice_new/services/sync/sync_status_manager.dart';

class SyncManager {
  //! shared prefrences
  bool _isSyncing = false;

  Future<void> checkAndSyncIfNeeded() async {
    if (!await DBHelper().isDbExists()) {
      await _attemptSync();
    } else {
      if (await SyncStatusManager.needsSync()) {
        final success = await _attemptSync();
        if (success) {
          await SyncStatusManager.markSyncCompleted();
        }
      }
    }
  }

  Future<bool> _attemptSync() async {
    if (_isSyncing) return false;
    _isSyncing = true;

    try {
      // 1. Check if signed in
      if (!await SignInHelper.isSignedIn()) {
        final signedIn = await SignInHelper.signedIn();
        if (signedIn == null) {
          return false;
        }
      }

      // 2. Get database path
      final dbPath = await DBHelper().getDatabasesPath();
      final isDbExits = await DBHelper().isDbExists();

      // 3. If this is initial sync, download from Drive
      if (!isDbExits) {
        final success = await DriveManager().downloadFile(
          DBHelper().fileName,
          dbPath,
        );
        if (success) {
          _isSyncing = false;
          return true;
        } else {
          return false;
        }
      }
      // 4. Upload local changes to Drive
      else {
        final success = await DriveManager().uploadFile(
          dbPath,
          DBHelper().fileName,
        );
        if (success) {
          _isSyncing = false;
          return true;
        } else {
          return false;
        }
      }
    } catch (e) {
      print('Sync error: $e');
      return false;
    } finally {
      _isSyncing = false;
    }
  }
}
