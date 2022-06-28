import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:game_template/src/constants/effect_constants.dart';

import '../../helpers/matrix_helper.dart';

class LaterMoveEffect {
  final Vector2 destination;
  final EffectController controller;

  LaterMoveEffect({required this.destination, required this.controller});

  /// Make a later effect for an horizontal move
  static LaterMoveEffect horizontal({
    required Vector2 matrixAreaSize,
    required int nColumns,
    required int nRows,
    required List<int> positionInMatrix,
    required int displaceByVertical,
    required int displaceByHorizontal,
  }) {
    return LaterMoveEffect(
      destination: MatrixHelper.getIngredientPositionInMatrixArea(
        matrixAreaSize: matrixAreaSize,
        nColumns: nColumns,
        nRows: nRows,
        column: positionInMatrix.first,
        row: positionInMatrix.last + displaceByVertical.abs(),
      ),
      controller: CurvedEffectController(
        displaceByHorizontal.abs() * EffectConstants.movementDuration,
        Curves.easeInOutQuad,
      ),
    );
  }

  /// Make a later effect for a vertical move.
  static LaterMoveEffect vertical({
    required Vector2 positionInZone,
    required int displaceByVertical,
  }) {
    return LaterMoveEffect(
      destination: Vector2.copy(positionInZone),
      controller: CurvedEffectController(
        displaceByVertical.abs() * EffectConstants.movementDuration,
        Curves.easeInQuad,
      ),
    );
  }

  /// Make a later effect for a drop move.
  static LaterMoveEffect drop({
    required Vector2 matrixAreaSize,
    required int nColumns,
    required int nRows,
    required List<int> positionInMatrix,
  }) {
    return LaterMoveEffect(
      destination: MatrixHelper.getIngredientPositionInMatrixArea(
        matrixAreaSize: matrixAreaSize,
        nColumns: nColumns,
        nRows: nRows,
        column: positionInMatrix.first,
        row: 0,
      ),
      controller: CurvedEffectController(
        positionInMatrix.last != 0
            ? positionInMatrix.last * EffectConstants.movementDuration
            : EffectConstants.movementDuration,
        Curves.bounceOut,
      ),
    );
  }

  /// Build the move effect of this LaterMoveEffect.
  MoveEffect buildEffect() {
    return MoveEffect.to(destination, controller);
  }
}
