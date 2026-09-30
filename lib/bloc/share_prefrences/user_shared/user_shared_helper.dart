import 'dart:convert';
import 'package:fish_caster/api_services/auth_service/refresh_token_service.dart';
import 'package:fish_caster/bloc/token/token_bloc.dart';
import 'package:fish_caster/bloc/user/user_bloc.dart';
import 'package:fish_caster/bloc/user/user_event.dart';
import 'package:fish_caster/model/user_model/user_model.dart';
import 'package:fish_caster/screen/auth_screen/loginScreen.dart';
import 'package:fish_caster/screen/home_screen/homeScreen.dart';
import 'package:fish_caster/widgets/snackBar/gloabal_snack.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveUserModel(UserModel user) async {
  final prefs = await SharedPreferences.getInstance();

  // Convert UserModel to JSON string
  String userJson = json.encode(user.toJson());

  // Save the JSON string in SharedPreferences
  await prefs.setString('user', userJson);

  print("User data saved to SharedPreferences ${userJson}");
}

Future<UserModel?> getUserModel() async {
  final prefs = await SharedPreferences.getInstance();
  String? userJson = prefs.getString('user');

  if (userJson != null) {
    Map<String, dynamic> userMap = json.decode(userJson);
    print("Shared Get User: $userMap");
    return UserModel.fromJson(userMap);
  } else {
    print("No user data found in SharedPreferences.");
    return null;
  }
}
Future<void> loadUserAndSaveToBloc(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refreshToken');
    print("🪪 Refresh Token: $refreshToken");

    if (refreshToken == null) {
        print("⚠️ No refresh token found.");
        _forceLogout(context, "Session expired. Please log in again.");
        return;
    }

    try {
        // Attempt token refresh
        final tokenResponse = await RefreshTokenService.refreshToken(
            refreshToken: refreshToken,
            tokenBloc: BlocProvider.of<TokenBloc>(context, listen: false),
        );

        if (tokenResponse == null || tokenResponse['access'] == null) {
            print("❌ Token refresh failed.");
            _forceLogout(context, "Session expired. Please log in again.");
            return;
        }

        final user = await getUserModel();

        if (user == null) {
            print("❌ Failed to fetch user after refresh.");
            _forceLogout(context, "Session expired. Please log in again.");
            return;
        }

        print("✅ User loaded: ${user.email}");

        BlocProvider.of<UserBloc>(context, listen: false)
            .add(SaveUserEvent(user: user));

        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => HomeScreen()),
        );
    } catch (e) {
        print("🚨 Error during session restore: $e");
        _forceLogout(context, "Session expired. Please log in again.");
    }
}

void _forceLogout(BuildContext context, String message) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    globalSnack.showSnackBar(context, message);
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => Loginscreen()),
        (route) => false,
    );
}

// void loadUserAndSaveToBloc(BuildContext context) async {
//   final prefs = await SharedPreferences.getInstance();

//   String? sharedRefreshToken = prefs.getString('refreshToken');

//   print("Refresh Token: $sharedRefreshToken");

//   if (sharedRefreshToken != null) {
//     final user = await getUserModel();

//     // Calling refreshToken with the TokenBloc
//     final tokenResponse = await RefreshTokenService.refreshToken(
//       refreshToken: sharedRefreshToken,
//       tokenBloc: BlocProvider.of<TokenBloc>(
//         context,
//         listen: false,
//       ), // Pass the TokenBloc
//     );

//     // If the response was successful, handle the navigation
//     if (tokenResponse != null && tokenResponse['access'] != null) {
//       // If the user is found, handle the user saving event
//       if (user != null) {
//         print("🚀 User found: ${user.email}");
//         BlocProvider.of<UserBloc>(
//           context,
//           listen: false,
//         ).add(SaveUserEvent(user: user));

//         //  if (user.profile == null) {
//         //   print("🔄 User profile is missing, redirecting to Profile Setup Screen.");

//         // } else {
//         //   print("✅ User profile found, navigating to Home Screen.");

//         // }

//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => HomeScreen()),
//         );
//       } else {
//         print("❌ No user data found in SharedPreferences");
//         globalSnack.showSnackBar(context, "Session Expired");

//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => Loginscreen()),
//         );
//       }
//     } else {
//       print("❌ Token refresh failed. Navigating to login...");
//       globalSnack.showSnackBar(context, "Session Expired");

//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => Loginscreen()),
//       );
//     }
//   } else {
//     print("❌ Refresh Token is null");
//     // globalSnack.showSnackBar(context, "Session Expired");
//     // Navigate to LoginScreen if the refresh token is null
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (context) => Loginscreen()),
//     );
//   }
// }

void clearSharedPreferencesAndLogout(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();

  // Clear all data from SharedPreferences
  await prefs.clear();

  // Optionally, you can also remove specific keys like this:
  // await prefs.remove('refreshToken'); // If you want to clear just a specific key

  print("✅ SharedPreferences cleared");

  // After clearing the SharedPreferences, navigate to LoginScreen
  // Navigator.pushReplacementNamed(context, '/login');
}
