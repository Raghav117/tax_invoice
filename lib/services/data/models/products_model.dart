import 'package:tax_invoice_new/services/data/models/model_type.dart';

class ProductModel extends ModelType {
  final int? id;
  String name;
  String hsnCode;
  double cgst;
  double sgst;
  double igst;
  double qty;
  double price;
  double totalPrice;

  ProductModel({
    this.id,
    required this.name,
    required this.hsnCode,
    required this.cgst,
    required this.sgst,
    required this.igst,
    this.qty = 0,
    this.price = 0,
    this.totalPrice = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'hsnCode': hsnCode,
      'cgst': cgst,
      'sgst': sgst,
      'igst': igst,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'],
      name: map['name'],
      hsnCode: map['hsnCode'],
      cgst: map['cgst'],
      sgst: map['sgst'],
      igst: map['igst'],
    );
  }
}
