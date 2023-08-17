import 'package:flutter/material.dart';
import 'package:awesome_card/awesome_card.dart';
import 'package:fithub_app/model/payment_method.dart'; // Import the PaymentMethod model class.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fithub_app/profile.dart';

class BillingUpdatePage extends StatefulWidget {
  final dynamic userData;

  BillingUpdatePage({this.userData});

  @override
  _BillingUpdatePageState createState() => _BillingUpdatePageState();
}

class _BillingUpdatePageState extends State<BillingUpdatePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(); // Add this key
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController expirationDateController =
      TextEditingController();
  final TextEditingController cvvController = TextEditingController();
  final TextEditingController cardHolderNameController =
      TextEditingController();
  bool _showBackSide = false;

  // Inside the updateBillingCard() method
  void updateBillingCard() {
    if (_formKey.currentState.validate()) {
      String cardNumber = cardNumberController.text;
      String expirationDate = expirationDateController.text;
      String cvv = cvvController.text;
      String cardHolderName = cardHolderNameController.text;

      if (widget.userData != null) {
        PaymentMethod paymentMethod = PaymentMethod(
          cardNumber: cardNumber,
          cardHolderName: cardHolderName,
          expiryDate: expirationDate,
          cvv: cvv,
          email: widget.userData.email,
        );

        FirebaseFirestore.instance
            .collection('billing')
            .doc(widget.userData.uid)
            .collection('payment_methods')
            .add(paymentMethod.toMap())
            .then((docRef) {
          // Successfully added the payment method
          print('Payment method added successfully');
          _scaffoldKey.currentState.showSnackBar(
            SnackBar(
              content: Text('Card has been added successfully'),
            ),
          );
          // Clear the form fields
          clearFields();
          // Navigate back to the profile page
          Navigator.pop(context);
        }).catchError((error) {
          // Failed to add the payment method
          print('Error adding payment method: $error');
          _scaffoldKey.currentState.showSnackBar(
            SnackBar(
              content: Text('Failed to add card. Please try again.'),
            ),
          );
        });
      } else {
        // Handle the case when userData is null or does not contain the necessary information
        print('Error: userData is null or invalid');
      }
    }
  }

  void clearFields() {
    cardNumberController.clear();
    expirationDateController.clear();
    cvvController.clear();
    setState(() {
      _showBackSide = false;
    });
  }

  @override
  void dispose() {
    cardNumberController.dispose();
    expirationDateController.dispose();
    cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(widget.userData.uid);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Add Billing Card', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 200,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: CreditCard(
                      cardNumber: cardNumberController.text,
                      cardExpiry: expirationDateController.text,
                      cardHolderName: cardHolderNameController.text,
                      cvv: cvvController.text,
                      showBackSide: _showBackSide,
                      frontBackground: Container(
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      backBackground: Container(
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  controller:
                      cardHolderNameController, // Use the TextEditingController
                  decoration: InputDecoration(
                    labelText: 'Card Holder Name',
                    labelStyle: TextStyle(color: Colors.black),
                  ),
                  onEditingComplete: () {
                    setState(() {
                      // Update the card holder name
                    });
                  },
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter the card holder name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: cardNumberController,
                  decoration: InputDecoration(
                    labelText: 'Card Number',
                    labelStyle: TextStyle(color: Colors.black),
                  ),
                  onEditingComplete: () {
                    setState(() {
                      // Update the card number
                    });
                  },
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter the card number';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: expirationDateController,
                  decoration: InputDecoration(
                    labelText: 'Expiration Date',
                    labelStyle: TextStyle(color: Colors.black),
                  ),
                  onEditingComplete: () {
                    setState(() {
                      // Update the expiration date
                    });
                  },
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter the expiration date';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: cvvController,
                  decoration: InputDecoration(
                    labelText: 'CVV',
                    labelStyle: TextStyle(color: Colors.black),
                  ),
                  onEditingComplete: () {
                    setState(() {
                      // Update the CVV
                    });
                  },
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter the CVV';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: updateBillingCard,
                  child: Text('Add Billing Card',
                      style: TextStyle(color: Colors.black)),
                  style: ElevatedButton.styleFrom(primary: Colors.orange),
                ),
                SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Show Back Side',
                        style: TextStyle(color: Colors.black)),
                    Switch(
                      value: _showBackSide,
                      onChanged: (value) {
                        setState(() {
                          _showBackSide = value;
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 20.0),
                Center(
                  child: ElevatedButton(
                    onPressed: clearFields,
                    child: Text('Clear Fields',
                        style: TextStyle(color: Colors.black)),
                    style: ElevatedButton.styleFrom(primary: Colors.orange),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
