import 'package:flutter/material.dart';
import 'package:tax_invoice_new/services/data/database/database_helper.dart';
import 'package:tax_invoice_new/services/data/models/products_model.dart';
import 'package:tax_invoice_new/features/products/product_form_page.dart';

class ProductListPage extends StatefulWidget {
  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  List<ProductModel> _allProducts = [];
  List<ProductModel> _filteredProducts = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _loadProducts() async {
    final products =
        await DBHelper().getProducts(); // Ensure this method exists
    setState(() {
      _allProducts = products;
      _filteredProducts = products;
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts =
          _allProducts
              .where((product) => product.name.toLowerCase().contains(query))
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Product List")),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.yellow,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProductFormPage()),
          );
          _loadProducts();
        },
        tooltip: 'Add',
        child: Icon(Icons.add, size: 48, color: Colors.blue),
      ),

      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: "Search Product",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            Expanded(
              child:
                  _filteredProducts.isEmpty
                      ? Center(child: Text("No Products Found"))
                      : ListView.builder(
                        itemCount: _filteredProducts.length,
                        itemBuilder: (_, index) {
                          final product = _filteredProducts[index];
                          return Column(
                            children: [
                              InkWell(
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) =>
                                              ProductFormPage(product: product),
                                    ),
                                  );
                                  _loadProducts();
                                },
                                child: Container(
                                  width: double.infinity,
                                  child: Card(
                                    color: Colors.white,
                                    margin: EdgeInsets.symmetric(horizontal: 4),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Container(
                                      padding: EdgeInsets.all(4),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(height: 4),
                                          Text(
                                            product.name,
                                            style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.blue,
                                            ),
                                          ),
                                          Divider(),
                                          SizedBox(height: 4),
                                          Text(
                                            "${product.hsnCode}",
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 16),
                            ],
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
