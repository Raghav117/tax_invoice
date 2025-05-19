import 'package:flutter/material.dart';
import 'package:tax_invoice_new/services/data/models/products_model.dart';

String invoice = '';
String date = "";
TextEditingController name = TextEditingController();
TextEditingController gstin = TextEditingController();
TextEditingController address = TextEditingController();

List<ProductModel> products = [
  ProductModel(name: "", hsnCode: "", cgst: 0, sgst: 0, igst: 0),
];
