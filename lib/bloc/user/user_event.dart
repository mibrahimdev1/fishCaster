import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:fish_caster/model/user_model/user_model.dart';

abstract class UserEvent {}

class SaveUserEvent extends UserEvent {
  final UserModel user;

  SaveUserEvent({required this.user});
}

class GetUserEvent extends UserEvent {
  // You can add any parameters if needed (like userId)
}

// class UpdateUserProfileEvent extends UserEvent with EquatableMixin {
//   final String name;
//   final String? firstName;
//   final String? lastName;

//   UpdateUserProfileEvent({
//     required this.name,
//     this.firstName,
//     this.lastName,
//   });

//   @override
//   List<Object> get props => [
//         dob,
//         profilePicture,
//         displayName,
//         firstName ?? '',
//         lastName ?? '',
//       ]; // Ensures comparison is based on the properties
// }

class LoginUserEvent extends UserEvent {
  final String email;
  final String password;

  LoginUserEvent({required this.email, required this.password});
}

class GoogleLoginEvent extends UserEvent {
  final String token;
  final String fcmToken;

  GoogleLoginEvent({required this.token, required this.fcmToken});

  @override
  List<Object?> get props => [token, fcmToken];
}

class UpdateProfileEvent extends UserEvent {
  final String token;
  final String userId;
  final String? name;
  final String? email;
  final String? country;
  final String? state;
  final String? city;
  final String? zipCode;

  UpdateProfileEvent({
    required this.token,
    required this.userId,
    this.name,
    this.email,
    this.country,
    this.state,
    this.city,
    this.zipCode,
  });

  @override
  List<Object?> get props => [
    token,
    userId,
    name,
    email,
    country,
    state,
    city,
    zipCode,
  ];
}

class UpdatePriceIdEvent extends UserEvent {
  final String newPriceId;

  UpdatePriceIdEvent(this.newPriceId);

  @override
  List<Object> get props => [newPriceId];
}
