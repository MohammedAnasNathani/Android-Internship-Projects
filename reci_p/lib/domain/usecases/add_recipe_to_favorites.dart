import 'package:reci_p/domain/entities/recipe.dart';
import 'package:reci_p/domain/repositories/recipe_repository.dart';

class AddRecipeToFavorites {
  final RecipeRepository repository;

  AddRecipeToFavorites(this.repository);

  Future<void> call(Recipe recipe) async {
    return await repository.addRecipeToFavorites(recipe);
  }
}