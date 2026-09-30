import 'dart:convert';
import 'dart:developer';
import 'package:fish_caster/core/string_cons.dart';
import 'package:fish_caster/model/criteria_model/criteriaModel.dart';
import 'package:fish_caster/widgets/snackBar/gloabal_snack.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CriteriaService {
  CriteriaService();

  Future<List<CriteriaProfile>> getAllProfiles(String token) async {
    final response = await http.get(
      Uri.parse('${StringCons.baseApiUrl}/criteria/user'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<CriteriaProfile> allProfiles = [];

      final predefined = data['predefined'] as List<dynamic>? ?? [];
      final custom = data['custom'] as List<dynamic>? ?? [];
      final hotFishing = data['hotFishing'] as List<dynamic>? ?? [];

      allProfiles.addAll(predefined.map((e) => CriteriaProfile.fromJson(e)));
      allProfiles.addAll(custom.map((e) => CriteriaProfile.fromJson(e)));
      allProfiles.addAll(hotFishing.map((e) => CriteriaProfile.fromJson(e)));

      return allProfiles;
    } else {
      throw Exception('Failed to load criteria');
    }
  }

  Future<Map<String, dynamic>?> createCriteria({
    required String token,
    required String name,
    required List<Map<String, dynamic>> variables,
  }) async {
    final url = Uri.parse('${StringCons.baseApiUrl}/criteria/custom');
    final body = {"name": name, "variables": variables};
    // log("Body: $body");
    final prettyJson = JsonEncoder.withIndent('  ').convert(body);
    // log("Body: $prettyJson");
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      final responseBody = jsonDecode(response.body);

      // Attach status code for UI logic
      return {'code': response.statusCode, 'body': responseBody};
    } catch (e) {
      return {
        'code': 0, // use 0 or -1 to indicate network/client error
        'body': {'message': 'Network error. Please check your connection.'},
      };
    }
  }

  Future<CriteriaProfile?> createHotFishingCriteria({
    required String authToken,
    required String locationId,
    required String name,
    required String description,
    required String species,
    required String presentation,
    required String waterTemp,
    required BuildContext context,
    required String waterBodyType,
  }) async {
    final url = Uri.parse('${StringCons.baseApiUrl}/criteria/hot-fishing');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode({
        'locationId': locationId,
        'name': name,
        'description': description,
        'species': species,
        'presentation': presentation,
        'waterTemp': waterTemp,
        'waterBodyType': waterBodyType,
      }),
    );

    // if (response.statusCode == 200 || response.statusCode == 201) {
    //   final data = jsonDecode(response.body);
    //   final profileJson = data['data'];
    //   return CriteriaProfile.fromJson(profileJson);
    // } else {
    //   throw Exception(
    //     'Failed to create hot fishing criteria: ${response.body}',
    //   );
    // }
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final profileJson = data['data'];
      return CriteriaProfile.fromJson(profileJson);
    } else if (response.statusCode == 403) {
      final message = jsonDecode(response.body)['message'] ?? 'Unauthorized';
      globalSnack.showErrorSnackBar(context, message);

      // throw Exception('Unauthorized: $message');
      return null;
    } else {
      final error =
          jsonDecode(response.body)['message'] ?? 'Something went wrong';
      throw Exception('Failed to create hot fishing criteria: $error');
    }
  }

  Future<void> deleteProfile(String token, String id) async {
    final url = Uri.parse('${StringCons.baseApiUrl}/criteria/custom/$id');
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete profile: ${response.body}');
    }
  }

  Future<void> updateProfileName(
    String token,
    String id,
    String newName,
  ) async {
    final url = Uri.parse('${StringCons.baseApiUrl}/criteria/custom/$id');

    final response = await http.patch(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'name': newName}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update profile');
    }
  }

  // Get criteria data for editing
  Future<Map<String, dynamic>?> getCriteriaForEdit({
    required String token,
    required String id,
    required BuildContext context,
  }) async {
    try {
      final url = Uri.parse('${StringCons.baseApiUrl}/criteria/custom/$id');
      
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final result = data['data'] ?? data; // Return the criteria data
        print('API Response for criteria $id: $result');
        return result;
      } else if (response.statusCode == 403) {
        final message = jsonDecode(response.body)['message'] ?? 'Unauthorized';
        globalSnack.showErrorSnackBar(context, message);
        return null;
      } else {
        final error = jsonDecode(response.body)['message'] ?? 'Failed to fetch criteria';
        globalSnack.showErrorSnackBar(context, error);
        return null;
      }
    } catch (e) {
      print('Error fetching criteria: $e');
      globalSnack.showErrorSnackBar(context, 'Network error. Please check your connection.');
      return null;
    }
  }

  // Update criteria with full data
  Future<Map<String, dynamic>?> updateCriteria({
    required String token,
    required String id,
    required String name,
    required List<Map<String, dynamic>> variables,
    required BuildContext context,
  }) async {
    try {
      final url = Uri.parse('${StringCons.baseApiUrl}/criteria/custom/$id');
      
      final response = await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'variables': variables,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data;
      } else if (response.statusCode == 403) {
        final message = jsonDecode(response.body)['message'] ?? 'Unauthorized';
        globalSnack.showErrorSnackBar(context, message);
        return null;
      } else {
        final error = jsonDecode(response.body)['message'] ?? 'Failed to update criteria';
        globalSnack.showErrorSnackBar(context, error);
        return null;
      }
    } catch (e) {
      print('Error updating criteria: $e');
      globalSnack.showErrorSnackBar(context, 'Network error. Please check your connection.');
      return null;
    }
  }
}
