import 'dart:math';

import 'package:flame/components.dart';
import 'package:game_template/src/constants/ingredient_constants.dart';
import 'package:game_template/src/constants/level_design_constants.dart';

abstract class MatrixHelper {
  /// This method gives an ingredient size based on total available play zone
  /// size, number of columns, and number of rows. If `isDouble` is set to
  ///  `true`, gives the size for a double size ingredient.
  static Vector2 getIngredientSize({
    required Vector2 matrixAreaSize,
    required int nColumns,
    required int nRows,
    bool isDouble = false,
  }) {
    final double maxWidthBasedOnWidth = matrixAreaSize.x / (nColumns + 2);
    final double maxHeightBasedOnHeight = matrixAreaSize.y / (nRows + 2);
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
  static Vector2 getMatrixAreaSize({
    required Vector2 playAreaSize,
    required int nColumns,
    required int nRows,
  }) {
    final size = getIngredientSize(
      matrixAreaSize: playAreaSize,
      nColumns: nColumns,
      nRows: nRows,
    );
    final width = size.x * (nColumns + 2);
    final height = size.y * (nRows + 1);

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
  /// `Anchor.center`.
  static Vector2 getIngredientPositionInMatrixArea({
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
    // We also use y = matrixAreaSize.y - the first y value, because Y axis
    // is reverted on screen
    return Vector2(
      (column + 1.5) * singleWidth,
      matrixAreaSize.y - (row + 0.5) * singleHeight,
    );
  }

  /// Returns the maximum play area size based on the current screen size.
  static Vector2 getPlayAreaSize(Vector2 gameSize) {
    const widthPercentage = 1 -
        (LevelDesignConstants.leftMarginPercentage +
            LevelDesignConstants.rightMarginPercentage);
    const heightPercentage = 1 -
        (LevelDesignConstants.bottomMarginPercentage +
            LevelDesignConstants.topMarginPercentage);

    return Vector2(
      gameSize.x * widthPercentage,
      gameSize.y * heightPercentage,
    );
  }

  /// Gives the matrix area position (anchor top left on screen) so the
  /// matrix area fits the play area with exact margin at the bottom, and in
  /// between the minimal margins on right and left sides.
  static Vector2 getMatrixAreaPosition({
    required Vector2 gameSize,
    required int nColumns,
    required int nRows,
  }) {
    final playAreaSize = getPlayAreaSize(gameSize);
    final matrixAreaSize = getMatrixAreaSize(
      playAreaSize: playAreaSize,
      nColumns: nColumns,
      nRows: nRows,
    );
    final verticalPosition =
        (1 - LevelDesignConstants.bottomMarginPercentage) * gameSize.y -
            matrixAreaSize.y;
    final horizontalPosition =
        LevelDesignConstants.leftMarginPercentage * gameSize.x +
            (playAreaSize.x - matrixAreaSize.x) / 2;

    return Vector2(horizontalPosition, verticalPosition);
  }
}
