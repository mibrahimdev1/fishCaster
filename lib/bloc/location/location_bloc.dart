import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:fish_caster/api_services/location_service/locationService.dart';
import 'package:fish_caster/bloc/location/location_event.dart';
import 'package:fish_caster/bloc/location/location_state.dart';
import 'package:fish_caster/bloc/share_prefrences/location_shared/shared_preferences.dart';
import 'package:fish_caster/model/location_model/locationModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final LocationService locationService;

  Location? _selectedLocation;
  List<Location> _locationList = [];

  LocationBloc({required this.locationService}) : super(LocationInitial()) {
    on<FetchLocationEvent>((event, emit) async {
      emit(LocationLoading());
      try {
        _locationList = await locationService.fetchLocation();

        final prefs = await SharedPreferences.getInstance();
        final cached = prefs.getString('selected_location');

        if (cached != null) {
          final decoded = Location.fromJson(jsonDecode(cached));
          _selectedLocation = _locationList.firstWhere(
            (loc) => loc.id == decoded.id,
            orElse: () => _locationList.first,
          );
        }

        emit(
          LocationListLoaded(
            _locationList,
            selectedLocation: _selectedLocation,
          ),
        );
      } catch (e) {
        emit(LocationError(e.toString()));
      }
    });

    on<SelectLocationEvent>((event, emit) async {
      _selectedLocation = event.selectedLocation;

      await saveSelectedLocation(_selectedLocation!);

      emit(
        LocationListLoaded(_locationList, selectedLocation: _selectedLocation),
      );
    });

    on<ClearLocation>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('selected_location');
      _selectedLocation = null;
      emit(LocationInitial());
    });
  }
}
