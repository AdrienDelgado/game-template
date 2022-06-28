import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:game_template/src/game/bloc/level_status_bloc.dart';
import 'package:game_template/src/game/gameplay/sort_gameplay.dart';
import 'package:logging/logging.dart';

import '../../level_selection/levels.dart';
import '../bloc/ingredient_matrix_bloc.dart';

class StarterComponent extends TextBoxComponent
    with
        HasGameRef<SortGameplay>,
        FlameBlocReader<LevelStatusBloc, LevelStatusState>,
        FlameBlocListenable<LevelStatusBloc, LevelStatusState> {
  StarterComponent({super.text});
  static final _log = Logger('StarterComponent');

  late final GameLevel level;

  @override
  void onMount() {
    super.onMount();
    _log.fine('$runtimeType was mounted on ${parent.runtimeType}');
    bloc.add(StartLoadingIngredientsEvent());
    level = gameRef.level;
  }

  @override
  void onNewState(LevelStatusState state) {
    switch (state.runtimeType) {
      case InitialLoadingState:
        gameRef.ingredientMatrixBloc.add(
          LevelDetailsLoadedEvent(
            matrixAreaSize: gameRef.matrixAreaSize,
            nColumns: level.nColumns,
            nRows: level.nRows,
            seed: level.seed,
          ),
        );
        break;
      // When components are loaded, wait 3 seconds and start the game,
      // then remove the component
      case LevelReadyState:
        Future<void>.delayed(Duration(seconds: 3)).then((_) {
          bloc.add(StartGameEvent());
          add(RemoveEffect());
        });
        break;
      default:
    }
  }
}
