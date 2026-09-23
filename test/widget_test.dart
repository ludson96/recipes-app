import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:recipes_app/core/storage/storage_repository.dart';
import 'package:recipes_app/features/recipes/models/recipe_model.dart';
import 'package:recipes_app/main.dart';

void main() {
  testWidgets('GourmetLabApp smoke test and render', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const GourmetLabApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('GourmetLab'), findsWidgets);
    expect(find.text('ENTRAR'), findsOneWidget);
  });

  test('RecipeModel parse Meal JSON with 20 ingredients', () {
    final mockMealJson = {
      'idMeal': '52772',
      'strMeal': 'Teriyaki Chicken Casserole',
      'strCategory': 'Chicken',
      'strArea': 'Japanese',
      'strInstructions': 'Preheat oven to 350 F...',
      'strMealThumb': 'https://www.themealdb.com/images/media/meals/wvpsxx1468256321.jpg',
      'strYoutube': 'https://www.youtube.com/watch?v=4aZr5hZXP_s',
      'strIngredient1': 'soy sauce',
      'strIngredient2': 'water',
      'strIngredient3': 'brown sugar',
      'strMeasure1': '3/4 cup',
      'strMeasure2': '1/2 cup',
      'strMeasure3': '1/4 cup',
    };

    final model = RecipeModel.fromMealJson(mockMealJson);

    expect(model.id, '52772');
    expect(model.name, 'Teriyaki Chicken Casserole');
    expect(model.type, RecipeType.meal);
    expect(model.ingredients.length, 3);
    expect(model.ingredients[0].displayText, 'soy sauce (3/4 cup)');
  });
}
