part of 'ingredient_matrix_bloc.dart';

@immutable
abstract class IngredientMatrixState {}

class IngredientMatrixInitial extends IngredientMatrixState {}

class DummyState extends IngredientMatrixState {
  final int count;

  DummyState(this.count);
}
