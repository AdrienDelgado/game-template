import 'package:flame/components.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:game_template/src/game/bloc/level_status_bloc.dart';
import 'package:game_template/src/game/gameplay/sort_gameplay.dart';

class StatusComponent extends TextBoxComponent
    with
        HasGameRef<SortGameplay>,
        FlameBlocReader<LevelStatusBloc, LevelStatusState> {
  StatusComponent({super.text});

  @override
  void onMount() {
    bloc.add(StartLoadingIngredientsEvent());
    super.onMount();
  }
}
