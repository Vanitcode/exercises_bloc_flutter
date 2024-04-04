# Solution

## Add the dependency

 ```
 dart pub add bloc
 ```
 
 Also, we will work with `flutter_bloc`:
 
 ```
 dart pub add flutter_bloc
 ```
 
 And the Equatable package:
 ```
 dart pub add equatable
 ```
 
## Directory structure
 
 This is the directory structure proposed:
 
```
└── 📁lib
    └── app.dart
    └── main.dart
    └── ticker.dart
    └── 📁timer
        └── 📁bloc
            └── timer_bloc.dart
            └── timer_event.dart
            └── timer_state.dart
        └── timer.dart
        └── 📁view
            └── timer_page.dart
```

As usually, a feature-driven structure.

## Ticker

The Ticker must be a stream of integer values that are periodically emitted every second. The aim of this Ticker will be exposed it and we will subscribe and react to it.
So that, at `lib/ticker.dart`:
```flutter
class Ticker {
  const Ticker();
  Stream<int> tick({required int ticks}) {
    return Stream.periodic(const Duration(seconds: 1), (x) => ticks - x - 1)
        .take(ticks);
  }
}
```

## Timer Bloc

Now, it's time to ask ourselves about the Timer-bloc design. Remember that a `Bloc`is a class which relies on  `events`to *trigger* `state`changes. Let's create their respective classes.

### TimerState

Thinking about the state which the `TimerBloc`can be in, we will find the next possibilities:
- `TimerInitial`: ready to start counting down from the specified duration.
- `TimerRunInProgress`: actively counting down from the specified duration.
- `TimerRunPause`: paused at some remaining duration.
- `TimerRunComplete`: completed with a remaining duration of 0.

The user interface will change based on the states described above.

So that, we can write our `TimerState`class at `lib/timer/bloc/timer_state.dart`:

```flutter
part of 'timer_bloc.dart';

sealed class TimerState extends Equatable {
  const TimerState(this.duration);
  final int duration;

  @override
  List<Object> get props => [duration];
}

final class TimerInitial extends TimerState {
  const TimerInitial(super.duration);

  @override
  String toString() => 'TimerInitial { duration: $duration }';
}

final class TimerRunPause extends TimerState {
  const TimerRunPause(super.duration);

  @override
  String toString() => 'TimerRunPause { duration: $duration }';
}

final class TimerRunInProgress extends TimerState {
  const TimerRunInProgress(super.duration);

  @override
  String toString() => 'TimerRunInProgress { duration: $duration }';
}

final class TimerRunComplete extends TimerState {
  const TimerRunComplete() : super(0);
}
```

All the `TimerStates`extend the abstract base class `TimerState`which has a *duration* property. Thanks this property, we will know how much time is remaining from any state.

### TimerEvent
With the states defined, we can proceed to define the event class. Let's think about all the possibles events:
 - `TimerStarted`: informs to the `TimerBloc` that the timer should be started.
 - `TimerPaused`: informs the `TimerBloc` that the timer should be paused.
 - `TimerResumed`: informs the `TimerBloc` that the timer should be resumed.
 - `TimerReset`: informs the `TimerBloc` that the timer should be reset to the original state.
 - `_TimerTicked`: informs the `TimerBloc` that a tick has occurred and that it needs to update its state accordingly.

Tip: a good way to obtain the possible events is to think about the transitions that can occur from one of the previous states to another. However, this could be enough. In this case, we have to add the `_TimerTicked` event.

So, at `lib/timer/bloc/timer_event.dart`:

```flutter
part of 'timer_bloc.dart';

sealed class TimerEvent {
  const TimerEvent();
}

final class TimerStarted extends TimerEvent {
  const TimerStarted({required this.duration});
  final int duration;
}

final class TimerPaused extends TimerEvent {
  const TimerPaused();
}

final class TimerResumed extends TimerEvent {
  const TimerResumed();
}

class TimerReset extends TimerEvent {
  const TimerReset();
}

class _TimerTicked extends TimerEvent {
  const _TimerTicked({required this.duration});
  final int duration;
}
```

