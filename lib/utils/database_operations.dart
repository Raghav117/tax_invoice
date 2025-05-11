// import 'dart:io';
// import 'package:flutter_excel/excel.dart';
// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';

// class ExcelDatabaseOperations {
//   ExcelDatabaseOperations._();

//   static Future<bool> getPermissionToReadFile() async {
//     // Request permission for Android
//     var status = await Permission.manageExternalStorage.request();
//     if (status.isGranted) {
//       // Permission denied by the user
//       return true;
//     }
//     return false;
//   }

//   static List<List<String>> data = [];

//   static Future<void> readExcelFile() async {
//     try {
//       if (await getPermissionToReadFile()) {
//         const path = 'storage/emulated/0/gst.xlsx';
//         File file = File(path);
//         if (await file.exists()) {
//           var bytes = file.readAsBytesSync();
//           var excel = Excel.decodeBytes(bytes);

//           data.clear();

//           for (var table in excel.tables.keys) {
//             print(table); //sheet Name
//             print(excel.tables[table]!.maxCols!);
//             print(excel.tables[table]!.maxRows!);

//             for (var row in excel.tables[table]!.rows) {
//               List<String> rowData = [];

//               if (row[0] != null && row[1] != null && row[2] != null) {
//                 rowData.add(row[0]!.value!.toString());
//                 rowData.add(row[1]!.value!.toString());
//                 rowData.add(row[2]!.value!.toString());
//                 data.add(rowData);
//               }
//             }
//           }
//         }
//       }
//     } catch (e) {
//       debugPrint(e.toString());
//     }
//   }
// }
