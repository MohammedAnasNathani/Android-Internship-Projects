import 'package:reci_p/domain/entities/recipe.dart';

abstract class RecipeRepository {
  Future<List<Recipe>> getRecipes(List<String> ingredients);
  Future<Recipe> getRecipeDetails(String recipeId);
  Future<void> addRecipeToFavorites(Recipe recipe);
  Future<void> removeRecipeFromFavorites(Recipe recipe);
  Future<List<Recipe>> getFavoriteRecipes();
}