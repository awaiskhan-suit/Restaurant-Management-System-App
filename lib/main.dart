import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'auth/login_page.dart';
import 'admin/admin_dashboard.dart';
import 'auth/signup_page.dart';
import 'customer/customer_home_page.dart';
import 'customer/customer_page.dart';
import 'customer/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
    );
  }
}

/// AuthWrapper safely handles role-based navigation
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // User not logged in → show login page
        if (!snapshot.hasData || snapshot.data == null) {
          return const LoginPaged();
        }

        // User is logged in → get role from Firestore
        final uid = snapshot.data!.uid;
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
          builder: (context, roleSnapshot) {
            // Loading Firestore data
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // If Firestore fails or document is missing, fallback to login
            if (roleSnapshot.hasError || !roleSnapshot.hasData || !roleSnapshot.data!.exists) {
              return const LoginPaged();
            }

            // Safely get role
            final data = roleSnapshot.data!.data() as Map<String, dynamic>?;

            if (data == null || !data.containsKey('role')) {
              return const LoginPaged();
            }

            final role = data['role'] as String? ?? 'customer';

            // Navigate based on role
            if (role == 'admin') {
              return LoginPaged();
            } else {
              return const LoginPaged();
            }
          },
        );
      },
    );
  }
}
