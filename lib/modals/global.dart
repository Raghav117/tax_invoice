import 'package:flutter/material.dart';
import 'package:tax_invoice_new/services/data/models/products_model.dart';

enum InvoiceType {
  gstInvoice,
  simpleBill,
}

extension InvoiceTypeExtension on InvoiceType {
  String get displayName {
    switch (this) {
      case InvoiceType.gstInvoice:
        return 'GST Invoice';
      case InvoiceType.simpleBill:
        return 'Simple Bill';
    }
  }
}

String invoice = '';
String date = "";
InvoiceType invoiceType = InvoiceType.gstInvoice;
TextEditingController name = TextEditingController();
TextEditingController gstin = TextEditingController();
TextEditingController address = TextEditingController();

List<ProductModel> products = [
  ProductModel(name: "", hsnCode: "", cgst: 0, sgst: 0, igst: 0),
];
