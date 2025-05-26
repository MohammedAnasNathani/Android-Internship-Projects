import 'package:reci_p/domain/entities/recipe.dart';
import 'package:reci_p/domain/repositories/recipe_repository.dart';

class GetRecipeDetails {
  final RecipeRepository repository;

  GetRecipeDetails(this.repository);

  Future<Recipe> call(String recipeId) async {
    return await repository.getRecipeDetails(recipeId);
  }
}