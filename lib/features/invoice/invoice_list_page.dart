import 'package:flutter/material.dart';
import 'package:tax_invoice_new/modals/global.dart';
import 'package:tax_invoice_new/services/data/database/database_helper.dart';
import 'package:tax_invoice_new/services/data/models/invoice_model.dart';
import 'package:tax_invoice_new/features/invoice_generation/invoice_generation_page.dart';
import 'package:tax_invoice_new/services/data/models/products_model.dart';

class InvoiceListPage extends StatefulWidget {
  const InvoiceListPage({Key? key}) : super(key: key);

  @override
  State<InvoiceListPage> createState() => _InvoiceListPageState();
}

class _InvoiceListPageState extends State<InvoiceListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<InvoiceModel> gstInvoices = [];
  List<InvoiceModel> simpleBills = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadInvoices();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadInvoices() async {
    setState(() {
      isLoading = true;
    });

    try {
      List<InvoiceModel> allInvoices = await DBHelper().getInvoices();

      setState(() {
        gstInvoices =
            allInvoices
                .where(
                  (invoice) => invoice.invoiceType == InvoiceType.gstInvoice,
                )
                .toList();
        simpleBills =
            allInvoices
                .where(
                  (invoice) => invoice.invoiceType == InvoiceType.simpleBill,
                )
                .toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error loading invoices: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _deleteInvoice(InvoiceModel invoice) async {
    // Show confirmation dialog
    bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Invoice'),
          content: Text(
            'Are you sure you want to delete ${invoice.invoiceType.displayName} #${invoice.invoiceNumber}?\n\nCustomer: ${invoice.customer.name}\n\nThis action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      try {
        await DBHelper().deleteInvoice(invoice.id!);
        _showSuccessMessage('Invoice deleted successfully!');
        _loadInvoices(); // Refresh the list
      } catch (e) {
        print('Error deleting invoice: $e');
        _showErrorMessage('Failed to delete invoice. Please try again.');
      }
    }
  }

  Future<void> _editInvoice(InvoiceModel invoice) async {
    // Navigate to invoice generation page in edit mode
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InvoiceGenerationPage(editInvoice: invoice),
      ),
    );

    // Refresh the list if an invoice was updated
    if (result == true) {
      _loadInvoices();
    }
  }

  double _calculateTotalAmount(List<ProductModel> products) {
    return products.fold(0.0, (sum, product) => sum + product.totalPrice);
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildInvoiceCard(InvoiceModel invoice) {
    double totalAmount = _calculateTotalAmount(invoice.products);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _editInvoice(invoice),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with invoice number and actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color:
                              invoice.invoiceType == InvoiceType.gstInvoice
                                  ? const Color(0xFFD4A574).withOpacity(0.2)
                                  : Colors.blue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${invoice.invoiceType.displayName} #${invoice.invoiceNumber}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color:
                                invoice.invoiceType == InvoiceType.gstInvoice
                                    ? const Color(0xFFB8956A)
                                    : Colors.blue[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _editInvoice(invoice);
                      } else if (value == 'delete') {
                        _deleteInvoice(invoice);
                      }
                    },
                    itemBuilder:
                        (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 18),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 18, color: Colors.red),
                                SizedBox(width: 8),
                                Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                    icon: const Icon(Icons.more_vert),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Customer info
              Row(
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 16,
                    color: Color(0xFF6C757D),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      invoice.customer.name.isEmpty
                          ? 'No Name'
                          : invoice.customer.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF495057),
                      ),
                    ),
                  ),
                ],
              ),
              if (invoice.customer.gstin.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.account_balance_outlined,
                      size: 16,
                      color: Color(0xFF6C757D),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'GSTIN: ${invoice.customer.gstin}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6C757D),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 8),

              // Date and amount
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: Color(0xFF6C757D),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        invoice.invoiceDate,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6C757D),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4A574),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '₹${totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              // Products count
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.inventory_2_outlined,
                    size: 16,
                    color: Color(0xFF6C757D),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${invoice.products.length} product${invoice.products.length == 1 ? '' : 's'}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6C757D),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceList(List<InvoiceModel> invoices, String emptyMessage) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4A574)),
        ),
      );
    }

    if (invoices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first invoice to see it here',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadInvoices,
      color: const Color(0xFFD4A574),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: invoices.length,
        itemBuilder: (context, index) {
          return _buildInvoiceCard(invoices[index]);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Invoice History',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: const Color(0xFFD4A574),
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.receipt, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'GST Invoice (${gstInvoices.length})',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.description, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Simple Bill (${simpleBills.length})',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInvoiceList(gstInvoices, 'No GST invoices found'),
          _buildInvoiceList(simpleBills, 'No simple bills found'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const InvoiceGenerationPage(),
            ),
          );
          if (result == true) {
            _loadInvoices();
          }
        },
        backgroundColor: const Color(0xFFD4A574),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
