// Event
import 'package:equatable/equatable.dart';
import 'package:fish_caster/model/location_model/locationModel.dart';

abstract class LocationEvent extends Equatable {
  const LocationEvent();

  @override
  List<Object> get props => [];
}

class FetchLocationEvent extends LocationEvent {}

class SelectLocationEvent extends LocationEvent {
  final Location selectedLocation;

  const SelectLocationEvent(this.selectedLocation);

  @override
  List<Object> get props => [selectedLocation];
}

class ClearLocation extends LocationEvent {}
