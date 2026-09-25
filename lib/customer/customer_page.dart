import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class customerhomepage extends StatelessWidget {
  const customerhomepage({super.key});

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Customer Home"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => logout(context),
          )
        ],
      ),
      body: const Center(
        child: Text(
          "Welcome Customer 🍔",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
