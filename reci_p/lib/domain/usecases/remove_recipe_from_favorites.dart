import 'package:reci_p/domain/entities/recipe.dart';
import 'package:reci_p/domain/repositories/recipe_repository.dart';

class RemoveRecipeFromFavorites {
  final RecipeRepository repository;

  RemoveRecipeFromFavorites(this.repository);

  Future<void> call(Recipe recipe) async {
    return await repository.removeRecipeFromFavorites(recipe);
  }
}