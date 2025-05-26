// recipe_list_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reci_p/domain/usecases/get_recipes.dart';
import 'package:reci_p/presentation/features/recipe_list/bloc/recipe_list_event.dart';
import 'package:reci_p/presentation/features/recipe_list/bloc/recipe_list_state.dart';
import 'package:reci_p/domain/repositories/recipe_repository.dart';

class RecipeListBloc extends Bloc<RecipeListEvent, RecipeListState> {
  final GetRecipes _getRecipes;
  final RecipeRepository recipeRepository;

  RecipeListBloc({required this.recipeRepository})
      : _getRecipes = GetRecipes(recipeRepository),
        super(RecipeListInitial()) {
    on<FetchRecipes>(_onFetchRecipes);
  }

  Future<void> _onFetchRecipes(
      FetchRecipes event, Emitter<RecipeListState> emit) async {
    emit(RecipeListLoading());
    try {
      final recipes = await _getRecipes(event.ingredients);
      emit(RecipeListLoaded(recipes: recipes));
    } catch (e) {
      emit(RecipeListError(error: e.toString()));
    }
  }
}