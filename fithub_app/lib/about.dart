import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import 'package:firebase_messaging/firebase_messaging.dart';

class AboutPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  // Function to launch the telephone application
Future<void> sendEmail({
  String name,
  String email,
  String subject,
  String message,
}) async {
  // Define the service ID, template ID, and user ID for EmailJS
  final serviceId = 'service_uxld5ks';
  final templateId = 'template_fctf5fe';
  final userId = '9DkS1yoD0Jc7d8uak';

  // Define the URL for sending the email using EmailJS API
  final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
  
  // Send a POST request to the EmailJS API
  final response = await http.post(
    url,
    headers: {
      'origin': 'http://localhost', // Set the origin for the request
      'Content-Type': 'application/json', // Set the content type to JSON
    },
    body: json.encode({
      'service_id': serviceId,
      'template_id': templateId,
      'user_id': userId,
      'template_params': {
        'user_name': name,
        'user_email': email,
        'user_subject': subject,
        'user_message': message,
      }
    }),
  );
}


  @override
  Widget build(BuildContext context) {
    _firebaseMessaging.requestNotificationPermissions();
    _firebaseMessaging.configure();
    _firebaseMessaging.getToken().then((token) {
      print('FCM Registration Token: $token');
    });
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: 1430,
          child: Stack(
            children: [
              // Background image
              Image.asset(
                'images/login-background.jpg', // Replace with your background image path
                fit: BoxFit.fill,
                width: double.infinity,
                height: 800,
              ),
              // Dark purple transparency overlay
              Container(
                color: Color.fromRGBO(
                  49,
                  0,
                  98,
                  0.1,
                ), // Dark purple transparent color
                width: double.infinity,
                height: double.infinity,
              ),
              // Content
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 0.0),
                    child: Image.asset(
                      'images/fithub_logo.png', // Replace with your logo image path
                      width: 200,
                      height: 170,
                    ),
                  ),
                  SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    height: 50,
                    color: Color.fromRGBO(
                      0,
                      0,
                      0,
                      0.8,
                    ),
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: 8),
                        Text(
                          'About FITHUB',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    color: Color.fromRGBO(
                      0,
                      0,
                      0,
                      0.7,
                    ), // Transparent black with 50% opacity

                    child: Column(
                      children: <Widget>[
                        SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            'Fithub is a health and fitness platform dedicated to helping individuals achieve their wellness goals. We believe that fitness is not just about physical strength, but also about mental and emotional well-being. With our wide range of workout programs, nutrition plans, and expert guidance, we aim to provide a holistic approach to health. Whether you are a beginner or an advanced fitness enthusiast',
                            textDirection: TextDirection.ltr,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: '',
                            ),
                          ),
                        ),
                        SizedBox(height: 25),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            'Fithub is your ultimate fitness companion. Our goal is to make fitness accessible to all, regardless of your schedule or preferences. With our flexible workout options, you can exercise anytime and anywhere. Our collection of workouts includes cardio, strength training, yoga, and more, catering to all fitness levels',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: '',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    width: double.infinity,
                    height: 50,
                    color: Color.fromRGBO(
                      0,
                      0,
                      0,
                      0.8,
                    ),
                  ),
                  Container(
                      width: double.infinity,
                      height: 370,
                      color: Colors.grey[850],
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            'Meet The Developer',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: 18,
                          ),
                          CircleAvatar(
                            backgroundColor: Colors.purpleAccent,
                            radius: 110,
                            child: CircleAvatar(
                              backgroundColor: Colors.purple,
                              radius: 105,
                              child: CircleAvatar(
                                backgroundImage: AssetImage("images/pp.jpg"),
                                radius: 100,
                              ), //CircleAvatar
                            ), //CircleAvatar
                          ), //CircleAvatar
                          SizedBox(
                            height: 18,
                          ),
                          Text("Cho Zhi Xian",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              )),
                          Text("Nanyang Polytechnic Student",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              )),
                          Text("Developer of FitHub",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              )),
                        ],
                      )),
                  SingleChildScrollView(
                    child: Container(
                      height: 420,
                      color: Colors.white,
                      child: Column(
                        children: <Widget>[
                          Container(
                            height: 420,
                            color: Colors.white,
                            child: GridView.count(
                              crossAxisCount: 2,
                              children: [
                                Container(
                                  color: Colors.red,
                                  height: 100,
                                  width: 100,
                                  child: InkWell(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text('Email Us'),
                                            content: SingleChildScrollView(
                                              child: SizedBox(
                                                width: 400,
                                                height: 300,
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    TextField(
                                                      controller:
                                                          _nameController,
                                                      decoration:
                                                          InputDecoration(
                                                        hintText: 'Name',
                                                      ),
                                                    ),
                                                    TextField(
                                                      controller:
                                                          _emailController,
                                                      decoration:
                                                          InputDecoration(
                                                        hintText: 'Your Email',
                                                      ),
                                                    ),
                                                    TextField(
                                                      controller:
                                                          _subjectController,
                                                      decoration:
                                                          InputDecoration(
                                                        hintText:
                                                            'Subject Of The Enquiry',
                                                      ),
                                                    ),
                                                    SingleChildScrollView(
                                                      child: TextField(
                                                        controller:
                                                            _bodyController,
                                                        decoration:
                                                            InputDecoration(
                                                          hintText:
                                                              'Type Here...',
                                                        ),
                                                        maxLines: 4,
                                                        textInputAction:
                                                            TextInputAction
                                                                .newline,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text('Cancel'),
                                              ),
                                              ElevatedButton(
                                                onPressed: () async {
                                                  await sendEmail(
                                                    name: _nameController.text,
                                                    email:
                                                        _emailController.text,
                                                    subject:
                                                        _subjectController.text,
                                                    message:
                                                        _bodyController.text,
                                                  );
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text('Send'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Icon(
                                          Icons.email,
                                          size: 32,
                                          color: Colors.white,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Email Us',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  color: Colors.green,
                                  height: 100,
                                  width: 100,
                                  child: GestureDetector(
                                    onTap: () {
                                      UrlLauncher.launch(
                                          "tel://+6594559849"); 
                                    },
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Icon(
                                          Icons.call,
                                          size: 32,
                                          color: Colors.white,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Call Us',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  color: Colors.blue,
                                  height: 100,
                                  width: 100,
                                  child: GestureDetector(
                                    onTap: () {
                                      UrlLauncher.launch(
                                          "https://www.facebook.com"); 
                                    },
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Image.asset(
                                          'images/facebook_logo.png', 
                                          width: 32,
                                          height: 32,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Facebook',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  color: Colors.yellow[700],
                                  height: 100,
                                  width: 100,
                                  child: GestureDetector(
                                    onTap: () {
                                      UrlLauncher.launch(
                                          "https://www.instagram.com"); 
                                    },
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Image.asset(
                                          'images/instagram_logo.png', 
                                          width: 32,
                                          height: 32,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Instagram',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
