// criteria_bloc.dart
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'criteria_event.dart';
import 'criteria_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CriteriaBloc extends Bloc<CriteriaEvent, CriteriaState> {
  CriteriaBloc() : super(CriteriaInitial()) {
    // Registering the event handler for SaveSelectedCriteria event
    on<SaveSelectedCriteria>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();

      // Convert full profile to JSON string
      final jsonString = json.encode(event.criteriaProfile.toJson());

      // Save full JSON string
      await prefs.setString('selected_criteria', jsonString);

      emit(CriteriaSelected(event.criteriaProfile));
    });

    on<ClearCriteria>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('selected_criteria');
      emit(CriteriaInitial());
    });
  }
}
