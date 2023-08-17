import 'package:flutter/material.dart';
import 'package:fithub_app/CartController.dart';
import 'package:get/get.dart';
import 'cartPage.dart';

class ProductDetailPage extends StatefulWidget {
  final String imgPath;
  final String itemName;
  final String itemPrice;
  final dynamic userData;

  // Constructor to receive necessary data when creating the page
  ProductDetailPage({
    this.imgPath,
    this.itemName,
    this.itemPrice,
    this.userData,
  });

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  @override
  Widget build(BuildContext context) {
    // Print the UID of the user for debugging purposes 
    print(widget.userData.user.uid);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.itemName), // Set the title of the app bar
        backgroundColor: Colors.black, // Set the background color of the app bar
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Display the product image
          Image.asset(
            'images/${widget.imgPath}',
            fit: BoxFit.fitWidth,
          ),
          SizedBox(height: 16.0), // Add some spacing
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              widget.itemName, // Display the product name
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              widget.itemPrice, // Display the product price
              style: TextStyle(fontSize: 16.0),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Product description goes here.', // Display a placeholder description
                style: TextStyle(fontSize: 16.0),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Access the CartController using Get.find()
              CartController cartController = Get.find<CartController>();
              
              // Add the product to the cart
              cartController.addToCart(
                widget.itemName,
                widget.itemPrice,
                widget.imgPath,
              );
              
              // Navigate to the CartPage
              Get.to(
                CartPage(userData: widget.userData),
              );
              
              // Show a snackbar to indicate that the item was added to the cart
              Get.snackbar(
                'Added to Cart',
                'Item added to cart successfully.',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: Text('Add to Cart'), // Button text
          ),
        ],
      ),
    );
  }
}
