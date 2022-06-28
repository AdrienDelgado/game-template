import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flame/game.dart';
import 'package:game_template/src/game/bloc/level_status_bloc.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

import '../../helpers/matrix_helper.dart';
import '../flame_components/ingredient_component.dart';

part 'ingredient_matrix_event.dart';
part 'ingredient_matrix_state.dart';

class IngredientMatrixBloc
    extends Bloc<IngredientMatrixEvent, IngredientMatrixState> {
  static final _log = Logger('IngredientMatrixBloc');
  IngredientMatrixBloc({required this.levelStatusBloc})
      : super(IngredientMatrixInitialState()) {
    // When we get the level details, build the initial matrix.
    on<LevelDetailsLoadedEvent>((event, emit) {
      _log.fine('received ${event.runtimeType}');
      final random = Random(event.seed);
      final ingredientMatrix = MatrixHelper.buildInitialMatrix(
        matrixAreaSize: event.matrixAreaSize,
        event: event,
        random: random,
      );
      final ingredientPositionsMapping =
          MatrixHelper.buildInitialPositionMapping(ingredientMatrix);
      _log.fine('sending IngredientMatrixFirstFilled state');
      emit.call(
        IngredientMatrixFirstFilled(
          matrixAreaSize: event.matrixAreaSize,
          ingredientMatrix: ingredientMatrix,
          ingredientPositionsMapping: ingredientPositionsMapping,
          random: random,
        ),
      );
    });

    // When all initial components are loaded, mark matrix as active
    on<ComponentsLoadedEvent>(
      (event, emit) {
        _log.fine('received ${event.runtimeType}');
        _log.fine('sending MarkLevelReadyEvent to status bloc');
        levelStatusBloc.add(MarkLevelReadyEvent());
        _log.fine('sending IngredientMatrixActiveState status');
        emit.call(
          IngredientMatrixActiveState(
            matrixAreaSize: state.matrixAreaSize,
            ingredientMatrix: state.ingredientMatrix,
            ingredientPositionsMapping: state.ingredientPositionsMapping,
            nColumns: state.nColumns,
            nRows: state.nRows,
            random: state.random,
            heldIngredientId: '',
          ),
        );
      },
    );
  }

  final LevelStatusBloc levelStatusBloc;
}
