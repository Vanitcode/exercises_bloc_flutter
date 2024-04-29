part of 'counter_timer_bloc.dart';

sealed class CounterTimerState extends Equatable {
  const CounterTimerState(this.duration);
  final int duration;

  @override
  List<Object> get props => [];
}

final class CounterTimerInitial extends CounterTimerState {
  const CounterTimerInitial(super.duration);

  @override
  String toString() => 'CounterTimerInitial { duration: $duration}';
}

final class CounterTimerRunPause extends CounterTimerState {
  const CounterTimerRunPause(super.duration);

  @override
  String toString() => 'CounterTimerRunPause { duration: $duration}';
}

final class CounterTimerRunInProgress extends CounterTimerState {
  const CounterTimerRunInProgress(super.duration);

  @override
  String toString() => 'CounterTimerRunInProgress { duration: $duration}';
}

final class CounterTimerRunComplete extends CounterTimerState {
  const CounterTimerRunComplete() : super(0);
}

final class CounterTimerRunSuccess extends CounterTimerState {
  const CounterTimerRunSuccess() : super(10);

  @override
  String toString() => 'CounterTimerRunSuccess { duration: $duration}';
}

final class CounterTimerRunIncrement extends CounterTimerState {
  const CounterTimerRunIncrement(super.duration);

  @override
  String toString() => 'CounterTimerRunIncrement { duration: $duration}';
}

final class CounterTimerRunDecrement extends CounterTimerState {
  const CounterTimerRunDecrement(super.duration);

  @override
  String toString() => 'CounterTimerRunDecrement { duration: $duration}';
}
