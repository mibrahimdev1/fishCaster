import 'dart:convert';
import 'package:fish_caster/import_file.dart';
import 'package:fish_caster/core/string_cons.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static const String _baseUrl = "${StringCons.baseApiUrl}";

  Future<Map<String, String>?> registerUser(
    BuildContext context,
    String email,
    String password,
    String name,
    String country,
    String state,
    String city,
    String zip,
  ) async {
    try {
      // final fcToken = await FirebaseApi.getDevicetoken();
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "name": name,
          "email": email,
          "password": password,
          "country": country,
          "state": state,
          "city": city,
          "zipCode": zip,
          // "fcmToken": fcToken
        }),
      );

      final data = response.body.isNotEmpty ? json.decode(response.body) : {};

      if (response.statusCode == 200 || response.statusCode == 201) {
        String accessToken = data["tokens"]["access"]["token"];
        String refreshToken = data["tokens"]["refresh"]["token"];

        print(
          "User Registered, Access Token: $accessToken, Refresh Token: $refreshToken",
        );

        globalSnack.showSnackBar(
          context,
          "User registered successfully! Please login.",
        );

        return {
          "accessToken": accessToken,
          "refreshToken": refreshToken,
        }; // Return both tokens
      } else {
        print("Registration failed: ${data["message"]}");
        globalSnack.showSnackBar(
          context,
          "Registration failed: ${data["message"]}",
        );

        return null;
      }
    } catch (e) {
      print("Error during registration: $e");
      globalSnack.showSnackBar(context, "Error during registration: $e");
      return null;
    }
  }

  // static Future<Map<String, dynamic>?> login({
  //   required String email,
  //   required String password,
  //   required String fcmToken,
  // }) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse('$_baseUrl/auth/login'),
  //       headers: {"Content-Type": "application/json"},
  //       body: jsonEncode({"email": email, "password": password, "fcmToken" : fcmToken}),
  //     );

  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       print("User Response: $data");
  //       return data; // Contains "user" and "tokens"
  //     } else {
  //       print("❌ Login failed: ${response.body}");
  //       return null;
  //     }
  //   } catch (e) {
  //     print("⚠️ Error during login: $e");
  //     return null;
  //   }
  // }

  static Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
    // required String fcmToken,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print("User Response: $data");
        return data; // Successful response
      } else {
        print("❌ Login failed: $data"); // Show full response
        return {
          "error": data["message"] ?? "Login failed",
        }; // Return error message
      }
    } catch (e) {
      print("⚠️ Error during login: $e");
      return {
        "error": "Something went wrong. Please try again.",
      }; // Return generic error
    }
  }

  static Future<Map<String, dynamic>?> googleSignIn({
    required String idToken,
  }) async {
    // try {
    final response = await http.post(
      Uri.parse("$_baseUrl/auth/google"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"token": idToken}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      print("✅ API Response: $data");

      return data; // ✅ Return the response data
    } else {
      print("❌ API Error: ${response.statusCode}, Body: ${response.body}");
      return null;
    }
    // } catch (e) {
    //   print("❌ API Request Failed: $e");
    //   return null;
    // }
  }

  static Future<Map<String, dynamic>?> appleSignIn({
    required String identityToken,
    required String authorizationCode,
    required String fullName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/auth/apple"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "identityToken": identityToken,
          // "authorizationCode": authorizationCode,
          "fullName": "fullName",
          "action": 'signup',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print("✅ Apple Sign-In API Response: $data");
        return data;
      } else {
        print("❌ Apple Sign-In Failed: ${response.body}");
        return {
          "error":
              jsonDecode(response.body)["message"] ?? "Apple Sign-In failed",
        };
      }
    } catch (e) {
      print("❌ Apple Sign-In Error: $e");
      return {"error": "Something went wrong during Apple Sign-In."};
    }
  }

  static Future<Map<String, dynamic>?> logoutService({
    required String refreshToken,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/logout'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"refreshToken": refreshToken}),
      );

      if (response.statusCode == 204) {
      } else {
        print("❌ Login failed: ${response.body}");
        return null;
      }
    } catch (e) {
      print("⚠️ Error during login: $e");
      return null;
    }
    return null;
  }
}
