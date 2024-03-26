import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solution/counter/counter.dart';

class CounterView extends StatelessWidget {
  const CounterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          const CounterCheck(),
          GridView.count(
            crossAxisCount: 2,
            children: const [
              CounterComponent(index: 0),
              CounterComponent(index: 1),
              CounterComponent(index: 2),
              CounterComponent(index: 3),
            ],
          ),
        ],
      ),
    );
  }
}

class CounterCheck extends StatelessWidget {
  const CounterCheck({
    super.key,
  });
  List<int> generateSecretList() {
    List<int> randomList = [];
    for (int i = 0; i < 4; i++) {
      int randomNumber = Random().nextInt(10);
      randomList.add(randomNumber);
    }
    return randomList;
  }

  @override
  Widget build(BuildContext context) {
    List<int> secretList = generateSecretList();
    return Center(
      child: BlocBuilder<CounterCubit, List>(
        builder: (context, state) {
          return GridView.count(
            crossAxisCount: 2,
            children: [
              Container(
                color: state[0] == secretList[0] ? Colors.green : Colors.red,
              ),
              Container(
                color: state[1] == secretList[1] ? Colors.green : Colors.red,
              ),
              Container(
                color: state[2] == secretList[2] ? Colors.green : Colors.red,
              ),
              Container(
                color: state[3] == secretList[3] ? Colors.green : Colors.red,
              )
            ],
          );
        },
      ),
    );
  }
}

class CounterComponent extends StatelessWidget {
  const CounterComponent({super.key, required this.index});
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          BlocBuilder<CounterCubit, List>(
            builder: ((context, state) {
              return Text('${state[index]}');
            }),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton(
                child: const Icon(Icons.add),
                onPressed: () => context.read<CounterCubit>().increment(index),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                child: const Icon(Icons.remove),
                onPressed: () => context.read<CounterCubit>().decrement(index),
              )
            ],
          ),
        ]);
  }
}
