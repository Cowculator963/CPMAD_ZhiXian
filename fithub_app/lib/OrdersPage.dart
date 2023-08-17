import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './model/order.dart';
import 'package:fithub_app/OrderDetailPage.dart';

class OrdersPage extends StatelessWidget {
  final dynamic userData;

  OrdersPage({this.userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Past Orders'),
        backgroundColor: Colors.orange,
      ),
      body: FutureBuilder<List<Order>>(
        future: fetchUserOrders(
            userData.user.uid), // Fetch user orders using the function
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child:
                    CircularProgressIndicator()); // Display loading indicator while fetching data
          } else if (snapshot.hasError) {
            return Center(
                child: Text(
                    'Error fetching orders')); // Display error message if fetching fails
          } else if (snapshot.hasData && snapshot.data.isEmpty) {
            return Center(
                child: Text(
                    'No orders found.')); // Display message if no orders are found
          } else {
            final orders = snapshot.data;
            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return ListTile(
                  title: Text('Order ID: ${order.orderId}'),
                  subtitle: Text('Date: ${order.timestamp.toString()}'),
                  trailing: Text('Total: \$${calculateOrderTotal(order)}'),
                  onTap: () {
                    // Navigate to a detailed order page passing the order details
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderDetailPage(order: order),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }

  // Fetch user orders from Firestore using user ID
  Future<List<Order>> fetchUserOrders(String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .get();

    final orders = snapshot.docs.map((doc) {
      // Extract the data from the Firestore document
      final data = doc.data() as Map<String, dynamic>;

      // Create an 'Order' object for each document
      return Order(
        // Set the 'orderId' property to the Firestore document ID
        orderId: doc.id,

        // Set the 'userId' property using the 'userId' field from Firestore
        userId: data['userId'],

        // Convert Firestore timestamp to a 'DateTime' object for 'timestamp'
        timestamp: data['timestamp'].toDate(),

        // Create a list of 'OrderItem' objects for 'items'
        items: (data['items'] as List<dynamic>).map((item) {
          // Create an 'OrderItem' object for each item in 'items' list
          return OrderItem(
            // Set 'itemName' using 'itemName' field from the item
            itemName: item['itemName'],

            // Set 'itemPrice' using 'itemPrice' field from the item
            itemPrice: item['itemPrice'],

            // Set 'quantity' using 'quantity' field from the item
            quantity: item['quantity'],

            // Set 'imagePath' using 'imagePath' field from the item
            imagePath: item['imagePath'],
          );
        }).toList(),
      );
    }).toList();

    return orders;
  }

  // Calculate total order amount
  String calculateOrderTotal(Order order) {
    double total = 0.0;
    order.items.forEach((item) {
      double price = double.parse(item.itemPrice.replaceAll('\$', ''));
      total += price * item.quantity;
    });
    return total.toStringAsFixed(2);
  }
}
