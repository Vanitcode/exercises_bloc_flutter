import 'package:bloc/bloc.dart';

class CounterCubit extends Cubit<List<int>> {
  CounterCubit() : super([0, 0, 0, 0]);

  void increment(int index) {
    if (index >= 0 && index < state.length && (state[index] < 9)) {
      List<int> newState = List.from(state);
      newState[index] += 1;
      emit(newState);
    }
  }

  void decrement(int index) {
    if (index >= 0 && index < state.length && (state[index] > 0)) {
      List<int> newState = List.from(state);
      newState[index] -= 1;
      emit(newState);
    }
  }
}
