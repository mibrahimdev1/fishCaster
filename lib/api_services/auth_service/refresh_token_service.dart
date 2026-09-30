// import 'dart:convert';
// import 'package:fish_caster/bloc/token/token_bloc.dart';
// import 'package:fish_caster/bloc/token/token_event.dart';
// import 'package:fish_caster/core/string_cons.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';

// class RefreshTokenService {
//   static const String _baseUrl = "${StringCons.baseApiUrl}";

//   // Static method receives TokenBloc as a parameter
//   static Future<Map<String, dynamic>?> refreshToken({
//     required String refreshToken,
//     required TokenBloc tokenBloc, // Add TokenBloc as parameter
//   }) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$_baseUrl/auth/refresh-tokens'),
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode({"refreshToken": refreshToken}),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         print("Regain Token: $data");

//         // Extract access and refresh tokens from the response
//         final String accessToken = data['access']['token'];
//         final String refreshToken = data['refresh']['token'];

//         // Save tokens into BLoC
//         tokenBloc.add(SaveTokenEvent(accessToken, refreshToken));
//         final prefs = await SharedPreferences.getInstance();

//         await prefs.setString('refreshToken', data["refresh"]["token"]);

//         return data;
//       } else {
//         print("❌ Login failed: ${response.body}");
//         final prefs = await SharedPreferences.getInstance();

//         await prefs.clear();

//         return null;
//       }
//     } catch (e) {
//       print("⚠️ Error during login: $e");
//       return null;
//     }
//   }
// }
import 'dart:convert';
import 'package:fish_caster/bloc/token/token_bloc.dart';
import 'package:fish_caster/bloc/token/token_event.dart';
import 'package:fish_caster/core/string_cons.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RefreshTokenService {
    static const String _baseUrl = "${StringCons.baseApiUrl}";

    static Future<Map<String, dynamic>?> refreshToken({
        required String refreshToken,
        required TokenBloc tokenBloc,
    }) async {
        try {
            final response = await http.post(
                Uri.parse('$_baseUrl/auth/refresh-tokens'),
                headers: {"Content-Type": "application/json"},
                body: jsonEncode({"refreshToken": refreshToken}),
            );

            final prefs = await SharedPreferences.getInstance();

            if (response.statusCode == 200) {
                final data = jsonDecode(response.body);
                print("✅ Refreshed Tokens: $data");

                final String newAccessToken = data['access']['token'];
                final String newRefreshToken = data['refresh']['token'];

                // Update tokens in Bloc
                tokenBloc.add(SaveTokenEvent(newAccessToken, newRefreshToken));

                // Store in SharedPreferences
                await prefs.setString('refreshToken', newRefreshToken);

                return data;
            } else if (response.statusCode == 401 || response.statusCode == 403) {
                print("⚠️ Refresh token invalid or expired. Response: ${response.body}");
                await prefs.clear();
                return null;
            } else {
                print("❌ Unexpected error: ${response.statusCode}, Body: ${response.body}");
                return null;
            }
        } catch (e) {
            print("❌ Exception during token refresh: $e");
            return null;
        }
    }
}
