part of 'ingredient_matrix_bloc.dart';

@immutable
abstract class IngredientMatrixEvent extends Equatable {
  const IngredientMatrixEvent();
}

class LevelDetailsLoadedEvent extends IngredientMatrixEvent {
  final int nColumns;
  final int nRows;
  final int? seed;
  final Vector2 matrixAreaSize;

  const LevelDetailsLoadedEvent({
    required this.nColumns,
    required this.nRows,
    required this.seed,
    required this.matrixAreaSize,
  });

  @override
  List<Object> get props => [nColumns, nRows];
}

class ComponentsLoadedEvent extends IngredientMatrixEvent {
  const ComponentsLoadedEvent();

  @override
  List<Object?> get props => [];
}

class IngredientPickedUpEvent extends IngredientMatrixEvent {
  final String componentId;
  final int hashcode;

  const IngredientPickedUpEvent({
    required this.componentId,
    required this.hashcode,
  });

  @override
  List<Object> get props => [componentId, hashcode];
}

class IngredientDroppedDownEvent extends IngredientMatrixEvent {
  final String componentId;
  final int hashcode;

  const IngredientDroppedDownEvent({
    required this.componentId,
    required this.hashcode,
  });

  @override
  List<Object> get props => [componentId, hashcode];
}

class IngredientSwipedEvent extends IngredientMatrixEvent {
  final String componentId;
  final int dragHash;
  final SwipeSide side;

  const IngredientSwipedEvent({
    required this.componentId,
    required this.side,
    required this.dragHash,
  });

  @override
  List<Object> get props => [componentId, dragHash, side.toString()];
}