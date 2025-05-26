import 'package:reci_p/domain/entities/recipe.dart';
import 'package:reci_p/domain/repositories/recipe_repository.dart';

class GetFavoriteRecipes {
  final RecipeRepository repository;

  GetFavoriteRecipes(this.repository);

  Future<List<Recipe>> call() async {
    return await repository.getFavoriteRecipes();
  }
}