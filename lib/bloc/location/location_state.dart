// State
import 'package:equatable/equatable.dart';
import 'package:fish_caster/model/location_model/locationModel.dart';

abstract class LocationState extends Equatable {
  const LocationState();

  @override
  List<Object> get props => [];
}

class LocationInitial extends LocationState {}

class LocationLoading extends LocationState {}

class LocationLoaded extends LocationState {
  final Location location;

  const LocationLoaded(this.location);

  @override
  List<Object> get props => [location];
}

class LocationError extends LocationState {
  final String message;

  const LocationError(this.message);

  @override
  List<Object> get props => [message];
}

class LocationListLoaded extends LocationState {
  final List<Location> locations;
  final Location? selectedLocation;

  LocationListLoaded(this.locations, {this.selectedLocation});
}

class SelectedLocationLoaded extends LocationState {
  final Location selectedLocation;

  const SelectedLocationLoaded(this.selectedLocation);

  @override
  List<Object> get props => [selectedLocation];
}
