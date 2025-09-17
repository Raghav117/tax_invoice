import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';

import 'package:tax_invoice_new/services/data/models/organisation_model.dart';
import 'package:tax_invoice_new/services/data/models/products_model.dart';
import 'package:tax_invoice_new/services/data/models/invoice_model.dart';
import 'package:tax_invoice_new/services/sync/sync_status_manager.dart';
import 'package:tax_invoice_new/modals/global.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  static Database? _database;
  String fileName = "invoice.db";

  DBHelper._internal();

  factory DBHelper() {
    return _instance;
  }

  Future<bool> isDbExists() async {
    final path = await getDatabasesPath();
    final dbFile = File(path);
    final dbExists = await dbFile.exists();
    return dbExists;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  Future<String> getDatabasesPath() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, fileName);
    return path;
  }

  Future<Database> initDB() async {
    String path = await getDatabasesPath();

    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE organizations (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT COLLATE NOCASE,
            address TEXT,
            gstin TEXT COLLATE NOCASE,
            UNIQUE(name, gstin)
          )
        ''');

        await db.execute('''
          CREATE TABLE products (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT COLLATE NOCASE,
            hsnCode TEXT COLLATE NOCASE,
            cgst REAL,
            sgst REAL,
            igst REAL,
            UNIQUE(name, hsnCode)
          )
        ''');

        await db.execute('''
          CREATE TABLE invoices (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            invoice_number INTEGER NOT NULL,
            invoice_date TEXT NOT NULL,
            invoice_type TEXT NOT NULL,
            customer_data TEXT NOT NULL,
            products_data TEXT NOT NULL,
            created_at INTEGER,
            updated_at INTEGER,
            UNIQUE(invoice_number, invoice_type)
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE invoices (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              invoice_number INTEGER NOT NULL,
              invoice_date TEXT NOT NULL,
              invoice_type TEXT NOT NULL,
              customer_data TEXT NOT NULL,
              products_data TEXT NOT NULL,
              created_at INTEGER,
              updated_at INTEGER,
              UNIQUE(invoice_number, invoice_type)
            )
          ''');
        }
      },
    );
  }

  Future<int> insertOrganization(OrganizationModel org) async {
    final db = await database;

    final existing = await db.query(
      'organizations',
      where: 'LOWER(name) = ? AND LOWER(gstin) = ?',
      whereArgs: [org.name.toLowerCase(), org.address.toLowerCase()],
    );

    if (existing.isNotEmpty) {
      print('Duplicate entry skipped: ${org.toMap()}');
      return -1;
    }

    await SyncStatusManager.markSyncNeeded();

    return await db.insert('organizations', org.toMap());
  }

  Future<int> updateOrganization(OrganizationModel organization) async {
    final db = await database;

    await SyncStatusManager.markSyncNeeded();
    return await db.update(
      'organizations',
      organization.toMap(),
      where: 'id = ?',
      whereArgs: [organization.id],
    );
  }

  Future<List<OrganizationModel>> getOrganizations() async {
    final db = await database;
    final res = await db.query('organizations');
    return res.map((e) => OrganizationModel.fromMap(e)).toList();
  }

  Future<List<OrganizationModel>> searchOrganizationsByName(String name) async {
    final db = await database;
    final res = await db.query(
      'organizations',
      where: 'LOWER(name) LIKE ?',
      whereArgs: ['%$name%'],
    );
    return res.map((e) => OrganizationModel.fromMap(e)).toList();
  }

  Future<int> insertProduct(ProductModel product) async {
    final db = await database;
    final existing = await db.query(
      'products',
      where: 'LOWER(name) = ? AND LOWER(hsnCode) = ?',
      whereArgs: [product.name.toLowerCase(), product.hsnCode.toLowerCase()],
    );

    if (existing.isNotEmpty) {
      print('Duplicate entry skipped: ${product.toMap()}');
      return -1;
    }

    await SyncStatusManager.markSyncNeeded();

    return await db.insert('products', product.toMap());
  }

  Future<List<ProductModel>> getProducts() async {
    final db = await database;
    final res = await db.query('products');
    return res.map((e) => ProductModel.fromMap(e)).toList();
  }

  Future<List<ProductModel>> searchProductsByName(String name) async {
    final db = await database;
    final res = await db.query(
      'products',
      where: 'name LIKE ?',
      whereArgs: ['%$name%'],
    );
    return res.map((e) => ProductModel.fromMap(e)).toList();
  }

  Future<int> updateProduct(ProductModel product) async {
    final db = await database;

    await SyncStatusManager.markSyncNeeded();

    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteOrganization(int id) async {
    final db = await database;
    return await db.delete('organizations', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteProduct(int id) async {
    final db = await database;
    return await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  // Invoice CRUD Operations
  Future<int> insertInvoice(InvoiceModel invoice) async {
    final db = await database;
    
    // Check for duplicate invoice number
    final existing = await db.query(
      'invoices',
      where: 'invoice_number = ?',
      whereArgs: [invoice.invoiceNumber],
    );
    
    if (existing.isNotEmpty) {
      print('Duplicate invoice number: ${invoice.invoiceNumber}');
      return -1;
    }

    await SyncStatusManager.markSyncNeeded();

    // Insert invoice with JSON data
    return await db.insert('invoices', invoice.toMap());
  }

  Future<List<InvoiceModel>> getInvoices() async {
    final db = await database;
    final res = await db.query(
      'invoices',
      orderBy: 'created_at DESC',
    );
    
    return res.map((row) => InvoiceModel.fromMap(row)).toList();
  }

  Future<InvoiceModel?> getInvoiceById(int id) async {
    final db = await database;
    final res = await db.query(
      'invoices',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (res.isEmpty) return null;
    
    return InvoiceModel.fromMap(res.first);
  }


  Future<List<InvoiceModel>> searchInvoicesByNumber(int invoiceNumber) async {
    final db = await database;
    final res = await db.query(
      'invoices',
      where: 'invoice_number = ?',
      whereArgs: [invoiceNumber],
      orderBy: 'created_at DESC',
    );
    
    return res.map((row) => InvoiceModel.fromMap(row)).toList();
  }

  Future<List<InvoiceModel>> searchInvoicesByNumberAndType(int invoiceNumber, InvoiceType invoiceType) async {
    final db = await database;
    final res = await db.query(
      'invoices',
      where: 'invoice_number = ? AND invoice_type = ?',
      whereArgs: [invoiceNumber, invoiceType.name],
      orderBy: 'created_at DESC',
    );
    
    return res.map((row) => InvoiceModel.fromMap(row)).toList();
  }

  Future<List<InvoiceModel>> searchInvoicesByCustomer(String customerName) async {
    final db = await database;
    final res = await db.query(
      'invoices',
      where: 'customer_data LIKE ?',
      whereArgs: ['%${customerName.toLowerCase()}%'],
      orderBy: 'created_at DESC',
    );
    
    return res.map((row) => InvoiceModel.fromMap(row)).toList();
  }

  Future<int> updateInvoice(InvoiceModel invoice) async {
    final db = await database;
    
    await SyncStatusManager.markSyncNeeded();
    
    return await db.update(
      'invoices',
      invoice.toMap(),
      where: 'id = ?',
      whereArgs: [invoice.id],
    );
  }

  Future<int> deleteInvoice(int id) async {
    final db = await database;
    await SyncStatusManager.markSyncNeeded();
    
    return await db.delete('invoices', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> getNextInvoiceNumber(InvoiceType invoiceType) async {
    final db = await database;
    
    // Get the highest invoice number for this type
    final res = await db.rawQuery('''
      SELECT MAX(invoice_number) as max_number FROM invoices 
      WHERE invoice_type = ?
    ''', [invoiceType.name]);
    
    dynamic maxNumberValue = res.first['max_number'];
    int maxNumber = 0;
    
    if (maxNumberValue != null) {
      if (maxNumberValue is int) {
        maxNumber = maxNumberValue;
      } else if (maxNumberValue is String) {
        maxNumber = int.tryParse(maxNumberValue) ?? 0;
      }
    }
    
    return maxNumber + 1;
  }
}
