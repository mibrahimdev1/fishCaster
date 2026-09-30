import 'package:flutter_bloc/flutter_bloc.dart';
import 'token_event.dart';
import 'token_state.dart';

class TokenBloc extends Bloc<TokenEvent, TokenState> {
  TokenBloc() : super(TokenInitial()) {
    // Handle SaveTokenEvent
    on<SaveTokenEvent>((event, emit) {
      print("📢 Storing token in BLoC: ${event.token}");
      emit(TokenLoaded(event.token, event.refreshToken));
      print("🎉 Token successfully stored in BLoC: ${event.token}");
    });

    // Handle GetTokenEvent
    on<GetTokenEvent>((event, emit) {
      if (state is TokenLoaded) {
        // If the token is already loaded, emit it back
        print("📢 Retrieving stored token: ${(state as TokenLoaded).token}");
        emit(
          TokenLoaded(
            (state as TokenLoaded).token,
            (state as TokenLoaded).refreshToken,
          ),
        );
      } else {
        print("❌ No token found");
        emit(TokenInitial()); // No token available, reset to initial state
      }
    });
  }
}
