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
import 'package:tax_invoice_new/services/data/models/model_type.dart';
import 'package:tax_invoice_new/services/data/models/organisation_model.dart';
import 'package:tax_invoice_new/services/data/models/products_model.dart';
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
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  invoiceAndDate(),
                  SizedBox(height: 16),

                  customerDetails(context),
                  SizedBox(height: 16),

                  for (int i = 0; i < products.length; ++i) productDetails(i),
                  SizedBox(height: 40),

                  addProduct(),
                  SizedBox(height: 40),
                  generateInvoiceCta(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget productDetails(int i) {
    return Card(
      margin: EdgeInsets.all(8),
      elevation: 4,
      shadowColor: Colors.yellow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      color: Color(0xFFFFFFF0),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () async {
                    List<ProductModel> searchData =
                        await DBHelper().getProducts();
                    await showDialog(
                      context: context,
                      builder: (context) {
                        return StatefulBuilder(
                          builder:
                              (context, setState) => Material(
                                child: getSelectionCards(
                                  searchData: searchData,

                                  onTextChange: (value) async {
                                    searchData = await DBHelper()
                                        .searchProductsByName(
                                          value.toLowerCase(),
                                        );
                                    setState(() {});
                                  },
                                  onTextSubmitted: (value) {
                                    products[i].name = value;

                                    Navigator.pop(context);
                                  },
                                  onSelectCard: (value) {
                                    value = value as ProductModel;
                                    products[i] = value;
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                        );
                      },
                    );
                    setState(() {});
                  },
                  icon: Icon(Icons.card_travel_outlined),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    key: Key(products[i].name),
                    initialValue: products[i].name,

                    decoration: InputDecoration(counterText: "Product Name"),
                    textCapitalization: TextCapitalization.characters,
                    onChanged: (value) {
                      products[i].name = value;
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Text(
                    "CGST: ",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(width: 40),
                  Text(
                    products[i].cgst.toString() + " %",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Text(
                    "SGST: ",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(width: 40),
                  Text(
                    products[i].sgst.toString() + " %",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Text(
                    "HSN: ",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(width: 40),
                  Text(
                    products[i].hsnCode.toString() + " %",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),

            Container(
              padding: EdgeInsets.all(8),
              margin: EdgeInsets.all(2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.yellow),
                color: Color(0xFFFFFFF0),
              ),
              child: Column(
                children: [
                  const Center(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Price Of One Unit",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 60),
                      child: TextField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(counterText: "Amount"),
                        onChanged: (value) {
                          products[i].price = double.tryParse(value) ?? 0;
                        },
                      ),
                    ),
                  ),
                  const Center(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Quantity",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),

                  Center(
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 60),
                      child: TextField(
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          products[i].qty = double.tryParse(value) ?? 0;
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container addProduct() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        color: Color(0xFFFFFFF0),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        color: Colors.black,
        iconSize: 30,
        onPressed: () {
          products.add(
            ProductModel(name: "", hsnCode: "", cgst: 0, sgst: 0, igst: 0),
          );

          setState(() {});
        },
        icon: const Icon(Icons.add),
      ),
    );
  }

  InkWell generateInvoiceCta() {
    return InkWell(
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
          child: Text("Download Tax Invoice", style: TextStyle(fontSize: 16)),
        ),
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.yellow),
          color: Color(0xFFFFFFF0),
        ),
      ),
    );
  }

  Widget customerDetails(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      elevation: 4,
      shadowColor: Colors.yellow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      color: Color(0xFFFFFFF0),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Name",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
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
                              child: getSelectionCards(
                                searchData: searchData,

                                onTextChange: (value) async {
                                  searchData = await DBHelper()
                                      .searchOrganizationsByName(
                                        value.toLowerCase(),
                                      );
                                  setState(() {});
                                },
                                onTextSubmitted: (value) {
                                  name.text = value;
                                  address.text = "";
                                  gstIn.text = "";
                                  setState(() {});
                                  Navigator.pop(context);
                                },
                                onSelectCard: (value) {
                                  value = value as OrganizationModel;
                                  name.text = value.name;
                                  address.text = value.address;
                                  gstIn.text = value.gstin;
                                  setState(() {});
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                      );
                    },
                  );
                },
                child: TextField(
                  enabled: false,
                  controller: name,
                  decoration: const InputDecoration(counterText: "Name"),
                  textCapitalization: TextCapitalization.characters,
                ),
              ),
            ),

            Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "GST No.",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            Center(
              child: SizedBox(
                child: TextField(
                  decoration: const InputDecoration(counterText: "GST Number"),
                  controller: gstIn,
                  textCapitalization: TextCapitalization.characters,
                ),
              ),
            ),
            const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Address",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            Center(
              child: SizedBox(
                child: TextField(
                  controller: address,
                  decoration: const InputDecoration(counterText: "Address"),
                  textCapitalization: TextCapitalization.characters,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget invoiceAndDate() {
    return Card(
      margin: EdgeInsets.all(8),
      elevation: 4,
      shadowColor: Colors.yellow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      color: Color(0xFFFFFFF0),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Invoice",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
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
            SizedBox(height: 8),
            const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Date",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
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
    );
  }

  Column getSelectionCards({
    required List<ModelType> searchData,
    required void onTextChange(String),
    required void onTextSubmitted(String),
    required void onSelectCard(OrganizationModel),
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: TextField(
            onChanged: (value) {
              onTextChange(value);
            },
            onSubmitted: (value) {
              onTextSubmitted(value);
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
                      onSelectCard(searchData[index]);
                    },
                    child: ListTile(
                      title: Text(
                        searchData[index] is OrganizationModel
                            ? (searchData[index] as OrganizationModel).name
                            : (searchData[index] as ProductModel).name,
                        style: TextStyle(color: Colors.black),
                      ),

                      subtitle: Text(
                        searchData[index] is OrganizationModel
                            ? (searchData[index] as OrganizationModel).name
                            : (searchData[index] as ProductModel).hsnCode,
                        style: TextStyle(color: Colors.black),
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
    );
  }
}
