import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ExerciseDetailsPage extends StatelessWidget {
  final dynamic exercise;

  ExerciseDetailsPage({this.exercise});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          exercise['name'].toUpperCase(),
          style: TextStyle(
              color: Colors.white), // Change the title text color to white
        ),
        centerTitle: true,
        backgroundColor:
            Colors.black, // Change the app bar background color to black
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: Colors.purple, width: 2), // Set the purple border
            ),
            child: Image.network(
              exercise['gifUrl'],
              width: 500,
              height: 350,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Equipment Needed: ${exercise['equipment']}',
            style: TextStyle(
                fontSize: 18,
                color: Colors.black), // Set the text color to black
          ),
          // Add more exercise details as needed
        ],
      ),
    );
  }
}
