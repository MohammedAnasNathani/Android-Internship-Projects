import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reci_p/data/repositories/recipe_repository_impl.dart';
import 'package:reci_p/domain/repositories/recipe_repository.dart';
import 'package:reci_p/presentation/routes.dart';
import 'package:reci_p/presentation/theme.dart';
import 'package:reci_p/presentation/features/scan/bloc/scan_bloc.dart';
import 'package:reci_p/presentation/features/recipe_list/bloc/recipe_list_bloc.dart';

class MyApp extends StatelessWidget {
  final RecipeRepository _recipeRepository = RecipeRepositoryImpl();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<RecipeRepository>.value(
      value: _recipeRepository,
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ScanBloc>(
            create: (context) => ScanBloc(recipeRepository: _recipeRepository),
          ),
          BlocProvider<RecipeListBloc>(
            create: (context) => RecipeListBloc(recipeRepository: _recipeRepository),
          ),
        ],
        child: MaterialApp(
          title: 'Reci-P',
          theme: appTheme,
          onGenerateRoute: AppRoutes.generateRoute,
          initialRoute: AppRoutes.home,
        ),
      ),
    );
  }
}