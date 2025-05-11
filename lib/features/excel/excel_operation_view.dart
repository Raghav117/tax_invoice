import 'package:flutter/material.dart';
import 'package:tax_invoice_new/services/data/database/database_helper.dart';
import 'package:tax_invoice_new/services/excel/excel_manager.dart';

class ExcelOperationView extends StatelessWidget {
  final ExcelManager _excelManager = ExcelManager();

  ExcelOperationView({super.key});

  void _showStatusDialog(
    BuildContext context,
    String title,
    String message, {
    bool isSuccess = true,
  }) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Row(
              children: [
                Icon(
                  isSuccess ? Icons.check_circle : Icons.error,
                  color: isSuccess ? Colors.green : Colors.red,
                  size: 10,
                ),
                const SizedBox(width: 8),
                Text(title),
              ],
            ),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  Future<void> _handleImport(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      await _excelManager.importExcelToDB(context);
      Navigator.pop(context); // Remove loading
      _showStatusDialog(
        context,
        "Import Successful",
        "Excel data imported into database.",
      );
    } catch (e) {
      Navigator.pop(context); // Remove loading
      _showStatusDialog(
        context,
        "Import Failed",
        e.toString(),
        isSuccess: false,
      );
    }
  }

  Future<void> _handleExport(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final data = await DBHelper().getOrganizations();
      await _excelManager.exportDataToExcel(data);
      Navigator.pop(context);
      _showStatusDialog(
        context,
        "Export Successful",
        "Excel file saved to Download folder.",
      );
    } catch (e) {
      Navigator.pop(context);
      _showStatusDialog(
        context,
        "Export Failed",
        e.toString(),
        isSuccess: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Excel Operations")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.upload_file),
              label: const Text("Import from Excel"),
              onPressed: () => _handleImport(context),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.download),
              label: const Text("Export to Excel"),
              onPressed: () => _handleExport(context),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
