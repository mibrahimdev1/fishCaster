import 'dart:convert';
import 'package:fish_caster/api_services/api_handler.dart';
import 'package:fish_caster/core/string_cons.dart';
import 'package:fish_caster/widgets/snackBar/gloabal_snack.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ResetPasswordService {
  static const String _baseUrl = "${StringCons.baseApiUrl}";

  Future<String?> sendVerificationEmail(String email) async {
    final url = Uri.parse('$_baseUrl/auth/forgot-password');
    final headers = {'Content-Type': 'application/json'};

    final body = json.encode({'email': email});

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['sid'];
      } else {
        throw Exception('Failed to send verification email');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> verifyPassword(
    BuildContext context,
    String sid,
    String otp,
  ) async {
    final url = Uri.parse('$_baseUrl/auth/verify-reset-otp');
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode({'sid': sid, 'otp': otp});

    try {
      final response = await http.post(url, headers: headers, body: body);
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        final data = response.body.isNotEmpty ? json.decode(response.body) : {};
        String message = data['message'] ?? 'Email verified successfully';
        globalSnack.showSnackBar(context, message);

        return data; // ✅ Return the full response instead of just the message
      } else {
        final errorData = json.decode(response.body);
        String errorMessage = errorData['message'] ?? 'Failed to verify email';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );

        return {}; // ✅ Return empty map if failed
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return {}; // ✅ Return empty map on error
    }
  }

  Future<String?> changePassword(String password, String token) async {
    final url = Uri.parse('$_baseUrl/auth/reset-password?token=$token');
    final headers = {'Content-Type': 'application/json'};

    final body = json.encode({'password': password});

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 204) {
      } else {
        throw Exception('Failed to send verification email');
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  // Reset Password with Old Password

  static Future<bool> changeOldPassword({
    required ApiHandler apiHandler,
    required String oldPassword,
    required String newPassword,
  }) async {
    final response = await apiHandler.makeAuthenticatedRequest(
      url: '${StringCons.baseApiUrl}/auth/change-password',
      method: 'POST',
      body: jsonEncode({
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      }),
    );

    if (response != null && response.statusCode == 200) {
      return true;
    } else {
      print('Change password failed: ${response?.body}');
      return false;
    }
  }
}
