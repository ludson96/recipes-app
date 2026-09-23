import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/recipes_repository.dart';
import '../models/recipe_model.dart';

enum SearchCriteria { name, ingredient, firstLetter }

class CatalogState {
  final RecipeType currentType;
  final String selectedCategory;
  final String searchQuery;
  final SearchCriteria searchCriteria;
  final bool isSearching;
  final bool isLoading;
  final List<RecipeModel> recipes;
  final List<String> categories;
  final String? errorMessage;

  const CatalogState({
    required this.currentType,
    this.selectedCategory = 'All',
    this.searchQuery = '',
    this.searchCriteria = SearchCriteria.name,
    this.isSearching = false,
    this.isLoading = false,
    this.recipes = const [],
    this.categories = const [],
    this.errorMessage,
  });

  CatalogState copyWith({
    RecipeType? currentType,
    String? selectedCategory,
    String? searchQuery,
    SearchCriteria? searchCriteria,
    bool? isSearching,
    bool? isLoading,
    List<RecipeModel>? recipes,
    List<String>? categories,
    String? errorMessage,
  }) {
    return CatalogState(
      currentType: currentType ?? this.currentType,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      searchCriteria: searchCriteria ?? this.searchCriteria,
      isSearching: isSearching ?? this.isSearching,
      isLoading: isLoading ?? this.isLoading,
      recipes: recipes ?? this.recipes,
      categories: categories ?? this.categories,
      errorMessage: errorMessage,
    );
  }
}

class CatalogViewModel extends Notifier<CatalogState> {
  @override
  CatalogState build() {
    // Carrega dados iniciais assim que o provider é instanciado
    Future.microtask(() => init(RecipeType.meal));
    return const CatalogState(
      currentType: RecipeType.meal,
      isLoading: true,
    );
  }

  RecipesRepository get _repository => ref.read(recipesRepositoryProvider);

  Future<void> init(RecipeType type) async {
    state = state.copyWith(
      currentType: type,
      selectedCategory: 'All',
      searchQuery: '',
      isSearching: false,
      isLoading: true,
      errorMessage: null,
    );

    try {
      final List<RecipeModel> recipes;
      final List<String> categories;

      if (type == RecipeType.meal) {
        final results = await Future.wait([
          _repository.fetchInitialMeals(),
          _repository.fetchMealCategories(),
        ]);
        recipes = results[0] as List<RecipeModel>;
        categories = results[1] as List<String>;
      } else {
        final results = await Future.wait([
          _repository.fetchInitialDrinks(),
          _repository.fetchDrinkCategories(),
        ]);
        recipes = results[0] as List<RecipeModel>;
        categories = results[1] as List<String>;
      }

      state = state.copyWith(
        recipes: recipes,
        categories: ['All', ...categories.take(6)],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Falha ao carregar receitas. Verifique sua conexão.',
      );
    }
  }

  Future<void> selectType(RecipeType type) async {
    if (state.currentType == type) return;
    await init(type);
  }

  Future<void> selectCategory(String category) async {
    if (state.selectedCategory == category) {
      // Toggle off para 'All'
      return selectCategory('All');
    }

    state = state.copyWith(
      selectedCategory: category,
      searchQuery: '',
      isSearching: false,
      isLoading: true,
      errorMessage: null,
    );

    try {
      List<RecipeModel> recipes;
      if (category == 'All') {
        recipes = state.currentType == RecipeType.meal
            ? await _repository.fetchInitialMeals()
            : await _repository.fetchInitialDrinks();
      } else {
        recipes = state.currentType == RecipeType.meal
            ? await _repository.fetchMealsByCategory(category)
            : await _repository.fetchDrinksByCategory(category);
      }

      state = state.copyWith(recipes: recipes, isLoading: false);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao filtrar por categoria.',
      );
    }
  }

  void setSearchCriteria(SearchCriteria criteria) {
    state = state.copyWith(searchCriteria: criteria);
  }

  void toggleSearchMode() {
    state = state.copyWith(
      isSearching: !state.isSearching,
      searchQuery: state.isSearching ? '' : state.searchQuery,
    );
    if (!state.isSearching) {
      // Resetar busca
      selectCategory('All');
    }
  }

  Future<void> executeSearch(String query) async {
    if (query.trim().isEmpty) return;

    if (state.searchCriteria == SearchCriteria.firstLetter && query.trim().length > 1) {
      state = state.copyWith(
        errorMessage: 'Sua busca deve conter apenas 1 (um) caractere!',
      );
      return;
    }

    state = state.copyWith(
      searchQuery: query,
      isLoading: true,
      errorMessage: null,
      selectedCategory: 'All',
    );

    try {
      List<RecipeModel> results = [];
      final isMeal = state.currentType == RecipeType.meal;

      switch (state.searchCriteria) {
        case SearchCriteria.name:
          results = isMeal
              ? await _repository.searchMealsByName(query)
              : await _repository.searchDrinksByName(query);
          break;
        case SearchCriteria.ingredient:
          results = isMeal
              ? await _repository.searchMealsByIngredient(query)
              : await _repository.searchDrinksByIngredient(query);
          break;
        case SearchCriteria.firstLetter:
          results = isMeal
              ? await _repository.searchMealsByFirstLetter(query)
              : await _repository.searchDrinksByFirstLetter(query);
          break;
      }

      if (results.isEmpty) {
        state = state.copyWith(
          recipes: [],
          isLoading: false,
          errorMessage: 'Nenhuma receita encontrada para os critérios informados.',
        );
      } else {
        state = state.copyWith(recipes: results, isLoading: false);
      }
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao realizar a busca.',
      );
    }
  }
}

final catalogViewModelProvider = NotifierProvider<CatalogViewModel, CatalogState>(() {
  return CatalogViewModel();
});
