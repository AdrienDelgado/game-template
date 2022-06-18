import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_template/src/game/bloc/ingredient_matrix_bloc.dart';
import 'package:game_template/src/game/bloc/level_status_bloc.dart';
import 'package:game_template/src/game/gameplay/sort_gameplay.dart';
import 'package:game_template/src/level_selection/levels.dart';

class GamePage extends StatelessWidget {
  const GamePage({required this.level, super.key});

  final GameLevel level;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => IngredientMatrixBloc(),
        ),
        BlocProvider(
          create: (context) => LevelStatusBloc(),
        ),
      ],
      child: Scaffold(
        body: Center(
          child: GameView(level: level,),
        ),
      ),
    );
  }
}

class GameView extends StatefulWidget {
  const GameView({required this.level, super.key});

  final GameLevel level;

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {
  late final SortGameplay gameplay;

  @override
  void initState() {
    final ingredientMatrixBloc = context.read<IngredientMatrixBloc>();
    final levelStatusBloc = context.read<LevelStatusBloc>();
    gameplay = SortGameplay(
      ingredientMatrixBloc: ingredientMatrixBloc,
      levelStatusBloc: levelStatusBloc,
      level: widget.level,
    );
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
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
