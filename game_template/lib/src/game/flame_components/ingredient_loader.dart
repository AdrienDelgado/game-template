import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:game_template/src/game/bloc/ingredient_matrix_bloc.dart';
import 'package:game_template/src/game/bloc/level_status_bloc.dart';
import 'package:game_template/src/game/gameplay/sort_gameplay.dart';
import 'package:logging/logging.dart';

import '../../level_selection/levels.dart';

class IngredientLoader extends Entity
    with
        HasGameRef<SortGameplay>,
        FlameBlocListenable<IngredientMatrixBloc, IngredientMatrixState>,
        FlameBlocReader<IngredientMatrixBloc, IngredientMatrixState> {
  static final _log = Logger('IngredientLoader');

  // The matrix component of the level. It is already positioned correctly in
  // the game view, so components can directly be placed as childen of this.
  IngredientLoader({
    required this.matrixComponent,
  }) : super(
          behaviors: [_LevelStatusListener()],
        );

  final PositionComponent matrixComponent;

  void test() {}

  @override
  Future<void> onNewState(IngredientMatrixState state) async {
    if (state is InitialLoadingState) {
      //   for (final burger in state.ingredientMatrix) {
      //     for (final component in burger) {
      //       component!.position.add(gameRef.ingredientMatrixOffset);
      //       component.positionInMatrix =
      //           state.ingredientPositionsMapping[component.id]!;
      //       await gameRef.add(component);
      //     }
      //   }
      //   gameRef.read<IngredientMatrixBloc>().add(const ComponentsLoadedEvent());
      // } else if (state is IngredientMatrixActiveState) {
      //   if (state.newComponentsCount == null) {
      //     return;
      //   }
      //   for (int column in state.newComponentsCount!.keys) {
      //     final int numberToLoad = state.newComponentsCount![column]!;
      //     for (int row = state.nbRows - 1;
      //         row > state.nbRows - 1 - numberToLoad;
      //         row--) {
      //       final component = state.ingredientMatrix[column][row]!;
      //       component.position.add(gameRef.ingredientMatrixOffset);
      //       await gameRef.add(component);

      //       component.positionInMatrix =
      //           state.ingredientPositionsMapping[component.id]!;
      //       final positionInZone =
      //           IngredientMatrixHelper.getIngredientPositionInZone(
      //         nColumns: state.nbColumns,
      //         nRows: state.nbRows,
      //         column: component.positionInMatrix!.first,
      //         row: component.positionInMatrix!.last,
      //       );

      //       component.moveEffects.add(
      //         LaterMoveEffect(
      //           destination: Vector2.copy(positionInZone)
      //             ..add(gameRef.ingredientMatrixOffset),
      //           controller: CurvedEffectController(
      //             (numberToLoad + 1) * GameConstants.movementDuration,
      //             Curves.easeInQuad,
      //           ),
      //         ),
      //       );

      //       component.playMoveEffect();
      //     }
      //   }
    }
  }
}

class _LevelStatusListener extends Behavior<IngredientLoader>
    with
        HasGameRef<SortGameplay>,
        FlameBlocListenable<LevelStatusBloc, LevelStatusState>,
        FlameBlocReader<LevelStatusBloc, LevelStatusState> {
  @override
  void onNewState(LevelStatusState state) {
    switch (state.runtimeType) {
      case InitialLoadingState:
        break;
      default:
    }
  }
}
