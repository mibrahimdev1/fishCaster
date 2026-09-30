abstract class TokenEvent {}

class SaveTokenEvent extends TokenEvent {
  final String token;
  final String refreshToken;
  SaveTokenEvent(this.token, this.refreshToken);
}

class GetTokenEvent extends TokenEvent {}
