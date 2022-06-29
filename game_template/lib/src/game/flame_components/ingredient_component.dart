import 'dart:collection';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flutter/material.dart' show Curves, Color, Colors, Offset;
import 'package:game_template/src/constants/effect_constants.dart';
import 'package:game_template/src/data/models/ingredient.dart';
import 'package:game_template/src/game/bloc/ingredient_matrix_bloc.dart';
import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/later_move_effect.dart';
import '../../data/models/swipe_side.dart';
import '../../helpers/matrix_helper.dart';
import '../gameplay/sort_gameplay.dart';

/// This is an ingredient component visible during the game. Contrarily to
/// `InteractableIngredientComponent`, it is not interactable, but simply shows
/// an ingredient for display purposes.
class IngredientComponent extends SpriteComponent
    with HasGameRef<SortGameplay> {
  IngredientComponent({
    required this.ingredient,
    super.size,
    super.position,
  }) : super(
          priority: 10,
        ) {
    _log.info('initial: size $size, position $position');
  }
  static final _log = Logger('IngredientComponent');
  // The ingredient of this component
  final Ingredient ingredient;

  @override
  Future<void>? onLoad() {
    sprite = gameRef.ingredientSprites[ingredient.type]!;
    return super.onLoad();
  }
}

class InteractableIngredientComponent extends Entity with Tappable {
  InteractableIngredientComponent({
    required Ingredient ingredient,
    super.position,
    super.size,
  }) : super(
          priority: 10,
          children: [
            IngredientComponent(
              ingredient: ingredient,
              size: size,
            ),
          ],
          behaviors: [
            _EffectBehavior(),
            _GridMoveBehavior(),
            _GestureBehavior(),
          ],
          anchor: Anchor.center,
        );

  String get id => _id;
  Ingredient get ingredient =>
      (children.first as IngredientComponent).ingredient;

  // The component identifier
  final String _id = const Uuid().v4();

  static final _log = Logger('InteractableIngredientComponent');

  final Queue<LaterMoveEffect> moveEffects = Queue<LaterMoveEffect>();

  // The last known position in the ingredient matrix
  List<int>? positionInMatrix;

  // The position in ingredient matrix zone of the ingredient
  Vector2? positionInZone;

  // The position in ingredient matrix zone of the ingredient
  Vector2? leftPositionInZone;

  // The position in ingredient matrix zone of the ingredient
  Vector2? rightPositionInZone;

  // If the component is currently held
  bool isHeld = false;

  // If the component is moving
  bool isMoving = false;
}

