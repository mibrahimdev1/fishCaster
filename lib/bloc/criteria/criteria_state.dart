// criteria_state.dart
import 'package:fish_caster/model/criteria_model/criteriaModel.dart';

abstract class CriteriaState {}

class CriteriaInitial extends CriteriaState {}

class CriteriaSelected extends CriteriaState {
  final CriteriaProfile criteriaProfile;

  CriteriaSelected(this.criteriaProfile);
}
