import 'package:reci_p/data/datasources/local/database_helper.dart';
import 'package:reci_p/domain/entities/recipe.dart';

class LocalRecipeDataSource {
  final DatabaseHelper dbHelper;

  LocalRecipeDataSource(this.dbHelper);

  Future<void> cacheRecipes(List<Recipe> recipes) async {
    for (var recipe in recipes) {
      await dbHelper.insertRecipe(recipe);
    }
  }

  Future<List<Recipe>> getCachedRecipes() async {
    return await dbHelper.getRecipes();
  }

  Future<void> addRecipeToFavorites(Recipe recipe) async {
  }

  Future<void> removeRecipeFromFavorites(Recipe recipe) async {
  }

  Future<List<Recipe>> getFavoriteRecipes() async {
    return [];
  }
}