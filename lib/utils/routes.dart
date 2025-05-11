import 'package:flutter/material.dart';
import 'package:tax_invoice_new/features/excel/excel_operation_view.dart';
import 'package:tax_invoice_new/features/organisation/organisation_list_page.dart';
import 'package:tax_invoice_new/features/products/product_list_page.dart';

class Routes {
  static Map<String, Widget Function(BuildContext)> routes = {
    '/productList': (context) => ProductListPage(),
    '/organisationList': (context) => OrganisationListPage(),
    '/excelOperationView': (context) => ExcelOperationView(),
  };
}
