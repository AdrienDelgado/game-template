import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:game_template/src/constants/ingredient_constants.dart';
import 'package:game_template/src/game/bloc/ingredient_matrix_bloc.dart';
import 'package:game_template/src/game/flame_components/ingredient_component.dart';
import 'package:game_template/src/game/flame_components/ingredient_loader.dart';
import 'package:game_template/src/helpers/matrix_helper.dart';
import 'package:logging/logging.dart';

import '../../data/models/ingredient.dart';
import '../../helpers/sprite_helper.dart';

class SortGameplay extends FlameGame with HasTappables, HasDraggables {
  SortGameplay({required this.ingredientMatrixBloc});

  static final _log = Logger('SortGameplay');

  final world = PositionComponent();

  final matrixComponent = PositionComponent();

  late final Map<IngredientType, Sprite> ingredientSprites;

  final IngredientMatrixBloc ingredientMatrixBloc;

  // TODO: remove dummy method. testing purposes only
  @override
  Future<void> onLoad() async {
    _log.info('game window size: $size');
    ingredientSprites = await SpriteHelper.getIngredientSprites();
    final nColumns = 1;
    final nRows = 10;

    final matrixPosition = MatrixHelper.getMatrixAreaPosition(
        gameSize: size, nColumns: nColumns, nRows: nRows);
    _log.info('matrixPosition: $matrixPosition');

    matrixComponent.position = matrixPosition;

    final matrixAreaSize = MatrixHelper.getMatrixAreaSize(
      playAreaSize: MatrixHelper.getPlayAreaSize(size),
      nColumns: nColumns,
      nRows: nRows,
    );
    _log.info('matrixAreaSize: $matrixAreaSize');

    await world.addAll(
      [
        // TODO remove, dummy example
        IngredientComponent(
          ingredient: Ingredient(type: IngredientType.cheese),
          position: MatrixHelper.getIngredientPositionInMatrixArea(
                matrixAreaSize: matrixAreaSize,
                nColumns: nColumns,
                nRows: nRows,
                column: 0,
                row: 0,
              ) +
              matrixPosition,
          size: MatrixHelper.getIngredientSize(
            matrixAreaSize: matrixAreaSize,
            nColumns: nColumns,
            nRows: nRows,
          ),
        ),
        matrixComponent,
        IngredientLoader(),
      ],
    );

    await addAll(
      [
        FlameMultiBlocProvider(
          providers: [
            FlameBlocProvider<IngredientMatrixBloc,
                IngredientMatrixState>.value(
              value: ingredientMatrixBloc,
            ),
          ],
          children: [
            world,
          ],
        ),
      ],
    );

    
  }
}
