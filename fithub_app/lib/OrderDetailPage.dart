import 'package:flutter/material.dart';
import './model/order.dart';

class OrderDetailPage extends StatelessWidget {
  final Order order; // Use your Order class here

  OrderDetailPage({this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Order ID: ${order.orderId}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text('Date: ${order.timestamp.toString()}'),
            Divider(thickness: 2),
            Text(
              'Items',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              itemCount: order.items.length,
              itemBuilder: (context, index) {
                final item = order.items[index];
                return ListTile(
                  leading: Image.asset(
                    'images/${item.imagePath}', // Use the correct image path here
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(item.itemName),
                  subtitle: Text('Price: ${item.itemPrice}'),
                  trailing: Text('Quantity: ${item.quantity}'),
                );
              },
            ),
            Divider(thickness: 2),
            Text(
              'Total: \$${calculateOrderTotal(order).toStringAsFixed(2)}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  double calculateOrderTotal(Order order) {
    double total = 0.0;
    order.items.forEach((item) {
      double price = double.parse(item.itemPrice.replaceAll('\$', ''));
      total += price * item.quantity;
    });
    return total;
  }
}
