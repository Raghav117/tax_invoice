import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:tax_invoice/functionality/convert_number.dart';
import 'package:screenshot/screenshot.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart' as provider;
import 'package:tax_invoice/modals/global.dart';

import 'screens/sales_invoice.dart';

void main() {
  runApp(const MaterialApp(
    home: MyApp(),
    title: "Sales Invoice",
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int sNo = 1;

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Sales Invoice"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Center(
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text("Invoice"),
                        ),
                      ),
                    ),
                    Center(
                      child: SizedBox(
                        height: 40,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            invoice = value;
                          },
                        ),
                      ),
                    )
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Center(
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text("Date Of Invoice"),
                        ),
                      ),
                    ),
                    Center(
                      child: SizedBox(
                        height: 40,
                        child: TextField(
                          keyboardType: TextInputType.datetime,
                          onChanged: (value) {
                            date = value;
                          },
                        ),
                      ),
                    )
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Center(
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text("Name"),
                        ),
                      ),
                    ),
                    Center(
                      child: SizedBox(
                        height: 40,
                        child: TextField(
                          textCapitalization: TextCapitalization.characters,
                          onChanged: (value) {
                            name = value;
                          },
                        ),
                      ),
                    )
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Center(
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text("Address"),
                        ),
                      ),
                    ),
                    Center(
                      child: SizedBox(
                        height: 40,
                        child: TextField(
                          textCapitalization: TextCapitalization.characters,
                          onChanged: (value) {
                            address = value;
                          },
                        ),
                      ),
                    )
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Center(
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text("GST No."),
                        ),
                      ),
                    ),
                    Center(
                      child: SizedBox(
                        height: 40,
                        child: TextField(
                          textCapitalization: TextCapitalization.characters,
                          onChanged: (value) {
                            gstIn = value;
                          },
                        ),
                      ),
                    )
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    Center(
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text("S.No."),
                        ),
                      ),
                    ),
                  ],
                ),
                for (int i = 0; i < sNo; ++i)
                  Center(
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 60),
                      child: TextField(
                        maxLines: 5,
                        minLines: 2,
                        textCapitalization: TextCapitalization.characters,
                        onChanged: (value) {
                          goods[i] = value;
                        },
                      ),
                    ),
                  ),
                IconButton(
                    onPressed: () {
                      goods.add("");
                      price.add(0);
                      quantity.add(1);
                      hsn.add("");
                      ++sNo;
                      setState(() {});
                    },
                    icon: const Icon(Icons.add)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Center(
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text("Price"),
                        ),
                      ),
                    ),
                    for (int i = 0; i < price.length; ++i)
                      Center(
                        child: Container(
                          constraints: const BoxConstraints(minHeight: 60),
                          child: TextField(
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              price[i] = int.tryParse(value)!;
                            },
                          ),
                        ),
                      ),
                    const SizedBox(
                      height: 20,
                    ),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Center(
                            child: Card(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text("Quantity"),
                              ),
                            ),
                          ),
                          for (int i = 0; i < price.length; ++i)
                            Center(
                              child: Container(
                                constraints:
                                    const BoxConstraints(minHeight: 60),
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    quantity[i] = int.tryParse(value)!;
                                  },
                                ),
                              ),
                            ),
                          const SizedBox(
                            height: 20,
                          ),
                        ]),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Center(
                            child: Card(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text("HSN Code"),
                              ),
                            ),
                          ),
                          for (int i = 0; i < sNo; ++i)
                            Center(
                              child: Container(
                                constraints:
                                    const BoxConstraints(minHeight: 60),
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    hsn[i] = value;
                                  },
                                ),
                              ),
                            ),
                          const SizedBox(
                            height: 20,
                          ),
                        ]),
                    InkWell(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return const SalesInvoice();
                        }));
                      },
                      child: Container(
                        child: const Center(
                            child: Text("Download Sales Invoice",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20))),
                        width: 250,
                        height: 50,
                        decoration: BoxDecoration(
                            color: Colors.yellow,
                            borderRadius: BorderRadius.circular(20)),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
