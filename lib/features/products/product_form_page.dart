import 'package:flutter/material.dart';
import 'package:tax_invoice_new/services/data/database/database_helper.dart';
import 'package:tax_invoice_new/services/data/models/organisation_model.dart';
import 'package:tax_invoice_new/services/data/models/products_model.dart';

class ProductFormPage extends StatefulWidget {
  final ProductModel? product;

  const ProductFormPage({Key? key, this.product}) : super(key: key);

  @override
  _ProductFormPageState createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final hsnController = TextEditingController();
  final cgstController = TextEditingController();
  final sgstController = TextEditingController();
  final igstController = TextEditingController();

  List<OrganizationModel> orgs = [];

  @override
  void initState() {
    super.initState();
    loadOrganizations();

    if (widget.product != null) {
      nameController.text = widget.product!.name;
      hsnController.text = widget.product!.hsnCode;
      cgstController.text = widget.product!.cgst.toString();
      sgstController.text = widget.product!.sgst.toString();
      igstController.text = widget.product!.igst.toString();
    }
  }

  Future<void> loadOrganizations() async {
    final fetched = await DBHelper().getOrganizations();
    setState(() => orgs = fetched);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Product' : 'Add Product')),
      body:
          orgs.isEmpty
              ? Center(child: Text('No organizations found. Add one first.'))
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextFormField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: 'Product Name',
                          ),
                        ),
                        TextFormField(
                          controller: hsnController,
                          decoration: InputDecoration(labelText: 'HSN Code'),
                          keyboardType: TextInputType.number,
                        ),
                        TextFormField(
                          controller: cgstController,
                          decoration: InputDecoration(labelText: 'CGST'),
                          keyboardType: TextInputType.number,
                        ),
                        TextFormField(
                          controller: sgstController,
                          decoration: InputDecoration(labelText: 'SGST'),
                          keyboardType: TextInputType.number,
                        ),
                        TextFormField(
                          controller: igstController,
                          decoration: InputDecoration(labelText: 'IGST'),
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () async {
                            if (!_formKey.currentState!.validate()) return;

                            final product = ProductModel(
                              id: widget.product?.id,
                              name: nameController.text.trim(),
                              hsnCode: hsnController.text.trim(),
                              cgst: double.parse(cgstController.text),
                              sgst: double.parse(sgstController.text),
                              igst: double.parse(igstController.text),
                            );

                            if (isEditing) {
                              await DBHelper().updateProduct(product);
                            } else {
                              await DBHelper().insertProduct(product);
                            }

                            Navigator.pop(context);
                          },
                          child: Text(isEditing ? 'Update' : 'Save'),
                        ),

                        SizedBox(height: 4),

                        if (isEditing)
                          Card(
                            child: IconButton(
                              icon: Icon(Icons.delete),
                              iconSize: 24,
                              color: Colors.red,
                              onPressed: () async {
                                if (!_formKey.currentState!.validate()) return;

                                if (widget.product != null &&
                                    widget.product?.id != null) {
                                  await DBHelper().deleteProduct(
                                    widget.product!.id!,
                                  );
                                }

                                Navigator.pop(context);
                              },
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
