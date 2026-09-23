import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../viewmodels/catalog_viewmodel.dart';

class SearchBarWidget extends StatefulWidget {
  final SearchCriteria currentCriteria;
  final Function(SearchCriteria) onCriteriaChanged;
  final Function(String) onSearch;
  final VoidCallback onClose;

  const SearchBarWidget({
    super.key,
    required this.currentCriteria,
    required this.onCriteriaChanged,
    required this.onSearch,
    required this.onClose,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: widget.currentCriteria == SearchCriteria.firstLetter
                        ? 'Digite a primeira letra...'
                        : 'Buscar receita...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                    suffixIcon: _controller.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () {
                              _controller.clear();
                              setState(() {});
                            },
                          )
                        : null,
                  ),
                  onChanged: (val) => setState(() {}),
                  onSubmitted: widget.onSearch,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.textSecondary),
                onPressed: widget.onClose,
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildRadioChip('Nome', SearchCriteria.name),
                const SizedBox(width: 8),
                _buildRadioChip('Ingrediente', SearchCriteria.ingredient),
                const SizedBox(width: 8),
                _buildRadioChip('Primeira Letra', SearchCriteria.firstLetter),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => widget.onSearch(_controller.text),
              icon: const Icon(Icons.search),
              label: const Text('PESQUISAR'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioChip(String label, SearchCriteria criteria) {
    final isSelected = widget.currentCriteria == criteria;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => widget.onCriteriaChanged(criteria),
      selectedColor: AppColors.primary,
      backgroundColor: Colors.grey[100],
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 13,
      ),
    );
  }
}
