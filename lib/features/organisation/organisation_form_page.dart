import 'package:flutter/material.dart';
import 'package:tax_invoice_new/services/data/database/database_helper.dart';
import 'package:tax_invoice_new/services/data/models/organisation_model.dart';

class OrganizationFormPage extends StatefulWidget {
  final OrganizationModel? organization;

  const OrganizationFormPage({Key? key, this.organization}) : super(key: key);

  @override
  _OrganizationFormPageState createState() => _OrganizationFormPageState();
}

class _OrganizationFormPageState extends State<OrganizationFormPage> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final gstinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.organization != null) {
      nameController.text = widget.organization!.name;
      addressController.text = widget.organization!.address;
      gstinController.text = widget.organization!.gstin;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.organization != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Organization' : 'Add Organization'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: gstinController,
                decoration: InputDecoration(labelText: 'GSTIN'),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: addressController,
                decoration: InputDecoration(labelText: 'Address'),
              ),

              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;

                  final org = OrganizationModel(
                    id: widget.organization?.id,
                    name: nameController.text.trim(),
                    address: addressController.text.trim(),
                    gstin: gstinController.text.trim(),
                  );

                  if (isEditing) {
                    await DBHelper().updateOrganization(org);
                  } else {
                    await DBHelper().insertOrganization(org);
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

                      if (widget.organization != null &&
                          widget.organization?.id != null) {
                        await DBHelper().deleteOrganization(
                          widget.organization!.id!,
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
    );
  }
}
