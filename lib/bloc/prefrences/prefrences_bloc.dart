import 'dart:convert';
import 'dart:developer';
import 'package:fish_caster/bloc/prefrences/prefrences_event.dart';
import 'package:fish_caster/bloc/prefrences/prefrences_state.dart';
import 'package:fish_caster/bloc/token/token_bloc.dart';
import 'package:fish_caster/bloc/token/token_state.dart';
import 'package:fish_caster/core/string_cons.dart';
import 'package:fish_caster/model/prefrences_model/prefrencesModel.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class PreferencesBloc extends Bloc<PreferencesEvent, PreferencesState> {
  static const _prefsKey = 'user_preferences';
  final TokenBloc tokenBloc;
  PreferencesBloc(this.tokenBloc)
    : super(
        PreferencesState(
          PreferencesModel(
            temperatureUnit: 'Fahrenheit',
            weightUnit: 'Kilograms',
            distanceUnit: 'Meters',
            depthUnit: 'Meters',
            cloudCondition: 'Clear',
            windSpeedUnit: 'mph',
            pressureUnit: 'inHg',
            humidityUnit: 'Percentage',
          ),
        ),
      ) {
    on<LoadPreferences>(_onLoad);
    on<UpdatePreference>(_onUpdate);
  }

  Future<void> _onLoad(
    LoadPreferences event,
    Emitter<PreferencesState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_prefsKey);
    // log("Load from bloc ${data}");
    if (data != null) {
      final json = jsonDecode(data);
      emit(PreferencesState(PreferencesModel.fromJson(json)));
    }
  }

  Future<void> _onUpdate(
    UpdatePreference event,
    Emitter<PreferencesState> emit,
  ) async {
    final updated = _updateModel(event.key, event.value, state.preferences);
    final prefs = await SharedPreferences.getInstance();

    String temperature =
        state.preferences.temperatureUnit == "Fahrenheit" ? "F" : "C";
    String windSpeed =
        state.preferences.windSpeedUnit.toLowerCase(); // m/s, km/h, mph as is
    String pressure = state.preferences.pressureUnit; // inHg, mb as is

    if (event.key == "temperatureUnit") {
      temperature = event.value == "Fahrenheit" ? "F" : "C";
    } else if (event.key == "windSpeedUnit") {
      windSpeed = event.value;
    } else if (event.key == "pressureUnit") {
      pressure = event.value;
    }

    final body = {
      "temperature": temperature,
      "windSpeed": windSpeed,
      "pressure": pressure,
    };

    String? token;
    if (tokenBloc.state is TokenLoaded) {
      token = (tokenBloc.state as TokenLoaded).token;
    } else {
      print("❌ No access token found in TokenBloc.");
      return; // or emit error state
    }

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final url = Uri.parse('${StringCons.baseApiUrl}/users/updatePreferences');

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print("✅ Preferences updated on server successfully.");
      } else {
        print("❌ Failed to update preferences. Status: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error while updating preferences: $e");
    }

    await prefs.setString(_prefsKey, jsonEncode(updated.toJson()));
    // log("Unit Save in Bloc ${updated.toJson()}");
    emit(PreferencesState(updated));
  }

  PreferencesModel _updateModel(
    String key,
    String value,
    PreferencesModel current,
  ) {
    switch (key) {
      case 'temperatureUnit':
        return current.copyWith(temperatureUnit: value);
      case 'weightUnit':
        return current.copyWith(weightUnit: value);
      case 'distanceUnit':
        return current.copyWith(distanceUnit: value);
      case 'depthUnit':
        return current.copyWith(depthUnit: value);
      case 'cloudCondition':
        return current.copyWith(cloudCondition: value);
      case 'windSpeedUnit':
        return current.copyWith(windSpeedUnit: value);
      case 'pressureUnit':
        return current.copyWith(pressureUnit: value);
      case 'humidityUnit':
        return current.copyWith(humidityUnit: value);
      default:
        return current;
    }
  }
}
