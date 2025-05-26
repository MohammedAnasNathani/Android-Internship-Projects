import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reci_p/domain/entities/recipe.dart';
import 'package:reci_p/domain/usecases/add_recipe_to_favorites.dart';
import 'package:reci_p/domain/usecases/get_recipe_details.dart';
import 'package:reci_p/domain/repositories/recipe_repository.dart';
import 'package:reci_p/domain/usecases/remove_recipe_from_favorites.dart';
import 'package:reci_p/presentation/features/recipe_details/bloc/recipe_details_event.dart';
import 'package:reci_p/presentation/features/recipe_details/bloc/recipe_details_state.dart';
import 'package:reci_p/data/datasources/favorites_datasource.dart';

class RecipeDetailsBloc extends Bloc<RecipeDetailsEvent, RecipeDetailsState> {
  final GetRecipeDetails _getRecipeDetails;
  final AddRecipeToFavorites _addRecipeToFavorites;
  final RemoveRecipeFromFavorites _removeRecipeFromFavorites;
  final RecipeRepository recipeRepository;
  final FavoritesDataSource _favoritesDataSource = FavoritesDataSource();

  RecipeDetailsBloc({required this.recipeRepository})
      : _getRecipeDetails = GetRecipeDetails(recipeRepository),
        _addRecipeToFavorites = AddRecipeToFavorites(recipeRepository),
        _removeRecipeFromFavorites = RemoveRecipeFromFavorites(recipeRepository),
        super(RecipeDetailsInitial()) {
    on<FetchRecipeDetails>(_onFetchRecipeDetails);
    on<ToggleFavoriteStatus>(_onToggleFavoriteStatus);
  }

  Future<void> _onFetchRecipeDetails(
      FetchRecipeDetails event, Emitter<RecipeDetailsState> emit) async {
    emit(RecipeDetailsLoading());
    try {
      final recipe = await _getRecipeDetails(event.recipeId);
      final isFavorite = await _isRecipeFavorite(recipe.id);
      emit(RecipeDetailsLoaded(recipe: recipe, isFavorite: isFavorite));
    } catch (e) {
      emit(RecipeDetailsError(error: e.toString()));
    }
  }

  Future<bool> _isRecipeFavorite(String recipeId) async {
    final favorites = await _favoritesDataSource.getFavorites();
    return favorites.contains(recipeId);
  }

  Future<void> _onToggleFavoriteStatus(
      ToggleFavoriteStatus event, Emitter<RecipeDetailsState> emit) async {
    if (state is RecipeDetailsLoaded) {
      final currentState = state as RecipeDetailsLoaded;
      try {
        if (currentState.isFavorite) {
          await _removeRecipeFromFavorites(currentState.recipe);
        } else {
          await _addRecipeToFavorites(currentState.recipe);
        }
        emit(currentState.copyWith(isFavorite: !currentState.isFavorite));
      } catch (e) {
        emit(RecipeDetailsError(
            error: 'Failed to update favorite status: ${e.toString()}'));
      }
    }
  }
}