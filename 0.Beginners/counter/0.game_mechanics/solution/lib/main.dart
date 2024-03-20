import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:solution/app.dart';
import 'package:solution/counter_observer.dart';

void main() {
  Bloc.observer = const CounterObserver();
  runApp(const CounterApp());
}
