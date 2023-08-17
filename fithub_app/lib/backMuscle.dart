import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fithub_app/exerciseDetail.dart';

// Function to capitalize the first letter of a string
String capitalizeFirstLetter(String text) {
  return text.substring(0, 1).toUpperCase() + text.substring(1);
}

class BackMusclePage extends StatefulWidget {
  @override
  _BackMusclePageState createState() => _BackMusclePageState();
}

class _BackMusclePageState extends State<BackMusclePage> {
  List<String> equipmentFilters = [];
  List<dynamic> exercisesData = [];
  List<dynamic> filteredExercises = [];

  @override
  void initState() {
    super.initState();
    // Fetch exercises data from API when the page initializes
    fetchExercises();
  }

  // Function to fetch exercises data from the API
  Future<void> fetchExercises() async {
    final response = await http.get(
      Uri.parse('https://exercisedb.p.rapidapi.com/exercises/target/upper%20back'),
      headers: {
        'X-RapidAPI-Key': 'YOUR_RAPIDAPI_KEY', // Replace with your RapidAPI Key
        'X-RapidAPI-Host': 'exercisedb.p.rapidapi.com',
      },
    );

    if (response.statusCode == 200) {
      // API call successful, parse the response body
      final data = json.decode(response.body);
      setState(() {
        exercisesData = data;
        filteredExercises = data;
        equipmentFilters = getEquipmentFilters(data);
      });
    } else {
      // API call failed, handle the error
      throw Exception('Failed to fetch exercises');
    }
  }

  // Function to extract unique equipment filters from exercises data
  List<String> getEquipmentFilters(List<dynamic> exercises) {
    Set<String> filters = Set<String>();
    for (var exercise in exercises) {
      filters.add(exercise['equipment']);
    }
    return filters.toList();
  }

  // Function to apply filter based on selected equipment
  void applyFilter(String filter) {
    setState(() {
      if (filter.isEmpty) {
        filteredExercises = exercisesData;
      } else {
        filteredExercises = exercisesData
            .where((exercise) => exercise['equipment'] == filter)
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<bool> isSelected =
        List.generate(equipmentFilters.length, (index) => false);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.purple, // Set app bar background to purple
        title: Text(
          'Back Muscle Page',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: ToggleButtons(
                isSelected: isSelected,
                color: Colors.white, // Set filter chip text color to white
                borderColor: null,
                borderWidth: 5,
                borderRadius: BorderRadius.circular(10),
                children: List.generate(
                  equipmentFilters.length,
                  (index) => FilterChip(
                    label: Text(
                      equipmentFilters[index],
                      style: TextStyle(
                          color: Colors
                              .white), // Set filter chip text color to white
                    ),
                    selected: isSelected[index],
                    onSelected: (selected) {
                      setState(() {
                        isSelected[index] = selected;
                      });
                      applyFilter(equipmentFilters[index]);
                    },
                    backgroundColor: Colors
                        .purple, // Set filter chip background color to purple
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: Colors.purple,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                onPressed: (int index) {
                  setState(() {
                    isSelected[index] = !isSelected[index];
                  });
                  applyFilter(equipmentFilters[index]);
                },
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Set the desired number of columns here
              ),
              itemCount: filteredExercises.length,
              itemBuilder: (context, index) {
                final exercise = filteredExercises[index];
                final exerciseName = capitalizeFirstLetter(exercise['name']);
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ExerciseDetailsPage(exercise: exercise),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.purple, width: 3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network(
                          exercise['gifUrl'],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                        SizedBox(height: 8),
                        Text(
                          exerciseName,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
