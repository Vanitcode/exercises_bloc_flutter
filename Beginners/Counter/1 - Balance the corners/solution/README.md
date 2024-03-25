# Solution

## Add the dependency
 ```dart
 dart pub add bloc
 ```
 Also, we will work with `flutter_bloc`:
 ```dart
 dart pub add flutter_bloc
 ```
 
## Directory structure
```
└── 📁lib
    └── app.dart
    └── 📁counter
        └── counter.dart
        └── 📁cubit
            └── counter_cubit.dart
        └── 📁view
            └── counter_page.dart
            └── counter_view.dart
            └── view.dart
    └── main.dart
```
In this case, we will keep the same structure. However, `counter_cubit`is going to be modified to manage the logic of the 4 `int` states.  In addition, of course, the `counter_view`will change.

## Building the CounterCubit

In the previous exercise,  we created a Cubit which managed a single `int` state. Now, we need to create a Cubit which manages the state of four `int`values at the same time. One clean and simple solution is to create a `class` which extends of a `Cubit<List<int>>`.
So that, at `lib/counter/cubit/counter_cubit.dart`:

```flutter
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
```
Pay attention to the conditions. This way we will ensure that we do not exceed the values we want for the states.

## The CounterPage
Nothing changes here! Why it have to change?
At `lib/counter/view/counter_page.dart`:
```flutter
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solution/counter/counter.dart';

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocProvider<CounterCubit>(
      create: (_) => CounterCubit(),
      child: const CounterView(),
    );
  }
}
```
## The big change: CounterView
The following code is only one of the many solutions. You just have to remember how to access the Cubit functions through `context.read<CounterCubit>().` and to build a `BlocBuilder` every time we want to show the current state in the UI.

```flutter
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

```

**Note**: aware that the generation of the list of secret numbers is not in the best place, the solution could vary in future updates.

## Barrel
Let's expose our fancy components. At `lib/counter/view/view.dart`:
```flutter
export 'counter_page.dart';
export 'counter_view.dart';
```
## The App
At `lib/app.dart`:
```flutter
import 'package:flutter/material.dart';
import 'package:solution/counter/counter.dart';

class BalanceCornerApp extends MaterialApp {
  const BalanceCornerApp({super.key}) : super(home: const CounterPage());
}
```
## Main
And, finally, at `lib/main.dart`:
```flutter
import 'package:flutter/widgets.dart';
import 'package:solution/app.dart';

void main() {
  runApp(const BalanceCornerApp());
}
```
