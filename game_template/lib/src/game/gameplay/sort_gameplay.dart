import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flutter/material.dart';
import 'package:game_template/src/game/bloc/ingredient_matrix_bloc.dart';
import 'package:game_template/src/game/flame_components/dummy_tap_component.dart';
import 'package:logging/logging.dart';

class SortGameplay extends FlameGame with HasTappables {
  SortGameplay({required this.ingredientMatrixBloc});

  static final _log = Logger('SortGameplay');

  final IngredientMatrixBloc ingredientMatrixBloc;

  // TODO: remove dummy method. testing purposes only
  @override
  Future<void> onLoad() async {
    _log.info('game window size: $size');
    // await add(
    //   CircleComponent(
    //     position: size / 2,
    //     radius: 100,
    //     paint: PaletteEntry(Colors.red).paint(),
    //   ),
    // );

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
            DummyTapComponent(),
          ]
        ),
      ],
    );
  }
}
