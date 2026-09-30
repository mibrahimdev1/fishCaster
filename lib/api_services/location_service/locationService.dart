import 'dart:convert';
import 'dart:developer';
import 'package:fish_caster/api_services/api_handler.dart';
import 'package:fish_caster/bloc/token/token_bloc.dart';
import 'package:fish_caster/bloc/token/token_event.dart';
import 'package:fish_caster/core/string_cons.dart';
import 'package:fish_caster/model/location_model/locationModel.dart';
import 'package:flutter/material.dart';

class LocationService {
  final TokenBloc tokenBloc;
  final BuildContext context;

  LocationService({required this.tokenBloc, required this.context});

  Future<List<Location>> fetchLocation() async {
    final api = ApiHandler(tokenBloc: tokenBloc, context: context);

    final response = await api.makeAuthenticatedRequest(
      url: '${StringCons.baseApiUrl}/locations/locations',
      method: 'GET',
    );

    if (response != null && response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      // log('Location data: $data');

      // Extract 'locations' field from the response and map it to a List<Location>
      final locationsList =
          (data['locations'] as List)
              .map((json) => Location.fromJson(json))
              .toList();

      return locationsList;
    } else {
      throw Exception(
        'Failed to fetch locations: ${response?.statusCode}, ${response?.body}',
      );
    }
  }

  // Future<bool> saveLocation({
  //   required String locationName,
  //   required String lat,
  //   required String lon,
  //   String? city,
  // }) async {
  //   final api = ApiHandler(tokenBloc: tokenBloc, context: context);

  //   final response = await api.makeAuthenticatedRequest(
  //     url: '${StringCons.baseApiUrl}/locations/set-location',
  //     method: 'POST',
  //     body: jsonEncode({
  //       'locationName': locationName,
  //       'lat': lat,
  //       'lon': lon,
  //       'city': city,
  //     }),
  //   );

  //   log("Location Add : ${response}");

  //   return response != null &&
  //       (response.statusCode == 200 || response.statusCode == 201);

  // }

  // Future<bool> saveLocation({
  //   required String locationName,
  //   required String lat,
  //   required String lon,
  //   String? city,
  // }) async {
  //   final api = ApiHandler(tokenBloc: tokenBloc, context: context);

  //   final response = await api.makeAuthenticatedRequest(
  //     url: '${StringCons.baseApiUrl}/locations/set-location',
  //     method: 'POST',
  //     body: jsonEncode({
  //       'locationName': locationName,
  //       'lat': lat,
  //       'lon': lon,
  //       'city': city,
  //     }),
  //   );

  //   // Check if response is not null and log the response body
  //   if (response != null) {
  //     log("Location Add Response: ${response.body}");

  //     // Optionally, you can log other useful details like status code
  //     log("Response Status Code: ${response.statusCode}");
  //   } else {
  //     log("Error: No response received from API.");
  //   }

  //   return response != null &&
  //       (response.statusCode == 200 || response.statusCode == 201);
  // }

  // Future<Map<String, dynamic>?> saveLocation({
  //   required String locationName,
  //   required String lat,
  //   required String lon,
  //   String? city,
  // }) async {
  //   final api = ApiHandler(tokenBloc: tokenBloc, context: context);

  //   final response = await api.makeAuthenticatedRequest(
  //     url: '${StringCons.baseApiUrl}/locations/set-location',
  //     method: 'POST',
  //     body: jsonEncode({
  //       'locationName': locationName,
  //       'lat': lat,
  //       'lon': lon,
  //       'city': city,
  //     }),
  //   );

  //   if (response != null &&
  //       (response.statusCode == 200 || response.statusCode == 201)) {
  //     log("Location Add Response: ${response.body}");
  //     return jsonDecode(response.body); // Return the response body as a Map
  //   } else {
  //     log("Error: No response received or failed status code.");
  //     return null;
  //   }
  // }

  Future<Location?> saveLocation({
    required String locationName,
    required String lat,
    required String lon,
    String? city,
  }) async {
    final api = ApiHandler(tokenBloc: tokenBloc, context: context);

    final response = await api.makeAuthenticatedRequest(
      url: '${StringCons.baseApiUrl}/locations/set-location',
      method: 'POST',
      body: jsonEncode({
        'locationName': locationName,
        'lat': lat,
        'lon': lon,
        'city': city,
      }),
    );

    if (response != null &&
        (response.statusCode == 200 || response.statusCode == 201)) {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      // log("Location Add Response: $decoded");

      // extract the nested 'location' object
      final locationJson = decoded['location'] as Map<String, dynamic>;
      return Location.fromJson(locationJson);
    } else {
      // log("Error: No response received or failed status code.");
      return null;
    }
  }

  Future<void> deleteLocationById(String locationId) async {
    final api = ApiHandler(tokenBloc: tokenBloc, context: context);

    final response = await api.makeAuthenticatedRequest(
      url: '${StringCons.baseApiUrl}/locations/$locationId',
      method: 'DELETE',
    );

    if (response == null || response.statusCode != 204) {
      throw Exception(
        'Failed to delete location: ${response?.statusCode}, ${response?.body}',
      );
    }
  }
}
