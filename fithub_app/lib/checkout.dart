import 'package:flutter/material.dart';
import 'package:fithub_app/CartController.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fithub_app/managePayment.dart';
import 'package:fithub_app/OrdersPage.dart';

class CheckoutPage extends StatefulWidget {
  final dynamic userData; // Store user data received from previous page

  CheckoutPage({this.userData});

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final CartController cartController = Get.find<CartController>();
  List<String> paymentMethods = [];
  String selectedPaymentMethod;

  // Fetch payment methods for the user from Firebase
  Future<void> fetchPaymentMethods() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('billing')
          .doc(widget.userData.user.uid)
          .collection('payment_methods')
          .get();

      setState(() {
        paymentMethods
            .clear(); // Clear paymentMethods list before adding new items
      });

      // Add each payment method to the paymentMethods list
      for (var doc in snapshot.docs) {
        paymentMethods.add(doc.data()['cardNumber']);
      }
    } catch (error) {
      print('Error fetching payment methods: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.userData != null) {
      fetchPaymentMethods(); // Fetch payment methods when initializing the page
    }
  }

  // Calculate the total amount of items in the cart
  double calculateTotalAmount(Map<String, CartItem> cartItems) {
    double totalAmount = 0.0;

    for (final cartItem in cartItems.values) {
      String cleanPrice = cartItem.itemPrice.replaceAll('\$', '').trim();
      double priceAsDouble = double.tryParse(cleanPrice);

      if (priceAsDouble != null) {
        totalAmount += priceAsDouble * cartItem.quantity.value;
      } else {
        debugPrint('Invalid price format: ${cartItem.itemPrice}');
      }
    }

    return totalAmount;
  }

  // Place an order and store it in Firestore
  Future<void> placeOrder() async {
    try {
      final userId = widget.userData.user.uid;
      final timestamp = DateTime.now();

      final orderData = {
        'userId': userId,
        'timestamp': timestamp,
        'items': cartController.cartItems.values.map((cartItem) {
          return {
            'itemName': cartItem.itemName,
            'itemPrice': cartItem.itemPrice,
            'quantity': cartItem.quantity.value,
            'imagePath': cartItem.imagePath,
          };
        }).toList(),
      };

      await FirebaseFirestore.instance.collection('orders').add(orderData);

      cartController.clearCart();

      Get.snackbar(
        'Order Placed',
        'Your order has been placed successfully.',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Navigate to the OrdersPage after placing the order
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => OrdersPage(userData: widget.userData)),
      );
    } catch (error) {
      print('Error placing order: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    print(widget.userData);
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Order Summary',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),

            // Display cart items in a ListView
            Expanded(
              child: ListView.builder(
                itemCount: cartController.cartItems.length,
                itemBuilder: (context, index) {
                  final cartItem =
                      cartController.cartItems.values.toList()[index];
                  final RxInt quantity =
                      cartController.getQuantity(cartItem.itemName);

                  return ListTile(
                    leading: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('images/' + cartItem.imagePath),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    title: Text(cartItem.itemName),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Price: \$${cartItem.itemPrice.toString()}'),
                        Text('Quantity: ${quantity.value}'),
                      ],
                    ),
                  );
                },
              ),
            ),

            Divider(thickness: 2),

            // Display the total order amount
            Text(
              'Total: \$${calculateTotalAmount(cartController.cartItems).toStringAsFixed(2)}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),

            // DropdownButton to select payment method
            DropdownButton<String>(
              value: selectedPaymentMethod,
              hint: Text("Select Payment Method"),
              items: paymentMethods.map((String method) {
                return DropdownMenuItem<String>(
                  value: method,
                  child: Text(method),
                );
              }).toList(),
              onChanged: (String newValue) {
                setState(() {
                  selectedPaymentMethod = newValue;
                });
              },
            ),

            SizedBox(height: 16),

            // Button to add a payment method if none available
            if (paymentMethods.isEmpty)
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ManagePaymentPage()));
                },
                child: Text('Add Payment Method'),
              ),

            // Button to place the order if a payment method is selected
            if (paymentMethods.isNotEmpty)
              ElevatedButton(
                onPressed: selectedPaymentMethod != null ? placeOrder : null,
                child: Text('Place Order'),
              ),
          ],
        ),
      ),
    );
  }
}
