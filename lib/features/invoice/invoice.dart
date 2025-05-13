import 'dart:io';
import 'dart:typed_data';
import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart' as provider;
import 'package:tax_invoice_new/utils/convert_number.dart';
import 'package:tax_invoice_new/modals/global.dart';

class TaxInvoice extends StatefulWidget {
  const TaxInvoice({Key? key}) : super(key: key);

  @override
  State<TaxInvoice> createState() => _TaxInvoiceState();
}

class _TaxInvoiceState extends State<TaxInvoice> {
  ScreenshotController screenshotController = ScreenshotController();

  Uint8List? _imageFile;
  @override
  void initState() {
    super.initState();
    getPermission();
    getAmtQty();
  }

  int amount = 0;
  double taxableAmount = 0;
  double cgstAmount = 0;
  double sgstAmount = 0;
  double totalTax = 0;
  int totalQty = 0;

  void getAmtQty() {
    for (var element in products) {
      totalQty += element.qty.toInt();
      amount += (element.qty.toInt()) * (element.price.toInt());
      element.totalPrice = element.qty * element.price;
    }
  }

  getPermission() async {
    await getPermissionStorage();
    // await getPermissionManageStorage();
  }

  getPermissionStorage() async {
    var status = await Permission.storage.status;
    if (status.isDenied) {
      await Permission.storage.request();
    } else {
      // getPermissionManageStorage();
    }
  }

  getPermissionManageStorage() async {
    var status = await Permission.manageExternalStorage.status;
    if (status.isDenied) {
      await Permission.manageExternalStorage.request();
    }
  }

