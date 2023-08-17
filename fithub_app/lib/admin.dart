import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fithub_app/login.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  CollectionReference products =
      FirebaseFirestore.instance.collection('Products');

  TextEditingController _nameController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  TextEditingController _detailsController = TextEditingController();
  TextEditingController _imageController = TextEditingController();

  void _logout() {
    // Perform any logout-related actions here, such as clearing session, etc.
    // Navigate back to the login page
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _detailsController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  void _addProduct() async {
    String name = _nameController.text;
    double price = double.tryParse(_priceController.text);
    String details = _detailsController.text;
    String imageName = _imageController.text;

    if (name.isEmpty || price == null || details.isEmpty || imageName.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Please fill in all fields.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    try {
      await products.add({
        'Name': name,
        'Price': price,
        'Details': details,
        'imageName': imageName,
      });
      print('Product added to Firestore');
      // Show a success message or navigate to a different page
    } catch (e) {
      print('Error adding product to Firestore: $e');
      // Show an error message or handle the error
    }

    // Clear the text fields after adding the product
    _nameController.clear();
    _priceController.clear();
    _detailsController.clear();
    _imageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Page'),
        leading: IconButton(
          icon: Icon(Icons.logout),
          onPressed: _logout,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Product Name',
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Price',
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _detailsController,
                decoration: InputDecoration(
                  labelText: 'Details',
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _imageController,
                decoration: InputDecoration(
                  labelText: 'Image Name (e.g., example.jpg or example.png)',
                ),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _addProduct,
                child: Text('Add Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
