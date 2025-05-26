import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reci_p/domain/entities/recipe.dart';
import 'package:reci_p/domain/repositories/recipe_repository.dart';
import 'package:reci_p/presentation/features/recipe_details/bloc/recipe_details_bloc.dart';
import 'package:reci_p/presentation/features/recipe_details/bloc/recipe_details_event.dart';
import 'package:reci_p/presentation/features/recipe_details/bloc/recipe_details_state.dart';
import 'package:reci_p/presentation/routes.dart';

class RecipeDetailsScreen extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailsScreen({Key? key, required this.recipe}) : super(key: key);

  @override
  _RecipeDetailsScreenState createState() => _RecipeDetailsScreenState();
}

class _RecipeDetailsScreenState extends State<RecipeDetailsScreen> {
  late RecipeDetailsBloc _recipeDetailsBloc;

  @override
  void initState() {
    super.initState();
    _recipeDetailsBloc = RecipeDetailsBloc(
      recipeRepository: RepositoryProvider.of<RecipeRepository>(context),
    )..add(FetchRecipeDetails(recipeId: widget.recipe.id));
  }

  @override
  void dispose() {
    _recipeDetailsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RecipeDetailsBloc>.value(
      value: _recipeDetailsBloc,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.recipe.name),
        ),
        body: BlocBuilder<RecipeDetailsBloc, RecipeDetailsState>(
          builder: (context, state) {
            if (state is RecipeDetailsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is RecipeDetailsLoaded) {
              final recipe = state.recipe;
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    recipe.imageUrl.isNotEmpty
                        ? Image.network(
                      recipe.imageUrl,
                      height: 250,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                        : Container(
                      height: 250,
                      width: double.infinity,
                      color: Colors.grey[200],
                      child:
                      Icon(Icons.image, size: 60, color: Colors.grey[400]),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        recipe.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Cuisine: ${recipe.cuisineType}'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Cooking Time: ${recipe.cookingTime} minutes'),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Ingredients:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: recipe.ingredients.length,
                      itemBuilder: (context, index) {
                        final ingredient = recipe.ingredients[index];
                        final quantity = ingredient.amount != null
                            ? ' - ${ingredient.amount}'
                            : '';
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          child: Text('• ${ingredient.name}$quantity'),
                        );
                      },
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Instructions:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: recipe.instructions.length,
                      itemBuilder: (context, index) {
                        final instruction = recipe.instructions[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          child: Text('${index + 1}. $instruction'),
                        );
                      },
                    ),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.cookingMode,
                              arguments: recipe);
                        },
                        child: const Text('Start Cooking'),
                      ),
                    ),
                    BlocBuilder<RecipeDetailsBloc, RecipeDetailsState>(
                      builder: (context, state) {
                        if (state is RecipeDetailsLoaded) {
                          return IconButton(
                            icon: Icon(
                              state.isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: state.isFavorite ? Colors.red : null,
                            ),
                            onPressed: () {
                              _recipeDetailsBloc.add(ToggleFavoriteStatus(state.recipe));
                            },
                          );
                        }
                        return Container();
                      },
                    )
                  ],
                ),
              );
            } else if (state is RecipeDetailsError) {
              return Center(child: Text(state.error));
            } else {
              return const Center(child: Text('Something went wrong.'));
            }
          },
        ),
      ),
    );
  }
}