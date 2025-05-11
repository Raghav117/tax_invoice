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
import 'package:tax_invoice_new/services/data/database/database_helper.dart';
import 'package:tax_invoice_new/services/data/models/organisation_model.dart';
import 'package:tax_invoice_new/services/excel/excel_manager.dart';
import 'package:tax_invoice_new/utils/database_operations.dart';
import 'package:tax_invoice_new/modals/global.dart';
import 'package:tax_invoice_new/utils/routes.dart';
import 'package:tax_invoice_new/features/invoice/invoice.dart';

class InvoiceGenerationPage extends StatefulWidget {
  const InvoiceGenerationPage({Key? key}) : super(key: key);

  @override
  State<InvoiceGenerationPage> createState() => _InvoiceGenerationPageState();
}

class _InvoiceGenerationPageState extends State<InvoiceGenerationPage> {
  int sNo = 1;

  @override
  void initState() {
    // ExcelDatabaseOperations.readExcelFile();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1),
      child: Scaffold(
        drawer: Drawer(
          child: SafeArea(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: Icon(Icons.inventory),
                  title: Text('Product List'),
                  onTap: () {
                    Navigator.pushNamed(context, '/productList');
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.business),
                  title: Text('Organisation List'),
                  onTap: () {
                    Navigator.pushNamed(context, '/organisationList');
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.business),
                  title: Text('Excel Operation Page'),
                  onTap: () {
                    Navigator.pushNamed(context, '/excelOperationView');
                  },
                ),
              ],
            ),
          ),
        ),
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Tax Invoice"),
          surfaceTintColor: Colors.orange,
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(8),
                  margin: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.orangeAccent.withOpacity(0.7),
                  ),

                  child: Column(
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
                          child: TextField(
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              counterText: "Invoice Number",
                            ),
                            onChanged: (value) {
                              invoice = value;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(8),
                  margin: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.orangeAccent.withOpacity(0.2),
                  ),
                  child: Column(
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
                          child: TextField(
                            decoration: const InputDecoration(
                              counterText: "Date Of Invoice",
                            ),
                            keyboardType: TextInputType.datetime,
                            onChanged: (value) {
                              date = value;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(8),
                  margin: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.orangeAccent.withOpacity(0.7),
                  ),
                  child: Column(
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
                        child: InkWell(
                          onTap: () async {
                            List<OrganizationModel> searchData =
                                await DBHelper().getOrganizations();
                            showDialog(
                              context: context,
                              builder: (context) {
                                return StatefulBuilder(
                                  builder:
                                      (context, setState) => Material(
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8.0,
                                                  ),
                                              child: TextField(
                                                onChanged: (value) async {
                                                  searchData = await DBHelper()
                                                      .searchOrganizationsByName(
                                                        value.toLowerCase(),
                                                      );
                                                  setState(() {});
                                                },
                                                onSubmitted: (value) {
                                                  name.text = value;
                                                  address.text = "";
                                                  gstIn.text = "";
                                                  setState(() {});
                                                  Navigator.pop(context);
                                                },
                                                decoration: InputDecoration(
                                                  labelText: 'Search',
                                                  border: OutlineInputBorder(),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: ListView.builder(
                                                itemCount: searchData.length,
                                                itemBuilder: (context, index) {
                                                  return Column(
                                                    children: [
                                                      InkWell(
                                                        onTap: () {
                                                          name.text =
                                                              searchData[index]
                                                                  .name;
                                                          address.text =
                                                              searchData[index]
                                                                  .address;
                                                          gstIn.text =
                                                              searchData[index]
                                                                  .gstin;
                                                          setState(() {});
                                                          Navigator.pop(
                                                            context,
                                                          );
                                                        },
                                                        child: ListTile(
                                                          title: Text(
                                                            searchData[index]
                                                                .name,
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),

                                                          subtitle: Text(
                                                            searchData[index]
                                                                .gstin,
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                        ),
                                                      ),

                                                      Divider(),
                                                    ],
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                );
                              },
                            );
                          },
                          child: TextField(
                            enabled: false,
                            controller: name,
                            decoration: const InputDecoration(
                              counterText: "Name",
                            ),
                            textCapitalization: TextCapitalization.characters,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(8),
                  margin: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.orangeAccent.withOpacity(0.2),
                  ),
                  child: Column(
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
                          child: TextField(
                            controller: address,
                            decoration: const InputDecoration(
                              counterText: "Address",
                            ),
                            textCapitalization: TextCapitalization.characters,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(8),
                  margin: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.orangeAccent.withOpacity(0.7),
                  ),
                  child: Column(
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
                          child: TextField(
                            decoration: const InputDecoration(
                              counterText: "GST Number",
                            ),
                            controller: gstIn,
                            textCapitalization: TextCapitalization.characters,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(8),
                  margin: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.orangeAccent.withOpacity(0.2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Center(
                        child: Card(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text("CGST"),
                          ),
                        ),
                      ),
                      Center(
                        child: SizedBox(
                          child: TextField(
                            decoration: const InputDecoration(
                              counterText: "CGST",
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              cgst = int.tryParse(value)!;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(8),
                  margin: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.orangeAccent.withOpacity(0.7),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Center(
                        child: Card(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text("SGST"),
                          ),
                        ),
                      ),
                      Center(
                        child: SizedBox(
                          child: TextField(
                            decoration: const InputDecoration(
                              counterText: "SGST",
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              sgst = int.tryParse(value)!;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: Center(child: Text("S.No.")),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(8),
                  margin: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.orangeAccent.withOpacity(0.2),
                  ),
                  child: Column(
                    children: [
                      for (int i = 0; i < sNo; ++i)
                        Center(
                          child: Container(
                            constraints: const BoxConstraints(minHeight: 60),
                            child: TextField(
                              maxLines: 5,
                              minLines: 2,
                              decoration: InputDecoration(
                                counterText: "Serioul ${i + 1}",
                              ),
                              textCapitalization: TextCapitalization.characters,
                              onChanged: (value) {
                                goods[i] = value;
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Card(
                  color: Colors.orangeAccent,
                  child: IconButton(
                    color: Colors.white,
                    onPressed: () {
                      goods.add("");
                      price.add(0);
                      quantity.add(1);
                      hsn.add("");
                      ++sNo;
                      setState(() {});
                    },
                    icon: const Icon(Icons.add),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(8),
                  margin: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.orangeAccent.withOpacity(0.2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Center(
                        child: Card(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text("Price Of One Unit"),
                          ),
                        ),
                      ),
                      for (int i = 0; i < price.length; ++i)
                        Center(
                          child: Container(
                            constraints: const BoxConstraints(minHeight: 60),
                            child: TextField(
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                counterText: "Amount ${i + 1}",
                              ),
                              onChanged: (value) {
                                price[i] = int.tryParse(value)!;
                              },
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),
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
                                constraints: const BoxConstraints(
                                  minHeight: 60,
                                ),
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    quantity[i] = int.tryParse(value)!;
                                  },
                                ),
                              ),
                            ),
                          const SizedBox(height: 20),
                        ],
                      ),
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
                                constraints: const BoxConstraints(
                                  minHeight: 60,
                                ),
                                child: TextField(
                                  decoration: InputDecoration(
                                    counterText: "HSN Code ${i + 1}",
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    hsn[i] = value;
                                  },
                                ),
                              ),
                            ),
                          const SizedBox(height: 20),
                        ],
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return const TaxInvoice();
                              },
                            ),
                          );
                        },
                        child: Container(
                          child: const Center(
                            child: Text(
                              "Download Tax Invoice",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          width: 250,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.orangeAccent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
