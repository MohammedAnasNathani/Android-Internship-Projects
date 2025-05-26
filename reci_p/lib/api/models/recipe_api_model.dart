import 'package:reci_p/domain/entities/ingredient.dart';
import 'package:reci_p/domain/entities/recipe.dart';

class RecipeApiModel {
  final int id;
  final String name;
  final String imageUrl;
  final List<Map<String, dynamic>> ingredients;
  final List<String> instructions;
  final int cookingTime;
  final List<String> dietaryTags;
  final String cuisineType;
  final double? rating;

  RecipeApiModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.ingredients,
    required this.instructions,
    required this.cookingTime,
    required this.dietaryTags,
    required this.cuisineType,
    this.rating,
  });

  factory RecipeApiModel.fromJson(Map<String, dynamic> json) {
    List<String> parsedInstructions = [];
    if (json['analyzedInstructions'] != null && json['analyzedInstructions'].isNotEmpty) {
      var steps = json['analyzedInstructions'][0]['steps'];
      if (steps != null) {
        for (var step in steps) {
          parsedInstructions.add(step['step']);
        }
      }
    }
    return RecipeApiModel(
      id: json['id'],
      name: json['title'],
      imageUrl: json['image'],
      ingredients: (json['extendedIngredients'] as List).cast<Map<String, dynamic>>(),
      instructions: parsedInstructions,
      cookingTime: json['readyInMinutes'],
      dietaryTags: [],
      cuisineType: '',
      rating: json['spoonacularScore']?.toDouble(),
    );
  }

  Recipe toEntity() {
    return Recipe(
      id: id.toString(),
      name: name,
      imageUrl: imageUrl,
      ingredients: ingredients.map((ingredient) => Ingredient.fromJson(ingredient)).toList(),
      instructions: instructions,
      cookingTime: cookingTime,
      dietaryTags: dietaryTags,
      cuisineType: cuisineType,
      rating: rating,
    );
  }
}