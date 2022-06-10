import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:game_template/src/constants/ingredient_constants.dart';
import 'package:game_template/src/game/bloc/ingredient_matrix_bloc.dart';
import 'package:game_template/src/game/flame_components/ingredient_component.dart';
import 'package:game_template/src/game/flame_components/ingredient_loader.dart';
import 'package:logging/logging.dart';

import '../../data/models/ingredient.dart';
import '../../helpers/sprite_helper.dart';

class SortGameplay extends FlameGame with HasTappables, HasDraggables {
  SortGameplay({required this.ingredientMatrixBloc});

  static final _log = Logger('SortGameplay');

  late final Map<IngredientType, Sprite> ingredientSprites;

  final IngredientMatrixBloc ingredientMatrixBloc;

  // TODO: remove dummy method. testing purposes only
  @override
  Future<void> onLoad() async {
    _log.info('game window size: $size');
    ingredientSprites = await SpriteHelper.getIngredientSprites();

    await addAll(
      [
        FlameMultiBlocProvider(providers: [
          FlameBlocProvider<IngredientMatrixBloc, IngredientMatrixState>.value(
            value: ingredientMatrixBloc,
          ),
        ], children: [
          // TODO: Dummy test case
          InteractableIngredientComponent(
            ingredient: Ingredient(type: IngredientType.bread),
            position: size / 2,
            size: Vector2(size.x, size.x * IngredientConstants.simpleRatio),
          ),
          // TODO: Dummy test case
          IngredientComponent(
            ingredient: Ingredient(type: IngredientType.bacon),
            position: size / 2,
            size: Vector2(size.x, size.x * IngredientConstants.simpleRatio),
          ),
          IngredientLoader(),
        ]),
      ],
    );
  }
}
