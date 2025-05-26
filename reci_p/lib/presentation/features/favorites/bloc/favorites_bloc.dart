import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reci_p/domain/repositories/recipe_repository.dart';
import 'package:reci_p/domain/usecases/get_favorite_recipes.dart';
import 'package:reci_p/presentation/features/favorites/bloc/favorites_event.dart';
import 'package:reci_p/presentation/features/favorites/bloc/favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final GetFavoriteRecipes _getFavoriteRecipes;
  final RecipeRepository recipeRepository;

  FavoritesBloc({required this.recipeRepository})
      : _getFavoriteRecipes = GetFavoriteRecipes(recipeRepository),
        super(FavoritesInitial()) {
    on<FetchFavorites>(_onFetchFavorites);
  }

  Future<void> _onFetchFavorites(
      FetchFavorites event, Emitter<FavoritesState> emit) async {
    emit(FavoritesLoading());
    try {
      final favorites = await _getFavoriteRecipes();
      emit(FavoritesLoaded(favorites: favorites));
    } catch (e) {
      emit(FavoritesError(error: e.toString()));
    }
  }
}