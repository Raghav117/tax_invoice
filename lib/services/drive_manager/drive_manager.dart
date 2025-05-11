import 'dart:io';

import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:tax_invoice_new/services/auth/sign_in_helper.dart';
import 'package:tax_invoice_new/services/drive_manager/google_auth_client.dart';

class DriveManager {
  drive.DriveApi? _driveApi;

  Future<void> getDriveApi() async {
    if (_driveApi != null) return;
    final account = await SignInHelper.signedIn();
    if (account == null) return;

    final authHeaders = await account.authHeaders;
    _driveApi = drive.DriveApi(GoogleAuthClient(authHeaders));
  }

  Future<String?> _getFileId(String fileName) async {
    await getDriveApi();

    if (_driveApi == null) return null;

    final response = await _driveApi!.files.list(
      q: "name = '$fileName' and trashed = false",
      $fields: 'files(id)',
    );

    return response.files?.isNotEmpty == true ? response.files!.first.id : null;
  }

  Future<bool> downloadFile(String fileName, String savePath) async {
    try {
      final fileId = await _getFileId(fileName);
      if (fileId == null) return false;

      final media =
          await _driveApi!.files.get(
                fileId,
                downloadOptions: drive.DownloadOptions.fullMedia,
              )
              as drive.Media;

      final fileContent = <int>[];
      await for (final data in media.stream) {
        fileContent.addAll(data);
      }

      final file = File(savePath);
      if (await file.exists()) {
        await file.delete(recursive: true);
      }
      await file.writeAsBytes(fileContent);
      return true;
    } catch (e) {
      print('Download error: $e');
      return false;
    }
  }

  Future<bool> uploadFile(String filePath, String fileName) async {
    try {
      final fileId = await _getFileId(fileName);
      final file = File(filePath);
      final media = drive.Media(file.openRead(), file.lengthSync());

      if (fileId != null) {
        await _driveApi!.files.update(
          drive.File()..name = fileName,
          fileId,
          uploadMedia: media,
        );
      } else {
        await _driveApi!.files.create(
          drive.File()..name = fileName,
          uploadMedia: media,
        );
      }
      return true;
    } catch (e) {
      print('Upload error: $e');
      return false;
    }
  }
}
