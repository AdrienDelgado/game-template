import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:game_template/src/data/models/ingredient.dart';
import 'package:game_template/src/game/bloc/ingredient_matrix_bloc.dart';
import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';

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
          anchor: Anchor.center,
          priority: 10,
        ) {
    _log.info('initial: size $size, position $position');
  }
  static final _log = Logger('IngredientComponent');
  // The ingredient of this component
  final Ingredient ingredient;

  // The component identifier
  final String id = const Uuid().v4();

  @override
  Future<void>? onLoad() {
    _log.fine(
        'Loaded ${ingredient.type.name} ingredient with id $id on position $position with size $size');
    sprite = gameRef.ingredientSprites[ingredient.type]!;
    // size = sprite!.originalSize;
    return super.onLoad();
  }
}

class InteractableIngredientComponent extends Entity {
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
            _GridMoveBehavior(),
            _EffectBehavior(),
          ],
        ){
          _log.info('initial: size $size, position $position');
        }

  static final _log = Logger('InteractableIngredientComponent');
}

class _GridMoveBehavior extends Behavior<InteractableIngredientComponent>
    with
        HasGameRef<SortGameplay>,
        Tappable,
        Draggable,
        FlameBlocListenable<IngredientMatrixBloc, IngredientMatrixState>,
        FlameBlocReader<IngredientMatrixBloc, IngredientMatrixState> {
  static final _log = Logger('_GridMoveBehavior');
  @override
  bool onTapDown(TapDownInfo info) {
    _log.info('sending dummy event');
    bloc.add(DummyTapEvent());
    return super.onTapDown(info);
  }

  @override
  void onNewState(IngredientMatrixState state) {
    _log.info('receiving new state');
    super.onNewState(state);
  }
}

class _EffectBehavior extends Behavior<InteractableIngredientComponent> {}
