// criteria_event.dart
import 'package:fish_caster/model/criteria_model/criteriaModel.dart';

abstract class CriteriaEvent {}

class SaveSelectedCriteria extends CriteriaEvent {
  final CriteriaProfile criteriaProfile;

  SaveSelectedCriteria(this.criteriaProfile);
}

class ClearCriteria extends CriteriaEvent {}
