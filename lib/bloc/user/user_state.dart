import 'package:fish_caster/model/user_model/user_model.dart';

abstract class UserState {}

class UserInitial extends UserState {}

class UserLoaded extends UserState {
  final UserModel user;

  UserLoaded({required this.user});
}

class UserError extends UserState {
  final String error;

  UserError({required this.error});
}

class UserLoading extends UserState {}

class UserRedirectToSetup extends UserState {}

class UserRedirectToHome extends UserState {}

class UserProfileUpdated extends UserState {}

class UserProfileUpdateError extends UserState {
  final String error;

  UserProfileUpdateError({required this.error});

  @override
  List<Object> get props => [error]; // For comparison in Equatable
}
