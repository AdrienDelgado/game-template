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
