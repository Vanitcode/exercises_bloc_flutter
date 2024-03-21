# Solution
========================
## Add bloc dependency
 ```dart
 dart pub add bloc
 ```
 Also, we will work with `flutter_bloc`:
 ```dart
 dart pub add flutter_bloc
 ```
 
## Project Structure
 
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
    └── counter_observer.dart
    └── main.dart
```
As usual, we will use a feature-driven directory structure. That means, every features in our app is self-contained.

## Counter Observer -> the BlocObserver

This widget will help us to **observe** all state changes in the application.

At `lib/counter_observer.dart`:
```flutter
import 'package:bloc/bloc.dart';

/// {@template counter_observer}
/// [BlocObserver] for the counter application which
/// observes all state changes.
/// {@endtemplate}
class CounterObserver extends BlocObserver {
  /// {@macro counter_observer}
  const CounterObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    // ignore: avoid_print
    print('${bloc.runtimeType} $change');
  }
}
```
When we extend a `BlocObserver`, we must know that it is an interface with several methods: `onClose(), onError(), onChange()`... In this case, we just override the `onChange()` method to print when a change occurs in the state.

## main.dart
At `lib/main.dart`:
```flutter
import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_counter/app.dart';
import 'package:flutter_counter/counter_observer.dart';

void main() {
  Bloc.observer = const CounterObserver();
  runApp(const CounterApp());
}
```

We are just initializing the `CounterObserver`we just created in the previous step. Also, we are calling a `CounterApp` widget which will be build at next.

## Counter App
At `lib/app.dart`:
``` flutter
import 'package:flutter/material.dart';
import 'package:flutter_counter/counter/counter.dart';

/// {@template counter_app}
/// A [MaterialApp] which sets the `home` to [CounterPage].
/// {@endtemplate}
class CounterApp extends MaterialApp {
  /// {@macro counter_app}
  const CounterApp({super.key}) : super(home: const CounterPage());
}
```
As we can see, this is just a `MaterialApp`with a `CounterPage`widget as the default route of the app.

## Counter Page
Here, the `CounterCubit` and the `CounterView` are created by the `CounterPage`widget.
In order to have a clean code, it is recommended to separate the creation of a `Cubit` from his consumption.
So, at `lib/counter/view/counter_page.dart`:
```
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_counter/counter/counter.dart';

/// {@template counter_page}
/// A [StatelessWidget] which is responsible for providing a
/// [CounterCubit] instance to the [CounterView].
/// {@endtemplate}
class CounterPage extends StatelessWidget {
  /// {@macro counter_page}
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CounterCubit(),
      child: const CounterView(),
    );
  }
}
```
## Counter Cubit
Where the logic takes place. We must remember that our mechanics consist of adding and subtracting one to the current state. So that, we need two methods:
* `increment`: adds 1 to the current state.
* `decrement`: subtracts 1 from the current state.
Our state is just an `int` and the initial state could be `0`.

So that, at `lib/counter/cubit/counter_cubit.dart`:
```flutter
import 'package:bloc/bloc.dart';

/// {@template counter_cubit}
/// A [Cubit] which manages an [int] as its state.
/// {@endtemplate}
class CounterCubit extends Cubit<int> {
  /// {@macro counter_cubit}
  CounterCubit() : super(0);

  /// Add 1 to the current state.
  void increment() => emit(state + 1);

  /// Subtract 1 from the current state.
  void decrement() => emit(state - 1);
}
```
## Counter View
Where the UI takes place. The `CounterView`is responsible for rendering the view, consuming the state and interacting with the `CounterCubit`.
At `lib/counter/view/counter_view.dart`:

```flutter
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_counter/counter/counter.dart';

/// {@template counter_view}
/// A [StatelessWidget] which reacts to the provided
/// [CounterCubit] state and notifies it in response to user input.
/// {@endtemplate}
class CounterView extends StatelessWidget {
  /// {@macro counter_view}
  const CounterView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: Center(
        child: BlocBuilder<CounterCubit, int>(
          builder: (context, state) {
            return Text('$state', style: textTheme.displayMedium);
          },
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            key: const Key('counterView_increment_floatingActionButton'),
            child: const Icon(Icons.add),
            onPressed: () => context.read<CounterCubit>().increment(),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            key: const Key('counterView_decrement_floatingActionButton'),
            child: const Icon(Icons.remove),
            onPressed: () => context.read<CounterCubit>().decrement(),
          ),
        ],
      ),
    );
  }
}
```
As we can see, we just wrapped the `Text` widget with the `BlocBuilder`. So, only this widget will be rebuilt in response to the state changes.

For more information about *Flutter Bloc Concepts*, you should visit the [bloc library docs](https://bloclibrary.dev/flutter-bloc-concepts/).

## Barrel
A barrel is a convenient way to roll up exports from several modules into a single module, which fits with our approach of making a feature-driven directory structure.

At `lib/counter/view/view.dart`:
```flutter
export 'counter_page.dart';
export 'counter_view.dart';
```
Also, add this at `lib/counter/counter.dart`:
```flutter
export 'cubit/counter_cubit.dart';
export 'view/view.dart';
```

## Knowledge check
We finish! We have separated the presentation layer (`CounterView`) from the business logic layer (`CounterCubit`). Try `flutter run`to run your mechanics.