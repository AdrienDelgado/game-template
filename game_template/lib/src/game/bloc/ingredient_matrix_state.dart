part of 'ingredient_matrix_bloc.dart';

abstract class IngredientMatrixState extends Equatable {
  late final List<List<InteractableIngredientComponent?>> ingredientMatrix;
  late final Map<String, List<int>> ingredientPositionsMapping;
  late final int nColumns;
  late final int nRows;
  late final Random random;
  late final String heldIngredientId;
  late final InteractableIngredientComponent? heldIngredient;
  late final Map<int, int>? newComponentsCount;
  late final Vector2 matrixAreaSize;

  @override
  List<Object> get props => [];
}

class IngredientMatrixInitialState extends IngredientMatrixState {
  @override
  List<Object> get props => [];
}

class IngredientMatrixFirstFilled extends IngredientMatrixState {
  IngredientMatrixFirstFilled({
    required final List<List<InteractableIngredientComponent?>>
        ingredientMatrix,
    required final Map<String, List<int>> ingredientPositionsMapping,
    required final Random random,
    required final Vector2 matrixAreaSize,
  }) {
    this.ingredientMatrix = ingredientMatrix;
    this.ingredientPositionsMapping = ingredientPositionsMapping;
    nColumns = ingredientMatrix.length;
    nRows = ingredientMatrix[0].length;
    this.random = random;
    this.matrixAreaSize = matrixAreaSize;
  }

  @override
  List<Object> get props => [ingredientPositionsMapping.toString()];
}

class IngredientMatrixActiveState extends IngredientMatrixState {
  IngredientMatrixActiveState({
    required final List<List<InteractableIngredientComponent?>>
        ingredientMatrix,
    required final Map<String, List<int>> ingredientPositionsMapping,
    required final int nColumns,
    required final int nRows,
    required final Random random,
    required final String heldIngredientId,
    required final Vector2 matrixAreaSize,
    final InteractableIngredientComponent? heldIngredient,
    final Map<int, int>? newComponentsCount,
  }) {
    this.ingredientMatrix = ingredientMatrix;
    this.ingredientPositionsMapping = ingredientPositionsMapping;
    this.nColumns = nColumns;
    this.nRows = nRows;
    this.random = random;
    this.heldIngredientId = heldIngredientId;
    this.heldIngredient = heldIngredient;
    this.newComponentsCount = newComponentsCount;
    this.matrixAreaSize = matrixAreaSize;
  }

  IngredientMatrixActiveState copyWith({
    final List<List<InteractableIngredientComponent?>>? ingredientMatrix,
    final Map<String, List<int>>? ingredientPositionsMapping,
    final int? nColumns,
    final int? nRows,
    final Random? random,
    final String? heldIngredientId,
    // WARNING! heldIngredient has to be specifically written every time
    required final InteractableIngredientComponent? heldIngredient,
    final Map<int, int>? newComponentsCount,
    required final Vector2? matrixAreaSize,
  }) {
    return IngredientMatrixActiveState(
      ingredientMatrix: ingredientMatrix ?? this.ingredientMatrix,
      ingredientPositionsMapping:
          ingredientPositionsMapping ?? this.ingredientPositionsMapping,
      nColumns: nColumns ?? this.nColumns,
      nRows: nRows ?? this.nRows,
      random: random ?? this.random,
      heldIngredientId: heldIngredientId ?? this.heldIngredientId,
      heldIngredient: heldIngredient,
      newComponentsCount: newComponentsCount,
      matrixAreaSize: matrixAreaSize ?? this.matrixAreaSize,
    );
  }

  @override
  List<Object> get props => [
        ingredientPositionsMapping.toString(),
        ingredientMatrix.toString(),
        nColumns,
        nRows,
        heldIngredientId,
      ];
}
