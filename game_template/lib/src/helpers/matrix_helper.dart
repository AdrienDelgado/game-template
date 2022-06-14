import 'dart:math';

import 'package:flame/components.dart';
import 'package:game_template/src/constants/ingredient_constants.dart';

abstract class MatrixHelper {
  /// This method gives an ingredient size based on total available play zone
  /// size, number of columns, and number of rows. If `isDouble` is set to
  ///  `true`, gives the size for a double size ingredient.
  static Vector2 ingredientSize({
    required Vector2 playAreaSize,
    required int nColumns,
    required int nRows,
    bool isDouble = false,
  }) {
    final double maxWidthBasedOnWidth = playAreaSize.x / (nColumns + 2);
    final double maxHeightBasedOnHeight = playAreaSize.y / (nRows + 2);
    final double width = min(maxWidthBasedOnWidth,
        maxHeightBasedOnHeight / IngredientConstants.imageSimpleRatio);
    final double height = width *
        (isDouble
            ? IngredientConstants.imageDoubleRatio
            : IngredientConstants.imageSimpleRatio);
    return Vector2(width, height);
  }

  /// This method returns the actual are used by the matrix inside the play
  /// area, fitted around the ingredients. `playAreaSize` is the whole allocated
  /// space for the ingredients to occupy, while the result of this method will
  /// return the space that they will occupy.
  static Vector2 matrixAreaSize({
    required Vector2 playAreaSize,
    required int nColumns,
    required int nRows,
  }) {
    final _ingredientSize = ingredientSize(
      playAreaSize: playAreaSize,
      nColumns: nColumns,
      nRows: nRows,
    );
    final width = _ingredientSize.x * (nColumns + 2);
    final height = _ingredientSize.y * (nRows + 1);

    return Vector2(width, height);
  }

  /// This method returns the screen position of an ingredient given its
  /// matrix position (column, row) in the play area.
  ///
  /// Note that one column remains empty within the matrix area for ingredients
  /// to fall on the sides. As well, one row on top of the matrix remains empty
  /// to store double size ingredients that may be on the top row.
  ///
  /// This position assumes that the anchor of ingredients is always
  /// `Anchor.center`
  static Vector2 ingredientPositionInPlayArea({
    required Vector2 matrixAreaSize,
    required int nColumns,
    required int nRows,
    required int column,
    required int row,
  }) {
    final singleWidth = matrixAreaSize.x / (nColumns + 2);
    final singleHeight = matrixAreaSize.y / (nRows + 1);

    // Here we add 1.5 (offset by 1 column + offset by half column for anchor)
    // in width factor, and 0.5 (offset by half row for anchor) in height factor
    return Vector2((column + 1.5) * singleWidth, (row + 0.5) * singleHeight);
  }
}
