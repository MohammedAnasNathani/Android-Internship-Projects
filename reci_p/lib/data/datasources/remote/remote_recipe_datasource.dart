// remote_recipe_datasource.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:reci_p/domain/entities/recipe.dart';
import 'package:reci_p/api/models/recipe_api_model.dart';

class RemoteRecipeDataSource {
  static const String baseUrl = 'https://api.spoonacular.com';
  static const String apiKey = 'ce4fc60282964c329942b209695714e9';

  Future<List<Recipe>> getRecipes(List<String> ingredients) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/recipes/complexSearch?includeIngredients=${ingredients.join(',')}&apiKey=$apiKey&addRecipeInformation=true&instructionsRequired=true&fillIngredients=true'),
      );

      print("API Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['results'] as List;
        return data
            .map((recipe) => RecipeApiModel.fromJson(recipe).toEntity())
            .toList();
      } else {
        print(
            "Error fetching from remote: ${response.statusCode} - ${response.body}");
        throw Exception(
            'Failed to load recipes from API. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching from remote: $e");
      throw e;
    }
  }

  Future<Recipe> getRecipeDetails(String recipeId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/recipes/$recipeId/information?apiKey=$apiKey'),
      );

      if (response.statusCode == 200) {
        return RecipeApiModel.fromJson(json.decode(response.body))
            .toEntity();
      } else {
        print(
            "Error fetching details from remote: ${response.statusCode} - ${response.body}");
        throw Exception(
            'Failed to load recipe details from API. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching details from remote: $e");
      throw e;
    }
  }

}