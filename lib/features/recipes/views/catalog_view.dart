import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/app_theme.dart';
import '../models/recipe_model.dart';
import '../viewmodels/catalog_viewmodel.dart';
import 'category_chips.dart';
import 'recipe_card.dart';
import 'search_bar_widget.dart';

class CatalogView extends ConsumerWidget {
  const CatalogView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(catalogViewModelProvider);
    final viewModel = ref.read(catalogViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.restaurant,
                color: AppColors.primaryDark,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'GourmetLab',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              state.isSearching ? Icons.search_off : Icons.search,
              color: AppColors.accent,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              viewModel.toggleSearchMode();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Alternador de Abas (Comidas / Bebidas)
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.primaryDark,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTypeButton(
                      context: context,
                      label: 'Pratos & Refeições',
                      icon: Icons.lunch_dining,
                      isSelected: state.currentType == RecipeType.meal,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        viewModel.selectType(RecipeType.meal);
                      },
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: _buildTypeButton(
                      context: context,
                      label: 'Drinks & Coquetéis',
                      icon: Icons.local_bar,
                      isSelected: state.currentType == RecipeType.drink,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        viewModel.selectType(RecipeType.drink);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Barra de Pesquisa Condicional
          if (state.isSearching)
            SearchBarWidget(
              currentCriteria: state.searchCriteria,
              onCriteriaChanged: viewModel.setSearchCriteria,
              onSearch: (q) {
                HapticFeedback.lightImpact();
                viewModel.executeSearch(q);
              },
              onClose: viewModel.toggleSearchMode,
            ),

          const SizedBox(height: 12),

          // Chips de Categorias Horizontais
          if (!state.isSearching) ...[
            CategoryChips(
              categories: state.categories,
              selectedCategory: state.selectedCategory,
              onSelectCategory: (cat) {
                HapticFeedback.selectionClick();
                viewModel.selectCategory(cat);
              },
            ),
            const SizedBox(height: 12),
          ],

          // Grid de Receitas ou Indicador de Carregamento
          Expanded(
            child: _buildContent(context, state, viewModel),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.primaryDark : Colors.white70,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primaryDark : Colors.white,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    CatalogState state,
    CatalogViewModel viewModel,
  ) {
    if (state.isLoading) {
      return _buildSkeletonGrid();
    }

    if (state.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.info_outline, size: 54, color: AppColors.error),
              const SizedBox(height: 12),
              Text(
                state.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => viewModel.selectCategory('All'),
                icon: const Icon(Icons.refresh),
                label: const Text('TENTAR NOVAMENTE'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.recipes.isEmpty) {
      return const Center(
        child: Text(
          'Nenhuma receita encontrada.',
          style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => viewModel.selectCategory(state.selectedCategory),
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 0.76,
        ),
        itemCount: state.recipes.length,
        itemBuilder: (context, index) {
          final recipe = state.recipes[index];
          return RecipeCard(
            recipe: recipe,
            onTap: () {
              HapticFeedback.lightImpact();
              context.push('/recipe/${recipe.type.name}/${recipe.id}');
            },
          );
        },
      ),
    );
  }

  Widget _buildSkeletonGrid() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.76,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }
}
