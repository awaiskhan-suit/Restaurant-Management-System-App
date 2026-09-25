import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  String? _selectedCategory;
  File? _imageFile;
  bool _loading = false;

  final List<String> _categories = [
    'Pizza', 'Burger', 'Sandwich', 'Shawarma', 'BBQ Items', 'Fries', 'Chicken', 'Fish', 'Drinks'
  ];

  // Pick image from gallery
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedImage != null) {
      setState(() => _imageFile = File(pickedImage.path));
    }
  }

  // Save image locally on the device
  Future<String?> _saveImageLocally(File imageFile) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
      final savedImage = await imageFile.copy('${appDir.path}/$fileName');
      return savedImage.path; // Return local file path
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save image locally: $e")),
      );
      return null;
    }
  }

  // Add product to Firestore with local image path
  Future<void> _addProduct() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Select a category")));
      return;
    }

    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Select an image")));
      return;
    }

    setState(() => _loading = true);

    try {
      String? localPath = await _saveImageLocally(_imageFile!);
      if (localPath == null) return;

      await _firestore.collection('products').add({
        'name': _nameController.text.trim(),
        'price': double.parse(_priceController.text.trim()),
        'category': _selectedCategory,
        'created_at': Timestamp.now(),
        'localImagePath': localPath, // Save local path
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Product added successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      _nameController.clear();
      _priceController.clear();
      setState(() {
        _selectedCategory = null;
        _imageFile = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Product"),
        backgroundColor: Colors.green.shade900,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                    labelText: "Product Name", border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? "Enter name" : null,
              ),
              const SizedBox(height: 15),

              // Price
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                    labelText: "Price", border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v!.isEmpty) return "Enter price";
                  if (double.tryParse(v) == null) return "Enter valid number";
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Category Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                    labelText: "Category", border: OutlineInputBorder()),
                value: _selectedCategory,
                items: _categories
                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedCategory = val),
                validator: (v) => v == null ? "Select category" : null,
              ),
              const SizedBox(height: 20),

              // Image Picker
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: _imageFile == null
                      ? Container(
                    width: 150,
                    height: 150,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.camera_alt, size: 50),
                  )
                      : Image.file(_imageFile!,
                      width: 150, height: 150, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 30),

              // Add Product Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _loading ? null : _addProduct,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade900),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Add Product",
                      style: TextStyle(fontSize: 18)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
