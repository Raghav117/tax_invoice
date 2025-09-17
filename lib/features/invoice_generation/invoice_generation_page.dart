import 'dart:io';
import 'dart:typed_data';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:screenshot/screenshot.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart' as provider;
import 'package:tax_invoice_new/features/organisation/organisation_form_page.dart';
import 'package:tax_invoice_new/features/organisation/organisation_list_page.dart';
import 'package:tax_invoice_new/features/products/product_form_page.dart';
import 'package:tax_invoice_new/features/products/product_list_page.dart';
import 'package:tax_invoice_new/services/data/database/database_helper.dart';
import 'package:tax_invoice_new/services/data/models/invoice_model.dart';
import 'package:tax_invoice_new/services/data/models/model_type.dart';
import 'package:tax_invoice_new/services/data/models/organisation_model.dart';
import 'package:tax_invoice_new/services/data/models/products_model.dart';
import 'package:tax_invoice_new/services/excel/excel_manager.dart';
import 'package:tax_invoice_new/utils/database_operations.dart';
import 'package:tax_invoice_new/modals/global.dart';
import 'package:tax_invoice_new/utils/routes.dart';
import 'package:tax_invoice_new/features/invoice/invoice.dart';

class InvoiceGenerationPage extends StatefulWidget {
  final InvoiceModel? editInvoice;

  const InvoiceGenerationPage({Key? key, this.editInvoice}) : super(key: key);

  @override
  State<InvoiceGenerationPage> createState() => _InvoiceGenerationPageState();
}

class _InvoiceGenerationPageState extends State<InvoiceGenerationPage> {
  Timer? _debounceTimer;
  final TextEditingController _invoiceController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  bool _isLoadingEditData = false;

