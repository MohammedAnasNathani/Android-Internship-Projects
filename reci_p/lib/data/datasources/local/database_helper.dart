import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:reci_p/domain/entities/recipe.dart';
import 'package:reci_p/domain/entities/ingredient.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'reci_p.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE recipes (
        id TEXT PRIMARY KEY,
        name TEXT,
        imageUrl TEXT,
        ingredients TEXT,
        instructions TEXT,
        cookingTime INTEGER,
        dietaryTags TEXT,
        cuisineType TEXT,
        rating REAL
      )
    ''');
  }

  Future<void> insertRecipe(Recipe recipe) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert(
      'recipes',
      {
        'id': recipe.id,
        'name': recipe.name,
        'imageUrl': recipe.imageUrl,
        'ingredients': jsonEncode(recipe.ingredients.map((e) => e.toJson()).toList()),
        'instructions': jsonEncode(recipe.instructions),
        'cookingTime': recipe.cookingTime,
        'dietaryTags': jsonEncode(recipe.dietaryTags),
        'cuisineType': recipe.cuisineType,
        'rating': recipe.rating,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Recipe>> getRecipes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('recipes');
    return List.generate(maps.length, (i) {
      return Recipe(
        id: maps[i]['id'],
        name: maps[i]['name'],
        imageUrl: maps[i]['imageUrl'],
        ingredients: (jsonDecode(maps[i]['ingredients']) as List)
            .map((item) => Ingredient.fromJson(item as Map<String, dynamic>))
            .toList(),
        instructions: (jsonDecode(maps[i]['instructions']) as List).cast<String>(),
        cookingTime: maps[i]['cookingTime'],
        dietaryTags: (jsonDecode(maps[i]['dietaryTags']) as List).cast<String>(),
        cuisineType: maps[i]['cuisineType'],
        rating: maps[i]['rating'],
      );
    });
  }
}