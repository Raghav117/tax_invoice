import 'dart:io';
import 'dart:typed_data';
import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:tax_invoice/functionality/convert_number.dart';
import 'package:screenshot/screenshot.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart' as provider;
import 'package:tax_invoice/modals/global.dart';

class SalesInvoice extends StatefulWidget {
  const SalesInvoice({Key? key}) : super(key: key);

  @override
  State<SalesInvoice> createState() => _SalesInvoiceState();
}

class _SalesInvoiceState extends State<SalesInvoice> {
  ScreenshotController screenshotController = ScreenshotController();

  Uint8List? _imageFile;
  int amount = 0;
  @override
  void initState() {
    super.initState();
    getPermission();
    getQty();
    for (var element in price) {
      amount += element * quantity[price.indexOf(element)];
    }
    getTaxableAmount();
  }

  Map<String, double> tax = {};
  double taxableAmount = 0;
  double cgstAmount = 0;
  double sgstAmount = 0;
  double totalTax = 0;
  int totalQty = 0;

  getTaxableAmount() {
    for (int i = 0; i < hsn.length; ++i) {
      if (tax.containsKey(hsn[i]) == false) {
        tax[hsn[i]] = double.parse((quantity[i] * price[i]).toString());
      } else {
        tax[hsn[i]] =
            tax[hsn[i]]! + double.parse((quantity[i] * price[i]).toString());
      }
    }
  }

  getQty() {
    for (var element in quantity) {
      totalQty += element;
    }
  }

  getPermission() async {
    await getPermissionStorage();
    await getPermissionManageStorage();
  }

  getPermissionStorage() async {
    var status = await Permission.storage.status;
    if (status.isDenied) {
      await Permission.storage.request();
      getPermissionStorage();
    } else {
      // getPermissionManageStorage();
    }
  }

  getPermissionManageStorage() async {
    var status = await Permission.manageExternalStorage.status;
    if (status.isDenied) {
      await Permission.manageExternalStorage.request();
      getPermissionManageStorage();
    }
  }

