import 'package:reci_p/data/datasources/local/local_recipe_datasource.dart';
import 'package:reci_p/data/datasources/remote/remote_recipe_datasource.dart';
import 'package:reci_p/domain/entities/recipe.dart';
import 'package:reci_p/domain/repositories/recipe_repository.dart';
import 'package:reci_p/data/datasources/local/database_helper.dart';
import 'package:reci_p/data/datasources/favorites_datasource.dart';

class RecipeRepositoryImpl implements RecipeRepository {
  final RemoteRecipeDataSource _remoteDataSource = RemoteRecipeDataSource();
  final LocalRecipeDataSource _localDataSource =
  LocalRecipeDataSource(DatabaseHelper.instance);
  final FavoritesDataSource _favoritesDataSource = FavoritesDataSource();

  bool hasInternetConnection =
  true;

  @override
  Future<List<Recipe>> getRecipes(List<String> ingredients) async {
    if (hasInternetConnection) {
      try {
        final recipes = await _remoteDataSource.getRecipes(ingredients);
        _localDataSource.cacheRecipes(recipes);
        return recipes;
      } catch (e) {
        print("Error fetching from remote: $e");
        return [];
      }
    } else {
      return _localDataSource.getCachedRecipes();
    }
  }

  @override
  Future<Recipe> getRecipeDetails(String recipeId) async {
    if (hasInternetConnection) {
      try {
        final recipe = await _remoteDataSource.getRecipeDetails(recipeId);
        return recipe;
      } catch (e) {
        print("Error fetching details from remote: $e");
        throw e;
      }
    } else {
      throw UnimplementedError(
          "Offline mode for recipe details not implemented yet.");
    }
  }


  @override
  Future<void> addRecipeToFavorites(Recipe recipe) async {
    await _favoritesDataSource.addFavorite(recipe.id);
  }

  @override
  Future<void> removeRecipeFromFavorites(Recipe recipe) async {
    await _favoritesDataSource.removeFavorite(recipe.id);
  }

  @override
  Future<List<Recipe>> getFavoriteRecipes() async {
    final favoriteIds = await _favoritesDataSource.getFavorites();
    final List<Recipe> favoriteRecipes = [];
    for (String id in favoriteIds) {
      try {
        final recipe = await getRecipeDetails(id);
        favoriteRecipes.add(recipe);
      } catch (e) {
        print("Error fetching favorite recipe details for id $id: $e");
      }
    }
    return favoriteRecipes;
  }

  @override
  Future<List<Recipe>> getRecipesByCategory(String category) {
    throw UnimplementedError();
  }

  @override
  Future<List<Recipe>> searchRecipes(String query) {
    throw UnimplementedError();
  }
}