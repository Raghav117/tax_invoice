import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_excel/excel.dart';
import 'package:tax_invoice_new/services/data/database/database_helper.dart';
import 'package:tax_invoice_new/services/data/models/organisation_model.dart';
import 'package:path_provider/path_provider.dart' as pathProvider;

class ExcelManager {
  Future<void> importExcelToDB(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      withData: false, // this avoids large files crashing
    );

    if (result == null || result.files.single.path == null) return;

    final filePath = result.files.single.path!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      final excel = Excel.decodeBytes(bytes);
      final sheet = excel.tables[excel.tables.keys.first];
      if (sheet == null) return;

      int count = 0;
      for (var row in sheet.rows) {
        final name = row[0]?.value?.toString() ?? '';
        final gstin = row[1]?.value?.toString() ?? '';
        final address = row[2]?.value?.toString() ?? '';

        if (name.isEmpty && gstin.isEmpty && address.isEmpty) continue;

        final org = OrganizationModel(
          name: name,
          gstin: gstin,
          address: address,
        );
        await DBHelper().insertOrganization(
          org,
        ); // WARNING: this must be isolate-safe
        print(org.toMap());
        count++;
      }
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Import completed successfully ($count rows).")),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Import failed: ${e.toString()}")));
    }
  }

  Future<void> exportDataToExcel(List<OrganizationModel> organisations) async {
    final excel = Excel.createExcel();
    final sheet = excel['Sheet1'];

    // Data rows
    for (var org in organisations) {
      sheet.appendRow([org.name, org.gstin, org.address]);
    }

    final downloadDir = Directory("/storage/emulated/0/Download");
    if (downloadDir == null) return;

    final file = File('${downloadDir.path}/gst.xlsx');
    if (await file.exists()) {
      await file.delete();
    }
    file.createSync(recursive: true);
    file.writeAsBytesSync(excel.encode()!);

    print('Excel exported to: ${file.path}');
  }
}
