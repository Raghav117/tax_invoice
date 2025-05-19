import 'package:tax_invoice_new/services/data/models/model_type.dart';

class OrganizationModel extends ModelType {
  final int? id;
  final String name;
  final String gstin;
  final String address;

  OrganizationModel({
    this.id,
    required this.name,
    required this.gstin,
    required this.address,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'address': gstin, 'gstin': address};
  }

  factory OrganizationModel.fromMap(Map<String, dynamic> map) {
    return OrganizationModel(
      id: map['id'],
      name: map['name'],
      gstin: map['address'],
      address: map['gstin'],
    );
  }
}
