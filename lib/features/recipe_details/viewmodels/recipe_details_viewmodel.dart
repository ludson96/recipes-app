import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../recipes/data/recipes_repository.dart';
import '../../recipes/models/recipe_model.dart';

class RecipeDetailsState {
  final RecipeModel? recipe;
  final List<RecipeModel> recommendations;
  final bool isLoading;
  final String? errorMessage;

  const RecipeDetailsState({
    this.recipe,
    this.recommendations = const [],
    this.isLoading = true,
    this.errorMessage,
  });

  RecipeDetailsState copyWith({
    RecipeModel? recipe,
    List<RecipeModel>? recommendations,
    bool? isLoading,
    String? errorMessage,
  }) {
    return RecipeDetailsState(
      recipe: recipe ?? this.recipe,
      recommendations: recommendations ?? this.recommendations,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// Parâmetro unificado para a família do provider
class RecipeDetailsParam {
  final String id;
  final RecipeType type;

  const RecipeDetailsParam({required this.id, required this.type});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecipeDetailsParam &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type;

  @override
  int get hashCode => id.hashCode ^ type.hashCode;
}

// Em Riverpod, para providers de família com estado assíncrono simples:
final recipeDetailsProvider =
    FutureProvider.family<RecipeDetailsState, RecipeDetailsParam>((ref, param) async {
  final repo = ref.watch(recipesRepositoryProvider);

  try {
    final RecipeModel? recipe;
    final List<RecipeModel> recommendations;

    if (param.type == RecipeType.meal) {
      recipe = await repo.fetchMealById(param.id);
      final drinks = await repo.fetchInitialDrinks();
      recommendations = drinks.take(6).toList();
    } else {
      recipe = await repo.fetchDrinkById(param.id);
      final meals = await repo.fetchInitialMeals();
      recommendations = meals.take(6).toList();
    }

    if (recipe == null) {
      return const RecipeDetailsState(
        isLoading: false,
        errorMessage: 'Receita não encontrada.',
      );
    }

    return RecipeDetailsState(
      recipe: recipe,
      recommendations: recommendations,
      isLoading: false,
    );
  } catch (_) {
    return const RecipeDetailsState(
      isLoading: false,
      errorMessage: 'Erro ao carregar detalhes da receita.',
    );
  }
});
