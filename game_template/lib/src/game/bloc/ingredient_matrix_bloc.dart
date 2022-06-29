import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flame/game.dart';
import 'package:game_template/src/game/bloc/level_status_bloc.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

import '../../data/models/swipe_side.dart';
import '../../helpers/matrix_bloc_helper.dart';
import '../../helpers/matrix_helper.dart';
import '../flame_components/ingredient_component.dart';

part 'ingredient_matrix_event.dart';
part 'ingredient_matrix_state.dart';

class IngredientMatrixBloc
    extends Bloc<IngredientMatrixEvent, IngredientMatrixState> {
  static final _log = Logger('IngredientMatrixBloc');
  final LevelStatusBloc levelStatusBloc;

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

    // When we pick an ingredient up, mark it as held if no other is held.
    on<IngredientPickedUpEvent>(
      (event, emit) {
        _log.fine('received ${event.runtimeType}');
        if (state is! IngredientMatrixActiveState ||
            state.heldIngredientId.isNotEmpty) {
          return;
        }
        final position = state.ingredientPositionsMapping[event.componentId]!;
        emit.call(
          (state as IngredientMatrixActiveState).copyWith(
            heldIngredientId: event.componentId,
            heldIngredient: state.ingredientMatrix[position.first]
                [position.last],
          ),
        );
      },
    );

    // When we drop an ingredient, mark none as held if we dropped the
    // held ingredient.
    on<IngredientDroppedDownEvent>(
      (event, emit) {
        _log.fine('received ${event.runtimeType}');
        if (state is! IngredientMatrixActiveState ||
            state.heldIngredientId != event.componentId) {
          return;
        }
        emit.call(
          (state as IngredientMatrixActiveState).copyWith(
            heldIngredientId: '',
            heldIngredient: null,
          ),
        );
      },
    );

    on<IngredientSwipedEvent>((event, emit) {
      if (state is! IngredientMatrixActiveState) {
        return;
      }

      final position = state.ingredientPositionsMapping[event.componentId]!;
      bool isOutsideBurger = !MatrixHelper.isValidLocation(
        col: position.first,
        row: position.last,
        ingredientMatrix: state.ingredientMatrix,
      );
      late final int newColumn;

      // If we enter this loop then we are holding an ingredient which is
      // aside the burger for now
      if (isOutsideBurger) {
        // If the target position below is not in the burger, just exit
        newColumn = position.first + (event.side == SwipeSide.right ? 1 : -1);

        final bool isTargetOutside = !MatrixHelper.isValidLocation(
          col: newColumn,
          row: position.last,
          ingredientMatrix: state.ingredientMatrix,
        );

        if (isTargetOutside) {
          return;
        }

        // Otherwise we will re-insert the ingredient in the burger
      }

      final impactedIngredients = MatrixBlocHelper.getImpactedIngredients(
        state: state,
        nextCol: isOutsideBurger ? newColumn : position.first,
        side: event.side,
        startingRow: position.last,
      );
      final newMatrixAndMapping = MatrixBlocHelper.updateMatrixAndMapping(
          state: state,
          impactedIngredients: impactedIngredients,
          side: event.side,
          isOutsideBurger: isOutsideBurger,
          componentId: event.componentId);
      emit.call(
        (state as IngredientMatrixActiveState).copyWith(
          ingredientMatrix: newMatrixAndMapping[0]
              as List<List<InteractableIngredientComponent?>>?,
          ingredientPositionsMapping:
              newMatrixAndMapping[1] as Map<String, List<int>>?,
          newComponentsCount: newMatrixAndMapping[2] as Map<int, int>?,
          heldIngredient: state.heldIngredient,
        ),
      );
    });
  }
}
