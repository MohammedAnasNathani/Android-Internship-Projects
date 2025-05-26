import 'package:shared_preferences/shared_preferences.dart';

class FavoritesDataSource {
  static const String _favoritesKey = 'favorites';

  Future<List<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_favoritesKey) ?? [];
  }

  Future<void> addFavorite(String recipeId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();
    if (!favorites.contains(recipeId)) {
      favorites.add(recipeId);
      await prefs.setStringList(_favoritesKey, favorites);
    }
  }

  Future<void> removeFavorite(String recipeId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();
    favorites.remove(recipeId);
    await prefs.setStringList(_favoritesKey, favorites);
  }
}