import 'package:reci_p/domain/entities/recipe.dart';
import 'package:reci_p/domain/repositories/recipe_repository.dart';

class GetRecipes {
  final RecipeRepository repository;

  GetRecipes(this.repository);

  Future<List<Recipe>> call(List<String> ingredients) async {
    return await repository.getRecipes(ingredients);
  }
}