import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:fithub_app/OrdersPage.dart';
import 'package:fithub_app/managePayment.dart';
import 'package:fithub_app/login.dart';

class ProfilePage extends StatefulWidget {
  final dynamic userData;

  ProfilePage({this.userData});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Controllers for text fields
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController heightController = TextEditingController();

  User user; // Current user
  Future<DocumentSnapshot> userFuture; // Future for retrieving user data
  bool showEditProfile = false; // Flag to control edit profile mode

  // Toggle the edit profile mode
  void toggleEditProfile() {
    setState(() {
      showEditProfile = !showEditProfile;
    });
  }

  @override
  void initState() {
    super.initState();
    user = widget.userData != null ? widget.userData.user : null;

    // Retrieve user data from Firestore
    userFuture = FirebaseFirestore.instance
        .collection('Users')
        .where('Email', isEqualTo: user.email.toLowerCase())
        .get()
        .then((QuerySnapshot querySnapshot) {
      if (querySnapshot.size > 0) {
        return querySnapshot.docs.first;
      } else {
        throw Exception('No data found');
      }
    }).catchError((error) {
      throw Exception('Error retrieving data: $error');
    });
  }

  // Function to build a ListTile
  ListTile buildListTile({
    IconData icon,
    String title,
    bool endIcon = false,
    VoidCallback onPress,
  }) {
    final Color iconColor = Colors.deepPurpleAccent;
    final Color textColor = Colors.white;

    return ListTile(
      onTap: onPress,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: iconColor.withOpacity(0.1),
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyText1.copyWith(color: textColor),
      ),
      trailing: endIcon
          ? Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: Colors.grey.withOpacity(0.1),
              ),
              child: const Icon(LineAwesomeIcons.angle_right,
                  size: 18.0, color: Colors.grey),
            )
          : null,
    );
  }

  // Calculate BMI based on height and weight
  String _calculateBMI(String height, String weight) {
    // Parse height and weight to double, or default to 0.0
    double heightInMeters = double.tryParse(height) ?? 0.0;
    double weightInKg = double.tryParse(weight) ?? 0.0;

    // Convert height from cm to meters
    heightInMeters = heightInMeters / 100;

    // Calculate BMI using the formula: weight (kg) / (height (m) * height (m))
    double bmi = weightInKg / (heightInMeters * heightInMeters);

    // Convert the BMI to a string with 2 decimal places
    String bmiString = bmi.toStringAsFixed(2);

    // Determine the BMI category based on the BMI value
    String category;
    if (bmi < 18.5) {
      category = 'Underweight';
    } else if (bmi >= 18.5 && bmi <= 24.9) {
      category = 'Normal';
    } else if (bmi >= 25 && bmi <= 29.9) {
      category = 'Overweight';
    } else {
      category = 'Obese';
    }

    // Return the BMI value and category as a formatted string
    return '$category';
  }

  // Pick an image from gallery and upload it to Firebase Storage
  Future<void> _pickImageAndUpload() async {
    final pickedImage =
        await ImagePicker().getImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      File imageFile = File(pickedImage.path);
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageReference =
          FirebaseStorage.instance.ref().child(fileName);

      UploadTask uploadTask = storageReference.putFile(imageFile);
      TaskSnapshot storageSnapshot = await uploadTask.whenComplete(() => null);
      String imageUrl = await storageSnapshot.ref.getDownloadURL();

      // Update Firestore document with the new image URL
      FirebaseFirestore.instance
          .collection('Users')
          .where('Email', isEqualTo: user.email.toLowerCase())
          .get()
          .then((QuerySnapshot querySnapshot) {
        if (querySnapshot.size > 0) {
          final documentSnapshot = querySnapshot.docs.first;
          final documentReference = documentSnapshot.reference;

          // Update the 'imageName' field
          documentReference.update({'imageName': imageUrl});
        } else {
          throw Exception('No data found');
        }
      }).catchError((error) {
        throw Exception('Error updating data: $error');
      });
    }
  }

  // Logout function
  void _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      print(e);
    }
  }

  void populateControllersWithUserData(Map<String, dynamic> userData) {
    firstNameController.text = userData['firstName'] ?? '';
    lastNameController.text = userData['lastName'] ?? '';
    weightController.text = userData['weight'] ?? '';
    heightController.text = userData['height'] ?? '';
  }

  void refreshUserData() {
    setState(() {
      userFuture = FirebaseFirestore.instance
          .collection('Users')
          .where('Email', isEqualTo: user.email.toLowerCase())
          .get()
          .then((QuerySnapshot querySnapshot) {
        if (querySnapshot.size > 0) {
          return querySnapshot.docs.first;
        } else {
          throw Exception('No data found');
        }
      }).catchError((error) {
        throw Exception('Error retrieving data: $error');
      });
    });
  }

  // Update user profile data in Firestore
  void updateProfileData() async {
    String firstName = firstNameController.text;
    String lastName = lastNameController.text;
    String weight = weightController.text;
    String height = heightController.text;
    if (firstName.isEmpty ||
        lastName.isEmpty ||
        weight.isEmpty ||
        height.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('All fields are required.'),
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
      return; // Exit the function if any field is empty
    }
    try {
      // Retrieve user document from Firestore
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('Email', isEqualTo: user.email.toLowerCase())
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        String documentId = querySnapshot.docs[0].id;

        // Update user profile data in Firestore
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(documentId)
            .update({
          'firstName': firstName,
          'lastName': lastName,
          'weight': weight,
          'height': height,
        });

        print('Profile data updated'); // Data updated successfully
        toggleEditProfile();
        refreshUserData(); // Refresh the user data
      } else {
        print('No user found'); // No user found with the given email
      }
    } catch (e) {
      print('Error updating profile data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Welcome to Profile',
            style: TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: Colors.grey[900], // Dark grey color
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
          },
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: userFuture,
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
                child: Text('Error: ${snapshot.error}',
                    style: TextStyle(color: Colors.white)));
          }

          if (!snapshot.hasData || !snapshot.data.exists) {
            return Center(
                child: Text('No data found',
                    style: TextStyle(color: Colors.white)));
          }

          final userData = snapshot.data.data();

          return SingleChildScrollView(
            child: Container(
              color: Colors.grey[850],
              width: 500,
              child: Column(
                children: [
                  SizedBox(height: 16),
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      // Display user profile image
                      // CachedNetworkImageProvider helps optimize the loading and caching of the image to improve performance and reduce unnecessary network requests.
                      CircleAvatar(
                        backgroundImage: userData['imageName'] != ""
                            ? CachedNetworkImageProvider(
                                '${userData['imageName']}?${DateTime.now().millisecondsSinceEpoch}',
                              )
                            : AssetImage('images/default.png'),
                        radius: 90,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () async {
                            await _pickImageAndUpload();
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: 35,
                            height: 35,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: Colors.orange[300],
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.black,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Display user name and email
                  SizedBox(height: 20),
                  Text(
                    '${userData['firstName']} ${userData['lastName']}',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  SizedBox(height: 5),
                  Text(
                    '${userData['Email']}',
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 20),

                  // Display user profile details
                  // If not in edit profile mode
                  if (!showEditProfile) ...[
                    Container(
                      width: 300.0, // Set the desired width
                      height: 50.0, // Set the desired height
                      child: ElevatedButton(
                        onPressed: () {
                          toggleEditProfile();
                          populateControllersWithUserData(userData);
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.deepPurpleAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            side: const BorderSide(
                                color: Colors.yellow, width: 5.0),
                          ),
                        ),
                        child: Text(
                          'Edit Profile',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    // Display user health data (height, weight, BMI)
                    Card(
                      margin:
                          EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                      clipBehavior: Clip.antiAlias,
                      color: Colors.grey[850],
                      elevation: 5.0,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 22.0),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                children: <Widget>[
                                  Text(
                                    "Height",
                                    style: TextStyle(
                                      color: Colors.purpleAccent,
                                      fontSize: 22.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5.0,
                                  ),
                                  Text(
                                    "${userData['height']} cm",
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      color: Colors.white,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: <Widget>[
                                  Text(
                                    "Weight",
                                    style: TextStyle(
                                      color: Colors.purpleAccent,
                                      fontSize: 22.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5.0,
                                  ),
                                  Text(
                                    "${userData['weight']} kg",
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      color: Colors.white,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: <Widget>[
                                  Text(
                                    "Your BMI",
                                    style: TextStyle(
                                      color: Colors.purpleAccent,
                                      fontSize: 22.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5.0,
                                  ),
                                  Text(
                                    _calculateBMI(
                                        userData['height'], userData['weight']),
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      color: Colors.white,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30.0,
                    ),

                    // List tiles for navigating to other pages
                    buildListTile(
                      icon: Icons.history,
                      title: 'Past Order',
                      onPress: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => OrdersPage(
                                    userData: widget.userData,
                                  )),
                        );
                      },
                      endIcon: true,
                    ),
                    buildListTile(
                      icon: Icons.account_balance_wallet,
                      title: 'Manage Payment',
                      onPress: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ManagePaymentPage()),
                        );
                      },
                      endIcon: true,
                    ),
                    SizedBox(
                      height: 20.0,
                    ),

                    // Logout button
                    Container(
                      width: 300.0,
                      height: 50.0,
                      child: ElevatedButton(
                        onPressed: () => _logout(context),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.grey[850],
                          side: const BorderSide(
                            width: 2.0,
                            color: Colors.purple,
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                        child: const Text('Log Out'),
                      ),
                      color: Colors.grey[850],
                    ),
                    SizedBox(
                      height: 50.0,
                    ),
                  ] else ...[
                    // Text fields for editing profile details
                    Container(
                      width: 350,
                      height: 75,
                      child: TextField(
                        controller: firstNameController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: Colors.purple),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: Colors.purple),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: Colors.purple),
                          ),
                          hintText: 'First Name',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                    Container(
                      width: 350,
                      height: 75,
                      child: TextField(
                        controller: lastNameController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: Colors.purple),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: Colors.purple),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: Colors.purple),
                          ),
                          hintText: 'Last Name',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                    Container(
                      width: 350,
                      height: 75,
                      child: TextField(
                        controller: weightController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: Colors.purple),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: Colors.purple),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: Colors.purple),
                          ),
                          hintText: 'Weight',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                    Container(
                      width: 350,
                      height: 75,
                      child: TextField(
                        controller: heightController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: Colors.purple),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: Colors.purple),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: Colors.purple),
                          ),
                          hintText: 'Height',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),

                    // Update profile and back buttons
                    Container(
                      width: 300.0, // Set the desired width
                      height: 50.0, // Set the desired height
                      child: ElevatedButton(
                        onPressed: () {
                          updateProfileData();
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.deepPurpleAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            side: const BorderSide(
                                color: Colors.yellow, width: 5.0),
                          ),
                        ),
                        child: Text(
                          'Update Profile',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Container(
                      width: 300.0, // Set the desired width
                      height: 50.0, // Set the desired height
                      child: ElevatedButton(
                        onPressed: () {
                          toggleEditProfile();
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.deepPurpleAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            side: const BorderSide(
                                color: Colors.yellow, width: 5.0),
                          ),
                        ),
                        child: Text(
                          'Back',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    )
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
