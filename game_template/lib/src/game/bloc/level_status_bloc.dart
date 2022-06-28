import 'package:bloc/bloc.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

part 'level_status_event.dart';
part 'level_status_state.dart';

class LevelStatusBloc extends Bloc<LevelStatusEvent, LevelStatusState> {
  static final _log = Logger('LevelStatusBloc');
  LevelStatusBloc() : super(LevelStatusInitial()) {
    on<LevelStatusEvent>((event, emit) {
      // TODO: implement event handler
    });

    on<StartLoadingIngredientsEvent>(
      (_, emit) {
        _log.fine('received ${_.runtimeType}, sending InitialLoadingState');
        emit.call(
          InitialLoadingState(),
        );
      },
    );
  }
}
