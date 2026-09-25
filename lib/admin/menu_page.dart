import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'EditProductPage.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final FirebaseFirestore _firebase = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategory;
  String _searchText = "";

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChange);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChange);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChange() {
    setState(() {
      _searchText = _searchController.text.toLowerCase();
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getMenuStream() {
    return _firebase.collection('products').orderBy('name').snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getCategoryStream() {
    return _firebase.collection('products').orderBy('category').snapshots();
  }

  List<String> _extractUniqueCategories(QuerySnapshot<Map<String, dynamic>> snapshot) {
    final Set<String> categories = {};
    for (var doc in snapshot.docs) {
      final category = doc.data()['category'] as String? ?? 'Uncategorized';
      categories.add(category);
    }
    final list = categories.toList()..sort();
    return ['All', ...list];
  }

  Map<String, List<DocumentSnapshot>> _filterAndGroupProducts(
      QuerySnapshot<Map<String, dynamic>> snapshot) {
    final Map<String, List<DocumentSnapshot>> groupedMap = {};

    final filteredDocs = snapshot.docs.where((doc) {
      final data = doc.data();
      final name = (data['name'] as String? ?? '').toLowerCase();
      final category = data['category'] as String? ?? 'Uncategorized';
      final categoryMatch =
      (_selectedCategory == null || _selectedCategory == 'All' || category == _selectedCategory);
      final searchMatch = name.contains(_searchText);
      return categoryMatch && searchMatch;
    }).toList();

    for (var doc in filteredDocs) {
      final data = doc.data();
      final category = data['category'] as String? ?? 'Uncategorized';
      final groupKey = (_selectedCategory == null || _selectedCategory == 'All') ? category : "products";

      if (!groupedMap.containsKey(groupKey)) {
        groupedMap[groupKey] = [];
      }
      groupedMap[groupKey]!.add(doc);
    }

    return groupedMap;
  }

  Future<void> _deleteProduct(String productId) async {
    final confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Confirmation"),
        content: const Text("Are you sure you want to delete this product?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _firebase.collection('products').doc(productId).delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Product deleted successfully")),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error deleting product: $e")),
          );
        }
      }
    }
  }

  void _editProduct(DocumentSnapshot doc) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProductPage(documentSnapshot: doc),
      ),
    );
  }

  Widget _buildProductItem(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final name = data['name'] ?? '';
    final price = data['price'] ?? '';
    final imagePath = data['image'] ?? null;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: ListTile(
        leading: _buildProductImage(imagePath),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Rs: $price"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _editProduct(doc),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteProduct(doc.id),
            ),
          ],
        ),
      ),
    );
  }

  /// Support local-only images or network images
  Widget _buildProductImage(String? imagePath) {
    if (imagePath != null && imagePath.isNotEmpty) {
      if (File(imagePath).existsSync()) {
        // Local file
        return ClipOval(
          child: Image.file(
            File(imagePath),
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const CircleAvatar(
              radius: 25,
              child: Icon(Icons.fastfood, color: Colors.grey),
              backgroundColor: Colors.white,
            ),
          ),
        );
      } else {
        // Network image fallback
        return ClipOval(
          child: Image.network(
            imagePath,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const CircleAvatar(
              radius: 25,
              child: Icon(Icons.fastfood, color: Colors.grey),
              backgroundColor: Colors.white,
            ),
          ),
        );
      }
    }
    return const CircleAvatar(
      radius: 25,
      child: Icon(Icons.fastfood, color: Colors.grey),
      backgroundColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Menu Management"),
        backgroundColor: Colors.green.shade900,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: "Search",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                // Category Filter
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: getCategoryStream(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return Container();
                    final categories = _extractUniqueCategories(snapshot.data!);

                    return SizedBox(
                      height: 50,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          final isActive = _selectedCategory == category ||
                              (_selectedCategory == null && category == 'All');

                          return ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedCategory =
                                (category == 'All' ? null : category);
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                              isActive ? Colors.black : Colors.white,
                              foregroundColor:
                              isActive ? Colors.white : Colors.black,
                              side: const BorderSide(color: Colors.black),
                            ),
                            child: Text(category),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: getMenuStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No menu item found"));
                }

                final groupedMenu = _filterAndGroupProducts(snapshot.data!);

                if (groupedMenu.isEmpty &&
                    (_searchText.isNotEmpty || _selectedCategory != null)) {
                  return const Center(
                      child: Text("No products match the current filter/search."));
                }

                return ListView(
                  children: groupedMenu.entries.map((entry) {
                    final category = entry.key;
                    final products = entry.value;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_selectedCategory == null || _selectedCategory == 'All')
                          Padding(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Text(
                              category,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ...products.map(_buildProductItem).toList(),
                      ],
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
