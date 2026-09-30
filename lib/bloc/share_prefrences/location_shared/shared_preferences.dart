import 'dart:convert';
import 'package:fish_caster/bloc/location/location_bloc.dart';
import 'package:fish_caster/bloc/location/location_event.dart';
import 'package:fish_caster/model/location_model/locationModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveSelectedLocation(Location selectedLocation) async {
  final prefs = await SharedPreferences.getInstance();

  // Convert Location to JSON string
  String locationJson = json.encode(selectedLocation.toJson());

  // Save the JSON string in SharedPreferences
  await prefs.setString('selected_location', locationJson);

  print("Location data saved to SharedPreferences: $locationJson");
}

Future<Location?> getSelectedLocation(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  String? locationJson = prefs.getString('selected_location');

  if (locationJson != null) {
    Map<String, dynamic> locationMap = json.decode(locationJson);
    print("Shared Get Location: $locationMap");

    // Dispatch event after accessing the context safely
    context.read<LocationBloc>().add(
      SelectLocationEvent(Location.fromJson(locationMap)),
    );

    return Location.fromJson(locationMap);
  } else {
    print("No location data found in SharedPreferences.");
    return null;
  }
}

Future<void> clearLocationData() async {
  final prefs = await SharedPreferences.getInstance();

  // Remove the selected location from SharedPreferences
  await prefs.remove('selected_location');
  print("Location data cleared from SharedPreferences.");
}
