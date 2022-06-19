import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flame/game.dart';
import 'package:meta/meta.dart';

import '../../helpers/matrix_helper.dart';
import '../flame_components/ingredient_component.dart';

part 'ingredient_matrix_event.dart';
part 'ingredient_matrix_state.dart';

class IngredientMatrixBloc
    extends Bloc<IngredientMatrixEvent, IngredientMatrixState> {
  IngredientMatrixBloc() : super(IngredientMatrixInitialState()) {

    // When we get the level details, build the initial matrix.
    on<LevelDetailsLoadedEvent>((event, emit) {
      final random = Random(event.seed);
      final ingredientMatrix = MatrixHelper.buildInitialMatrix(
        matrixAreaSize: event.matrixAreaSize,
        event: event,
        random: random,
      );
      final ingredientPositionsMapping =
          MatrixHelper.buildInitialPositionMapping(ingredientMatrix);
      emit.call(
        IngredientMatrixFirstFilled(
          matrixAreaSize: event.matrixAreaSize,
          ingredientMatrix: ingredientMatrix,
          ingredientPositionsMapping: ingredientPositionsMapping,
          random: random,
        ),
      );
    });
  }
}
