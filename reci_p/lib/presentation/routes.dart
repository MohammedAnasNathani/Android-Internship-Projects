import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reci_p/data/repositories/recipe_repository_impl.dart';
import 'package:reci_p/domain/repositories/recipe_repository.dart';
import 'package:reci_p/presentation/features/cooking_mode/cooking_mode_screen.dart';
import 'package:reci_p/presentation/features/favorites/favorites_screen.dart';
import 'package:reci_p/presentation/features/home/home_screen.dart';
import 'package:reci_p/presentation/features/recipe_details/recipe_details_screen.dart';
import 'package:reci_p/presentation/features/recipe_list/recipe_list_screen.dart';
import 'package:reci_p/presentation/features/scan/scan_screen.dart';
import 'package:reci_p/presentation/features/scan/bloc/scan_bloc.dart';
import 'package:reci_p/presentation/features/recipe_list/bloc/recipe_list_bloc.dart';
import 'package:reci_p/domain/entities/recipe.dart';
import 'package:reci_p/presentation/features/recipe_details/bloc/recipe_details_bloc.dart'; // Import RecipeDetailsBloc
import 'package:reci_p/presentation/features/cooking_mode/bloc/cooking_mode_bloc.dart';

class AppRoutes {
  static const String home = '/';
  static const String recipeList = '/recipe_list';
  static const String recipeDetails = '/recipe_details';
  static const String scan = '/scan';
  static const String cookingMode = '/cooking_mode';
  static const String favorites = '/favorites';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final recipeRepository = RecipeRepositoryImpl();

    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case recipeList:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => RecipeListBloc(recipeRepository: recipeRepository),
            child: const RecipeListScreen(),
          ),
          settings: settings,
        );
      case recipeDetails:
        final recipe = settings.arguments as Recipe;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => RecipeDetailsBloc(recipeRepository: recipeRepository),
            child: RecipeDetailsScreen(recipe: recipe),
          ),
        );
      case scan:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => ScanBloc(recipeRepository: recipeRepository),
            child: const ScanScreen(),
          ),
        );
      case cookingMode:
        final recipe = settings.arguments as Recipe;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => CookingModeBloc(recipe: recipe),
            child: CookingModeScreen(recipe: recipe),
          ),
        );
      case favorites:
        return MaterialPageRoute(
          builder: (_) => RepositoryProvider.value(
            value: recipeRepository,
            child: const FavoritesScreen(),
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}