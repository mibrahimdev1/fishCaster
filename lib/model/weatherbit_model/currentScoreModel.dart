// import 'dart:ui';
// import 'package:flutter/material.dart';

// class CurrentScoreModel {
//   final String message;
//   final String locationId;
//   final String criteriaId;
//   final int percentage;
//   final bool redFlag;
//   final int matchedPoints;
//   final int maxPoints;
//   final List<String> matchedFields;
//   final List<FailedField> failedFields;
//   final Map<String, EvaluationSummary> summary;

//   CurrentScoreModel({
//     required this.message,
//     required this.locationId,
//     required this.criteriaId,
//     required this.percentage,
//     required this.redFlag,
//     required this.matchedPoints,
//     required this.maxPoints,
//     required this.matchedFields,
//     required this.failedFields,
//     required this.summary,
//   });

//   factory CurrentScoreModel.fromJson(Map<String, dynamic> json) {
//     return CurrentScoreModel(
//       message: json['message'] ?? '',
//       locationId: json['locationId'] ?? '',
//       criteriaId: json['criteriaId'] ?? '',
//       percentage: json['percentage'] ?? 0,
//       redFlag: json['redFlag'] ?? false,
//       matchedPoints: json['matchedPoints'] ?? 0,
//       maxPoints: json['maxPoints'] ?? 0,
//       matchedFields: List<String>.from(json['matchedFields'] ?? []),
//       failedFields:
//           (json['failedFields'] as List<dynamic>?)
//               ?.map((e) => FailedField.fromJson(e))
//               .toList() ??
//           [],
//       summary:
//           (json['summary'] as Map<String, dynamic>?)?.map(
//             (key, value) => MapEntry(key, EvaluationSummary.fromJson(value)),
//           ) ??
//           {},
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'message': message,
//       'locationId': locationId,
//       'criteriaId': criteriaId,
//       'percentage': percentage,
//       'redFlag': redFlag,
//       'matchedPoints': matchedPoints,
//       'maxPoints': maxPoints,
//       'matchedFields': matchedFields,
//       'failedFields': failedFields.map((f) => f.toJson()).toList(),
//       'summary': summary.map((k, v) => MapEntry(k, v.toJson())),
//     };
//   }

//   Color get scoreColor {
//     if (percentage >= 75) return Color(0xff565F27);
//     if (percentage >= 50) return Color(0xffBA6E12);
//     return Color(0xff87132C);
//   }
// }

// class FailedField {
//   final String field;
//   final String reason;

//   FailedField({required this.field, required this.reason});

//   factory FailedField.fromJson(Map<String, dynamic> json) {
//     return FailedField(
//       field: json['field'] ?? '',
//       reason: json['reason'] ?? '',
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {'field': field, 'reason': reason};
//   }
// }

// class EvaluationSummary {
//   final dynamic actual;
//   final bool autoRedFlag;
//   final String field;
//   final String? label;
//   final int points;
//   final int maxPoints;
//   final bool? expected;
//   final String? selectedOption;
//   final String? min;
//   final String? max;
//   EvaluationSummary({
//     required this.actual,
//     required this.autoRedFlag,
//     required this.field,
//     required this.label,
//     required this.points,
//     required this.maxPoints,
//     this.expected,
//     this.selectedOption,
//     this.min,
//     this.max,
//   });

//   factory EvaluationSummary.fromJson(Map<String, dynamic> json) {
//     return EvaluationSummary(
//       actual: json['actual'],
//       autoRedFlag: json['autoRedFlag'] ?? false,
//       field: json['field'] ?? '',
//       label: json['label'],
//       points: json['points'] ?? 0,
//       maxPoints: json['maxPoints'] ?? 0,
//       expected: json['expected'],
//       selectedOption: json['selectedOption'] as String?,
//       min: json['min'] as String?,
//       max: json['max'] as String?,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'actual': actual,
//       'autoRedFlag': autoRedFlag,
//       'field': field,
//       'label': label,
//       'points': points,
//       'maxPoints': maxPoints,
//       'expected': expected,
//       if (selectedOption != null) 'selectedOption': selectedOption,
//       if (min != null) 'min': min,
//       if (max != null) 'max': max,
//     };
//   }
// }
import 'dart:ui';
import 'package:flutter/material.dart';

