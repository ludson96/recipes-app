import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/storage/storage_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../recipes/models/recipe_model.dart';

class FavoritesView extends ConsumerStatefulWidget {
  const FavoritesView({super.key});

  @override
  ConsumerState<FavoritesView> createState() => _FavoritesViewState();
}

class _FavoritesViewState extends ConsumerState<FavoritesView> {
  String _selectedFilter = 'all'; // 'all', 'meal', 'drink'

  @override
  Widget build(BuildContext context) {
    final favorites = ref.watch(favoritesProvider);
    final filtered = favorites.where((r) {
      if (_selectedFilter == 'meal') return r.type == RecipeType.meal;
      if (_selectedFilter == 'drink') return r.type == RecipeType.drink;
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Receitas Favoritas'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _buildFilterButton('Todas', 'all'),
                const SizedBox(width: 8),
                _buildFilterButton('Comidas', 'meal'),
                const SizedBox(width: 8),
                _buildFilterButton('Bebidas', 'drink'),
              ],
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.favorite_border, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        const Text(
                          'Nenhuma receita favoritada ainda.',
                          style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return _buildFavoriteCard(context, item);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label, String value) {
    final isSelected = _selectedFilter == value;
    return Expanded(
      child: OutlinedButton(
        onPressed: () {
          HapticFeedback.selectionClick();
          setState(() => _selectedFilter = value);
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: isSelected ? AppColors.primary : Colors.white,
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildFavoriteCard(BuildContext context, RecipeModel item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          context.push('/recipe/${item.type.name}/${item.id}');
        },
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              child: CachedNetworkImage(
                imageUrl: item.thumbUrl,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.type == RecipeType.meal
                          ? '${item.areaOrGlass ?? 'Prato'} - ${item.category}'
                          : '${item.alcoholicOrNot ?? 'Drink'} - ${item.category}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.share, color: AppColors.textSecondary, size: 20),
              onPressed: () {
                HapticFeedback.lightImpact();
                SharePlus.instance.share(
                  ShareParams(text: 'Veja minha receita favorita: ${item.name} no GourmetLab!'),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.favorite, color: AppColors.accent, size: 22),
              onPressed: () {
                HapticFeedback.mediumImpact();
                ref.read(favoritesProvider.notifier).toggle(item);
              },
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}
