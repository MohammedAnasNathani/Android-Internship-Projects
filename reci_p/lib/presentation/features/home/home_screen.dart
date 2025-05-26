// home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reci_p/presentation/features/recipe_list/bloc/recipe_list_bloc.dart';
import 'package:reci_p/presentation/features/recipe_list/bloc/recipe_list_event.dart';
import 'package:reci_p/presentation/routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Reci-P'),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search for recipes...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onSubmitted: (query) {
                  Navigator.pushNamed(context, AppRoutes.recipeList);
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Featured Recipes',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            SizedBox(
              height: 200,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildFeaturedRecipeCard(
                    context,
                    'https://img.spoonacular.com/recipes/715415-312x231.jpg',
                    'Featured Recipe 1',
                  ),
                  _buildFeaturedRecipeCard(
                    context,
                    'https://img.spoonacular.com/recipes/715415-312x231.jpg',
                    'Featured Recipe 2',
                  ),
                  _buildFeaturedRecipeCard(
                    context,
                    'https://img.spoonacular.com/recipes/715415-312x231.jpg',
                    'Featured Recipe 3',
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Recipe Categories',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                padding: const EdgeInsets.all(8.0),
                children: [
                  _buildCategoryCard(context, 'Breakfast', Icons.breakfast_dining),
                  _buildCategoryCard(context, 'Lunch', Icons.lunch_dining),
                  _buildCategoryCard(context, 'Dinner', Icons.dinner_dining),
                  _buildCategoryCard(context, 'Dessert', Icons.cake),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.scan);
              },
              child: const Icon(Icons.camera_alt),
              heroTag: null,
            ),
            SizedBox(height: 10,),
            FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.favorites);
              },
              child: const Icon(Icons.favorite),
              heroTag: null,
            )
          ],
        )
    );
  }

  Widget _buildFeaturedRecipeCard(BuildContext context, String imagePath, String title) {
    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.recipeList);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                  child: Image.network(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: Colors.grey[200],
                        child: Icon(Icons.image, size: 50, color: Colors.grey[400]),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String title, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, AppRoutes.recipeList);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}