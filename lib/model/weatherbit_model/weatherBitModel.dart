class CriteriaResultModel {
  final String locationId;
  final String criteriaId;
  final List<ResultDay> results;

  CriteriaResultModel({
    required this.locationId,
    required this.criteriaId,
    required this.results,
  });

  factory CriteriaResultModel.fromJson(Map<String, dynamic> json) {
    return CriteriaResultModel(
      locationId: json['locationId'],
      criteriaId: json['criteriaId'],
      results:
          (json['results'] as List).map((e) => ResultDay.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'locationId': locationId,
    'criteriaId': criteriaId,
    'results': results.map((e) => e.toJson()).toList(),
  };

  void removeLastTwoResultDays() {
    if (results.length > 1) {
      results.removeLast();
      results.removeLast();
    }
  }
}

class ResultDay {
  final String date;
  final List<SlotResult> slots;

  ResultDay({required this.date, required this.slots});

  factory ResultDay.fromJson(Map<String, dynamic> json) {
    return ResultDay(
      date: json['date'],
      slots:
          (json['slots'] as List).map((e) => SlotResult.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'date': date,
    'slots': slots.map((e) => e.toJson()).toList(),
  };

  void removeLastTwoSlots() {
    if (slots.length > 1) {
      slots.removeLast();
      slots.removeLast();
    }
  }
}

class SlotResult {
  final String slot;
  final String hour;
  final String? percentage;
  final bool? redFlag;
  final int? matchedPoints;
  final int? maxPoints;
  final List<String> matchedFields;
  final List<FailedField> failedFields;
  final Criteria? criteria;
  final WeatherMetadata? metadata;
  final List<EvaluationSummary> evaluationSummary;
  final bool? skipped;
  final String? message;
  final Map<String, dynamic>? summary;

  SlotResult({
    required this.slot,
    required this.hour,
    required this.percentage,
    required this.redFlag,
    required this.matchedPoints,
    required this.maxPoints,
    required this.matchedFields,
    required this.failedFields,
    required this.criteria,
    required this.metadata,
    required this.evaluationSummary,
    required this.skipped,
    required this.message,
    required this.summary,
  });

  factory SlotResult.fromJson(Map<String, dynamic> json) {
    List<FailedField> failedFieldsParsed;
    if (json['failedFields'] != null && json['failedFields'] is List) {
      final failedList = json['failedFields'] as List;
      failedFieldsParsed =
          failedList.map((e) {
            if (e is String) {
              return FailedField(field: e, reason: '');
            } else if (e is Map<String, dynamic>) {
              return FailedField.fromJson(e);
            } else {
              throw FormatException('Invalid failedField type: $e');
            }
          }).toList();
    } else {
      failedFieldsParsed = [];
    }

    return SlotResult(
      slot: json['slot'],
      hour: json['hour'],
      percentage: json['percentage']?.toString(),
      redFlag: json['redFlag'] as bool?,
      matchedPoints: _parseNullableInt(json['matchedPoints']),
      maxPoints: _parseNullableInt(json['maxPoints']),
      matchedFields: List<String>.from(json['matchedFields'] ?? []),
      failedFields: failedFieldsParsed,
      criteria:
          json['criteria'] != null ? Criteria.fromJson(json['criteria']) : null,
      metadata:
          json['metadata'] != null
              ? WeatherMetadata.fromJson(json['metadata'])
              : null,
      evaluationSummary:
          (json['evaluationSummary'] as List?)
              ?.map((e) => EvaluationSummary.fromJson(e))
              .toList() ??
          [],
      skipped: json['skipped'] as bool?,
      message: json['message'],
      summary: json['summary'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
    'slot': slot,
    'hour': hour,
    'percentage': percentage,
    'redFlag': redFlag,
    'matchedPoints': matchedPoints,
    'maxPoints': maxPoints,
    'matchedFields': matchedFields,
    'failedFields': failedFields.map((e) => e.toJson()).toList(),
    'criteria': criteria?.toJson(),
    'metadata': metadata?.toJson(),
    'evaluationSummary': evaluationSummary.map((e) => e.toJson()).toList(),
    'skipped': skipped,
    'message': message,
    'summary': summary,
  };

  static int? _parseNullableInt(dynamic value) {
    if (value == null || value == '-') return null;
    return int.tryParse(value.toString());
  }
}

class Criteria {
  final String? user;
  final String name;
  final String type;
  final List<Variable> variables;
  final String id;

  Criteria({
    required this.user,
    required this.name,
    required this.type,
    required this.variables,
    required this.id,
  });

  factory Criteria.fromJson(Map<String, dynamic> json) {
    return Criteria(
      user: json['user'],
      name: json['name'],
      type: json['type'],
      variables:
          (json['variables'] as List).map((e) => Variable.fromJson(e)).toList(),
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() => {
    'user': user,
    'name': name,
    'type': type,
    'variables': variables.map((e) => e.toJson()).toList(),
    'id': id,
  };
}

class WeatherMetadata {
  final double temp;
  final double appTemp;
  final int pop;
  final int pres;
  final int slp;
  final int barometricPressureLevel;
  // final int rh;
  final int clouds;
  final double windSpd;
  final int windDir;
  final int uv;
  final dynamic moonPhase;
  final dynamic moonriseTs;
  final dynamic moonsetTs;
  final dynamic sunriseTs;
  final dynamic sunsetTs;
  final Weather weather;

  WeatherMetadata({
    required this.temp,
    required this.appTemp,
    required this.pop,
    required this.pres,
    required this.slp,
    required this.barometricPressureLevel,
    // required this.rh,
    required this.clouds,
    required this.windSpd,
    required this.windDir,
    required this.uv,
    required this.moonPhase,
    required this.moonriseTs,
    required this.moonsetTs,
    required this.sunriseTs,
    required this.sunsetTs,
    required this.weather,
  });

  factory WeatherMetadata.fromJson(Map<String, dynamic> json) {
    return WeatherMetadata(
      temp: (json['temp'] as num).toDouble(),
      appTemp: (json['app_temp'] as num).toDouble(),
      pop: json['pop'],
      pres: json['pres'],
      slp: json['slp'],
      barometricPressureLevel: json['barometric_pressure_level'],
      // rh: json['rh'] ?? "",
      clouds: json['clouds'],
      windSpd: (json['wind_spd'] as num).toDouble(),
      windDir: json['wind_dir'],
      uv: json['uv'],
      moonPhase: json['moon_phase'],
      moonriseTs: json['moonrise_ts'],
      moonsetTs: json['moonset_ts'],
      sunriseTs: json['sunrise_ts'],
      sunsetTs: json['sunset_ts'],
      weather: Weather.fromJson(json['weather']),
    );
  }

  Map<String, dynamic> toJson() => {
    'temp': temp,
    'app_temp': appTemp,
    'pop': pop,
    'pres': pres,
    'slp': slp,
    'barometric_pressure_level': barometricPressureLevel,
    // 'rh': rh,
    'clouds': clouds,
    'wind_spd': windSpd,
    'wind_dir': windDir,
    'uv': uv,
    'moon_phase': moonPhase,
    'moonrise_ts': moonriseTs,
    'moonset_ts': moonsetTs,
    'sunrise_ts': sunriseTs,
    'sunset_ts': sunsetTs,
    'weather': weather.toJson(),
  };
}

class Weather {
  final String icon;
  final String description;
  final int code;

  Weather({required this.icon, required this.description, required this.code});

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      icon: json['icon'],
      description: json['description'],
      code: json['code'],
    );
  }

  Map<String, dynamic> toJson() => {
    'icon': icon,
    'description': description,
    'code': code,
  };
}

class EvaluationSummary {
  final String field;
  final bool matched;
  final int points;
  final int weight;
  final String? label;

  EvaluationSummary({
    required this.field,
    required this.matched,
    required this.points,
    required this.weight,
    required this.label,
  });

  factory EvaluationSummary.fromJson(Map<String, dynamic> json) {
    return EvaluationSummary(
      field: json['field'],
      matched: json['matched'],
      points: json['points'],
      weight: json['weight'] ?? 0,
      label: json['label'],
    );
  }

  Map<String, dynamic> toJson() => {
    'field': field,
    'matched': matched,
    'points': points,
    'weight': weight,
    'label': label,
  };
}

class Variable {
  final bool autoRedFlag;
  final String field;
  final dynamic expected;
  final int? points;
  final String? selectedOption;
  final num? min;
  final num? max;

  Variable({
    required this.autoRedFlag,
    required this.field,
    this.expected,
    this.points,
    this.selectedOption,
    this.min,
    this.max,
  });

  factory Variable.fromJson(Map<String, dynamic> json) {
    return Variable(
      autoRedFlag: json['autoRedFlag'],
      field: json['field'],
      expected: json['expected'],
      points: json['points'],
      selectedOption: json['selectedOption'],
      min: json['min'],
      max: json['max'],
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{'autoRedFlag': autoRedFlag, 'field': field};
    if (expected != null) data['expected'] = expected;
    if (points != null) data['points'] = points;
    if (selectedOption != null)
      data['selectedOption'] = selectedOption; // No change needed
    if (min != null) data['min'] = min;
    if (max != null) data['max'] = max;
    return data;
  }
}

class FailedField {
  final String field;
  final String reason;

  FailedField({required this.field, required this.reason});

  factory FailedField.fromJson(Map<String, dynamic> json) {
    return FailedField(field: json['field'], reason: json['reason']);
  }

  Map<String, dynamic> toJson() => {'field': field, 'reason': reason};
}
