/// All the different types of ingredients available in the game
enum IngredientType {
  bread,
  steak,
  cheese,
  tomato,
  salad,
  onion,
  bacon,
}

/// Basic data structure including the attributes of an ingredient:
/// `type` represents the type of ingredient, while `isConnectedAbove`
///  determines if it is linked to the ingredient above it (they move together)
/// and `isDoubleSize` determines if the ingredient takes up two rows
///  instead of one.
class Ingredient {
  // The type of ingredient
  final IngredientType type;

  // If the ingredient is linked to the ingredient above it
  final bool isConnectedAbove;

  // If the ingredient is a double-sized ingredient
  final bool isDoubleSize;

  // Constructor with ingredient type and possible color override
  Ingredient({
    required this.type,
    this.isConnectedAbove = false,
    this.isDoubleSize = false,
  });

  // Displaying the class type, ingredient type, and color
  @override
  String toString() {
    return '$runtimeType (type:${type.name}, isConnectedAbove:$isConnectedAbove, isConnectedBelow:$isDoubleSize)';
  }
}
