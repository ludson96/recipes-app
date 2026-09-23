enum RecipeType { meal, drink }

class IngredientItem {
  final String ingredient;
  final String measure;

  const IngredientItem({required this.ingredient, required this.measure});

  String get displayText =>
      measure.trim().isNotEmpty ? '$ingredient ($measure)' : ingredient;
}

class RecipeModel {
  final String id;
  final String name;
  final String category;
  final String? areaOrGlass;
  final String? alcoholicOrNot;
  final String instructions;
  final String thumbUrl;
  final String? videoUrl;
  final List<String> tags;
  final RecipeType type;
  final List<IngredientItem> ingredients;

  const RecipeModel({
    required this.id,
    required this.name,
    required this.category,
    this.areaOrGlass,
    this.alcoholicOrNot,
    required this.instructions,
    required this.thumbUrl,
    this.videoUrl,
    required this.tags,
    required this.type,
    required this.ingredients,
  });

  factory RecipeModel.fromMealJson(Map<String, dynamic> json) {
    final List<IngredientItem> extractedIngredients = [];
    for (int i = 1; i <= 20; i++) {
      final ingredient = json['strIngredient$i'] as String?;
      final measure = json['strMeasure$i'] as String?;
      if (ingredient != null && ingredient.trim().isNotEmpty) {
        extractedIngredients.add(
          IngredientItem(
            ingredient: ingredient.trim(),
            measure: measure?.trim() ?? '',
          ),
        );
      }
    }

    final tagsRaw = json['strTags'] as String?;
    final tags = tagsRaw != null && tagsRaw.trim().isNotEmpty
        ? tagsRaw.split(',').map((e) => e.trim()).toList()
        : <String>[];

    return RecipeModel(
      id: json['idMeal']?.toString() ?? '',
      name: json['strMeal']?.toString() ?? '',
      category: json['strCategory']?.toString() ?? '',
      areaOrGlass: json['strArea']?.toString(),
      alcoholicOrNot: null,
      instructions: json['strInstructions']?.toString() ?? '',
      thumbUrl: json['strMealThumb']?.toString() ?? '',
      videoUrl: json['strYoutube']?.toString(),
      tags: tags,
      type: RecipeType.meal,
      ingredients: extractedIngredients,
    );
  }

  factory RecipeModel.fromDrinkJson(Map<String, dynamic> json) {
    final List<IngredientItem> extractedIngredients = [];
    for (int i = 1; i <= 15; i++) {
      final ingredient = json['strIngredient$i'] as String?;
      final measure = json['strMeasure$i'] as String?;
      if (ingredient != null && ingredient.trim().isNotEmpty) {
        extractedIngredients.add(
          IngredientItem(
            ingredient: ingredient.trim(),
            measure: measure?.trim() ?? '',
          ),
        );
      }
    }

    return RecipeModel(
      id: json['idDrink']?.toString() ?? '',
      name: json['strDrink']?.toString() ?? '',
      category: json['strCategory']?.toString() ?? '',
      areaOrGlass: json['strGlass']?.toString(),
      alcoholicOrNot: json['strAlcoholic']?.toString(),
      instructions: json['strInstructions']?.toString() ?? '',
      thumbUrl: json['strDrinkThumb']?.toString() ?? '',
      videoUrl: null,
      tags: const [],
      type: RecipeType.drink,
      ingredients: extractedIngredients,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'areaOrGlass': areaOrGlass,
      'alcoholicOrNot': alcoholicOrNot,
      'instructions': instructions,
      'thumbUrl': thumbUrl,
      'videoUrl': videoUrl,
      'tags': tags,
      'type': type.name,
      'ingredients': ingredients
          .map((i) => {'ingredient': i.ingredient, 'measure': i.measure})
          .toList(),
    };
  }

  factory RecipeModel.fromMap(Map<String, dynamic> map) {
    final rawIngredients = (map['ingredients'] as List<dynamic>?) ?? [];
    return RecipeModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      areaOrGlass: map['areaOrGlass'],
      alcoholicOrNot: map['alcoholicOrNot'],
      instructions: map['instructions'] ?? '',
      thumbUrl: map['thumbUrl'] ?? '',
      videoUrl: map['videoUrl'],
      tags: List<String>.from(map['tags'] ?? []),
      type: map['type'] == 'drink' ? RecipeType.drink : RecipeType.meal,
      ingredients: rawIngredients
          .map((e) => IngredientItem(
                ingredient: e['ingredient'] ?? '',
                measure: e['measure'] ?? '',
              ))
          .toList(),
    );
  }
}
