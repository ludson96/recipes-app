import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/recipes/models/recipe_model.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences deve ser inicializado no main');
});

class StorageRepository {
  final SharedPreferences _prefs;

  StorageRepository(this._prefs);

  static const String _favoritesKey = 'gourmetlab_favorites';
  static const String _doneKey = 'gourmetlab_done_recipes';
  static const String _inProgressKey = 'gourmetlab_in_progress';
  static const String _userKey = 'gourmetlab_user';

  // =================== FAVORITOS ===================

  List<RecipeModel> getFavorites() {
    final raw = _prefs.getStringList(_favoritesKey) ?? [];
    return raw
        .map((str) => RecipeModel.fromMap(jsonDecode(str) as Map<String, dynamic>))
        .toList();
  }

  Future<void> toggleFavorite(RecipeModel recipe) async {
    final favorites = getFavorites();
    final index = favorites.indexWhere((r) => r.id == recipe.id && r.type == recipe.type);

    if (index >= 0) {
      favorites.removeAt(index);
    } else {
      favorites.add(recipe);
    }

    final rawList = favorites.map((r) => jsonEncode(r.toMap())).toList();
    await _prefs.setStringList(_favoritesKey, rawList);
  }

  bool isFavorite(String id, RecipeType type) {
    final favorites = getFavorites();
    return favorites.any((r) => r.id == id && r.type == type);
  }

  // =================== RECEITAS FEITAS ===================

  List<Map<String, dynamic>> getDoneRecipes() {
    final raw = _prefs.getStringList(_doneKey) ?? [];
    return raw.map((str) => jsonDecode(str) as Map<String, dynamic>).toList();
  }

  Future<void> addDoneRecipe(RecipeModel recipe) async {
    final doneList = getDoneRecipes();
    final now = DateTime.now();
    final dateStr = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';

    doneList.removeWhere((item) => item['id'] == recipe.id && item['type'] == recipe.type.name);

    doneList.insert(0, {
      ...recipe.toMap(),
      'doneDate': dateStr,
    });

    final rawList = doneList.map((item) => jsonEncode(item)).toList();
    await _prefs.setStringList(_doneKey, rawList);
  }

  // =================== EM PROGRESSO (CHECKLIST) ===================

  List<String> getInProgressSteps(String recipeId) {
    final raw = _prefs.getString(_inProgressKey);
    if (raw == null) return [];
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final list = map[recipeId] as List<dynamic>?;
      return list?.map((e) => e.toString()).toList() ?? [];
    } catch (_) {
      return [];
    }
  }

  Future<void> saveInProgressSteps(String recipeId, List<String> steps) async {
    Map<String, dynamic> current = {};
    final raw = _prefs.getString(_inProgressKey);
    if (raw != null) {
      try {
        current = jsonDecode(raw) as Map<String, dynamic>;
      } catch (_) {}
    }

    current[recipeId] = steps;
    await _prefs.setString(_inProgressKey, jsonEncode(current));
  }

  Future<void> clearInProgress(String recipeId) async {
    final raw = _prefs.getString(_inProgressKey);
    if (raw == null) return;
    try {
      final current = jsonDecode(raw) as Map<String, dynamic>;
      current.remove(recipeId);
      await _prefs.setString(_inProgressKey, jsonEncode(current));
    } catch (_) {}
  }

  // =================== USUÁRIO / SESSÃO ===================

  String? getUserEmail() {
    return _prefs.getString(_userKey);
  }

  Future<void> saveUser(String email) async {
    await _prefs.setString(_userKey, email);
  }

  Future<void> logout() async {
    await _prefs.remove(_userKey);
  }
}

final storageRepositoryProvider = Provider<StorageRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return StorageRepository(prefs);
});
