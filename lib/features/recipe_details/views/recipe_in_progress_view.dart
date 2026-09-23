import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/storage/storage_providers.dart';
import '../../../core/storage/storage_repository.dart';
import '../../../core/theme/app_theme.dart';
import '../../recipes/models/recipe_model.dart';
import '../viewmodels/recipe_details_viewmodel.dart';

class RecipeInProgressView extends ConsumerStatefulWidget {
  final String id;
  final RecipeType type;

  const RecipeInProgressView({
    super.key,
    required this.id,
    required this.type,
  });

  @override
  ConsumerState<RecipeInProgressView> createState() => _RecipeInProgressViewState();
}

class _RecipeInProgressViewState extends ConsumerState<RecipeInProgressView> {
  final Set<String> _checkedIngredients = {};
  bool _initialized = false;

  void _initStepsOnce(List<IngredientItem> ingredients) {
    if (_initialized) return;
    final storage = ref.read(storageRepositoryProvider);
    final saved = storage.getInProgressSteps(widget.id);
    _checkedIngredients.addAll(saved);
    _initialized = true;
  }

  void _toggleStep(String item, List<IngredientItem> all) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_checkedIngredients.contains(item)) {
        _checkedIngredients.remove(item);
      } else {
        _checkedIngredients.add(item);
      }
    });

    final storage = ref.read(storageRepositoryProvider);
    storage.saveInProgressSteps(widget.id, _checkedIngredients.toList());
  }

  @override
  Widget build(BuildContext context) {
    final detailsAsync = ref.watch(
      recipeDetailsProvider(RecipeDetailsParam(id: widget.id, type: widget.type)),
    );
    final favoritesNotifier = ref.read(favoritesProvider.notifier);
    final isFav = ref.watch(favoritesProvider.select(
      (list) => list.any((r) => r.id == widget.id && r.type == widget.type),
    ));

    return detailsAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Modo Preparo')),
        body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      ),
      error: (err, stack) => Scaffold(
        appBar: AppBar(title: const Text('Modo Preparo')),
        body: const Center(child: Text('Erro ao carregar dados da receita.')),
      ),
      data: (state) {
        final recipe = state.recipe;
        if (recipe == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Modo Preparo')),
            body: const Center(child: Text('Receita não encontrada.')),
          );
        }

        _initStepsOnce(recipe.ingredients);

        final totalSteps = recipe.ingredients.length;
        final completedSteps = _checkedIngredients.length;
        final progress = totalSteps > 0 ? (completedSteps / totalSteps).clamp(0.0, 1.0) : 1.0;
        final isAllDone = totalSteps > 0 && completedSteps == totalSteps;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Em Progresso'),
            actions: [
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  SharePlus.instance.share(
                    ShareParams(text: 'Estou preparando ${recipe.name} no GourmetLab!'),
                  );
                },
              ),
              IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? AppColors.accent : Colors.white,
                ),
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  favoritesNotifier.toggle(recipe);
                },
              ),
            ],
          ),
          body: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: recipe.thumbUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            recipe.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '$completedSteps de $totalSteps passos',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                '${(progress * 100).toInt()}%',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: isAllDone ? AppColors.success : AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isAllDone ? AppColors.success : AppColors.accent,
                              ),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Text(
                      'Marque os ingredientes utilizados:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: recipe.ingredients.length,
                        separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.border),
                        itemBuilder: (context, index) {
                          final item = recipe.ingredients[index];
                          final isChecked = _checkedIngredients.contains(item.ingredient);

                          return CheckboxListTile(
                            value: isChecked,
                            onChanged: (_) => _toggleStep(item.ingredient, recipe.ingredients),
                            activeColor: AppColors.primary,
                            title: Text(
                              item.displayText,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isChecked ? FontWeight.normal : FontWeight.w600,
                                color: isChecked ? AppColors.textMuted : AppColors.textPrimary,
                                decoration: isChecked ? TextDecoration.lineThrough : null,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Instruções de Preparo:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        recipe.instructions,
                        style: const TextStyle(fontSize: 14, height: 1.6, color: AppColors.textPrimary),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: isAllDone
                      ? () async {
                          HapticFeedback.heavyImpact();
                          await ref.read(doneRecipesProvider.notifier).addDone(recipe);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('🎉 Parabéns! Receita finalizada com sucesso!'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                            context.go('/done-recipes');
                          }
                        }
                      : null,
                  icon: const Icon(Icons.check_circle),
                  label: const Text('FINALIZAR RECEITA'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isAllDone ? AppColors.success : Colors.grey[400],
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
