abstract class TokenState {}

class TokenInitial extends TokenState {}

class TokenLoaded extends TokenState {
  final String token;
  final String refreshToken;
  TokenLoaded(this.token, this.refreshToken);
}
