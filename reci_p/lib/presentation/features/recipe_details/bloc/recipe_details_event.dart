import 'package:equatable/equatable.dart';
import 'package:reci_p/domain/entities/recipe.dart';

abstract class RecipeDetailsEvent extends Equatable {
  const RecipeDetailsEvent();

  @override
  List<Object> get props => [];
}

class FetchRecipeDetails extends RecipeDetailsEvent {
  final String recipeId;

  const FetchRecipeDetails({required this.recipeId});

  @override
  List<Object> get props => [recipeId];
}

class ToggleFavoriteStatus extends RecipeDetailsEvent {
  final Recipe recipe;

  const ToggleFavoriteStatus(this.recipe);

  @override
  List<Object> get props => [recipe];
}