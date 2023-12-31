import 'package:flutter/material.dart';

String invoice = '';
TextEditingController name = TextEditingController();
TextEditingController address = TextEditingController();
TextEditingController gstIn = TextEditingController();

int sgst = 1, cgst = 1;

String date = "";
List<String> goods = [""];
List<String> hsn = [""];
List<int> price = [0];
List<int> quantity = [1];
