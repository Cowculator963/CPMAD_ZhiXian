import 'package:flutter/material.dart';
import 'package:fithub_app/login.dart';
import 'about.dart';
import 'merch.dart';
import 'profile.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:fithub_app/legMuscle.dart';
import 'package:fithub_app/bicepMuscle.dart';
import 'package:fithub_app/backMuscle.dart';
import 'package:fithub_app/recipe.dart';
import 'package:fithub_app/CartController.dart';
import 'package:fithub_app/cartPage.dart';

class HomePage extends StatefulWidget {
  final dynamic userData;
  const HomePage({this.userData});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CartController cartController = Get.put(CartController());

  // Initialize the selected page index
  int _currentIndex = 0;
  
  // List of pages in the bottom navigation
  final List<Widget> _pages = [
    HomePageWidget(),
    AboutPage(),
    MerchPage(),
    ProfilePage(),
  ];

  // Get the appropriate page widget based on the selected index
  Widget _getPage(int index) {
    if (index >= 0 && index < _pages.length) {
      return _pages[index];
    }
    return Container(
      child: Text('Error'),
    ); // Return an empty container if index is out of range
  }

  @override
  Widget build(BuildContext context) {
    print(widget.userData.user.uid);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Welcome',
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CartPage(
                              userData: widget.userData,
                            )),
                  );
                },
              ),
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
          icon: Icon(Icons.logout),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          },
        ),
      ),
      body: _getPage(_currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        selectedIconTheme: IconThemeData(color: Colors.orange[900]),
        unselectedIconTheme: IconThemeData(color: Colors.black),
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 3) {
            Get.to(() => ProfilePage(userData: widget.userData));
          } else if (index == 2) {
            Get.to(() => MerchPage(userData: widget.userData));
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: Colors.orange[400],
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'About',
            backgroundColor: Colors.orange[200],
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Merch',
            backgroundColor: Colors.orange[300],
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
            backgroundColor: Colors.orange[400],
          ),
        ],
      ),
    );
  }
}

class HomePageWidget extends StatelessWidget {
  // List of images for the carousel slider
  List<String> imageList = [
    'images/carousel1.jpg',
    'images/carousel2.jpg',
    'images/carousel3.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      // Decorate the container with background image and color overlay
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('images/home-background.jpg'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.6),
            BlendMode.srcATop,
          ),
        ),
      ),
      child: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              // Create a carousel slider for images
              CarouselSlider(
                options: CarouselOptions(
                  aspectRatio: 6 / 3,
                  height: 175,
                  autoPlay: true,
                  autoPlayInterval: Duration(
                      seconds: 3), // Adjust the interval between slides
                  pauseAutoPlayOnTouch: true,
                  enlargeCenterPage: true,
                  enableInfiniteScroll: true,
                ),
                items: imageList.map((imagePath) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                        ),
                        child: Image.asset(
                          imagePath,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: 30),
              Text(
                "Workouts",
                style: TextStyle(
                    color: Colors.orange,
                    fontSize: 25,
                    fontFamily: 'xian',
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              // Build rounded boxes for different workout categories
              _buildRoundedBox(
                context,
                'Back Muscle',
                'images/back-muscle.jpg',
                BackMusclePage(),
              ),
              SizedBox(height: 30),
              _buildRoundedBox(context, 'Bicep Muscle',
                  'images/bicep-muscle.jpg', BicepMusclePage()),
              SizedBox(height: 30),
              _buildRoundedBox(context, 'Leg Muscle', 'images/leg-muscle.jpg',
                  LegMusclePage()),
              SizedBox(height: 30),
              Text(
                "Recipe",
                style: TextStyle(
                    color: Colors.orange,
                    fontSize: 25,
                    fontFamily: 'xian',
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              // Build rounded box for the recipe category
              _buildRoundedBox(context, 'Healthy Cooking', 'images/recipe.jpg',
                  RecipePage()),
              SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  // Build a rounded box for workout/recipe categories
  Widget _buildRoundedBox(
      BuildContext context, String text, String imagePath, Widget page) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black),
          color: Colors.black.withOpacity(0.6),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              imagePath,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 120,
            ),
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.purple,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 21,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
