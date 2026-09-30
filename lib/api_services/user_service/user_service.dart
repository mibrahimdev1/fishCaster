
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:fish_caster/core/string_cons.dart';
import 'package:fish_caster/model/user_model/user_model.dart';
import 'package:http/http.dart' as http;

class UserService {
  static Future<UserModel?> updateUserProfile({
    required String token,
    required String name,
    required String country,
    required String state,
    required String city,
    required String zipCode,
    required String userId,
  }) async {
    try {
      final url = Uri.parse(
        '${StringCons.baseApiUrl}/users/$userId',
      ); // Updated URL to include userId

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final body = json.encode({
        'name': name,
        'country': country,
        'state': state,
        'city': city,
        'zipCode': zipCode,
      });

      final response = await http.patch(url, headers: headers, body: body);
      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Create UserModel from the nested response
        return UserModel.fromJson(data);
      } else {
        print(
          "Failed to update profile: ${response.statusCode} - ${response.body}",
        );
        return null;
      }
    } catch (e) {
      print("Error updating profile: $e");
      return null;
    }
  }
}