class _GridMoveBehavior
    extends DraggableBehavior<InteractableIngredientComponent>
    with
        HasGameRef<SortGameplay>,
        FlameBlocListenable<IngredientMatrixBloc, IngredientMatrixState>,
        FlameBlocReader<IngredientMatrixBloc, IngredientMatrixState> {
  static final _log = Logger('_GridMoveBehavior');

  @override
  void onNewState(IngredientMatrixState state) {
    final id = parent.id;
    var positionInMatrix = parent.positionInMatrix;
    Vector2? positionInZone = parent.positionInZone;
    Vector2? leftPositionInZone = parent.leftPositionInZone;
    Vector2? rightPositionInZone = parent.rightPositionInZone;
    final ingredient = parent.ingredient;
    final moveEffects = parent.moveEffects;
    bool isHeld = parent.isHeld;
    _log.fine('receiving new ${state.runtimeType}');

    if (state is! IngredientMatrixActiveState ||
        !state.ingredientPositionsMapping.containsKey(id)) {
      return;
    }

    final effectBehavior = parent.findBehavior<_EffectBehavior>();

    int displaceByVertical = 0;
    int displaceByHorizontal = 0;

    // If this is a new ingredient in the matrix, no horizontal displacement
    if (positionInMatrix == null) {
      displaceByVertical =
          state.nRows + 1 - state.ingredientPositionsMapping[id]!.last;
      if (state.newComponentsCount == null) {
        _log.warning("Issue: state.newComponentsCount should not be null");
        displaceByVertical =
            state.nRows + 1 - state.ingredientPositionsMapping[id]!.last;
      } else {
        displaceByVertical = state
            .newComponentsCount![state.ingredientPositionsMapping[id]!.first]!;
        _log.warning(
            "New ${ingredient.type} will be displaced by $displaceByVertical");
      }
    }
    // If it was already in the matrix, it was then moved
    else {
      displaceByHorizontal =
          state.ingredientPositionsMapping[id]!.first - positionInMatrix.first;
      displaceByVertical =
          state.ingredientPositionsMapping[id]!.last - positionInMatrix.last;
    }

    positionInMatrix = state.ingredientPositionsMapping[id]!;

    positionInZone = MatrixHelper.getIngredientPositionInMatrixArea(
      matrixAreaSize: gameRef.matrixAreaSize,
      nColumns: state.nColumns,
      nRows: state.nRows,
      column: positionInMatrix.first,
      row: positionInMatrix.last,
    );

    leftPositionInZone = MatrixHelper.getIngredientPositionInMatrixArea(
      matrixAreaSize: gameRef.matrixAreaSize,
      nColumns: state.nColumns,
      nRows: state.nRows,
      column: positionInMatrix.first - 1,
      row: positionInMatrix.last,
    );

    rightPositionInZone = MatrixHelper.getIngredientPositionInMatrixArea(
      matrixAreaSize: gameRef.matrixAreaSize,
      nColumns: state.nColumns,
      nRows: state.nRows,
      column: positionInMatrix.first + 1,
      row: positionInMatrix.last,
    );

    // Horizontal movement first
    if (displaceByHorizontal != 0) {
      moveEffects.add(
        LaterMoveEffect.horizontal(
            matrixAreaSize: gameRef.matrixAreaSize,
            nColumns: state.nColumns,
            nRows: state.nRows,
            positionInMatrix: positionInMatrix,
            displaceByVertical: displaceByVertical,
            displaceByHorizontal: displaceByHorizontal),
      );
    }

    // Then vertical movement
    if (displaceByVertical != 0) {
      moveEffects.add(
        LaterMoveEffect.vertical(
          positionInZone: positionInZone,
          displaceByVertical: displaceByVertical,
        ),
      );
    }

    if (isHeld && state.heldIngredientId != id) {
      isHeld = false;
      _log.fine("component $id is not held anymore");
      parent.children.changePriority(this, 0);
      add(
        ScaleEffect.by(
          Vector2.all(1 / EffectConstants.heldScale),
          CurvedEffectController(
            EffectConstants.scaleDuration,
            Curves.easeInOut,
          ),
        ),
      );
    } else if (!isHeld && state.heldIngredientId == id) {
      isHeld = true;
      _log.fine("component $id is now held");
      parent.children.changePriority(this, 1);
      add(
        ScaleEffect.by(
          Vector2.all(EffectConstants.heldScale),
          CurvedEffectController(
            EffectConstants.scaleDuration,
            Curves.easeInOut,
          ),
        ),
      );
    }

    // Then fall movement if out of the matrix and not held
    if (!isHeld &&
        !MatrixHelper.isValidLocation(
          col: positionInMatrix.first,
          row: positionInMatrix.last,
          ingredientMatrix: state.ingredientMatrix,
        )) {
      // isInteractable = false;
      moveEffects.add(
        LaterMoveEffect.drop(
          matrixAreaSize: gameRef.matrixAreaSize,
          nColumns: state.nColumns,
          nRows: state.nRows,
          positionInMatrix: positionInMatrix,
        ),
      );
      // TODO fix: triggering too early
      parent.findBehavior<_EffectBehavior>().fadeOut(
          duration: EffectConstants.fadeDuration,
          delay: positionInMatrix.last * EffectConstants.movementDuration +
              EffectConstants.fadeDelay);
    }

    parent.findBehavior<_EffectBehavior>().playMoveEffect();
  }
}

