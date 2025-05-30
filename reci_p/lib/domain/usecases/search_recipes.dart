import 'package:reci_p/domain/entities/recipe.dart';
import 'package:reci_p/domain/repositories/recipe_repository.dart';

class SearchRecipes {
  final RecipeRepository repository;

  SearchRecipes(this.repository);

  Future<List<Recipe>> call(String query) async {
    return await repository.searchRecipes(query);
  }
}