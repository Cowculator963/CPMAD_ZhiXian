import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class RecipeDetail extends StatefulWidget {
  final String mealName;

  RecipeDetail({this.mealName});

  @override
  _RecipeDetailState createState() => _RecipeDetailState();
}

class _RecipeDetailState extends State<RecipeDetail> {
  final Map<int, bool> checkedParagraphs = {};

  Future<Map<String, dynamic>> fetchMealDetails(String mealName) async {
    final formattedMealName = mealName.replaceAll(' ', '%20');
    final response = await http.get(
      Uri.parse(
          'https://www.themealdb.com/api/json/v1/1/search.php?s=$formattedMealName'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['meals'] != null && data['meals'].isNotEmpty) {
        return data['meals'][0];
      }
    }
    throw Exception('Failed to fetch meal details');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recipe Detail'),
        backgroundColor: Colors.purple,
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchMealDetails(widget.mealName),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to fetch meal details'));
          } else if (snapshot.hasData) {
            final meal = snapshot.data;
            final mealInstructions =
                meal['strInstructions'].replaceAll('\r\n', '\n\n');
            final mealImage = meal['strMealThumb'];
            final mealVideoUrl = meal['strYoutube'];
            final mealIngredients = [
              meal['strIngredient1'],
              meal['strIngredient2'],
              meal['strIngredient3'],
              meal['strIngredient4'],
              meal['strIngredient5'],
              meal['strIngredient6'],
              meal['strIngredient7'],
              meal['strIngredient8'],
              meal['strIngredient9'],
              meal['strIngredient10'],
              meal['strIngredient11'],
              meal['strIngredient12'],
              meal['strIngredient13'],
              meal['strIngredient14'],
              meal['strIngredient15'],
              meal['strIngredient16'],
              meal['strIngredient17'],
              meal['strIngredient18'],
              meal['strIngredient19'],
              meal['strIngredient20'],
            ];

            // Remove empty ingredients
            final ingredients = mealIngredients
                .where(
                    (ingredient) => ingredient != null && ingredient.isNotEmpty)
                .toList();

            // Split mealInstructions into paragraphs
            final paragraphs = mealInstructions.split('\n\n');

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 16.0),
                  YoutubePlayer(
                    controller: YoutubePlayerController(
                      initialVideoId:
                          YoutubePlayer.convertUrlToId(mealVideoUrl),
                      flags: YoutubePlayerFlags(
                        autoPlay: false,
                        mute: false,
                      ),
                    ),
                    showVideoProgressIndicator: true,
                    progressIndicatorColor: Colors.blueAccent,
                    progressColors: ProgressBarColors(
                      playedColor: Colors.blue,
                      handleColor: Colors.blueAccent,
                    ),
                    onReady: () {
                      // Add your custom logic when the video is ready to play.
                    },
                  ),
                  SizedBox(height: 16.0),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Ingredients:',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: ingredients.length,
                    itemBuilder: (context, index) {
                      final ingredient = ingredients[index];
                      final ingredientMeasure = meal['strMeasure${index + 1}'];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text('${index + 1}'),
                        ),
                        title: Text('$ingredient ($ingredientMeasure)'),
                      );
                    },
                  ),
                  SizedBox(height: 16.0),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Steps:',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: paragraphs.length,
                    itemBuilder: (context, index) {
                      final paragraph = paragraphs[index];
                      final paragraphIndex = index + 1;
                      return CheckboxListTile(
                        title: Text(paragraph),
                        value: checkedParagraphs[paragraphIndex] ?? false,
                        onChanged: (bool newValue) {
                          setState(() {
                            checkedParagraphs[paragraphIndex] = newValue;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                      );
                    },
                  ),
                  SizedBox(height: 16.0),
                ],
              ),
            );
          } else {
            return Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}
