import 'package:reci_p/domain/entities/ingredient.dart';

class Recipe {
  final String id;
  final String name;
  final String imageUrl;
  final List<Ingredient> ingredients;
  final List<String> instructions;
  final int cookingTime;
  final List<String> dietaryTags;
  final String cuisineType;
  final double? rating;

  Recipe({
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

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String,
      ingredients: (json['ingredients'] as List<dynamic>)
          .map((ingredientJson) => Ingredient.fromJson(ingredientJson as Map<String, dynamic>))
          .toList(),
      instructions: (json['instructions'] as List<dynamic>).map((e) => e.toString()).toList(),
      cookingTime: json['cookingTime'] as int,
      dietaryTags: (json['dietaryTags'] as List<dynamic>).map((e) => e.toString()).toList(),
      cuisineType: json['cuisineType'] as String,
      rating: json['rating'] as double?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'ingredients': ingredients.map((ingredient) => ingredient.toJson()).toList(),
      'instructions': instructions,
      'cookingTime': cookingTime,
      'dietaryTags': dietaryTags,
      'cuisineType': cuisineType,
      'rating': rating,
    };
  }
}