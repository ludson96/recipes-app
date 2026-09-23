import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/storage/storage_providers.dart';
import '../../../core/theme/app_theme.dart';

class DoneRecipesView extends ConsumerStatefulWidget {
  const DoneRecipesView({super.key});

  @override
  ConsumerState<DoneRecipesView> createState() => _DoneRecipesViewState();
}

class _DoneRecipesViewState extends ConsumerState<DoneRecipesView> {
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final doneRecipes = ref.watch(doneRecipesProvider);
    final filtered = doneRecipes.where((r) {
      if (_selectedFilter == 'meal') return r['type'] == 'meal';
      if (_selectedFilter == 'drink') return r['type'] == 'drink';
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Receitas Concluídas'),
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
                        Icon(Icons.check_circle_outline, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        const Text(
                          'Nenhuma receita concluída ainda.',
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
                      return _buildDoneCard(context, item);
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

  Widget _buildDoneCard(BuildContext context, Map<String, dynamic> item) {
    final isMeal = item['type'] == 'meal';
    final tags = (item['tags'] as List<dynamic>?) ?? [];

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
          context.push('/recipe/${item['type']}/${item['id']}');
        },
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              child: CachedNetworkImage(
                imageUrl: item['thumbUrl'] ?? '',
                width: 110,
                height: 110,
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
                      item['name'] ?? '',
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
                      isMeal
                          ? '${item['areaOrGlass'] ?? 'Prato'} - ${item['category'] ?? ''}'
                          : '${item['alcoholicOrNot'] ?? 'Drink'} - ${item['category'] ?? ''}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 12, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          'Feita em: ${item['doneDate'] ?? ''}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                    if (tags.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 4,
                        children: tags.take(2).map((t) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '#$t',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.share, color: AppColors.textSecondary, size: 20),
              onPressed: () {
                HapticFeedback.lightImpact();
                SharePlus.instance.share(
                  ShareParams(text: 'Eu preparei com sucesso: ${item['name']} pelo app GourmetLab!'),
                );
              },
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}
