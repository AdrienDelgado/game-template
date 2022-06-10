import 'package:flame/components.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:game_template/src/game/bloc/ingredient_matrix_bloc.dart';
import 'package:game_template/src/game/gameplay/sort_gameplay.dart';
import 'package:logging/logging.dart';

class IngredientLoader extends Component
    with
        HasGameRef<SortGameplay>,
        FlameBlocReader<IngredientMatrixBloc, IngredientMatrixState>,
        FlameBlocListenable<IngredientMatrixBloc, IngredientMatrixState> {
  static final _log = Logger('IngredientLoader');
  @override
  void onNewState(IngredientMatrixState state) {
    _log.info('parent of this component is of type ${parent.runtimeType}');
    super.onNewState(state);
  }
}
