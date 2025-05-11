import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'package:tax_invoice_new/services/data/models/organisation_model.dart';
import 'package:tax_invoice_new/services/data/models/products_model.dart';
import 'package:tax_invoice_new/services/sync/sync_status_manager.dart';

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
      version: 1,
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
      },
    );
  }

  Future<int> insertOrganization(OrganizationModel org) async {
    final db = await database;

    final existing = await db.query(
      'organizations',
      where: 'LOWER(name) = ? AND LOWER(gstin) = ?',
      whereArgs: [org.name.toLowerCase(), org.gstin.toLowerCase()],
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
    final existing = await db.query(
      'organizations',
      where: 'LOWER(name) = ? AND LOWER(gstin) = ?',
      whereArgs: [
        organization.name.toLowerCase(),
        organization.gstin.toLowerCase(),
      ],
    );

    if (existing.isNotEmpty) {
      print('Duplicate entry skipped: ${organization.toMap()}');
      return -1;
    }

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
}
