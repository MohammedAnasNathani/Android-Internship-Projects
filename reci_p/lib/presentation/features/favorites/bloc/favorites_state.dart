import 'package:equatable/equatable.dart';
import 'package:reci_p/domain/entities/recipe.dart';

abstract class FavoritesState extends Equatable {
  const FavoritesState();

  @override
  List<Object> get props => [];
}

class FavoritesInitial extends FavoritesState {}

class FavoritesLoading extends FavoritesState {}

class FavoritesLoaded extends FavoritesState {
  final List<Recipe> favorites;

  const FavoritesLoaded({required this.favorites});

  @override
  List<Object> get props => [favorites];
}

class FavoritesError extends FavoritesState {
  final String error;

  const FavoritesError({required this.error});

  @override
  List<Object> get props => [error];
}