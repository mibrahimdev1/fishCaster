import 'dart:convert';
import 'dart:developer';
import 'package:fish_caster/import_file.dart';
import 'package:fish_caster/model/weatherbit_model/currentScoreModel.dart';
import 'package:fish_caster/model/weatherbit_model/weatherBitModel.dart';
import 'package:http/http.dart' as http;

class CriteriaEvaluationService {
  CriteriaEvaluationService();

  Future<CriteriaResultModel> evaluateHourlySlots({
    required String authToken,
    required String locationId,
    required String criteriaId,
  }) async {
    final uri = Uri.parse(
      '${StringCons.baseApiUrl}/criteria/evaluate-hourly-slots',
    ).replace(
      queryParameters: {'locationId': locationId, 'criteriaId': criteriaId},
    );

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
    );

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body);
      // log('Response : $jsonBody');
      // beautifyAndLogResponse(jsonBody);
      return CriteriaResultModel.fromJson(jsonBody);
    } else {
      throw Exception('Failed to evaluate hourly slots: ${response.body}');
    }
  }

  Future<CurrentScoreModel> getCriteriaEvaluation({
    required String locationId,
    required String criteriaId,
    required String authToken,
  }) async {
    final uri = Uri.parse('${StringCons.baseApiUrl}/weather/evaluate').replace(
      queryParameters: {'locationId': locationId, 'criteriaId': criteriaId},
    );

    try {
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // log('Response: ${response.body}');
        final decoded = jsonDecode(response.body);
        // beautifyAndLogResponse(decoded);
        // _logJsonTypes(decoded); // :point_left: Add this
        return CurrentScoreModel.fromJson(decoded);
        // return CurrentScoreModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load criteria evaluation: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}

void beautifyAndLogResponse(dynamic jsonBody) {
  const encoder = JsonEncoder.withIndent('  ');

  // Convert dynamic Map or String to formatted JSON String
  String prettyPrint;

  if (jsonBody is String) {
    // If already a string, decode first
    final decoded = jsonDecode(jsonBody);
    prettyPrint = encoder.convert(decoded);
  } else {
    prettyPrint = encoder.convert(jsonBody);
  }

  print(prettyPrint);
}

void _logJsonTypes(dynamic data, [String parentKey = '']) {
  if (data is Map) {
    data.forEach((key, value) {
      final fullKey = parentKey.isEmpty ? key : '$parentKey.$key';
      if (value is Map || value is List) {
        _logJsonTypes(value, fullKey);
      } else {
        log('$fullKey → ${value.runtimeType}');
      }
    });
  } else if (data is List) {
    for (var i = 0; i < data.length; i++) {
      _logJsonTypes(data[i], '$parentKey[$i]');
    }
  }
}
