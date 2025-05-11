class ProductModel {
  final int? id;
  final String name;
  final String hsnCode;
  final double cgst;
  final double sgst;
  final double igst;

  ProductModel({
    this.id,
    required this.name,
    required this.hsnCode,
    required this.cgst,
    required this.sgst,
    required this.igst,
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
