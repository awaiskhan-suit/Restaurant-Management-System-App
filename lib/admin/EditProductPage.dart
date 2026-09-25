import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProductPage extends StatefulWidget {
  final DocumentSnapshot documentSnapshot;

  const EditProductPage({
    super.key,
    required this.documentSnapshot,
  });

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _priceController;

  final List<String> _categories = [
    'Pizza',
    'Burger',
    'Sandwich',
    'Shawarma',
    'BBQ Items',
    'Fries',
    'Chicken',
    'Fish',
    'Drinks',
  ];

  String? _selectedCategory;
  String? _currentImagePath; // can be local path or URL
  File? _newImageFile;

  @override
  void initState() {
    super.initState();

    final data = widget.documentSnapshot.data() as Map<String, dynamic>;

    _nameController = TextEditingController(text: data['name'] ?? '');
    _priceController = TextEditingController(text: data['price']?.toString() ?? '');
    _selectedCategory = data['category'];
    _currentImagePath = data['image']; // store existing image path
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  /// Pick a new image from gallery
  Future<void> _pickNewImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (pickedImage != null) {
      setState(() {
        _newImageFile = File(pickedImage.path);
      });
    }
  }

  /// Update product
  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      // Determine image path to save
      String imageToSave = _currentImagePath ?? '';
      if (_newImageFile != null) {
        imageToSave = _newImageFile!.path; // store local path only
      }

      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.documentSnapshot.id)
          .update({
        'name': _nameController.text.trim(),
        'price': double.tryParse(_priceController.text.trim()) ?? 0,
        'category': _selectedCategory,
        'image': imageToSave, // save new or existing image path
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Product updated successfully")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error updating product: $e")),
        );
      }
    }
  }

  Widget _buildCurrentImage() {
    String? imagePath = _newImageFile?.path ?? _currentImagePath;

    if (imagePath == null || imagePath.isEmpty) {
      return const CircleAvatar(
        radius: 50,
        child: Icon(Icons.fastfood, size: 50, color: Colors.grey),
      );
    }

    if (File(imagePath).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(imagePath),
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        ),
      );
    }

    // fallback to network image if not a local file
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        imagePath,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const CircleAvatar(
          radius: 50,
          child: Icon(Icons.fastfood, size: 50, color: Colors.grey),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Product"),
        backgroundColor: Colors.green.shade900,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                /// Product Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: "Product Name",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                  value == null || value.isEmpty ? "Enter product name" : null,
                ),

                const SizedBox(height: 16),

                /// Product Price
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Price",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                  value == null || value.isEmpty ? "Enter price" : null,
                ),

                const SizedBox(height: 16),

                /// Category Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: "Category",
                    border: OutlineInputBorder(),
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                  validator: (value) => value == null ? "Select a category" : null,
                ),

                const SizedBox(height: 16),

                /// Current Image & Pick Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildCurrentImage(),
                    ElevatedButton.icon(
                      onPressed: _pickNewImage,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text("Change Image"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade900,
                      ),
                    )
                  ],
                ),

                const SizedBox(height: 30),

                /// Update Button
                ElevatedButton(
                  onPressed: _updateProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade900,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text("Update Product"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
