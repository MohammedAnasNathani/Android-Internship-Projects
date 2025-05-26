// recipe_list_event.dart
import 'package:equatable/equatable.dart';

abstract class RecipeListEvent extends Equatable {
  const RecipeListEvent();

  @override
  List<Object> get props => [];
}

class FetchRecipes extends RecipeListEvent {
  final List<String> ingredients;

  const FetchRecipes({required this.ingredients});

  @override
  List<Object> get props => [ingredients];
}