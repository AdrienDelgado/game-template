import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'ingredient_matrix_event.dart';
part 'ingredient_matrix_state.dart';

class IngredientMatrixBloc
    extends Bloc<IngredientMatrixEvent, IngredientMatrixState> {
  IngredientMatrixBloc() : super(IngredientMatrixInitial()) {
    on<IngredientMatrixEvent>((event, emit) {
      // TODO: implement event handler
    });

    on<DummyTapEvent>((event, emit) {
      if (state is DummyState) {
        emit.call(DummyState((state as DummyState).count + 1));
      } else {
        emit.call(DummyState(0));
      }
    });
  }
}
