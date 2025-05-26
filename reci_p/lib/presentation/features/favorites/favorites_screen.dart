import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reci_p/domain/repositories/recipe_repository.dart';
import 'package:reci_p/presentation/components/recipe_card.dart';
import 'package:reci_p/presentation/features/favorites/bloc/favorites_bloc.dart';
import 'package:reci_p/presentation/features/favorites/bloc/favorites_event.dart';
import 'package:reci_p/presentation/features/favorites/bloc/favorites_state.dart';
import 'package:reci_p/presentation/routes.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final recipeRepository = RepositoryProvider.of<RecipeRepository>(context);

    return BlocProvider<FavoritesBloc>(
      create: (context) => FavoritesBloc(recipeRepository: recipeRepository)..add(FetchFavorites()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Favorite Recipes'),
        ),
        body: BlocBuilder<FavoritesBloc, FavoritesState>(
          builder: (context, state) {
            if (state is FavoritesLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is FavoritesLoaded) {
              if (state.favorites.isEmpty) {
                return const Center(child: Text('You have no favorite recipes yet.'));
              }
              return ListView.builder(
                itemCount: state.favorites.length,
                itemBuilder: (context, index) {
                  final recipe = state.favorites[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.recipeDetails,
                          arguments: recipe);
                    },
                    child: RecipeCard(recipe: recipe),
                  );
                },
              );
            } else if (state is FavoritesError) {
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