  @override
  void initState() {
    // ExcelDatabaseOperations.readExcelFile();
    super.initState();
    if (widget.editInvoice != null) {
      _loadInvoiceForEditing();
    } else {
      _generateInvoiceNumber();
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _invoiceController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _generateInvoiceNumber() async {
    try {
      int nextNumber = await DBHelper().getNextInvoiceNumber(invoiceType);
      setState(() {
        invoice = nextNumber.toString();
        _invoiceController.text = nextNumber.toString();
      });
    } catch (e) {
      print('Error generating invoice number: $e');
    }
  }

  void _loadInvoiceForEditing() {
    if (widget.editInvoice == null) return;

    final editInvoice = widget.editInvoice!;

    // Set flag to prevent auto-search during edit loading
    _isLoadingEditData = true;

    // Use post frame callback to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        // Set invoice type
        invoiceType = editInvoice.invoiceType;

        // Set invoice details
        invoice = editInvoice.invoiceNumber.toString();
        _invoiceController.text = editInvoice.invoiceNumber.toString();
        date = editInvoice.invoiceDate;
        _dateController.text = editInvoice.invoiceDate;

        // Set customer details
        name.text = editInvoice.customer.name;
        address.text = editInvoice.customer.address;
        gstin.text = editInvoice.customer.gstin;

        // Set products
        products.clear();
        products.addAll(editInvoice.products);

        // Reset flag after loading
        _isLoadingEditData = false;
      });
    });
  }

  Future<void> _clearFormAndGenerateNewNumber() async {
    setState(() {
      // Clear invoice details
      invoice = '';
      date = '';
      _dateController.clear();

      // Clear customer details
      name.clear();
      address.clear();
      gstin.clear();

      // Clear products - keep one empty product
      products.clear();
      products.add(
        ProductModel(name: "", hsnCode: "", cgst: 0, sgst: 0, igst: 0),
      );
    });

    // Generate new invoice number
    await _generateInvoiceNumber();

    // _showSuccessMessage('Form cleared and new invoice number generated!');
  }

  void _onInvoiceNumberChanged(String value) {
    // Skip auto-search if we're loading edit data
    if (_isLoadingEditData) return;

    // Cancel previous timer
    _debounceTimer?.cancel();

    // Update the invoice variable immediately
    invoice = value;

    // Set up new timer for debounced search
    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
      if (value.isNotEmpty) {
        _searchAndFillInvoice(value);
      }
    });
  }

  Future<void> _searchAndFillInvoice(String invoiceNumber) async {
    try {
      // Parse invoice number to integer
      int? invoiceNum = int.tryParse(invoiceNumber);
      if (invoiceNum == null) {
        print('Invalid invoice number format: $invoiceNumber');
        return;
      }

      print(
        'Searching for invoice number: $invoiceNum with type: ${invoiceType.name}',
      ); // Debug

      List<InvoiceModel> existingInvoices = await DBHelper()
          .searchInvoicesByNumberAndType(invoiceNum, invoiceType);

      print(
        'Found ${existingInvoices.length} invoices for exact match: $invoiceNum with type: ${invoiceType.name}',
      ); // Debug

      if (existingInvoices.isNotEmpty) {
        InvoiceModel existingInvoice = existingInvoices.first;
        print('Loading invoice: ${existingInvoice.invoiceNumber}'); // Debug

        // Fill the form with existing invoice data
        // Use post frame callback to avoid setState during build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            // Set invoice type
            invoiceType = existingInvoice.invoiceType;

            // Set invoice date
            date = existingInvoice.invoiceDate;
            _dateController.text = existingInvoice.invoiceDate;

            // Set customer details
            name.text = existingInvoice.customer.name;
            address.text = existingInvoice.customer.address;
            gstin.text = existingInvoice.customer.gstin;

            // Set products
            products.clear();
            products.addAll(existingInvoice.products);

            // Update invoice controller
            _invoiceController.text = existingInvoice.invoiceNumber.toString();
            invoice = existingInvoice.invoiceNumber.toString();
          });

          // Show success message
          // _showSuccessMessage('Invoice data loaded successfully!');
        });
      } else {
        print('No invoice found with number: $invoiceNumber'); // Debug
        print('Trying partial match...'); // Debug

        // Try partial match as fallback
        List<InvoiceModel> partialMatches = await _searchInvoicesPartial(
          invoiceNumber,
        );
        if (partialMatches.isNotEmpty) {
          print('Found ${partialMatches.length} partial matches'); // Debug
          print(
            'Partial match numbers: ${partialMatches.map((i) => i.invoiceNumber).toList()}',
          ); // Debug
        }
      }
    } catch (e) {
      print('Error searching invoice: $e');
    }
  }

  Future<List<InvoiceModel>> _searchInvoicesPartial(
    String invoiceNumber,
  ) async {
    final db = await DBHelper().database;
    final res = await db.query(
      'invoices',
      where: 'invoice_number LIKE ?',
      whereArgs: ['%$invoiceNumber%'],
      orderBy: 'created_at DESC',
    );

    return res.map((row) => InvoiceModel.fromMap(row)).toList();
  }

  Future<void> _handleGenerateInvoice() async {
    // Validate required fields
    if (!_validateInvoiceData()) {
      return;
    }

    try {
      // Create customer organization (just for invoice model, not saving to DB)
      OrganizationModel customer = OrganizationModel(
        name: name.text,
        address: address.text,
        gstin: gstin.text,
      );

      // Parse invoice number to integer
      int? invoiceNum = int.tryParse(invoice);
      if (invoiceNum == null) {
        _showErrorMessage(
          'Invalid invoice number format. Please enter a valid number.',
        );
        return;
      }

      // Create invoice model
      InvoiceModel invoiceModel = InvoiceModel(
        invoiceNumber: invoiceNum,
        invoiceDate: date,
        invoiceType: invoiceType,
        customer: customer,
        products: List.from(products),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Check if invoice already exists (filter by type)
      List<InvoiceModel> existingInvoices = await DBHelper()
          .searchInvoicesByNumberAndType(invoiceNum, invoiceType);

      if (existingInvoices.isNotEmpty) {
        // Invoice exists, ask user for update confirmation
        bool? shouldUpdate = await _showUpdateConfirmationDialog();

        if (shouldUpdate == true) {
          // Update existing invoice
          InvoiceModel existingInvoice = existingInvoices.first;
          InvoiceModel updatedInvoice = invoiceModel.copyWith(
            id: existingInvoice.id,
            updatedAt: DateTime.now(),
          );

          await DBHelper().updateInvoice(updatedInvoice);
          // _showSuccessMessage('Invoice updated successfully!');

          // Navigate to invoice view
          _navigateToInvoiceView();
        } else {
          _navigateToInvoiceView();
        }
        // If user says no, do nothing
      } else {
        // Create new invoice
        int invoiceId = await DBHelper().insertInvoice(invoiceModel);

        if (invoiceId != -1) {
          // _showSuccessMessage(
          //   widget.editInvoice != null
          //       ? 'Invoice updated successfully!'
          //       : 'Invoice created successfully!',
          // );

          // Navigate to invoice view
          _navigateToInvoiceView();
        } else {
          _showErrorMessage(
            widget.editInvoice != null
                ? 'Failed to update invoice. Please try again.'
                : 'Failed to create invoice. Please try again.',
          );
        }
      }
    } catch (e) {
      print('Error handling invoice generation: $e');
      _showErrorMessage('An error occurred while processing the invoice.');
    }
  }

  bool _validateInvoiceData() {
    // Check if invoice number is provided
    if (invoice.isEmpty) {
      _showErrorMessage('Please provide an invoice number.');
      return false;
    }

    // Check if date is provided
    if (date.isEmpty) {
      _showErrorMessage('Please provide an invoice date.');
      return false;
    }

    // Check if customer name is provided
    if (name.text.isEmpty) {
      _showErrorMessage('Please provide customer name.');
      return false;
    }

    // Check if at least one product is added with valid data
    bool hasValidProduct = false;
    for (ProductModel product in products) {
      if (product.name.isNotEmpty && product.price > 0 && product.qty > 0) {
        hasValidProduct = true;
        break;
      }
    }

    if (!hasValidProduct) {
      _showErrorMessage(
        'Please add at least one product with valid price and quantity.',
      );
      return false;
    }

    return true;
  }

  Future<bool?> _showUpdateConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Invoice Already Exists'),
          content: Text(
            'An invoice with number "$invoice" already exists. Do you want to update it?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Yes, Update'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _navigateToInvoiceView() {
    // If creating new, go to invoice view
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return const TaxInvoice();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1),
      child: Scaffold(
        drawer: _buildModernDrawer(),
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: _buildModernAppBar(),
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFF8F9FA), Color(0xFFE9ECEF)],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    invoiceTypeSelection(),
                    const SizedBox(height: 20),
                    invoiceAndDate(),
                    const SizedBox(height: 20),
                    customerDetails(context),
                    const SizedBox(height: 20),
                    _buildProductsSection(),
                    const SizedBox(height: 24),
                    addProduct(),
                    const SizedBox(height: 32),
                    generateInvoiceCta(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFD4A574), Color(0xFFB8956A)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
      ),
      centerTitle: true,
      title: Text(
        widget.editInvoice != null ? "Edit Invoice" : "Invoice Generator",
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }

  Widget _buildModernDrawer() {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFD4A574), Color(0xFFB8956A)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              // const CircleAvatar(
              //   radius: 40,
              //   backgroundColor: Colors.white,
              //   child: Icon(
              //     Icons.receipt_long,
              //     size: 40,
              //     color: Color(0xFFF39C12),
              //   ),
              // ),
              // const SizedBox(height: 16),
              // const Text(
              //   'Invoice Manager',
              //   style: TextStyle(
              //     color: Colors.white,
              //     fontSize: 18,
              //     fontWeight: FontWeight.w600,
              //   ),
              // ),
              // const SizedBox(height: 30),
              _buildDrawerItem(
                icon: Icons.receipt_long_outlined,
                title: 'Invoice History',
                onTap: () => Navigator.pushNamed(context, '/invoiceList'),
              ),
              _buildDrawerItem(
                icon: Icons.inventory_2_outlined,
                title: 'Product List',
                onTap: () => Navigator.pushNamed(context, '/productList'),
              ),
              _buildDrawerItem(
                icon: Icons.business_outlined,
                title: 'Organisation List',
                onTap: () => Navigator.pushNamed(context, '/organisationList'),
              ),
              _buildDrawerItem(
                icon: Icons.table_chart_outlined,
                title: 'Excel Operations',
                onTap:
                    () => Navigator.pushNamed(context, '/excelOperationView'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: () {
          // Close the drawer first
          Navigator.of(context).pop();
          // Then execute the original onTap function
          onTap();
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        hoverColor: Colors.white.withOpacity(0.1),
      ),
    );
  }

  Widget _buildProductsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFD4A574), Color(0xFFB8956A)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.shopping_cart_outlined, color: Colors.white),
              const SizedBox(width: 12),
              const Text(
                'Products',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${products.length} item${products.length != 1 ? 's' : ''}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...products.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: productDetails(entry.key),
          );
        }).toList(),
      ],
    );
  }

  Widget productDetails(int i) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with product number and delete option
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Product ${i + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                if (products.length > 1)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        products.removeAt(i);
                      });
                    },
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    tooltip: 'Remove Product',
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Product Name Section
            _buildModernInputSection(
              title: 'Product Name',
              icon: Icons.shopping_bag_outlined,
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4A574).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
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
                      icon: const Icon(Icons.search, color: Color(0xFFB8956A)),
                      tooltip: 'Search Products',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      key: Key(products[i].name),
                      initialValue: products[i].name,
                      decoration: const InputDecoration(
                        hintText: "Enter product name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Color(0xFFF8F9FA),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6C757D),
                      ),
                      textCapitalization: TextCapitalization.words,
                      onChanged: (value) {
                        products[i].name = value;
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            // GST Information (always visible)
            _buildModernInputSection(
              title: 'GST Information',
              icon: Icons.receipt_outlined,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'CGST (%)',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                                color: Color(0xFF6C757D),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              key: Key('cgst_${products[i].name}_$i'),
                              initialValue:
                                  products[i].cgst == 0
                                      ? ''
                                      : products[i].cgst.toString(),
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: "CGST %",
                                hintStyle: TextStyle(fontSize: 12),
                                suffixText: "%",
                                suffixStyle: TextStyle(fontSize: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Color(0xFFF8F9FA),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                              ),
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6C757D),
                              ),
                              onChanged: (value) {
                                products[i].cgst = double.tryParse(value) ?? 0;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'SGST (%)',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                                color: Color(0xFF6C757D),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              key: Key('sgst_${products[i].name}_$i'),
                              initialValue:
                                  products[i].sgst == 0
                                      ? ''
                                      : products[i].sgst.toString(),
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: "SGST %",
                                hintStyle: TextStyle(fontSize: 12),
                                suffixText: "%",
                                suffixStyle: TextStyle(fontSize: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Color(0xFFF8F9FA),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                              ),
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6C757D),
                              ),
                              onChanged: (value) {
                                products[i].sgst = double.tryParse(value) ?? 0;
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'HSN Code',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                                color: Color(0xFF6C757D),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              key: Key('hsn_${products[i].name}_$i'),
                              initialValue:
                                  products[i].hsnCode.isEmpty
                                      ? ''
                                      : products[i].hsnCode,
                              decoration: const InputDecoration(
                                hintText: "HSN code",
                                hintStyle: TextStyle(fontSize: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Color(0xFFF8F9FA),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                              ),
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6C757D),
                              ),
                              textCapitalization: TextCapitalization.characters,
                              onChanged: (value) {
                                products[i].hsnCode = value;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'IGST (%)',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                                color: Color(0xFF6C757D),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              key: Key('igst_${products[i].name}_$i'),
                              initialValue:
                                  products[i].igst == 0
                                      ? ''
                                      : products[i].igst.toString(),
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: "IGST %",
                                hintStyle: TextStyle(fontSize: 12),
                                suffixText: "%",
                                suffixStyle: TextStyle(fontSize: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Color(0xFFF8F9FA),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                              ),
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6C757D),
                              ),
                              onChanged: (value) {
                                products[i].igst = double.tryParse(value) ?? 0;
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            // Price and Quantity Section
            _buildModernInputSection(
              title: 'Price & Quantity',
              icon: Icons.calculate_outlined,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Unit Price',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            color: Color(0xFF6C757D),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          key: Key('price_${products[i].name}_$i'),
                          initialValue:
                              products[i].price == 0
                                  ? ''
                                  : products[i].price.toString(),
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: "Price",
                            hintStyle: TextStyle(fontSize: 12),
                            prefixText: "₹ ",
                            prefixStyle: TextStyle(fontSize: 13),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8),
                              ),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Color(0xFFF8F9FA),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6C757D),
                          ),
                          onChanged: (value) {
                            products[i].price = double.tryParse(value) ?? 0;
                            setState(() {}); // Trigger rebuild to update total
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Quantity',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            color: Color(0xFF6C757D),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          key: Key('qty_${products[i].name}_$i'),
                          initialValue:
                              products[i].qty == 0
                                  ? ''
                                  : products[i].qty.toString(),
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: "Qty",
                            hintStyle: TextStyle(fontSize: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8),
                              ),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Color(0xFFF8F9FA),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6C757D),
                          ),
                          onChanged: (value) {
                            products[i].qty = double.tryParse(value) ?? 0;
                            setState(() {}); // Trigger rebuild to update total
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Total Amount Display
            if (products[i].price > 0 && products[i].qty > 0) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFD4A574).withOpacity(0.08),
                      const Color(0xFFB8956A).withOpacity(0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFD4A574).withOpacity(0.25),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    // Basic Amount
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Base Amount:',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                            color: Color(0xFF6C757D),
                          ),
                        ),
                        Text(
                          '₹${(products[i].price * products[i].qty).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: Color(0xFF495057),
                          ),
                        ),
                      ],
                    ),

                    // GST Calculations (if applicable)
                    if (products[i].cgst > 0 ||
                        products[i].sgst > 0 ||
                        products[i].igst > 0) ...[
                      const SizedBox(height: 8),
                      const Divider(height: 1, color: Color(0xFFE9ECEF)),
                      const SizedBox(height: 8),

                      // Taxable Amount
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Taxable Amount:',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              color: Color(0xFF6C757D),
                            ),
                          ),
                          Text(
                            '₹${((products[i].price * products[i].qty) * 100 / (100 + products[i].cgst + products[i].sgst + products[i].igst)).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              color: Color(0xFF495057),
                            ),
                          ),
                        ],
                      ),

                      // CGST
                      if (products[i].cgst > 0) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'CGST (${products[i].cgst}%):',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                                color: Color(0xFF6C757D),
                              ),
                            ),
                            Text(
                              '₹${(((products[i].price * products[i].qty) * 100 / (100 + products[i].cgst + products[i].sgst + products[i].igst)) * products[i].cgst / 100).toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                                color: Color(0xFF495057),
                              ),
                            ),
                          ],
                        ),
                      ],

                      // SGST
                      if (products[i].sgst > 0) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'SGST (${products[i].sgst}%):',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                                color: Color(0xFF6C757D),
                              ),
                            ),
                            Text(
                              '₹${(((products[i].price * products[i].qty) * 100 / (100 + products[i].cgst + products[i].sgst + products[i].igst)) * products[i].sgst / 100).toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                                color: Color(0xFF495057),
                              ),
                            ),
                          ],
                        ),
                      ],

                      // IGST
                      if (products[i].igst > 0) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'IGST (${products[i].igst}%):',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                                color: Color(0xFF6C757D),
                              ),
                            ),
                            Text(
                              '₹${(((products[i].price * products[i].qty) * 100 / (100 + products[i].cgst + products[i].sgst + products[i].igst)) * products[i].igst / 100).toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                                color: Color(0xFF495057),
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 8),
                      const Divider(height: 1, color: Color(0xFFE9ECEF)),
                      const SizedBox(height: 8),
                    ],

                    // Final Total
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Amount:',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Color(0xFF495057),
                          ),
                        ),
                        Text(
                          '₹${(products[i].price * products[i].qty).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: Color(0xFFB8956A),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildModernInputSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: const Color(0xFFB8956A)),
            const SizedBox(width: 6),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: Color(0xFF495057),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildInfoChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget addProduct() {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFD4A574), Color(0xFFB8956A)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD4A574).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              products.add(
                ProductModel(name: "", hsnCode: "", cgst: 0, sgst: 0, igst: 0),
              );
              setState(() {});
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.add_circle_outline, color: Colors.white, size: 24),
                  SizedBox(width: 12),
                  Text(
                    'Add Another Product',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget generateInvoiceCta() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00B894), Color(0xFF00CEC9)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00B894).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            await _handleGenerateInvoice();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.download_outlined,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  (invoiceType == InvoiceType.gstInvoice
                      ? 'Generate GST Invoice'
                      : 'Generate Simple Bill'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget customerDetails(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFD4A574), Color(0xFFB8956A)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Customer Details',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3436),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Customer Name
            _buildModernInputSection(
              title: 'Customer Name',
              icon: Icons.business_outlined,
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4A574).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () async {
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
                                        gstin.text = "";
                                        address.text = "";
                                        setState(() {});
                                        Navigator.pop(context);
                                      },
                                      onSelectCard: (value) {
                                        value = value as OrganizationModel;
                                        name.text = value.name;
                                        gstin.text = value.gstin;
                                        address.text = value.address;
                                        setState(() {});
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ),
                            );
                          },
                        );
                      },
                      icon: const Icon(Icons.search, color: Color(0xFFB8956A)),
                      tooltip: 'Search Customers',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: name,
                      decoration: const InputDecoration(
                        hintText: "Enter customer name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Color(0xFFF8F9FA),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6C757D),
                      ),
                      textCapitalization: TextCapitalization.words,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            // Address
            _buildModernInputSection(
              title: 'Address',
              icon: Icons.location_on_outlined,
              child: TextFormField(
                controller: address,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: "Enter customer address",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Color(0xFFF8F9FA),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                style: const TextStyle(fontSize: 13, color: Color(0xFF6C757D)),
                textCapitalization: TextCapitalization.words,
              ),
            ),

            const SizedBox(height: 20),
            // GST Number (always visible)
            _buildModernInputSection(
              title: 'GST Number',
              icon: Icons.receipt_long_outlined,
              child: TextFormField(
                controller: gstin,
                decoration: const InputDecoration(
                  hintText: "GST number",
                  hintStyle: TextStyle(fontSize: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Color(0xFFF8F9FA),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                style: const TextStyle(fontSize: 13, color: Color(0xFF6C757D)),
                textCapitalization: TextCapitalization.characters,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget invoiceTypeSelection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFD4A574), Color(0xFFB8956A)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.receipt_outlined,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Invoice Type',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3436),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildInvoiceTypeOption(
                    type: InvoiceType.gstInvoice,
                    title: 'GST Invoice',
                    subtitle: 'With tax calculations',
                    icon: Icons.receipt_long,
                    color: const Color(0xFFB8956A),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInvoiceTypeOption(
                    type: InvoiceType.simpleBill,
                    title: 'Simple Bill',
                    subtitle: 'Basic invoice format',
                    icon: Icons.description,
                    color: const Color(0xFFD4A574),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceTypeOption({
    required InvoiceType type,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = invoiceType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          invoiceType = type;
        });
        _generateInvoiceNumber();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: isSelected ? color : Colors.grey),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected ? color : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? color : Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget invoiceAndDate() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFD4A574), Color(0xFFB8956A)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.assignment_outlined,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Invoice Information',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3436),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: _buildModernInputSection(
                    title: 'Invoice Number',
                    icon: Icons.numbers,
                    child: TextFormField(
                      controller: _invoiceController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        hintText:
                            invoiceType == InvoiceType.gstInvoice ? "001" : "1",
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8F9FA),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.refresh, size: 18),
                          onPressed: _clearFormAndGenerateNewNumber,
                          tooltip: 'Clear Form & Generate New Number',
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6C757D),
                      ),
                      onChanged: _onInvoiceNumberChanged,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildModernInputSection(
                    title: 'Invoice Date',
                    icon: Icons.calendar_today_outlined,
                    child: TextFormField(
                      controller: _dateController,
                      keyboardType: TextInputType.datetime,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9/]')),
                        LengthLimitingTextInputFormatter(10),
                      ],
                      decoration: const InputDecoration(
                        hintText: "DD/MM/YYYY",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Color(0xFFF8F9FA),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6C757D),
                      ),
                      onChanged: (value) {
                        date = value;
                      },
                    ),
                  ),
                ),
              ],
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
