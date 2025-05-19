import 'package:flutter/material.dart';
import 'package:tax_invoice_new/services/data/database/database_helper.dart';
import 'package:tax_invoice_new/services/data/models/organisation_model.dart';
import 'package:tax_invoice_new/features/organisation/organisation_form_page.dart';

class OrganisationListPage extends StatefulWidget {
  @override
  _OrganisationListPageState createState() => _OrganisationListPageState();
}

class _OrganisationListPageState extends State<OrganisationListPage> {
  List<OrganizationModel> _allOrganisations = [];
  List<OrganizationModel> _filteredOrganisations = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadOrganisations();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _loadOrganisations() async {
    final orgs = await DBHelper().getOrganizations();
    setState(() {
      _allOrganisations = orgs;
      _filteredOrganisations = orgs;
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredOrganisations =
          _allOrganisations
              .where((org) => org.name.toLowerCase().contains(query))
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Organisation List")),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.yellow,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => OrganizationFormPage()),
          );
          _loadOrganisations();
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
                  labelText: "Search Organisation",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            Expanded(
              child:
                  _filteredOrganisations.isEmpty
                      ? Center(child: Text("No Organisations Found"))
                      : ListView.builder(
                        itemCount: _filteredOrganisations.length,
                        itemBuilder: (_, index) {
                          final org = _filteredOrganisations[index];
                          return Column(
                            children: [
                              InkWell(
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => OrganizationFormPage(
                                            organization: org,
                                          ),
                                    ),
                                  );
                                  _loadOrganisations();
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
                                            org.name,
                                            style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.blue,
                                            ),
                                          ),
                                          Divider(),
                                          SizedBox(height: 4),
                                          Text(
                                            org.address,
                                            style: TextStyle(fontSize: 20),
                                          ),
                                          Divider(),
                                          SizedBox(height: 4),
                                          Text(
                                            org.gstin,
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
