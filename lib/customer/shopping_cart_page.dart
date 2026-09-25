import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'delivery_form_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  User? user;
  late CollectionReference cartRef;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // 🔹 Only current user's cart
      cartRef = FirebaseFirestore.instance
          .collection('carts')
          .doc(user!.uid)
          .collection('items');
    }
  }

  // Calculate total price
  double calculateTotal(List<QueryDocumentSnapshot> items) {
    double total = 0;
    for (var doc in items) {
      final data = doc.data() as Map<String, dynamic>;
      final price = data['price'] ?? 0;
      final quantity = data['quantity'] ?? 1;
      total += price * quantity;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Cart"),
          backgroundColor: Colors.green.shade900,
        ),
        body: const Center(
          child: Text("Please login first to see your cart"),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Cart"),
        backgroundColor: Colors.green.shade900,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: cartRef.orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          // Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data?.docs ?? [];

          if (items.isEmpty) {
            return const Center(child: Text("Your cart is empty"));
          }

          final total = calculateTotal(items);

          return Column(
            children: [
              // 🔹 List of cart items
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final doc = items[index];
                    final data = doc.data() as Map<String, dynamic>;

                    final name = data['name'] ?? '';
                    final price = data['price'] ?? 0;
                    final quantity = data['quantity'] ?? 1;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green.shade900,
                          child: Text(quantity.toString(),
                              style: const TextStyle(color: Colors.white)),
                        ),
                        title: Text(name),
                        subtitle: Text("Rs $price x $quantity = Rs ${price * quantity}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Decrease quantity
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () {
                                if (quantity > 1) {
                                  cartRef.doc(doc.id).update({
                                    'quantity': quantity - 1,
                                  });
                                }
                              },
                            ),

                            // Increase quantity
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                cartRef.doc(doc.id).update({
                                  'quantity': quantity + 1,
                                });
                              },
                            ),

                            // Delete item
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                cartRef.doc(doc.id).delete();
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // 🔹 Total and Checkout section
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey.shade200,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total: Rs $total",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>DeliveryFormPage(total:total,)));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade900,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Checkout"),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
