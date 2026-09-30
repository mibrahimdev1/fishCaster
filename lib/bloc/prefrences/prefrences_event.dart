abstract class PreferencesEvent {}

class LoadPreferences extends PreferencesEvent {}

class UpdatePreference extends PreferencesEvent {
  final String key;
  final String value;

  UpdatePreference(this.key, this.value);
}
