import 'package:flutter/material.dart';
import 'package:fithub_app/model/payment_method.dart'; // Import the PaymentMethod model class.
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fithub_app/billingAddPage.dart'; // Import the AddPaymentPage if you have one.

// Rest of the code for the ManagePaymentPage...

class ManagePaymentPage extends StatelessWidget {
  final User user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Payment'),
        backgroundColor: Colors.orange,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('billing')
            .doc(user.uid)
            .collection('payment_methods')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error fetching payment methods'));
          } else {
            // Payment methods/cards available, display them in a list
            final paymentMethods = snapshot.data.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return PaymentMethod(
                email: doc.id,
                cardNumber: data['cardNumber'],
                cardHolderName: data['cardHolderName'],
                expiryDate: data['expiryDate'],
              );
            }).toList();

            return Column(
              children: [
                if (paymentMethods.isNotEmpty)
                  Expanded(
                    child: ListView.builder(
                      itemCount: paymentMethods.length,
                      itemBuilder: (context, index) {
                        final paymentMethod = paymentMethods[index];
                        return ListTile(
                          leading: Icon(Icons.credit_card),
                          title: Text(
                              'Card ending in ${paymentMethod.cardNumber.substring(paymentMethod.cardNumber.length - 4)}'),
                          subtitle: Text('Expiry: ${paymentMethod.expiryDate}'),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              // Delete the payment method/card from Firebase
                              FirebaseFirestore.instance
                                  .collection('billing')
                                  .doc(user.uid)
                                  .collection('payment_methods')
                                  .doc(paymentMethod.email)
                                  .delete();
                            },
                          ),
                        );
                      },
                    ),
                  ),
                Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              BillingUpdatePage(userData: user)),
                    );
                  },
                  icon: Icon(Icons.add),
                  label: Text('Add New Card'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.orange, // Set the background color to orange
                  ),
                ),
              ),

              ],
            );
          }
        },
      ),
    );
  }
}
