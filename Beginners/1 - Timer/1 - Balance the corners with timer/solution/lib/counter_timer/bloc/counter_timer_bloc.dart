import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:solution/ticker.dart';

part 'counter_timer_event.dart';
part 'counter_timer_state.dart';

class CounterTimerBloc extends Bloc<CounterTimerEvent, CounterTimerState> {
  static const int _duration = 10;
  final Ticker _ticker;

  StreamSubscription<int>? _tickerSubscription;

  CounterTimerBloc({required Ticker ticker})
      : _ticker = ticker,
        super(const CounterTimerInitial(_duration)) {
    on<TimerStarted>(_onStarted);
    on<_TimerTicked>(_onTicked);
    on<TimerPaused>(_onPaused);
    on<TimerResumed>(_onResumed);
    on<TimerReset>(_onReset);
    on<CounterIncremented>(_onIncremented);
    on<CounterDecremented>(_onDecremented);
    on<RunCompleted>(_onRunCompleted);
  }
}
