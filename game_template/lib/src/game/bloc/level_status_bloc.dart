import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'level_status_event.dart';
part 'level_status_state.dart';

class LevelStatusBloc extends Bloc<LevelStatusEvent, LevelStatusState> {
  LevelStatusBloc() : super(LevelStatusInitial()) {
    on<LevelStatusEvent>((event, emit) {
      // TODO: implement event handler
    });

    on<StartLoadingIngredientsEvent>(
      (_, emit) => emit.call(
        InitialLoadingState(),
      ),
    );
  }
}
