import 'dart:collection';

import 'package:game_template/src/game/bloc/ingredient_matrix_bloc.dart';
import 'package:game_template/src/game/flame_components/ingredient_component.dart';

import '../data/models/swipe_side.dart';
import 'matrix_helper.dart';

/// Returns a map of all ingredients impacted by a move, with keys as columns
/// and values as rows
abstract class MatrixBlocHelper {
  static Map<int, Set<int>> getImpactedIngredients({
    required int nextCol,
    required SwipeSide side,
    required IngredientMatrixState state,
    Map<int, Set<int>>? currentMap,
    int? startingRow,
  }) {
    currentMap ??= SplayTreeMap();

    late final Set<int> nextRows;
    // If we start the call chain
    if (startingRow != null) {
      nextRows = _getImpactedIngredientsByColumn(
        state: state,
        col: nextCol,
        currentRows: HashSet()..add(startingRow),
      );
    }
    // Otherwise, if we continue the call chain
    else {
      nextRows = _getImpactedIngredientsByColumn(
        state: state,
        col: nextCol,
        currentRows:
            currentMap[side == SwipeSide.left ? nextCol + 1 : nextCol - 1] ??
                HashSet(),
      );
    }

    // When no more ingredients are to be added, return current map
    if (nextRows.isEmpty) {
      return currentMap;
    }
    // Otherwise add new ingredients and compute next column
    else {
      return getImpactedIngredients(
        state: state,
        currentMap: currentMap
          ..putIfAbsent(
            nextCol,
            () => nextRows,
          ),
        nextCol: side == SwipeSide.left ? nextCol - 1 : nextCol + 1,
        side: side,
      );
    }
  }

  /// Updates the ingredient matrix and position mapping of the ingredients
  static List<dynamic> updateMatrixAndMapping({
    required IngredientMatrixState state,
    required Map<int, Set<int>> impactedIngredients,
    required SwipeSide side,
    required bool isOutsideBurger,
    String? componentId,
  }) {
    final List<List<InteractableIngredientComponent?>> ingredientMatrix =
        MatrixHelper.ingredientMatrixDeepCopy(state.ingredientMatrix);
    final Map<String, List<int>> ingredientPositionsMapping =
        MatrixHelper.ingredientPositionsMappingDeepCopy(
            state.ingredientPositionsMapping);
    final Map<int, int> newComponentsCount = HashMap();

    final nColumns = ingredientMatrix.length;
    final nRows = ingredientMatrix[0].length;

    moveMatrixIngredients(
      state: state,
      impactedIngredients: impactedIngredients,
      side: side,
      ingredientPositionsMapping: ingredientPositionsMapping,
      ingredientMatrix: ingredientMatrix,
    );

    // Make adjustments if ingredient is outside burger
    if (isOutsideBurger) {
      final position = state.ingredientPositionsMapping[componentId]!;
      final newCol = position.first + (side == SwipeSide.right ? 1 : -1);
      ingredientMatrix[newCol][position.last] = state.heldIngredient;
      ingredientPositionsMapping.update(
          componentId!, (pos) => pos..first = newCol);
    }

    makeMatrixIngredientsFall(
      state: state,
      ingredientPositionsMapping: ingredientPositionsMapping,
      ingredientMatrix: ingredientMatrix,
    );

    for (var col = 0; col < ingredientMatrix.length; col++) {
      final missingCount =
          ingredientMatrix[col].where((element) => element == null).length;
      if (missingCount != 0) {
        newComponentsCount.putIfAbsent(col, () => missingCount);
      }
      int spawnRow = nRows + 1;
      for (int row = nRows - missingCount; row < nRows; row++) {
        final newComponent = MatrixHelper.makeNewIngredient(
          matrixAreaSize: state.matrixAreaSize,
          column: col,
          row: spawnRow,
          random: state.random,
          nColumns: nColumns,
          nRows: nRows,
        );
        ingredientMatrix[col][row] = newComponent;
        ingredientPositionsMapping.putIfAbsent(
          newComponent.id,
          () => List.empty(growable: true)
            ..add(col)
            ..add(row),
        );
        spawnRow++;
      }
    }

    return List<dynamic>.empty(growable: true)
      ..add(ingredientMatrix)
      ..add(ingredientPositionsMapping)
      ..add(newComponentsCount);
  }

