import '../data/models/ingredient.dart';

abstract class SpriteConstants {
  /// Give an ingredient type, get the file path to its asset.
  static final Map<IngredientType, String> ingredientMap = {
    for (var type in IngredientType.values) type: 'ingredients/${type.name}.png'
  };
}