  bool loading = false;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 0.75),
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            _imageFile = await screenshotController.capture();

            final Directory? directory =
                await Directory("/storage/emulated/0").create(recursive: true);
            final String path = directory!.path + "/bill.jpeg";

            setState(() {
              loading = true;
            });
            try {
              File file = await File(path).create(recursive: true);
              file.writeAsBytesSync(_imageFile!);
              setState(() {
                loading = false;
              });
              Get.snackbar("File Saved Sucessfully", "",
                  snackPosition: SnackPosition.BOTTOM);
            } catch (e) {
              setState(() {
                loading = false;
              });
              Get.snackbar("Error", "e.toString()",
                  snackPosition: SnackPosition.BOTTOM);
            }
          },
          child: const Icon(Icons.share),
        ),
        body: loading == true
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Screenshot(
                  controller: screenshotController,
                  child: Container(
                      color: Colors.white,
                      width: MediaQuery.of(context).size.width * 1.5,
                      padding: const EdgeInsets.all(20),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        "  GSTIN : 09AHRPA5442J2Z2",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const Spacer(),
                                      SizedBox(
                                          height: 40,
                                          width: 40,
                                          child:
                                              Image.asset("assets/ne@4x.png"))
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  const Center(
                                    child: Text(
                                      "TAX INVOICE",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          decoration: TextDecoration.underline),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  const Center(
                                      child: Text("NEERAJ ELECTRONICS",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 22,
                                          ))),
                                  const Center(
                                    child: Text(
                                      "OLD TANKI ROAD, BISAULI",
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ),
                                  const Center(
                                    child: Text(
                                      "Tel. : 9927387458,  Email Id: sji.elec@gmail.com",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              child: Row(
                                children: [
                                  Expanded(
                                      child: Container(
                                    decoration:
                                        BoxDecoration(border: Border.all()),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(4),
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  const Expanded(
                                                    flex: 1,
                                                    child: Text("Invoice No."),
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text(": $invoice"),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  const Expanded(
                                                    flex: 1,
                                                    child:
                                                        Text("Date of Invoice"),
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text(": $date"),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Divider(
                                          color: Colors.black,
                                          thickness: 0.5,
                                        ),
                                        Column(
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(4),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        const Text(
                                                          "Billed to  :",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontStyle:
                                                                  FontStyle
                                                                      .italic),
                                                        ),
                                                        const SizedBox(
                                                          height: 5,
                                                        ),
                                                        Text(
                                                          "$name,",
                                                          style:
                                                              const TextStyle(),
                                                        ),
                                                        Text(
                                                          "$address,",
                                                          style:
                                                              const TextStyle(),
                                                        ),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        Text(
                                                          "GSTIN/UIN :  $gstIn",
                                                          style:
                                                              const TextStyle(),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Container(
                                                    decoration: const BoxDecoration(
                                                        border: Border(
                                                            left: BorderSide(
                                                                color: Colors
                                                                    .black))),
                                                    padding:
                                                        const EdgeInsets.all(4),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        const Text(
                                                          "Shipped to  :",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontStyle:
                                                                  FontStyle
                                                                      .italic),
                                                        ),
                                                        const SizedBox(
                                                          height: 5,
                                                        ),
                                                        Text(
                                                          "$name,",
                                                          style:
                                                              const TextStyle(),
                                                        ),
                                                        Text(
                                                          "$address,",
                                                          style:
                                                              const TextStyle(),
                                                        ),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        Text(
                                                          "GSTIN/UIN :  $gstIn",
                                                          style:
                                                              const TextStyle(),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  )),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Container(
                                decoration: const BoxDecoration(
                                    border: Border(
                                        bottom:
                                            BorderSide(color: Colors.black))),
                                child: Row(
                                  children: [
                                    Expanded(
                                        flex: 2,
                                        child: Container(
                                          decoration: const BoxDecoration(
                                              border:
                                                  Border(right: BorderSide())),
                                          child: Column(
                                            children: [
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              const Center(
                                                  child: Text(
                                                "S.N.",
                                              )),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              const Divider(
                                                color: Colors.black,
                                                thickness: 0.5,
                                              ),
                                              ...goods.map((e) {
                                                return Column(
                                                  children: [
                                                    Text((goods.indexOf(e) + 1)
                                                        .toString()),
                                                    const SizedBox(
                                                      height: 10,
                                                    )
                                                  ],
                                                );
                                              }).toList()
                                            ],
                                          ),
                                        )),
                                    Expanded(
                                        flex: 10,
                                        child: Container(
                                          decoration: const BoxDecoration(
                                              border:
                                                  Border(right: BorderSide())),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              const Center(
                                                  child: Text(
                                                "Description of Goods",
                                              )),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              const Divider(
                                                color: Colors.black,
                                                thickness: 0.5,
                                              ),
                                              ...goods.map((e) {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.all(2.0),
                                                  child: Column(
                                                    children: [
                                                      Text(e,
                                                          style:
                                                              const TextStyle(
                                                                  fontSize:
                                                                      12)),
                                                      const SizedBox(
                                                        height: 5,
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }).toList()
                                            ],
                                          ),
                                        )),
                                    Expanded(
                                        flex: 4,
                                        child: Container(
                                          decoration: const BoxDecoration(
                                              border:
                                                  Border(right: BorderSide())),
                                          child: Column(
                                            children: [
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              const Center(
                                                  child: Text(
                                                "HSN/SAC",
                                              )),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              const Divider(
                                                color: Colors.black,
                                                thickness: 0.5,
                                              ),
                                              ...hsn.map((e) {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.all(2.0),
                                                  child: Column(
                                                    children: [
                                                      Text(e.toString()),
                                                      const SizedBox(
                                                        height: 5,
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }).toList()
                                            ],
                                          ),
                                        )),
                                    Expanded(
                                        flex: 2,
                                        child: Container(
                                          decoration: const BoxDecoration(
                                              border:
                                                  Border(right: BorderSide())),
                                          child: Column(
                                            children: [
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              const Center(
                                                  child: Text(
                                                "Qty.",
                                              )),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              const Divider(
                                                color: Colors.black,
                                                thickness: 0.5,
                                              ),
                                              ...quantity.map((e) {
                                                return Column(
                                                  children: [
                                                    Text(e.toString()),
                                                    const SizedBox(
                                                      height: 10,
                                                    )
                                                  ],
                                                );
                                              }).toList()
                                            ],
                                          ),
                                        )),
                                    Expanded(
                                        flex: 2,
                                        child: Container(
                                          decoration: const BoxDecoration(
                                              border:
                                                  Border(right: BorderSide())),
                                          child: Column(
                                            children: [
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              const Center(
                                                  child: Text(
                                                "Unit",
                                              )),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              const Divider(
                                                color: Colors.black,
                                                thickness: 0.5,
                                              ),
                                              ...goods.map((e) {
                                                return Column(
                                                  children: const [
                                                    Text("Pcs."),
                                                    SizedBox(
                                                      height: 10,
                                                    )
                                                  ],
                                                );
                                              }).toList()
                                            ],
                                          ),
                                        )),
                                    Expanded(
                                        flex: 2,
                                        child: Container(
                                          decoration: const BoxDecoration(
                                              border:
                                                  Border(right: BorderSide())),
                                          child: Column(
                                            children: [
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              const Center(
                                                  child: Text(
                                                "Price",
                                              )),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              const Divider(
                                                color: Colors.black,
                                                thickness: 0.5,
                                              ),
                                              ...price.map((e) {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.all(2.0),
                                                  child: Column(
                                                    children: [
                                                      Text(e.toString()),
                                                      const SizedBox(
                                                        height: 5,
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }).toList()
                                            ],
                                          ),
                                        )),
                                    Expanded(
                                        flex: 4,
                                        child: Container(
                                          decoration: const BoxDecoration(
                                              border:
                                                  Border(right: BorderSide())),
                                          child: Column(
                                            children: [
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              const Center(
                                                  child: Text(
                                                "Amount(' )",
                                              )),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              const Divider(
                                                color: Colors.black,
                                                thickness: 0.5,
                                              ),
                                              ...price.map((e) {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.all(2.0),
                                                  child: Column(
                                                    children: [
                                                      Text((e *
                                                              quantity[price
                                                                  .indexOf(e)])
                                                          .toString()),
                                                      const SizedBox(
                                                        height: 5,
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }).toList()
                                            ],
                                          ),
                                        )),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              height: 50,
                              decoration: const BoxDecoration(
                                  border: Border(bottom: BorderSide())),
                              child: Row(
                                children: [
                                  const Expanded(
                                    flex: 8,
                                    child: Center(
                                      child: Text("Grand Total"),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                          border: Border(
                                              left: BorderSide(),
                                              right: BorderSide())),
                                      child: Center(
                                        child: Text(totalQty.toString()),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                          border: Border(
                                              left: BorderSide(),
                                              right: BorderSide())),
                                      child: Center(
                                        child: Text(amount.toString()),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              child: Row(
                                children: [
                                  Container(
                                    decoration:
                                        BoxDecoration(border: Border.all()),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          const Text("HSN/SAC",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          ...List.generate(tax.length, (index) {
                                            return Text(
                                                tax.keys.elementAt(index));
                                          }),
                                          const Text("Total",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    decoration:
                                        BoxDecoration(border: Border.all()),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          const Text("Tax Rate",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          ...List.generate(tax.length, (index) {
                                            return Text("${cgst + sgst}");
                                          }),
                                          const Text(" ",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold))
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    decoration:
                                        BoxDecoration(border: Border.all()),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          const Text("Taxable Amt.",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          ...tax.values.map((e) {
                                            if (tax.values
                                                    .toList()
                                                    .indexOf(e) ==
                                                0) {
                                              taxableAmount = 0;
                                            }
                                            taxableAmount = taxableAmount +
                                                (e * 100 / (100 + cgst + sgst));
                                            return Text(
                                                (e * 100 / (100 + cgst + sgst))
                                                    .toStringAsFixed(2));
                                          }).toList(),
                                          Text(
                                            taxableAmount.toStringAsFixed(2),
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    decoration:
                                        BoxDecoration(border: Border.all()),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          const Text("CGST Amt.",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          ...tax.values.map((e) {
                                            if (tax.values
                                                    .toList()
                                                    .indexOf(e) ==
                                                0) {
                                              cgstAmount = 0;
                                            }
                                            cgstAmount += (e *
                                                    100 /
                                                    (100 + cgst + sgst)) *
                                                cgst /
                                                100;
                                            return Text(((e *
                                                        100 /
                                                        (100 + cgst + sgst)) *
                                                    cgst /
                                                    100)
                                                .toStringAsFixed(2));
                                          }).toList(),
                                          Text(
                                            cgstAmount.toStringAsFixed(2),
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    decoration:
                                        BoxDecoration(border: Border.all()),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          const Text("SGST Amt.",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          ...tax.values.map((e) {
                                            if (tax.values
                                                    .toList()
                                                    .indexOf(e) ==
                                                0) {
                                              sgstAmount = 0;
                                            }
                                            sgstAmount += (e *
                                                    100 /
                                                    (100 + cgst + sgst)) *
                                                sgst /
                                                100;
                                            return Text(((e *
                                                        100 /
                                                        (100 + cgst + sgst)) *
                                                    sgst /
                                                    100)
                                                .toStringAsFixed(2));
                                          }).toList(),
                                          Text(
                                            sgstAmount.toStringAsFixed(2),
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    decoration:
                                        BoxDecoration(border: Border.all()),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          const Text("Total Tax",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          ...tax.values.map((e) {
                                            if (tax.values
                                                    .toList()
                                                    .indexOf(e) ==
                                                0) {
                                              totalTax = 0;
                                            }
                                            totalTax += (e *
                                                    100 /
                                                    (100 + cgst + sgst)) *
                                                (cgst + sgst) /
                                                100;
                                            return Text(((e *
                                                        100 /
                                                        (100 + cgst + sgst)) *
                                                    (cgst + sgst) /
                                                    100)
                                                .toStringAsFixed(2));
                                          }).toList(),
                                          Text(
                                            totalTax.toStringAsFixed(2),
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              "RUPEES " +
                                  NumberToWordsEnglish.convert(amount)
                                      .toUpperCase() +
                                  " ONLY",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline),
                            ),
                            Container(
                              height: 50,
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                border: Border(bottom: BorderSide()),
                              ),
                              child: const Text(
                                "Bank Details : PNB Bank IFSC Code: PUNB0168810 AC NO.: 16881132001900",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 100,
                              child: Row(
                                children: [
                                  Expanded(
                                      child: Container(
                                    decoration: const BoxDecoration(
                                        border: Border(right: BorderSide())),
                                    padding: const EdgeInsets.all(4),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: const [
                                        Text(
                                            "1. Goods once sold will not be taken back."),
                                        Text(
                                            "2. Subject to 'Bisauli District Badaun Uttar Pradesh' Juridiction only."),
                                      ],
                                    ),
                                  )),
                                  Expanded(
                                      child: Container(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text("Reciever's Signature"),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        const Divider(
                                          thickness: 0.5,
                                          color: Colors.black,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: const [
                                            Text(
                                              "For NEERAJ ELECTRONICS",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        const Spacer(),
                                        const Text(
                                          "Authorized Signature",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ))
                                ],
                              ),
                            ),
                          ],
                        ),
                      )),
                ),
              ),
      ),
    );
  }
}
