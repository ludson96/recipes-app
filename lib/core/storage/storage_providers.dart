import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/recipes/models/recipe_model.dart';
import 'storage_repository.dart';

class FavoritesNotifier extends Notifier<List<RecipeModel>> {
  @override
  List<RecipeModel> build() {
    final storage = ref.watch(storageRepositoryProvider);
    return storage.getFavorites();
  }

  Future<void> toggle(RecipeModel recipe) async {
    final storage = ref.read(storageRepositoryProvider);
    await storage.toggleFavorite(recipe);
    state = storage.getFavorites();
  }

  bool isFavorite(String id, RecipeType type) {
    return state.any((r) => r.id == id && r.type == type);
  }
}

final favoritesProvider = NotifierProvider<FavoritesNotifier, List<RecipeModel>>(() {
  return FavoritesNotifier();
});

class DoneRecipesNotifier extends Notifier<List<Map<String, dynamic>>> {
  @override
  List<Map<String, dynamic>> build() {
    final storage = ref.watch(storageRepositoryProvider);
    return storage.getDoneRecipes();
  }

  Future<void> addDone(RecipeModel recipe) async {
    final storage = ref.read(storageRepositoryProvider);
    await storage.addDoneRecipe(recipe);
    await storage.clearInProgress(recipe.id);
    state = storage.getDoneRecipes();
  }
}

final doneRecipesProvider = NotifierProvider<DoneRecipesNotifier, List<Map<String, dynamic>>>(() {
  return DoneRecipesNotifier();
});
