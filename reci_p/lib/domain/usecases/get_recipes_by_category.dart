import 'package:reci_p/domain/entities/recipe.dart';
import 'package:reci_p/domain/repositories/recipe_repository.dart';

class GetRecipesByCategory {
  final RecipeRepository repository;

  GetRecipesByCategory(this.repository);

  Future<List<Recipe>> call(String category) async {
    return await repository.getRecipesByCategory(category);
  }
}