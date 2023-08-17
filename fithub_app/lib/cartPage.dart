import 'package:flutter/material.dart';
import 'package:fithub_app/CartController.dart';
import 'package:get/get.dart';
import 'checkout.dart'; // Import the CheckoutPage
import 'package:cloud_firestore/cloud_firestore.dart';

class CartPage extends StatefulWidget {
  final dynamic userData; // Add this variable to store the user data

  CartPage({this.userData});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final CartController cartController = Get.find<CartController>();
  bool isCartEmpty = false; // Variable to track if the cart is empty

  @override
  void initState() {
    super.initState();
    // Check if the cart is empty when the page is loaded
    checkCartEmpty();
  }

  void checkCartEmpty() {
    setState(() {
      // Set the value of isCartEmpty based on whether the cart is empty or not
      isCartEmpty = cartController.cartItems.isEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    print(widget.userData);
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
      ),
      body: Obx(() {
        return ListView.builder(
          itemCount: cartController.cartItems.length,
          itemBuilder: (context, index) {
            final cartItem = cartController.cartItems.values.toList()[index];
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
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () {
                          cartController.decreaseQuantity(cartItem.itemName);
                        },
                      ),
                      Obx(() => Text('${quantity.value}')),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          cartController.increaseQuantity(cartItem.itemName);
                        },
                      ),
                    ],
                  ),
                ],
              ),
              trailing: IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {
                  cartController.removeFromCart(cartItem.itemName);
                  // Call checkCartEmpty after removing an item from the cart
                  checkCartEmpty();
                },
              ),
            );
          },
        );
      }),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            isCartEmpty // Check if the cart is empty using isCartEmpty variable
                ? ElevatedButton(
                    onPressed: null, // Disable the button when cart is empty
                    child: Text('Check Out'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  )
                : ElevatedButton(
                    onPressed: () {
                      // Navigate to the CheckoutPage
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CheckoutPage(
                              userData:
                                  widget.userData), // Pass the userData here
                        ),
                      );
                    },
                    child: Text('Check Out'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
      ),
    );
  }
}
