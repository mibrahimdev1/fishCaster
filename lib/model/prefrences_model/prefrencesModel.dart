class PreferencesModel {
  final String temperatureUnit;
  final String weightUnit;
  final String distanceUnit;
  final String depthUnit;
  final String cloudCondition;
  final String windSpeedUnit;
  final String pressureUnit;
  final String humidityUnit;

  PreferencesModel({
    required this.temperatureUnit,
    required this.weightUnit,
    required this.distanceUnit,
    required this.depthUnit,
    required this.cloudCondition,
    required this.windSpeedUnit,
    required this.pressureUnit,
    required this.humidityUnit,
  });

  PreferencesModel copyWith({
    String? temperatureUnit,
    String? weightUnit,
    String? distanceUnit,
    String? depthUnit,
    String? cloudCondition,
    String? windSpeedUnit,
    String? pressureUnit,
    String? humidityUnit,
  }) {
    return PreferencesModel(
      temperatureUnit: temperatureUnit ?? this.temperatureUnit,
      weightUnit: weightUnit ?? this.weightUnit,
      distanceUnit: distanceUnit ?? this.distanceUnit,
      depthUnit: depthUnit ?? this.depthUnit,
      cloudCondition: cloudCondition ?? this.cloudCondition,
      windSpeedUnit: windSpeedUnit ?? this.windSpeedUnit,
      pressureUnit: pressureUnit ?? this.pressureUnit,
      humidityUnit: humidityUnit ?? this.humidityUnit,
    );
  }

  Map<String, dynamic> toJson() => {
    'temperatureUnit': temperatureUnit,
    'weightUnit': weightUnit,
    'distanceUnit': distanceUnit,
    'depthUnit': depthUnit,
    'cloudCondition': cloudCondition,
    'windSpeedUnit': windSpeedUnit,
    'pressureUnit': pressureUnit,
    'humidityUnit': humidityUnit,
  };

  factory PreferencesModel.fromJson(Map<String, dynamic> json) {
    return PreferencesModel(
      temperatureUnit: json['temperatureUnit'] ?? 'Celsius',
      weightUnit: json['weightUnit'] ?? 'Kilograms',
      distanceUnit: json['distanceUnit'] ?? 'Meters',
      depthUnit: json['depthUnit'] ?? 'Meters',
      cloudCondition: json['cloudCondition'] ?? 'Clear',
      windSpeedUnit: json['windSpeedUnit'] ?? 'km/h',
      pressureUnit: json['pressureUnit'] ?? 'mbar',
      humidityUnit: json['humidityUnit'] ?? 'Percentage',
    );
  }
}
