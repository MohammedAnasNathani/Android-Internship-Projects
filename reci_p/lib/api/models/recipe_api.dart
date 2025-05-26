import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:reci_p/api/models/recipe_api_model.dart';

class RecipeApi {
  static const String baseUrl = 'https://api.spoonacular.com';
  static const String apiKey = 'ce4fc60282964c329942b209695714e9';

  Future<List<RecipeApiModel>> getRecipes(List<String> ingredients) async {
    final response = await http.get(
      Uri.parse('$baseUrl/recipes/search?ingredients=${ingredients.join(',')}'),
      headers: {'x-api-key': apiKey},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((recipe) => RecipeApiModel.fromJson(recipe)).toList();
    } else {
      throw Exception('Failed to load recipes from API');
    }
  }

  Future<RecipeApiModel> getRecipeDetails(String recipeId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/recipes/$recipeId'),
      headers: {'x-api-key': apiKey},
    );

    if (response.statusCode == 200) {
      return RecipeApiModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load recipe details from API');
    }
  }
}