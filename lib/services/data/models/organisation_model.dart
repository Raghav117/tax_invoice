import 'package:tax_invoice_new/services/data/models/model_type.dart';

class OrganizationModel extends ModelType {
  final int? id;
  final String name;
  final String address;
  final String gstin;

  OrganizationModel({
    this.id,
    required this.name,
    required this.address,
    required this.gstin,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'address': address, 'gstin': gstin};
  }

  factory OrganizationModel.fromMap(Map<String, dynamic> map) {
    return OrganizationModel(
      id: map['id'],
      name: map['name'],
      address: map['address'],
      gstin: map['gstin'],
    );
  }
}