class _EffectBehavior extends Behavior<InteractableIngredientComponent>
    with
        Tappable,
        Draggable,
        FlameBlocListenable<IngredientMatrixBloc, IngredientMatrixState>,
        FlameBlocReader<IngredientMatrixBloc, IngredientMatrixState> {
  static final _log = Logger('_EffectBehavior');

  /// Play the next move effect in the move effect list of the component
  Future<void> playMoveEffect() async {
    if (parent.moveEffects.isEmpty || parent.isMoving) {
      return;
    }
    MoveEffect effect = parent.moveEffects.removeFirst().buildEffect();
    parent.isMoving = true;
    await add(effect)!.then((_) async {
      await Future.delayed(
        Duration(milliseconds: (effect.controller.duration! * 1000).toInt()),
        () {
          parent.isMoving = false;
          playMoveEffect();
        },
      );
    });
  }

  /// Fades the component out of the game once it was dropped
  void fadeOut({
    required double duration,
    double delay = 0.0,
    Color color = Colors.green,
  }) {
    final effectController = DelayedEffectController(
      CurvedEffectController(
        duration,
        Curves.easeOutQuad,
      ),
      delay: delay,
    );

    add(
      OpacityEffect.fadeOut(
        effectController,
      ),
    );

    add(
      ColorEffect(
        Colors.green,
        const Offset(0.0, 0.9),
        effectController,
      ),
    );

    add(
      ScaleEffect.by(
        Vector2.all(1.5),
        effectController,
      ),
    );

    add(
      RemoveEffect(
        delay: delay + duration,
      ),
    );
  }
}

class _GestureBehavior extends Behavior<InteractableIngredientComponent>
    with
        HasGameRef<SortGameplay>,
        Tappable,
        Draggable,
        FlameBlocListenable<IngredientMatrixBloc, IngredientMatrixState>,
        FlameBlocReader<IngredientMatrixBloc, IngredientMatrixState> {
  static final _log = Logger('_GestureBehavior');

  // This picks up the fact that the ingredient is being held
  @override
  bool onTapDown(TapDownInfo info) {
    _log.fine('onTapDown: ${info.hashCode}');
    bloc.add(
      IngredientPickedUpEvent(
        componentId: parent.id,
        hashcode: info.hashCode,
      ),
    );
    return super.onTapDown(info);
  }

  // This releases the ingredient if we did not move it
  @override
  bool onTapUp(TapUpInfo info) {
    bloc.add(
      IngredientDroppedDownEvent(
        componentId: parent.id,
        hashcode: info.hashCode,
      ),
    );
    return super.onTapUp(info);
  }

  // Checks if we move an ingredient correctly
  //TODO Change coordinates system
  @override
  bool onDragUpdate(DragUpdateInfo info) {
    if (parent.leftPositionInZone == null ||
        parent.rightPositionInZone == null ||
        parent.positionInZone == null) {
      return false;
    }
    SwipeSide side = SwipeSide.none;
    final distanceBetweenIngredients = Vector2.copy(parent.positionInZone!)
        .distanceTo(parent.leftPositionInZone!); // TODO HERE
    final detectionDistance = distanceBetweenIngredients / 2.1;

    if (info.eventPosition.global.distanceTo( // TODO HERE
            Vector2.copy(parent.leftPositionInZone!)
              ..add(gameRef.matrixPosition)) <
        detectionDistance) {
      side = SwipeSide.left;
    } else if (info.eventPosition.global.distanceTo( // TODO HERE
            Vector2.copy(parent.rightPositionInZone!)
              ..add(gameRef.matrixPosition)) <
        detectionDistance) {
      side = SwipeSide.right;
    }

    if (side != SwipeSide.none) {
      _log.fine("sending a move with id ${parent.id} and side $side");
      bloc.add(
            IngredientSwipedEvent(
              componentId: parent.id,
              side: side,
              dragHash: info.hashCode,
            ),
          );
    }
    return super.onDragUpdate(info);
  }
}
