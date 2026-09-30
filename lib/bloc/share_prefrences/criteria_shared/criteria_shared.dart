import 'dart:convert';
import 'package:fish_caster/model/criteria_model/criteriaModel.dart';
import 'package:fish_caster/bloc/criteria/criteria_bloc.dart';
import 'package:fish_caster/bloc/criteria/criteria_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveSelectedCriteria(CriteriaProfile criteriaProfile) async {
  final prefs = await SharedPreferences.getInstance();

  // Convert CriteriaProfile to JSON string
  String criteriaJson = json.encode(criteriaProfile.toJson());

  // Save JSON string in SharedPreferences
  await prefs.setString('selected_criteria', criteriaJson);

  print("Criteria data saved to SharedPreferences: $criteriaJson");
}

Future<CriteriaProfile?> getSelectedCriteria(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  String? criteriaJson = prefs.getString('selected_criteria');

  if (criteriaJson != null) {
    try {
      Map<String, dynamic> criteriaMap = json.decode(criteriaJson);
      print("Shared Get Criteria: $criteriaMap");

      final criteriaProfile = CriteriaProfile.fromJson(criteriaMap);
      context.read<CriteriaBloc>().add(SaveSelectedCriteria(criteriaProfile));
      return criteriaProfile;
    } catch (e, stack) {
      print("Error parsing CriteriaProfile: $e\n$stack");
      return null;
    }
  } else {
    print("No criteria data found in SharedPreferences.");
    return null;
  }
}

Future<void> clearCriteriaData() async {
  final prefs = await SharedPreferences.getInstance();

  // Remove the selected criteria from SharedPreferences
  await prefs.remove('selected_criteria');
  print("Criteria data cleared from SharedPreferences.");
}
