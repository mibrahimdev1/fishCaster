// class Criteria {
//   final String field;
//   final double? min;
//   final double? max;
//   final int? points;
//   final bool? autoRedFlag;
//   final String? selectedOption;
//   final dynamic expected;

//   Criteria({
//     required this.field,
//     this.min,
//     this.max,
//     this.points,
//     this.autoRedFlag,
//     this.selectedOption,
//     this.expected,
//   });

//   factory Criteria.fromJson(Map<String, dynamic> json) {
//     return Criteria(
//       field: json['field'],
//       min: (json['min'] as num?)?.toDouble(),
//       max: (json['max'] as num?)?.toDouble(),
//       points: json['points'] as int?,
//       autoRedFlag: json['autoRedFlag'] as bool?,
//       selectedOption: json['selectedOption'] as String?,
//       expected: json['expected'],
//     );
//   }
// }

// class CriteriaProfile {
//   final String id;
//   final String name;
//   final String type;
//   final List<Criteria> variables;

//   CriteriaProfile({
//     required this.id,
//     required this.name,
//     required this.type,
//     required this.variables,
//   });

//   factory CriteriaProfile.fromJson(Map<String, dynamic> json) {
//     final List<dynamic> varsJson = json['variables'] ?? [];
//     return CriteriaProfile(
//       id: json['id'],
//       name: json['name'],
//       type: json['type'] ?? 'unknown', // Add default or handle null safely
//       variables: varsJson.map((v) => Criteria.fromJson(v)).toList(),
//     );
//   }

//   Map<String, dynamic> toJson() => {
//     'id': id,
//     'name': name,
//     'type': type,
//     'variables': variables.map((v) => v.toJson()).toList(),
//   };
// }

// extension on Criteria {
//   Map<String, dynamic> toJson() => {
//     'field': field,
//     'min': min,
//     'max': max,
//     'points': points,
//     'autoRedFlag': autoRedFlag,
//     'selectedOption': selectedOption,
//     'expected': expected,
//   };
// }

class CriteriaResponse {
  final Map<String, List<Criteria>> fields;

  CriteriaResponse({required this.fields});

  factory CriteriaResponse.fromJson(Map<String, dynamic> json) {
    final map = <String, List<Criteria>>{};
    json.forEach((key, value) {
      if (value is List) {
        map[key] = value.map((item) => Criteria.fromJson(item)).toList();
      }
    });
    return CriteriaResponse(fields: map);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    fields.forEach((key, value) {
      data[key] = value.map((e) => e.toJson()).toList();
    });
    return data;
  }
}

class Criteria {
  final String field;
  final num? min;
  final num? max;
  final int? points;
  final bool? autoRedFlag;
  final String? selectedOption;
  final dynamic expected;

  Criteria({
    required this.field,
    this.min,
    this.max,
    this.points,
    this.autoRedFlag,
    this.selectedOption,
    this.expected,
  });

  factory Criteria.fromJson(Map<String, dynamic> json) {
    return Criteria(
      field: json['field'],
      min: json['min'] as num?,
      max: json['max'] as num?,
      points: json['points'] as int?,
      autoRedFlag: json['autoRedFlag'] as bool?,
      selectedOption: json['selectedOption'] as String?,
      expected: json['expected'],
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{'field': field};
    if (min != null) data['min'] = min;
    if (max != null) data['max'] = max;
    if (points != null) data['points'] = points;
    if (autoRedFlag != null) data['autoRedFlag'] = autoRedFlag;
    if (selectedOption != null) data['selectedOption'] = selectedOption;
    if (expected != null) data['expected'] = expected;
    return data;
  }
}

class CriteriaProfile {
  final String id;
  String name;
  final String type;
  final String? user;
  final List<Criteria> variables;

  CriteriaProfile({
    required this.id,
    required this.name,
    required this.type,
    this.user,
    required this.variables,
  });

  factory CriteriaProfile.fromJson(Map<String, dynamic> json) {
    final List<dynamic> varsJson = json['variables'] ?? [];
    return CriteriaProfile(
      id: json['id'],
      name: json['name'],
      type: json['type'] ?? 'unknown',
      user: json['user'] as String?,
      variables: varsJson.map((v) => Criteria.fromJson(v)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
    'user': user,
    'variables': variables.map((v) => v.toJson()).toList(),
  };
}
