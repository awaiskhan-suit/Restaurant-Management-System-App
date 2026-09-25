import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'AddProductPage.dart';
import 'menu_page.dart';
import 'orders.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ================== HELPERS ==================
  int _countPending(QuerySnapshot<Map<String, dynamic>> snap) {
    return snap.docs.where((d) => d.data()['status'] == 'pending').length;
  }

  int _countDelivered(QuerySnapshot<Map<String, dynamic>> snap) {
    return snap.docs.where((d) => d.data()['status'] == 'delivered').length;
  }

  int _countTodayOrders(QuerySnapshot<Map<String, dynamic>> snap) {
    final today = DateTime.now();

    return snap.docs.where((d) {
      final ts = d.data()['timestamp'];
      if (ts is! Timestamp) return false;
      final date = ts.toDate().toLocal();
      return date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;
    }).length;
  }

  double _todayRevenue(QuerySnapshot<Map<String, dynamic>> snap) {
    final today = DateTime.now();
    double total = 0;

    for (var d in snap.docs) {
      final data = d.data();
      final ts = data['timestamp'];
      final price = data['total'];

      if (ts is! Timestamp) continue;

      final date = ts.toDate().toLocal();
      if (date.year == today.year &&
          date.month == today.month &&
          date.day == today.day) {
        total += (price is int) ? price.toDouble() : (price is double) ? price : 0;
      }
    }

    return total;
  }

  // ================== UI COMPONENTS ==================
  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(.15),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 13)),
              Text(value,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color)),
            ],
          )
        ],
      ),
    );
  }

  Widget _drawerItem(
      IconData icon, String text, VoidCallback onTap, bool active) {
    return ListTile(
      leading: Icon(icon, color: active ? Colors.green : Colors.grey),
      title: Text(text,
          style: TextStyle(
              color: active ? Colors.green : Colors.black,
              fontWeight: active ? FontWeight.bold : FontWeight.normal)),
      onTap: onTap,
    );
  }

  Drawer _drawer() {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.green[900]),
            child: const ListTile(
              leading: Icon(Icons.restaurant, color: Colors.white),
              title: Text("FoodZone Admin",
                  style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
          ),
          _drawerItem(Icons.dashboard, "Dashboard",
                  () => Navigator.pop(context), true),
          _drawerItem(Icons.add, "Add Product", () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AddProductPage()));
          }, false),
          _drawerItem(Icons.menu_book, "Menu", () {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => const MenuPage()));
          }, false),
          _drawerItem(Icons.receipt_long, "Orders", () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AdminOrdersPage()));
          }, false),
        ],
      ),
    );
  }

  // ================== BUILD ==================
  @override
  Widget build(BuildContext context) {
    final ordersStream = _firestore.collection('orders').snapshots();

    return Scaffold(
      drawer: _drawer(),
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: Colors.green[900],
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: StreamBuilder(
          stream: ordersStream,
          builder: (context, snap) {
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final pending = _countPending(snap.data!);
            final delivered = _countDelivered(snap.data!);
            final todayOrders = _countTodayOrders(snap.data!);
            final revenue = _todayRevenue(snap.data!).toStringAsFixed(0);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _statCard("Pending Orders", "$pending",
                      Icons.timelapse, Colors.orange),
                  _statCard("Delivered Orders", "$delivered",
                      Icons.check_circle, Colors.green),
                  _statCard("Today Orders", "$todayOrders",
                      Icons.today, Colors.purple),
                  _statCard(
                      "Today's Sales", "Rs $revenue", Icons.money, Colors.teal),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
