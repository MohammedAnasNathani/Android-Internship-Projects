import 'package:equatable/equatable.dart';
import 'package:reci_p/domain/entities/recipe.dart';

abstract class RecipeDetailsState extends Equatable {
  const RecipeDetailsState();

  @override
  List<Object> get props => [];
}

class RecipeDetailsInitial extends RecipeDetailsState {}

class RecipeDetailsLoading extends RecipeDetailsState {}

class RecipeDetailsLoaded extends RecipeDetailsState {
  final Recipe recipe;
  final bool isFavorite;

  const RecipeDetailsLoaded(
      {required this.recipe, this.isFavorite = false});

  RecipeDetailsLoaded copyWith({Recipe? recipe, bool? isFavorite}) {
    return RecipeDetailsLoaded(
      recipe: recipe ?? this.recipe,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  List<Object> get props => [recipe, isFavorite];
}

class RecipeDetailsError extends RecipeDetailsState {
  final String error;

  const RecipeDetailsError({required this.error});

  @override
  List<Object> get props => [error];
}