part of 'counter_timer_bloc.dart';

sealed class CounterTimerEvent {
  const CounterTimerEvent();
}

final class TimerStarted extends CounterTimerEvent {
  const TimerStarted({required this.duration});
  final int duration;
}

final class TimerPaused extends CounterTimerEvent {
  const TimerPaused();
}

final class TimerResumed extends CounterTimerEvent {
  const TimerResumed();
}

final class TimerReset extends CounterTimerEvent {
  const TimerReset();
}

final class _TimerTicked extends CounterTimerEvent {
  const _TimerTicked({required this.duration});
  final int duration;
}

final class CounterIncremented extends CounterTimerEvent {
  const CounterIncremented();
}

final class CounterDecremented extends CounterTimerEvent {
  const CounterDecremented();
}

final class RunCompleted extends CounterTimerEvent {
  const RunCompleted();
}
