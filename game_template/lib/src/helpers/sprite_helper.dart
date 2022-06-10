import 'dart:collection';

import 'package:flame/sprite.dart';

import '../constants/sprite_constants.dart';
import '../data/models/ingredient.dart';

class SpriteHelper {
  /// Loads all ingredient sprites and return the map to access them
  static Future<Map<IngredientType, Sprite>> getIngredientSprites() async {
    final Map<IngredientType, Sprite> map = HashMap();

    for (var type in IngredientType.values) {
      final sprite = await Sprite.load(SpriteConstants.ingredientMap[type]!);
      map.putIfAbsent(type, () => sprite);
    }

    return map;
  }
}
