import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User(this.id);
  final String id;

  @override
  List<Object> get props => [id];

  static const empty = User('i');
}

//Otras propiedades que podría tener el Usuario: firstName, lastName, avatarUrl