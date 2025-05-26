import 'package:flutter/material.dart';
import 'package:reci_p/domain/entities/recipe.dart';
import 'package:reci_p/presentation/routes.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;

  const RecipeCard({Key? key, required this.recipe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.recipeDetails,
            arguments: recipe,
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: recipe.imageUrl.isNotEmpty
                  ? Image.network(
                recipe.imageUrl,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: Icon(Icons.image, size: 50, color: Colors.grey[400]),
                  );
                },
              )
                  : Container(
                height: 200,
                color: Colors.grey[200],
                child: Icon(Icons.image, size: 50, color: Colors.grey[400]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('Cuisine: ${recipe.cuisineType}'),
                  const SizedBox(height: 4),
                  Text('Cooking Time: ${recipe.cookingTime} minutes'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}