  static void moveMatrixIngredients({
    required IngredientMatrixState state,
    required Map<String, List<int>> ingredientPositionsMapping,
    required List<List<InteractableIngredientComponent?>> ingredientMatrix,
    required Map<int, Set<int>> impactedIngredients,
    required SwipeSide side,
  }) {
    if (side == SwipeSide.left) {
      for (int col = 0; col < state.nColumns; col++) {
        final rows = impactedIngredients[col] ?? const Iterable<int>.empty();
        for (int row in rows) {
          ingredientPositionsMapping[ingredientMatrix[col][row]!.id]![0]--;
          if (MatrixHelper.isValidLocation(
            col: col - 1,
            row: row,
            ingredientMatrix: ingredientMatrix,
          )) {
            ingredientMatrix[col - 1][row] = ingredientMatrix[col][row];
          }
          ingredientMatrix[col][row] = null;
        }
      }
    } else {
      for (int col = state.nColumns - 1; col >= 0; col--) {
        final rows = impactedIngredients[col] ?? const Iterable<int>.empty();
        for (int row in rows) {
          ingredientPositionsMapping[ingredientMatrix[col][row]!.id]![0]++;
          if (MatrixHelper.isValidLocation(
            col: col + 1,
            row: row,
            ingredientMatrix: ingredientMatrix,
          )) {
            ingredientMatrix[col + 1][row] = ingredientMatrix[col][row];
          }
          ingredientMatrix[col][row] = null;
        }
      }
    }
  }

  static void makeMatrixIngredientsFall({
    required IngredientMatrixState state,
    required Map<String, List<int>> ingredientPositionsMapping,
    required List<List<InteractableIngredientComponent?>> ingredientMatrix,
  }) {
    for (int col = 0; col < state.nColumns; col++) {
      ingredientMatrix[col].removeWhere((element) => element == null);
      for (int row = 0; row < ingredientMatrix[col].length; row++) {
        ingredientPositionsMapping[ingredientMatrix[col][row]!.id]![1] = row;
      }
      final currentRowcount = ingredientMatrix[col].length;
      for (int _ = 0; _ < state.nRows - currentRowcount; _++) {
        ingredientMatrix[col].add(null);
      }
    }
  }

  // Internal method: returns all ingredients in a column that are targeted
  // by a move. To do so, is based on previous column's impacted ingredients
  static Set<int> _getImpactedIngredientsByColumn({
    required int col,
    required Set<int> currentRows,
    required IngredientMatrixState state,
  }) {
    Set<int> newRows = HashSet();

    for (int row in currentRows) {
      newRows.addAll(
        _expandVerticallyFromLocation(
          state: state,
          col: col,
          row: row,
        ),
      );
    }
    return newRows;
  }

  // Internal method: takes an ingredient that should be impacted,
  // and adds all adjacent ingredients (above and below) that are
  // attached to it, to mark them as impacted
  static Set<int> _expandVerticallyFromLocation({
    required int col,
    required int row,
    required IngredientMatrixState state,
  }) {
    Set<int> rows = HashSet();
    int currentRow = row;

    // Check if main ingredient is valid to move
    // This will mostly detect if we are not in the columns anymore
    // but later on we can add elements that are not movable
    if (MatrixHelper.isValidIngredient(
      col: col,
      row: row,
      ingredientMatrix: state.ingredientMatrix,
    )) {
      rows.add(row);
    } else {
      return rows;
    }

    // Check for connected ingredients above
    while (true) {
      final bool isValidIngredient = MatrixHelper.isValidIngredient(
        col: col,
        row: currentRow,
        ingredientMatrix: state.ingredientMatrix,
      );
      final bool isValidIngredientAbove =
          MatrixHelper.isValidIngredient(
        col: col,
        row: currentRow + 1,
        ingredientMatrix: state.ingredientMatrix,
      );
      if (!isValidIngredient || !isValidIngredientAbove) {
        break;
      }

      final bool isConnectedAbove = state.ingredientMatrix
          .elementAt(col)
          .elementAt(currentRow)!
          .ingredient
          .isConnectedAbove;
      final bool isDoubleSize = state.ingredientMatrix
          .elementAt(col)
          .elementAt(currentRow)!
          .ingredient
          .isDoubleSize;

      if (isConnectedAbove || isDoubleSize) {
        currentRow++;
        rows.add(currentRow);
      } else {
        break;
      }
    }

    currentRow = row;
    // Check for connected ingredients below
    while (true) {
      final bool isValidIngredient = MatrixHelper.isValidIngredient(
        col: col,
        row: currentRow,
        ingredientMatrix: state.ingredientMatrix,
      );
      final bool isValidIngredientBelow =
          MatrixHelper.isValidIngredient(
        col: col,
        row: currentRow - 1,
        ingredientMatrix: state.ingredientMatrix,
      );
      if (!isValidIngredient || !isValidIngredientBelow) {
        break;
      }

      final bool isConnectedBelow = state.ingredientMatrix
          .elementAt(col)
          .elementAt(currentRow - 1)!
          .ingredient
          .isConnectedAbove;
      final bool isDoubleSizeBelow = state.ingredientMatrix
          .elementAt(col)
          .elementAt(currentRow - 1)!
          .ingredient
          .isDoubleSize;

      if (isConnectedBelow || isDoubleSizeBelow) {
        currentRow--;
        rows.add(currentRow);
      } else {
        break;
      }
    }

    return rows;
  }


}
