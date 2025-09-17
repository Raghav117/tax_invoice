import 'dart:convert';
import 'package:tax_invoice_new/services/data/models/model_type.dart';
import 'package:tax_invoice_new/services/data/models/products_model.dart';
import 'package:tax_invoice_new/services/data/models/organisation_model.dart';
import 'package:tax_invoice_new/modals/global.dart';

class InvoiceModel extends ModelType {
  final int? id;
  final int invoiceNumber;
  final String invoiceDate;
  final InvoiceType invoiceType;
  final OrganizationModel customer;
  final List<ProductModel> products;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  InvoiceModel({
    this.id,
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.invoiceType,
    required this.customer,
    required this.products,
    this.createdAt,
    this.updatedAt,
  });

  // Basic map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoice_number': invoiceNumber,
      'invoice_date': invoiceDate,
      'invoice_type': invoiceType.name,
      'customer_data': jsonEncode(customer.toMap()),
      'products_data': jsonEncode(products.map((p) => p.toWholeMap()).toList()),
      'created_at': createdAt?.millisecondsSinceEpoch,
      'updated_at': updatedAt?.millisecondsSinceEpoch,
    };
  }

  // Complete map including customer and products data
  Map<String, dynamic> toWholeMap() {
    return {
      'id': id,
      'invoice_number': invoiceNumber,
      'invoice_date': invoiceDate,
      'invoice_type': invoiceType.name,
      'customer': customer.toMap(),
      'products': products.map((product) => product.toWholeMap()).toList(),
      'created_at': createdAt?.millisecondsSinceEpoch,
      'updated_at': updatedAt?.millisecondsSinceEpoch,
    };
  }

  // Create from database map (with JSON data)
  factory InvoiceModel.fromMap(Map<String, dynamic> map) {
    // Parse customer from JSON
    OrganizationModel customer = OrganizationModel.fromMap(
      jsonDecode(map['customer_data'])
    );
    
    // Parse products from JSON
    List<ProductModel> productList = [];
    if (map['products_data'] != null) {
      List<dynamic> productsJson = jsonDecode(map['products_data']);
      productList = productsJson
          .map((productMap) => ProductModel.fromMap(productMap))
          .toList();
    }

    return InvoiceModel(
      id: map['id'],
      invoiceNumber: (map['invoice_number'] ?? 0) is int 
          ? map['invoice_number'] ?? 0 
          : int.tryParse(map['invoice_number'].toString()) ?? 0,
      invoiceDate: map['invoice_date'] ?? '',
      invoiceType: InvoiceType.values.firstWhere(
        (type) => type.name == map['invoice_type'],
        orElse: () => InvoiceType.gstInvoice,
      ),
      customer: customer,
      products: productList,
      createdAt: map['created_at'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['created_at'])
          : null,
      updatedAt: map['updated_at'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['updated_at'])
          : null,
    );
  }

  // Create from complete map (with customer and products)
  factory InvoiceModel.fromWholeMap(Map<String, dynamic> map) {
    OrganizationModel customer = OrganizationModel.fromMap(map['customer']);
    
    List<ProductModel> productList = [];
    if (map['products'] != null) {
      productList = (map['products'] as List)
          .map((productMap) => ProductModel.fromMap(productMap))
          .toList();
    }

    return InvoiceModel(
      id: map['id'],
      invoiceNumber: map['invoice_number'] ?? '',
      invoiceDate: map['invoice_date'] ?? '',
      invoiceType: InvoiceType.values.firstWhere(
        (type) => type.name == map['invoice_type'],
        orElse: () => InvoiceType.gstInvoice,
      ),
      customer: customer,
      products: productList,
      createdAt: map['created_at'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['created_at'])
          : null,
      updatedAt: map['updated_at'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['updated_at'])
          : null,
    );
  }


  // Copy with method for updates
  InvoiceModel copyWith({
    int? id,
    int? invoiceNumber,
    String? invoiceDate,
    InvoiceType? invoiceType,
    OrganizationModel? customer,
    List<ProductModel>? products,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InvoiceModel(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      invoiceType: invoiceType ?? this.invoiceType,
      customer: customer ?? this.customer,
      products: products ?? this.products,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
