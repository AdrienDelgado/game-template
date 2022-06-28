import 'dart:collection';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:game_template/src/constants/ingredient_constants.dart';
import 'package:game_template/src/constants/level_design_constants.dart';

import '../data/models/ingredient.dart';
import '../game/bloc/ingredient_matrix_bloc.dart';
import '../game/flame_components/ingredient_component.dart';

abstract class MatrixHelper {
  /// This method gives an ingredient size based on total available play zone
  /// size, number of columns, and number of rows. If `isDouble` is set to
  ///  `true`, gives the size for a double size ingredient.
  static Vector2 getIngredientSize({
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
  static Vector2 getMatrixAreaSize({
    required Vector2 playAreaSize,
    required int nColumns,
    required int nRows,
  }) {
    final size = getIngredientSize(
      playAreaSize: playAreaSize,
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

  /// This method builds the initial matrix of ingredients based on level
  ///  properties: number of columns, number of rows, seed
  static List<List<InteractableIngredientComponent?>> buildInitialMatrix({
    required Vector2 matrixAreaSize,
    required LevelDetailsLoadedEvent event,
    required Random random,
  }) {
    // final ingredientSize = getIngredientSize(
    //   playAreaSize: matrixAreaSize,
    //   nColumns: event.nColumns,
    //   nRows: event.nRows,
    // );
    final ingredientSize = Vector2(
      matrixAreaSize.x / (event.nColumns + 2),
      matrixAreaSize.y / (event.nRows + 1),
    );

    List<List<InteractableIngredientComponent?>> ingredientMatrix =
        List.generate(
      event.nColumns,
      (column) => List.generate(
        event.nRows,
        (row) => InteractableIngredientComponent(
          ingredient: Ingredient(
            type: IngredientType
                .values[random.nextInt(IngredientType.values.length)],
          ),
          position: getIngredientPositionInMatrixArea(
            matrixAreaSize: matrixAreaSize,
            nColumns: event.nColumns,
            nRows: event.nRows,
            column: column,
            row: row,
          ),
          size: ingredientSize,
        ),
      ),
    );

    return ingredientMatrix;
  }

  /// Returns the mapping of each component via its id to its position in the
  ///  matrix as an int list. To get the position, we will need to treat the
  ///  first element of the list as the column, and the second as the row
  static Map<String, List<int>> buildInitialPositionMapping(
      List<List<InteractableIngredientComponent?>> ingredientMatrix) {
    final positionMapping = HashMap<String, List<int>>();

    for (int column = 0; column < ingredientMatrix.length; column++) {
      for (int row = 0; row < ingredientMatrix.first.length; row++) {
        positionMapping.putIfAbsent(
          ingredientMatrix[column][row]!.id,
          () => [column, row],
        );
      }
    }

    return positionMapping;
  }

  /// This method checks is given indices are valid matrix coordinates
  static bool isValidLocation({
    required final int col,
    required final int row,
    required final List<List<InteractableIngredientComponent?>>
        ingredientMatrix,
  }) {
    // Check if matrix size is null or if we access negative indices
    if (ingredientMatrix.isEmpty || col < 0 || row < 0) {
      return false;
    }

    // check if indices are withing bounds of the matrix
    if (col >= ingredientMatrix.length ||
        row >= ingredientMatrix.first.length) {
      return false;
    }

    return true;
  }
}