### TimerBloc
At this part, we have to register *event handlers* via the `on<Event>`API. As said in the [bloclibrary](https://bloclibrary.dev/bloc-concepts/#:~:text=An%20event%20handler%20is%20responsible%20for%20converting%20any%20incoming%20events%20into%20zero%20or%20more%20outgoing%20states.) documentation, **an event handler is responsible for converting any incoming events into zero or more outgoing states**. Let's describe them one by one and we will see the full code at the final of this chapter.

#### TimerBloc constructor
The initial state of our Timer will be `TimerInitial` with a preset duration of 60 seconds. Also, we need to define the dependency on our previous `Ticker` and create an instance of a `StreamSubscrption<int>`. All  this leads us to the following:

 `lib/timer/bloc/timer_bloc.dart`
```flutter
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter_timer/ticker.dart';

part 'timer_event.dart';
part 'timer_state.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  final Ticker _ticker;
  static const int _duration = 60;

  StreamSubscription<int>? _tickerSubscription;

  TimerBloc({required Ticker ticker})
      : _ticker = ticker,
        super(TimerInitial(_duration)) {
  }
}
```

#### Override the close() function
Honestly, I always forget these types of situations. We should worry about canceling the Stream subscription in case the Bloc closes:

```flutter
@override
Future<void> close() {
_tickerSubscription?.cancel();
return super.close();
}

```

#### TimerStarted event handler function
This could be the most tricky function. We need to handle two situations:
 - Push a `TimerRunInProgress`state.
 - Cancel any possible `_tickerSubscription` already open and listen/subscribe to a new stream of "ticks". Without forget, that we will need to add a `_TimerTicked` event for every tick that we listen from the Stream.

```flutter
void _onStarted(TimerStarted event, Emitter<TimerState> emit) {
    emit(TimerRunInProgress(event.duration));
    _tickerSubscription?.cancel();
    _tickerSubscription = _ticker
        .tick(ticks: event.duration)
        .listen((duration) => add(_TimerTicked(duration: duration)));
  }
```

The method `add()` notifies the `Bloc` of a new `event` which triggers all corresponding `EventHandler` instances. In this case, it notifies about a `_TimerTicked` event.
**Note**.  In this step, we are sending the int value of the Stream to the Bloc. Now, we can access to this value via de event handlers.


#### TimerTicked event handler function
Every time a `_TimerTicked` event is received, if the tick’s duration is greater than 0, we need to push an updated `TimerRunInProgress` state with the new duration. Otherwise, if the tick’s duration is 0, our timer has ended and we need to push a `TimerRunComplete` state.
```flutter
void _onTicked(_TimerTicked event, Emitter<TimerState> emit) {
    emit(
      event.duration > 0
          ? TimerRunInProgress(event.duration)
          : TimerRunComplete(),
    );
}
```

#### TimerPaused event handler function

The user will be able to push the future Pause button only when the timing is running. So that:
```flutter
void _onPaused(TimerPaused event, Emitter<TimerState> emit) {
    if (state is TimerRunInProgress) {
      _tickerSubscription?.pause();
      emit(TimerRunPause(state.duration));
    }
}
```

#### TimerResumed event handler function

Very similar to the idea in the previous function:

```flutter
void _onResumed(TimerResumed resume, Emitter<TimerState> emit) {
    if (state is TimerRunPause) {
      _tickerSubscription?.resume();
      emit(TimerRunInProgress(state.duration));
    }
  }
```

#### TimerReset event handler function

Just be sure to cancel the subscription:

``` flutter
void _onReset(TimerReset event, Emitter<TimerState> emit) {
    _tickerSubscription?.cancel();
    emit(const TimerInitial(_duration));
  }
```
 
##  Application UI

### Main
This part is easy. At `lib/main.dart`:
```flutter
import 'package:flutter/material.dart';
import 'package:flutter_timer/app.dart';

void main() => runApp(const App());
```
### App
Just a simple `MaterialApp`, for example:
```flutter
import 'package:flutter/material.dart';
import 'package:flutter_timer/timer/timer.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Timer',
      theme: ThemeData(
        colorScheme: const ColorScheme.light(
          primary: Color.fromRGBO(72, 74, 126, 1),
        ),
      ),
      home: const TimerPage(),
    );
  }
}
```
Let's build that `TimerPage()`.

### TimerPage
This widget will be responsible for displaying the remaining time and the corresponding buttons to control the timer. Such as start, reset and pause.
To avoid nesting blocks and get the hilarious [Hadouken identation](https://external-preview.redd.it/6TTm4tS5pMCiq2KlgviubpGKt1QzvetOi2Z6Z3lB1Nc.jpg?width=640&crop=smart&auto=webp&s=cd2af28be432a66e51aab2acdfa8988d522c87d2) we will divide this `TimerPage` widget in several widgets. Let's see them one by one and we will get the full code at the final of this section.

At `lib/timer/view/timer_page.dart`:

```flutter
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_timer/ticker.dart';
import 'package:flutter_timer/timer/timer.dart';

class TimerPage extends StatelessWidget {
  const TimerPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TimerBloc(ticker: Ticker()),
      child: const TimerView(),
    );
  }
}
```

This step is simple. We create a widget which returns a `BlocProvider`widgets. This allow us to access the instance of our `TimerBloc`. Let's define that `TimerView()` widget.

```flutter
class TimerView extends StatelessWidget {
  const TimerView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Timer')),
      body: Stack(
        children: [
          const Background(),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(vertical: 100.0),
                child: Center(child: TimerText()),
              ),
              Actions(),
            ],
          ),
        ],
      ),
    );
  }
}
```
This consists of a stack of different widgets.

The `Background` widget could be a Linear Gradient in a `Box Decoration` for example:
```flutter
class Background extends StatelessWidget {
  const Background({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blue.shade50,
            Colors.blue.shade500,
          ],
        ),
      ),
    );
  }
}
```

The `TimerText()`widget will show the property duration of the state. Just because we only need this small part of the state, we can access to it with `context.select`:
```flutter
class TimerText extends StatelessWidget {
  const TimerText({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final duration = context.select((TimerBloc bloc) => bloc.state.duration);
    final minutesStr =
        ((duration / 60) % 60).floor().toString().padLeft(2, '0');
    final secondsStr = (duration % 60).floor().toString().padLeft(2, '0');
    return Text(
      '$minutesStr:$secondsStr',
      style: Theme.of(context).textTheme.headline1,
    );
  }
}
```
Finally, we will define the `Actions` widget, where the buttons to control the Timer will change in function of the state of the Bloc.

```flutter
class Actions extends StatelessWidget {
  const Actions({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimerBloc, TimerState>(
      buildWhen: (prev, state) => prev.runtimeType != state.runtimeType,
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ...switch (state) {
              TimerInitial() => [
                  FloatingActionButton(
                    child: const Icon(Icons.play_arrow),
                    onPressed: () => context
                        .read<TimerBloc>()
                        .add(TimerStarted(duration: state.duration)),
                  ),
                ],
              TimerRunInProgress() => [
                  FloatingActionButton(
                    child: const Icon(Icons.pause),
                    onPressed: () =>
                        context.read<TimerBloc>().add(const TimerPaused()),
                  ),
                  FloatingActionButton(
                    child: const Icon(Icons.replay),
                    onPressed: () =>
                        context.read<TimerBloc>().add(const TimerReset()),
                  ),
                ],
              TimerRunPause() => [
                  FloatingActionButton(
                    child: const Icon(Icons.play_arrow),
                    onPressed: () =>
                        context.read<TimerBloc>().add(const TimerResumed()),
                  ),
                  FloatingActionButton(
                    child: const Icon(Icons.replay),
                    onPressed: () =>
                        context.read<TimerBloc>().add(const TimerReset()),
                  ),
                ],
              TimerRunComplete() => [
                  FloatingActionButton(
                    child: const Icon(Icons.replay),
                    onPressed: () =>
                        context.read<TimerBloc>().add(const TimerReset()),
                  ),
                ]
            }
          ],
        );
      },
    );
  }
}
```
Note how the user can add events to the Bloc when he presses the buttons.
By the way, I have used an *spread operator* inside the children of the Row (. . .). This operator is used within a list to **unpack** the elements from another list that is generated within a switch based on the state.

## Barrel
Let's export our fancy Timer:
At `lib/timer/timer.dart`:
```flutter
export 'bloc/timer_bloc.dart';
export 'view/timer_page.dart';
```

## Knowledge check
We finish! We've created a Bloc which subscribes a Stream of int. Also, we've created a responsive state page which allows to the user control the Timer without implementing any logic of this. Try `flutter run`to run your mechanics.