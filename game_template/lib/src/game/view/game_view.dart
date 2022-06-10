import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_template/src/game/bloc/ingredient_matrix_bloc.dart';
import 'package:game_template/src/game/gameplay/sort_gameplay.dart';

class GamePage extends StatelessWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => IngredientMatrixBloc(),
      child: Scaffold(
        body: Center(
          child: GameView(),
        ),
      ),
    );
  }
}

class GameView extends StatefulWidget {
  const GameView({super.key});

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {
  late final SortGameplay gameplay;

  @override
  void initState() {
    final ingredientMatrixBloc = context.read<IngredientMatrixBloc>();
    gameplay = SortGameplay(ingredientMatrixBloc: ingredientMatrixBloc);
    super.initState();
  }

  @override
  Widget build(BuildContext gameViewContext) {
    return GameWidget(
      game: gameplay,
      backgroundBuilder: (gameWidgetContext) => Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/images/back_photo.jpg'),
              fit: BoxFit.cover),
        ),
      ),
    );
  }
}
