// Import necessary Flutter and package dependencies
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import 'package:fithub_app/support_page.dart';
import 'package:fithub_app/CartController.dart';
import 'package:fithub_app/profile.dart';
import 'package:fithub_app/ProductDetail.dart'; // Import the ProductDetailPage
import 'package:fithub_app/cartPage.dart';

// Create a StatefulWidget for the Merchandise page
class MerchPage extends StatefulWidget {
  final dynamic userData;

  MerchPage({this.userData});
  
  @override
  _MerchPageState createState() => _MerchPageState();
}

// Create the state for the Merchandise page
class _MerchPageState extends State<MerchPage> {
  // Get the CartController using GetX
  final CartController cartController = Get.find<CartController>();
  
  @override
  Widget build(BuildContext context) {
    print(widget.userData.user.uid);
    return Scaffold(
      appBar: AppBar(
        // Title and styling for the AppBar
        title: Text(
          'Welcome',
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        actions: [
          // Shopping cart icon with item count display
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: () {
                  // Navigate to the CartPage when cart icon is pressed
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CartPage(
                              userData: widget.userData,
                            )),
                  );
                },
              ),
              // Show item count on the cart icon using Obx
              Obx(
                () => cartController.cartItems.isNotEmpty
                    ? Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red,
                          ),
                          child: Text(
                            '${cartController.getCartItemCount()}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    : SizedBox.shrink(),
              ),
            ],
          ),
        ],
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_rounded),
            onPressed: () {
              // Navigate back to the previous screen
              Navigator.pop(context);
            }),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Products').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a loading indicator while data is being fetched
            return Center(child: CircularProgressIndicator());
          }

          // Build the grid of products using a GridView.builder
          return GridView.builder(
        // Create the grid layout using SliverGridDelegateWithFixedCrossAxisCount
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,          // Number of items per row (columns)
          childAspectRatio: 0.7,      // Aspect ratio of the grid items
        ),
        // Set the total number of items in the grid
        itemCount: snapshot.data != null ? snapshot.data.docs.length : 0,
        // Define how each grid item should be built
        itemBuilder: (context, index) {
          // Access the document data for the current item from the snapshot
          var doc = snapshot.data != null ? snapshot.data.docs[index] : null;
          // Extract the 'Name' field from the document, default to an empty string
          String name = doc != null ? doc['Name'] : '';
          // Extract the 'Price' field from the document, default to 0.0
          double price = doc != null ? doc['Price'] : 0.0;
          // Extract the 'imageName' field from the document, default to an empty string
          String imagePath = doc != null ? doc['imageName'] : '';


              // Wrap each product in a Hero widget to enable shared element transition
              return Hero(
                tag: 'image$index',
                child: Material(
                  child: InkWell(
                    splashColor: Colors.blueAccent,
                    highlightColor: Colors.blueAccent.withOpacity(1.0),
                    onTap: () {
                      // Navigate to the ProductDetailPage when a product is tapped
                      _navigateToProductDetail(context, imagePath, name, price);
                    },
                    child: _buildGridCards(
                      context,
                      index,
                      imagePath,
                      name,
                      '\$$price',
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the SupportPage when the FloatingActionButton is pressed
          Navigator.push(
            context,
            CupertinoPageRoute(builder: (context) => SupportPage()),
          );
        },
        child: Icon(Icons.support_agent),
      ),
    );
  }

  // Navigate to the ProductDetailPage
  void _navigateToProductDetail(
    BuildContext context,
    String imgPath,
    String itemName,
    double itemPrice,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailPage(
          imgPath: imgPath,
          itemName: itemName,
          itemPrice: '\$$itemPrice',
          userData: widget.userData,
        ),
      ),
    );
  }

  // Build grid cards for products
  Widget _buildGridCards(
    BuildContext context,
    int index,
    String imgPath,
    String itemName,
    String itemPrice,
  ) {
    // Each product card is wrapped in an InkWell for onTap functionality
    return InkWell(
      onTap: () {
        // Navigate to the ProfilePage when a product card is tapped
        Get.to(() => ProfilePage());
      },
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: Colors.purple[700], // Set the desired border color here
            width: 2.0, // Set the desired border width here
          ),
        ),
        child: InkWell(
          onTap: () {
            // Navigate to the ProductDetailPage when a product card is tapped
            _navigateToProductDetail(context, imgPath, itemName,
                double.parse(itemPrice.substring(1)));
          },
          splashColor: Colors.purple,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Display the product image with a BoxDecoration for styling
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('images/' + imgPath),
                        fit: BoxFit.fitWidth,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              // Display product name and price
              Row(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        itemName,
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      itemPrice,
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
