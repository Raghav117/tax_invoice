import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart' as provider;
import 'package:tax_invoice_new/features/organisation/organisation_form_page.dart';
import 'package:tax_invoice_new/features/organisation/organisation_list_page.dart';
import 'package:tax_invoice_new/features/products/product_form_page.dart';
import 'package:tax_invoice_new/features/products/product_list_page.dart';
import 'package:tax_invoice_new/features/sign_in/sign_in_view.dart';
import 'package:tax_invoice_new/services/sync/sync_manager.dart';
import 'package:tax_invoice_new/utils/database_operations.dart';
import 'package:tax_invoice_new/modals/global.dart';
import 'package:tax_invoice_new/utils/routes.dart';
import 'package:tax_invoice_new/features/invoice/invoice.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await SyncManager().checkAndSyncIfNeeded();
  runApp(
    MaterialApp(
      home: SignInView(),
      title: "Vyapar Setu",
      routes: Routes.routes,
    ),
  );
}
