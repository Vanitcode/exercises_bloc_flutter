import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solution/counter/counter.dart';
import 'package:solution/ticker.dart';
import '../../timer/timer.dart';

class CounterTimerPage extends StatelessWidget {
  const CounterTimerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CounterCubit>(
          create: (BuildContext context) => CounterCubit(),
        ),
        BlocProvider<TimerBloc>(
          create: (BuildContext context) => TimerBloc(ticker: const Ticker()),
        ),
      ],
      child: const CounterTimerView(),
    );
  }
}

class CounterTimerView extends StatelessWidget {
  const CounterTimerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Counter Timer')),
      body: const Stack(
        children: [
          CounterView(),
          TimerView(),
        ],
      ),
    );
  }
}
