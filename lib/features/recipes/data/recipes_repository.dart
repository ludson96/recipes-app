import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../models/recipe_model.dart';

class RecipesRepository {
  final Dio _mealsDio;
  final Dio _drinksDio;

  RecipesRepository({required Dio mealsDio, required Dio drinksDio})
      : _mealsDio = mealsDio,
        _drinksDio = drinksDio;

  // =================== MEALS API ===================

  Future<List<RecipeModel>> fetchInitialMeals() async {
    try {
      final response = await _mealsDio.get('/search.php?s=');
      final data = response.data['meals'] as List<dynamic>?;
      if (data == null) return [];
      return data.map((json) => RecipeModel.fromMealJson(json)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<RecipeModel>> searchMealsByName(String name) async {
    try {
      final response = await _mealsDio.get('/search.php?s=${Uri.encodeComponent(name)}');
      final data = response.data['meals'] as List<dynamic>?;
      if (data == null) return [];
      return data.map((json) => RecipeModel.fromMealJson(json)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<RecipeModel>> searchMealsByIngredient(String ingredient) async {
    try {
      final response = await _mealsDio.get('/filter.php?i=${Uri.encodeComponent(ingredient)}');
      final data = response.data['meals'] as List<dynamic>?;
      if (data == null) return [];
      return data.map((json) => RecipeModel(
        id: json['idMeal']?.toString() ?? '',
        name: json['strMeal']?.toString() ?? '',
        category: '',
        instructions: '',
        thumbUrl: json['strMealThumb']?.toString() ?? '',
        tags: const [],
        type: RecipeType.meal,
        ingredients: const [],
      )).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<RecipeModel>> searchMealsByFirstLetter(String letter) async {
    try {
      final response = await _mealsDio.get('/search.php?f=${Uri.encodeComponent(letter)}');
      final data = response.data['meals'] as List<dynamic>?;
      if (data == null) return [];
      return data.map((json) => RecipeModel.fromMealJson(json)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<RecipeModel>> fetchMealsByCategory(String category) async {
    try {
      final response = await _mealsDio.get('/filter.php?c=${Uri.encodeComponent(category)}');
      final data = response.data['meals'] as List<dynamic>?;
      if (data == null) return [];
      return data.map((json) => RecipeModel(
        id: json['idMeal']?.toString() ?? '',
        name: json['strMeal']?.toString() ?? '',
        category: category,
        instructions: '',
        thumbUrl: json['strMealThumb']?.toString() ?? '',
        tags: const [],
        type: RecipeType.meal,
        ingredients: const [],
      )).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<String>> fetchMealCategories() async {
    try {
      final response = await _mealsDio.get('/list.php?c=list');
      final data = response.data['meals'] as List<dynamic>?;
      if (data == null) return [];
      return data.map((e) => e['strCategory']?.toString() ?? '').where((s) => s.isNotEmpty).toList();
    } catch (_) {
      return [];
    }
  }

  Future<RecipeModel?> fetchMealById(String id) async {
    try {
      final response = await _mealsDio.get('/lookup.php?i=${Uri.encodeComponent(id)}');
      final data = response.data['meals'] as List<dynamic>?;
      if (data == null || data.isEmpty) return null;
      return RecipeModel.fromMealJson(data[0]);
    } catch (_) {
      return null;
    }
  }

  // =================== DRINKS API ===================

  Future<List<RecipeModel>> fetchInitialDrinks() async {
    try {
      final response = await _drinksDio.get('/search.php?s=');
      final raw = response.data['drinks'];
      if (raw is List<dynamic>) {
        return raw.map((json) => RecipeModel.fromDrinkJson(json)).toList();
      }
      // Fallback
      final fallback = await _drinksDio.get('/search.php?f=a');
      final fallbackData = fallback.data['drinks'] as List<dynamic>?;
      if (fallbackData == null) return [];
      return fallbackData.map((json) => RecipeModel.fromDrinkJson(json)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<RecipeModel>> searchDrinksByName(String name) async {
    try {
      final response = await _drinksDio.get('/search.php?s=${Uri.encodeComponent(name)}');
      final raw = response.data['drinks'];
      if (raw is List<dynamic>) {
        return raw.map((json) => RecipeModel.fromDrinkJson(json)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<List<RecipeModel>> searchDrinksByIngredient(String ingredient) async {
    try {
      final response = await _drinksDio.get('/filter.php?i=${Uri.encodeComponent(ingredient)}');
      final data = response.data['drinks'] as List<dynamic>?;
      if (data == null) return [];
      return data.map((json) => RecipeModel(
        id: json['idDrink']?.toString() ?? '',
        name: json['strDrink']?.toString() ?? '',
        category: '',
        instructions: '',
        thumbUrl: json['strDrinkThumb']?.toString() ?? '',
        tags: const [],
        type: RecipeType.drink,
        ingredients: const [],
      )).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<RecipeModel>> searchDrinksByFirstLetter(String letter) async {
    try {
      final response = await _drinksDio.get('/search.php?f=${Uri.encodeComponent(letter)}');
      final data = response.data['drinks'] as List<dynamic>?;
      if (data == null) return [];
      return data.map((json) => RecipeModel.fromDrinkJson(json)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<RecipeModel>> fetchDrinksByCategory(String category) async {
    try {
      final response = await _drinksDio.get('/filter.php?c=${Uri.encodeComponent(category)}');
      final data = response.data['drinks'] as List<dynamic>?;
      if (data == null) return [];
      return data.map((json) => RecipeModel(
        id: json['idDrink']?.toString() ?? '',
        name: json['strDrink']?.toString() ?? '',
        category: category,
        instructions: '',
        thumbUrl: json['strDrinkThumb']?.toString() ?? '',
        tags: const [],
        type: RecipeType.drink,
        ingredients: const [],
      )).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<String>> fetchDrinkCategories() async {
    try {
      final response = await _drinksDio.get('/list.php?c=list');
      final data = response.data['drinks'] as List<dynamic>?;
      if (data == null) return [];
      return data.map((e) => e['strCategory']?.toString() ?? '').where((s) => s.isNotEmpty).toList();
    } catch (_) {
      return [];
    }
  }

  Future<RecipeModel?> fetchDrinkById(String id) async {
    try {
      final response = await _drinksDio.get('/lookup.php?i=${Uri.encodeComponent(id)}');
      final data = response.data['drinks'] as List<dynamic>?;
      if (data == null || data.isEmpty) return null;
      return RecipeModel.fromDrinkJson(data[0]);
    } catch (_) {
      return null;
    }
  }
}

// Injeção de Dependência limpa via Riverpod
final recipesRepositoryProvider = Provider<RecipesRepository>((ref) {
  final mealsDio = ref.watch(mealsDioProvider);
  final drinksDio = ref.watch(drinksDioProvider);
  return RecipesRepository(mealsDio: mealsDio, drinksDio: drinksDio);
});
