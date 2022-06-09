import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:game_template/src/game/bloc/ingredient_matrix_bloc.dart';
import 'package:game_template/src/game/gameplay/sort_gameplay.dart';

class DummyTapComponent extends CircleComponent
    with
        HasGameRef<SortGameplay>,
        Tappable,
        FlameBlocListenable<IngredientMatrixBloc, IngredientMatrixState>,
        FlameBlocReader<IngredientMatrixBloc, IngredientMatrixState> {
  @override
  Future<void> onLoad() {
    anchor = Anchor.center;
    position = gameRef.size / 2;
    radius = gameRef.size.x / 2;
    paint = PaletteEntry(Colors.red).paint();
    return super.onLoad();
  }

  @override
  void onNewState(IngredientMatrixState state) {
    position.y++;
  }

  @override
  bool onTapDown(TapDownInfo info) {
    bloc.add(DummyTapEvent());
    return super.onTapDown(info);
  }
}