  bool loading = false;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 0.5),
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: onSaveCta,
          child: const Icon(Icons.share),
        ),
        body:
            loading == true
                ? const Center(child: CircularProgressIndicator())
                : InteractiveViewer(
                  panEnabled: true, // Set to false to disable panning
                  scaleEnabled: true, // Set to false to disable zoom
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Screenshot(
                      controller: screenshotController,
                      child: Container(
                        color: Colors.white,
                        width: 600,
                        padding: const EdgeInsets.all(20),
                        child: Container(
                          decoration: BoxDecoration(border: Border.all()),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TopSection(),
                              const SizedBox(height: 2),
                              Section2(),
                              Expanded(
                                child: Container(
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(color: Colors.black),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            border: Border(right: BorderSide()),
                                          ),
                                          child: Column(
                                            children: [
                                              const SizedBox(height: 5),
                                              const Center(child: Text("S.N.")),
                                              const SizedBox(height: 5),
                                              const Divider(
                                                color: Colors.black,
                                                thickness: 0.5,
                                              ),
                                              ...products.map((e) {
                                                return Column(
                                                  children: [
                                                    Text(
                                                      (products.indexOf(e) + 1)
                                                          .toString(),
                                                    ),
                                                    const SizedBox(height: 10),
                                                  ],
                                                );
                                              }).toList(),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 10,
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            border: Border(right: BorderSide()),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(height: 5),
                                              const Center(
                                                child: Text(
                                                  "Description of Goods",
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              const Divider(
                                                color: Colors.black,
                                                thickness: 0.5,
                                              ),
                                              ...products.map((e) {
                                                return Padding(
                                                  padding: const EdgeInsets.all(
                                                    2.0,
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                        e.name,
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 5),
                                                    ],
                                                  ),
                                                );
                                              }).toList(),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 4,
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            border: Border(right: BorderSide()),
                                          ),
                                          child: Column(
                                            children: [
                                              const SizedBox(height: 5),
                                              const Center(
                                                child: Text("HSN/SAC"),
                                              ),
                                              const SizedBox(height: 5),
                                              const Divider(
                                                color: Colors.black,
                                                thickness: 0.5,
                                              ),
                                              ...products.map((e) {
                                                return Padding(
                                                  padding: const EdgeInsets.all(
                                                    2.0,
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                        e.hsnCode.toString(),
                                                      ),
                                                      const SizedBox(height: 5),
                                                    ],
                                                  ),
                                                );
                                              }).toList(),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            border: Border(right: BorderSide()),
                                          ),
                                          child: Column(
                                            children: [
                                              const SizedBox(height: 5),
                                              const Center(child: Text("Qty.")),
                                              const SizedBox(height: 5),
                                              const Divider(
                                                color: Colors.black,
                                                thickness: 0.5,
                                              ),
                                              ...products.map((e) {
                                                return Column(
                                                  children: [
                                                    Text(e.qty.toString()),
                                                    const SizedBox(height: 10),
                                                  ],
                                                );
                                              }).toList(),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            border: Border(right: BorderSide()),
                                          ),
                                          child: Column(
                                            children: [
                                              const SizedBox(height: 5),
                                              const Center(child: Text("Unit")),
                                              const SizedBox(height: 5),
                                              const Divider(
                                                color: Colors.black,
                                                thickness: 0.5,
                                              ),
                                              ...products.map((e) {
                                                return Column(
                                                  children: const [
                                                    Text("Pcs."),
                                                    SizedBox(height: 10),
                                                  ],
                                                );
                                              }).toList(),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            border: Border(right: BorderSide()),
                                          ),
                                          child: Column(
                                            children: [
                                              const SizedBox(height: 5),
                                              const Center(
                                                child: Text("Price"),
                                              ),
                                              const SizedBox(height: 5),
                                              const Divider(
                                                color: Colors.black,
                                                thickness: 0.5,
                                              ),
                                              ...products.map((e) {
                                                return Padding(
                                                  padding: const EdgeInsets.all(
                                                    2.0,
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Text(e.price.toString()),
                                                      const SizedBox(height: 5),
                                                    ],
                                                  ),
                                                );
                                              }).toList(),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 4,
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            border: Border(right: BorderSide()),
                                          ),
                                          child: Column(
                                            children: [
                                              const SizedBox(height: 5),
                                              const Center(
                                                child: Text("Amount(' )"),
                                              ),
                                              const SizedBox(height: 5),
                                              const Divider(
                                                color: Colors.black,
                                                thickness: 0.5,
                                              ),
                                              ...products.map((e) {
                                                return Padding(
                                                  padding: const EdgeInsets.all(
                                                    2.0,
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        '₹' +
                                                            (e.price * e.qty)
                                                                .toString(),
                                                      ),
                                                      const SizedBox(height: 5),
                                                    ],
                                                  ),
                                                );
                                              }).toList(),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              GrandTotalSection(
                                totalQty: totalQty,
                                amount: amount,
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          const Text(
                                            "HSN/SAC",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          ...List.generate(products.length, (
                                            index,
                                          ) {
                                            return Text(
                                              products[index].hsnCode,
                                            );
                                          }),
                                          const Text(
                                            "Total",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          const Text(
                                            "Tax Rate",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          ...List.generate(products.length, (
                                            index,
                                          ) {
                                            return Text(
                                              "${products[index].cgst + products[index].sgst}",
                                            );
                                          }),
                                          const Text(
                                            " ",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          const Text(
                                            "Taxable Amt.",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          ...products.map((e) {
                                            if (products.indexOf(e) == 0) {
                                              taxableAmount = 0;
                                            }
                                            final thisTaxableAmount =
                                                (e.totalPrice *
                                                    100 /
                                                    (100 + e.cgst + e.sgst));
                                            taxableAmount =
                                                taxableAmount +
                                                thisTaxableAmount;
                                            return Text(
                                              thisTaxableAmount.toStringAsFixed(
                                                2,
                                              ),
                                            );
                                          }).toList(),
                                          Text(
                                            taxableAmount.toStringAsFixed(2),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          const Text(
                                            "CGST Amt.",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          ...products.map((e) {
                                            if (products.toList().indexOf(e) ==
                                                0) {
                                              cgstAmount = 0;
                                            }
                                            final thisCgstAmount =
                                                (e.totalPrice *
                                                    100 /
                                                    (100 + e.cgst + e.sgst)) *
                                                e.cgst /
                                                100;
                                            cgstAmount += thisCgstAmount;
                                            return Text(
                                              thisCgstAmount.toStringAsFixed(2),
                                            );
                                          }).toList(),
                                          Text(
                                            cgstAmount.toStringAsFixed(2),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          const Text(
                                            "SGST Amt.",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          ...products.map((e) {
                                            if (products.toList().indexOf(e) ==
                                                0) {
                                              sgstAmount = 0;
                                            }
                                            final thisSgstAmount =
                                                (e.totalPrice *
                                                    100 /
                                                    (100 + e.cgst + e.sgst)) *
                                                e.sgst /
                                                100;
                                            sgstAmount += thisSgstAmount;
                                            return Text(
                                              thisSgstAmount.toStringAsFixed(2),
                                            );
                                          }).toList(),
                                          Text(
                                            sgstAmount.toStringAsFixed(2),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          const Text(
                                            "Total Tax",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          ...products.map((e) {
                                            if (products.toList().indexOf(e) ==
                                                0) {
                                              totalTax = 0;
                                            }
                                            final thisTotalTaxAmt =
                                                (e.totalPrice *
                                                    100 /
                                                    (100 + e.cgst + e.sgst)) *
                                                (e.cgst + e.sgst) /
                                                100;
                                            totalTax += thisTotalTaxAmt;
                                            return Text(
                                              thisTotalTaxAmt.toStringAsFixed(
                                                2,
                                              ),
                                            );
                                          }).toList(),
                                          Text(
                                            totalTax.toStringAsFixed(2),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              LastSection(amount: amount),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
      ),
    );
  }

  void onSaveCta() async {
    _imageFile = await screenshotController.capture();

    final Directory? directory = await Directory(
      "/storage/emulated/0/Download/bill",
    ).create(recursive: true);
    final String path = directory!.path + "/bill_${name.text} _${invoice}.jpeg";

    setState(() {
      loading = true;
    });
    try {
      File file = await File(path).create(recursive: true);
      file.writeAsBytesSync(_imageFile!);
      setState(() {
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
      Get.snackbar(
        "Error",
        "e.toString()",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}

class LastSection extends StatelessWidget {
  const LastSection({Key? key, required this.amount}) : super(key: key);

  final int amount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "RUPEES " +
              NumberToWordsEnglish.convert(amount).toUpperCase() +
              " ONLY",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.underline,
          ),
        ),
        Container(
          height: 20,
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(border: Border(bottom: BorderSide())),
          child: const Text(
            "Bank Details : PNB Bank IFSC Code: PUNB0168810 AC NO.: 1688108700000403",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(height: 10),
        SizedBox(
          height: 60,
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(right: BorderSide()),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("1. Goods once sold will not be taken back."),
                      Text(
                        "2. Subject to 'Bisauli District Badaun Uttar Pradesh' Juridiction only.",
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      const Text("Reciever's Signature"),
                      const Divider(
                        thickness: 0.5,
                        color: Colors.black,
                        height: 0.5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: const [
                          Text(
                            "For NEERAJ ELECTRONICS",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Text("Authorized Signature"),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class GrandTotalSection extends StatelessWidget {
  const GrandTotalSection({
    Key? key,
    required this.totalQty,
    required this.amount,
  }) : super(key: key);

  final int totalQty;
  final int amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      decoration: const BoxDecoration(border: Border(bottom: BorderSide())),
      child: Row(
        children: [
          const Expanded(flex: 10, child: Center(child: Text("Grand Total"))),
          Expanded(
            flex: 3,
            child: Container(
              decoration: const BoxDecoration(
                border: Border(left: BorderSide(), right: BorderSide()),
              ),
              child: Center(child: Text('Total Qty: ' + totalQty.toString())),
            ),
          ),
          Expanded(flex: 2, child: SizedBox.expand()),
          Expanded(
            flex: 3,
            child: Container(
              decoration: const BoxDecoration(
                border: Border(left: BorderSide(), right: BorderSide()),
              ),
              child: Center(child: Text('₹' + amount.toString())),
            ),
          ),
        ],
      ),
    );
  }
}

class Section2 extends StatelessWidget {
  const Section2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(border: Border.all()),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Expanded(flex: 1, child: Text("Invoice No.")),
                            Expanded(flex: 2, child: Text(": $invoice")),
                          ],
                        ),
                        Row(
                          children: [
                            const Expanded(
                              flex: 1,
                              child: Text("Date of Invoice"),
                            ),
                            Expanded(flex: 2, child: Text(": $date")),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Colors.black, thickness: 0.5),
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Billed to  :",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "${name.text},",
                                    style: const TextStyle(),
                                  ),
                                  Text(
                                    "${address.text},",
                                    style: const TextStyle(),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "GSTIN/UIN :  ${gstIn.text}",
                                    style: const TextStyle(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              decoration: const BoxDecoration(
                                border: Border(
                                  left: BorderSide(color: Colors.black),
                                ),
                              ),
                              padding: const EdgeInsets.all(4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Shipped to  :",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "${name.text},",
                                    style: const TextStyle(),
                                  ),
                                  Text(
                                    "${address.text},",
                                    style: const TextStyle(),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "GSTIN/UIN :  ${gstIn.text}",
                                    style: const TextStyle(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TopSection extends StatelessWidget {
  const TopSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                "  GSTIN : 09AHRPA5442J2Z2",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              SizedBox(
                height: 40,
                width: 40,
                child: Image.asset("images/ne@4x.png"),
              ),
            ],
          ),
          const Center(
            child: Text(
              "TAX INVOICE",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Center(
            child: Text(
              "NEERAJ ELECTRONICS",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
          ),
          const Center(
            child: Text(
              "OLD TANKI ROAD, BISAULI",
              style: TextStyle(fontSize: 18),
            ),
          ),
          const Center(
            child: Text(
              "Tel. : 9927387458,  Email Id: sji.elec@gmail.com",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
