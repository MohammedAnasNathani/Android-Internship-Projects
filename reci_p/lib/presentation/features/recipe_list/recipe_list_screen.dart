// recipe_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reci_p/domain/repositories/recipe_repository.dart';
import 'package:reci_p/presentation/components/recipe_card.dart';
import 'package:reci_p/presentation/features/recipe_list/bloc/recipe_list_bloc.dart';
import 'package:reci_p/presentation/features/recipe_list/bloc/recipe_list_event.dart';
import 'package:reci_p/presentation/features/recipe_list/bloc/recipe_list_state.dart';
import 'package:reci_p/presentation/routes.dart';

class RecipeListScreen extends StatelessWidget {
  const RecipeListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final recipeRepository = RepositoryProvider.of<RecipeRepository>(context);

    return BlocProvider<RecipeListBloc>(
      create: (context) => RecipeListBloc(recipeRepository: recipeRepository)
        ..add(FetchRecipes(ingredients: [])),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Recipe List'),
        ),
        body: BlocBuilder<RecipeListBloc, RecipeListState>(
          builder: (context, state) {
            if (state is RecipeListLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is RecipeListLoaded) {
              return ListView.builder(
                itemCount: state.recipes.length,
                itemBuilder: (context, index) {
                  final recipe = state.recipes[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.recipeDetails,
                          arguments: recipe);
                    },
                    child: RecipeCard(recipe: recipe),
                  );
                },
              );
            } else if (state is RecipeListError) {
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