class CurrentScoreModel {
  final String message;
  final String locationId;
  final String criteriaId;
  final int percentage;
  final bool redFlag;
  final int matchedPoints;
  final int maxPoints;
  final List<String> matchedFields;
  final List<FailedField> failedFields;
  final Map<String, EvaluationSummary> summary;

  CurrentScoreModel({
    required this.message,
    required this.locationId,
    required this.criteriaId,
    required this.percentage,
    required this.redFlag,
    required this.matchedPoints,
    required this.maxPoints,
    required this.matchedFields,
    required this.failedFields,
    required this.summary,
  });

  factory CurrentScoreModel.fromJson(Map<String, dynamic> json) {
    return CurrentScoreModel(
      message: json['message']?.toString() ?? '',
      locationId: json['locationId']?.toString() ?? '',
      criteriaId: json['criteriaId']?.toString() ?? '',
      percentage:
          (json['percentage'] is int)
              ? json['percentage']
              : int.tryParse(json['percentage'].toString()) ?? 0,
      redFlag: json['redFlag'] ?? false,
      matchedPoints:
          (json['matchedPoints'] is int)
              ? json['matchedPoints']
              : int.tryParse(json['matchedPoints'].toString()) ?? 0,
      maxPoints:
          (json['maxPoints'] is int)
              ? json['maxPoints']
              : int.tryParse(json['maxPoints'].toString()) ?? 0,
      matchedFields: List<String>.from(json['matchedFields'] ?? []),
      failedFields:
          (json['failedFields'] as List<dynamic>?)
              ?.map((e) => FailedField.fromJson(e))
              .toList() ??
          [],
      summary:
          (json['summary'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, EvaluationSummary.fromJson(value)),
          ) ??
          {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'locationId': locationId,
      'criteriaId': criteriaId,
      'percentage': percentage,
      'redFlag': redFlag,
      'matchedPoints': matchedPoints,
      'maxPoints': maxPoints,
      'matchedFields': matchedFields,
      'failedFields': failedFields.map((f) => f.toJson()).toList(),
      'summary': summary.map((k, v) => MapEntry(k, v.toJson())),
    };
  }

  Color get scoreColor {
    if (percentage >= 75) return const Color(0xff565F27);
    if (percentage >= 50) return const Color(0xffBA6E12);
    return const Color(0xff87132C);
  }
}

class FailedField {
  final String field;
  final String reason;

  FailedField({required this.field, required this.reason});

  factory FailedField.fromJson(Map<String, dynamic> json) {
    return FailedField(
      field: json['field']?.toString() ?? '',
      reason: json['reason']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'field': field, 'reason': reason};
  }
}

class EvaluationSummary {
  final dynamic actual;
  final bool autoRedFlag;
  final String field;
  final String? label;
  final int points;
  final int maxPoints;
  final bool? expected;
  final String? selectedOption;
  final String? min;
  final String? max;

  EvaluationSummary({
    required this.actual,
    required this.autoRedFlag,
    required this.field,
    required this.label,
    required this.points,
    required this.maxPoints,
    this.expected,
    this.selectedOption,
    this.min,
    this.max,
  });

  factory EvaluationSummary.fromJson(Map<String, dynamic> json) {
    return EvaluationSummary(
      actual: json['actual'],
      autoRedFlag: json['autoRedFlag'] ?? false,
      field: json['field']?.toString() ?? '',
      label: json['label']?.toString(),
      points:
          (json['points'] is int)
              ? json['points']
              : int.tryParse(json['points'].toString()) ?? 0,
      maxPoints:
          (json['maxPoints'] is int)
              ? json['maxPoints']
              : int.tryParse(json['maxPoints'].toString()) ?? 0,
      expected:
          json['expected'] == null
              ? null
              : (json['expected'] is bool
                  ? json['expected']
                  : json['expected'].toString().toLowerCase() == 'true'),
      selectedOption: json['selectedOption']?.toString(),
      min: json['min']?.toString(),
      max: json['max']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'actual': actual,
      'autoRedFlag': autoRedFlag,
      'field': field,
      'label': label,
      'points': points,
      'maxPoints': maxPoints,
      'expected': expected,
      if (selectedOption != null) 'selectedOption': selectedOption,
      if (min != null) 'min': min,
      if (max != null) 'max': max,
    };
  }
}
