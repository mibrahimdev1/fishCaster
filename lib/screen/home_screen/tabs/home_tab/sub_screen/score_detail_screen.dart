import 'dart:developer';
import 'package:fish_caster/screen/home_screen/tabs/home_tab/homeTab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fish_caster/bloc/prefrences/prefrences_bloc.dart';
import 'package:fish_caster/bloc/prefrences/prefrences_state.dart';
import 'package:fish_caster/model/weatherbit_model/currentScoreModel.dart';
import 'package:fish_caster/model/weatherbit_model/weatherBitModel.dart';
import 'package:fish_caster/screen/home_screen/homeScreen.dart';
import 'package:fish_caster/widgets/Buttons/custom_button_textfield.dart';
import 'package:fish_caster/import_file.dart';

class ScoreDetailScreen extends StatefulWidget {
  final String title;
  final String day;
  final String score;
  final Color color;
  final SlotResult? slotResult;
  final CurrentScoreModel? currentScoreModel;

  final bool isBestFishing;
  final bool isComfortAndSafety;
  const ScoreDetailScreen({
    super.key,
    required this.title,
    required this.score,
    required this.color,
    required this.day,
    this.slotResult,
    this.currentScoreModel,
    this.isBestFishing = false,
    this.isComfortAndSafety = false,
  });

  @override
  State<ScoreDetailScreen> createState() => _ScoreDetailScreenState();
}

class _ScoreDetailScreenState extends State<ScoreDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return BlocBuilder<PreferencesBloc, PreferencesState>(
      builder: (context, state) {
        final preferences = state.preferences;
        final String tempUnit =
            preferences.temperatureUnit == 'Celsius' ? '°C' : '°F';
        // final String windUnit =
        //     preferences.windSpeedUnit == 'km/h' ? 'km/h' : 'm/s';
        final String windUnit =
            preferences.windSpeedUnit == 'km/h'
                ? 'km/h'
                : preferences.windSpeedUnit == 'mph'
                ? 'mph'
                : 'm/s';

        final String pressureUnit =
            preferences.pressureUnit == 'mb' ? 'mb' : 'inHg';

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: false,
            elevation: 0,
            leading: InkWell(
              onTap: () {
                // Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
                Navigator.pop(context);
              },
              child: const Icon(Icons.arrow_back_ios, color: Colors.white),
            ),
          ),
          body: ThemedBackground(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 700),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CustomText(
                          text: widget.title,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        const SizedBox(height: 20),
                        CustomButtonTextField(
                          width: screenWidth * 0.5,
                          isHeight: true,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: CustomText(
                                    textAlign: TextAlign.center,
                                    text: widget.day,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                scoreWidget(
                                  score: widget.score,
                                  color: widget.color,
                                  ontap: () {},
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        CustomButtonTextField(
                          width: screenWidth * 0.9,
                          isHeight: true,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      minWidth: 100,
                                    ),
                                    child: Table(
                                      columnWidths: const {
                                        0: FixedColumnWidth(120),
                                        1: FixedColumnWidth(120),
                                        2: FixedColumnWidth(120),
                                        3: FixedColumnWidth(80),
                                        4: FixedColumnWidth(100),
                                      },
                                      border: TableBorder.symmetric(
                                        inside: BorderSide(
                                          color: Colors.white24,
                                        ),
                                      ),
                                      children: [
                                        _buildTableRow([
                                          'Variable',
                                          'Preferred',
                                          'Predicted',
                                          'Points',
                                          'Max Points',
                                        ], isHeader: true),
                                        ..._buildVariableRows(
                                          tempUnit: tempUnit,
                                          windUnit: windUnit,
                                          pressureUnit: pressureUnit,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // List<TableRow> _buildVariableRows({
  //   required String tempUnit,
  //   required String windUnit,
  //   required String pressureUnit,
  // }) {
  //   final Map<String, dynamic>? summaryData =
  //       widget.slotResult?.summary ??
  //       widget.currentScoreModel?.summary.map(
  //         (k, v) => MapEntry(k, v.toJson()),
  //       );

  //   if (summaryData == null || summaryData.isEmpty) {
  //     log("No summary data available.");
  //     return [];
  //   }

  //   // Group entries by prefix (first part before _)
  //   final Map<String, List<MapEntry<String, dynamic>>> grouped = {};

  //   for (var entry in summaryData.entries) {
  //     final parts = entry.key.split('_');
  //     final prefix = parts[0];

  //     if (!grouped.containsKey(prefix)) {
  //       grouped[prefix] = [];
  //     }

  //     grouped[prefix]!.add(entry);
  //   }

  //   List<TableRow> rows = [];

  //   grouped.forEach((prefix, entries) {
  //     final String variableName = _formatFieldName(prefix).toUpperCase();
  //     List<String> preferredItems = [];
  //     List<String> predictedItems = [];
  //     int totalPoints = 0;
  //     int totalMaxPoints = 0;

  //     for (var entry in entries) {
  //       final fieldData = entry.value;
  //       final unit = _getUnitForField(
  //         entry.key,
  //         tempUnit,
  //         windUnit,
  //         pressureUnit,
  //       );

  //       // Preferred value logic with line breaks
  //       String preferred = '';
  //       if (fieldData['selectedOption'] != null) {
  //         preferred = fieldData['selectedOption'].toString();
  //       } else if (fieldData['min'] != null && fieldData['max'] != null) {
  //         final min = _convertValue(entry.key, fieldData['min'], unit);
  //         final max = _convertValue(entry.key, fieldData['max'], unit);
  //         preferred = 'min $min $unit\nmax $max $unit';
  //       } else if (fieldData['max'] != null) {
  //         final max = _convertValue(entry.key, fieldData['max'], unit);
  //         preferred = 'max $max $unit';
  //       } else if (fieldData['field'] != null) {
  //         preferred = fieldData['field'].toString();
  //       }

  //       final labelField = fieldData['label'];
  //       final actual = fieldData['actual'];
  //       String predicted =
  //           entry.key.contains('timeOfDay')
  //               ? 'N/A'
  //               : labelField != null
  //               ? labelField.toString()
  //               : actual != null
  //               ? '${_convertValue(entry.key, actual, unit)} $unit'
  //               : '-';

  //       if (preferred.isNotEmpty) {
  //         preferredItems.add(preferred);
  //       }
  //       if (predicted.isNotEmpty) {
  //         predictedItems.add(predicted);
  //       }

  //       // Points
  //       final fieldPoints = fieldData['points'] ?? 0;
  //       final fieldMaxPoints = fieldData['maxPoints'] ?? 0;

  //       final int parsedPoints =
  //           fieldPoints is int
  //               ? fieldPoints
  //               : (fieldPoints is num ? fieldPoints.toInt() : 0);

  //       final int parsedMaxPoints =
  //           fieldMaxPoints is int
  //               ? fieldMaxPoints
  //               : (fieldMaxPoints is num ? fieldMaxPoints.toInt() : 0);

  //       // If field is 'timeOfDay' or 'moon_phase', override totalPoints and totalMaxPoints
  //       if (fieldData['field'] == 'timeOfDay' ||
  //           fieldData['field'] == 'moon_phase') {
  //         totalPoints = parsedPoints;
  //         totalMaxPoints = parsedMaxPoints;
  //       } else {
  //         totalPoints += parsedPoints;
  //         totalMaxPoints += parsedMaxPoints;
  //       }
  //     }

  //     rows.add(
  //       _buildTableRow([
  //         variableName,
  //         preferredItems.join('\n'),
  //         predictedItems.join('\n'),
  //         totalPoints.toString(),
  //         totalMaxPoints.toString(),
  //       ]),
  //     );
  //   });

  //   return rows;
  // }

  List<TableRow> _buildVariableRows({
    required String tempUnit,
    required String windUnit,
    required String pressureUnit,
  }) {
    final Map<String, dynamic>? summaryData =
        widget.slotResult?.summary ??
        widget.currentScoreModel?.summary.map(
          (k, v) => MapEntry(k, v.toJson()),
        );

    if (summaryData == null || summaryData.isEmpty) {
      log("No summary data available.");
      return [];
    }

    // Group entries by prefix (first part before _)
    final Map<String, List<MapEntry<String, dynamic>>> grouped = {};

    for (var entry in summaryData.entries) {
      log(entry.toString());
      final parts = entry.key.split('_');
      final prefix = parts[0];

      if (!grouped.containsKey(prefix)) {
        grouped[prefix] = [];
      }

      grouped[prefix]!.add(entry);
    }

    List<TableRow> rows = [];

    grouped.forEach((prefix, entries) {
      final String variableName = _formatFieldName(prefix).toUpperCase();
      List<String> preferredItems = [];
      List<String> predictedItems = [];
      int totalPoints = 0;
      int totalMaxPoints = 0;

      bool isSpecialField = false;
      String specialPredicted = '';

      for (var entry in entries) {
        final fieldData = entry.value;
        final unit = _getUnitForField(
          entry.key,
          tempUnit,
          windUnit,
          pressureUnit,
        );

        // Preferred value logic with line breaks
        String preferred = '';
        if (fieldData['selectedOption'] != null) {
          preferred = fieldData['selectedOption'].toString();
        } else if (fieldData['min'] != null && fieldData['max'] != null) {
          final min = _convertValue(entry.key, fieldData['min'], unit);
          final max = _convertValue(entry.key, fieldData['max'], unit);
          preferred = 'min $min $unit\nmax $max $unit';
        } else if (fieldData['max'] != null) {
          final max = _convertValue(entry.key, fieldData['max'], unit);
          preferred = 'max $max $unit';
        } else if (fieldData['field'] != null) {
          preferred = fieldData['field'].toString();
        }

        final labelField = fieldData['label'];
        final actual = fieldData['actual'];
        String predicted =
            entry.key.contains('timeOfDay')
                ? 'N/A'
                : labelField != null
                ? labelField.toString()
                : actual != null
                ? '${_convertValue(entry.key, actual, unit)} $unit'
                : '-';

        if (preferred.isNotEmpty) {
          preferredItems.add(preferred);
        }

        // ✅ For 'timeOfDay' or 'moon_phase', only store the first predicted value
        if (widget.isBestFishing == true) {
          if (fieldData['field'] == 'timeOfDay') {
            isSpecialField = true;
            if (specialPredicted.isEmpty && predicted.isNotEmpty) {
              specialPredicted = predicted;
            }
          } else {
            if (predicted.isNotEmpty) {
              predictedItems.add(predicted);
            }
          }
        } else {
          if (fieldData['field'] == 'timeOfDay' ||
              fieldData['field'] == 'moon_phase') {
            isSpecialField = true;
            // if(predicted == 'N/A')
            if ((specialPredicted.isEmpty && predicted.isNotEmpty) ||
                specialPredicted == 'N/A') {
              specialPredicted = predicted;
            }
          } else {
            if (predicted.isNotEmpty) {
              predictedItems.add(predicted);
            }
          }
        }

        // Points
        final fieldPoints = fieldData['points'] ?? 0;
        final fieldMaxPoints = fieldData['maxPoints'] ?? 0;

        final int parsedPoints =
            fieldPoints is int
                ? fieldPoints
                : (fieldPoints is num ? fieldPoints.toInt() : 0);

        final int parsedMaxPoints =
            fieldMaxPoints is int
                ? fieldMaxPoints
                : (fieldMaxPoints is num ? fieldMaxPoints.toInt() : 0);

        // If field is 'timeOfDay' or 'moon_phase', override totalPoints and totalMaxPoints
        if (widget.isBestFishing == true) {
          if (fieldData['field'] == 'timeOfDay') {
            totalPoints = parsedPoints > 0 ? totalPoints : parsedPoints;
            totalMaxPoints = parsedMaxPoints;
          } else {
            totalPoints += parsedPoints;
            totalMaxPoints += parsedMaxPoints;
          }
        } else {
          if (fieldData['field'] == 'timeOfDay') {
            totalPoints = parsedPoints > 0 ? parsedPoints : totalPoints;
            totalMaxPoints = parsedMaxPoints;
          } else {
            totalPoints += parsedPoints;
            totalMaxPoints += parsedMaxPoints;
          }
        }
      }

      // ✅ If special field, only add its single predicted value
      if (isSpecialField) {
        predictedItems = [specialPredicted];
      }

      rows.add(
        _buildTableRow([
          variableName,
          preferredItems.join('\n'),
          predictedItems.join('\n'),
          totalPoints.toString(),
          totalMaxPoints.toString(),
        ]),
      );
    });

    return rows;
  }

  TableRow _buildTableRow(
    List<String> cells, {
    bool isHeader = false,
    bool isGroupHeader = false,
  }) {
    return TableRow(
      children:
          cells.map((cell) {
            final isFirst = cells.indexOf(cell) == 0;
            return Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 10.0,
                horizontal: 5,
              ),
              child: Text(
                cell,
                style: TextStyle(
                  fontWeight:
                      isHeader || (isGroupHeader && isFirst)
                          ? FontWeight.bold
                          : FontWeight.normal,
                  fontSize: isHeader || isGroupHeader ? 15 : 13,
                  color: Colors.white,
                ),
              ),
            );
          }).toList(),
    );
  }

  String _getUnitForField(
    String field,
    String tempUnit,
    String windUnit,
    String pressureUnit,
  ) {
    switch (field) {
      case 'app_temp':
      case 'temp':
        return tempUnit;
      case 'wind_spd':
        return windUnit;
      case 'slp':
      case 'barometric_pressure_level':
        return pressureUnit;
      case 'temperature_trend':
        return tempUnit;
      default:
        return '';
    }
  }

  String _formatFieldName(String field) {
    switch (field) {
      case 'temp':
        return 'Temperature';
      case 'timeOfDay':
        return 'Time Of Day';
      case 'app_temp':
        return 'Feels Like Temp';
      case 'slp':
        return 'Barometric Pressure';
      case 'wind_spd':
        return 'Wind Speed';
      case 'clouds':
        return 'Cloud Cover';
      case 'pop':
        return 'Precipitation Chance';
      case 'uv':
        return 'UV Index';
      case 'moon_phase':
        return 'Moon Phase';
      case 'wind_dir':
        return 'Wind Direction';
      case 'thunderstorm_today':
        return 'Thunderstorm';
      default:
        return field
            .replaceAll('_', ' ')
            .splitMapJoin(
              RegExp(r'\b\w'),
              onMatch: (m) => m.group(0)!.toUpperCase(),
              onNonMatch: (n) => n,
            );
    }
  }

  String _degreesToCardinal(double degrees) {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW', 'N'];
    final index = ((degrees % 360) / 45).round();
    return directions[index];
  }

  dynamic _convertValue(String field, dynamic value, String unit) {
    if (value == null || value == '-') return value;

    double parsedValue;
    try {
      parsedValue = value is String ? double.parse(value) : value.toDouble();
    } catch (_) {
      return value;
    }

    switch (field) {
      case 'app_temp':
      case 'temperature_trend':
        return unit == '°F'
            ? ((parsedValue * 9 / 5) + 32).toStringAsFixed(1)
            : parsedValue.toStringAsFixed(1);
      case 'wind_spd':
        if (unit == 'km/h') {
          return (parsedValue * 3.6).toStringAsFixed(1);
        } else if (unit == 'mph') {
          return (parsedValue * 2.23694).toStringAsFixed(1);
        } else {
          return parsedValue.toStringAsFixed(1); // fallback for m/s
        }
      case 'wind_dir':
        return _degreesToCardinal(parsedValue);
      case 'pres':
      case 'slp':
        return unit == 'inHg'
            ? (parsedValue * 0.02953).toStringAsFixed(2)
            : parsedValue.toStringAsFixed(1);
      case 'clouds':
      case 'pop':
        return '${parsedValue.toStringAsFixed(0)}%';
      default:
        return value;
    }
  }

  // List<TableRow> _buildVariableRows({
  //   required String tempUnit,
  //   required String windUnit,
  //   required String pressureUnit,
  // }) {
  //   final Map<String, dynamic>? summaryData =
  //       widget.slotResult?.summary ??
  //       widget.currentScoreModel?.summary.map(
  //         (k, v) => MapEntry(k, v.toJson()),
  //       );

  //   if (summaryData == null || summaryData.isEmpty) {
  //     log("No summary data available.");
  //     return [];
  //   }

  //   // Group entries by prefix
  //   final Map<String, List<MapEntry<String, dynamic>>> grouped = {};

  //   for (var entry in summaryData.entries) {
  //     final parts = entry.key.split('_');
  //     final prefix = parts[0];

  //     if (!grouped.containsKey(prefix)) {
  //       grouped[prefix] = [];
  //     }

  //     grouped[prefix]!.add(entry);
  //   }

  //   List<TableRow> rows = [];

  //   grouped.forEach((prefix, entries) {
  //     // Add main prefix row
  //     rows.add(
  //       _buildTableRow([
  //         _formatFieldName(prefix).toUpperCase(),
  //         '',
  //         '',
  //         '',
  //         '',
  //       ]),
  //     );

  //     // Add sub-rows for each entry under this prefix
  //     for (var entry in entries) {
  //       final fieldData = entry.value;

  //       final unit = _getUnitForField(
  //         entry.key,
  //         tempUnit,
  //         windUnit,
  //         pressureUnit,
  //       );

  //       String selectedOption = '';
  //       if (fieldData['selectedOption'] != null) {
  //         selectedOption = fieldData['selectedOption'].toString();
  //       } else if (fieldData['min'] != null && fieldData['max'] != null) {
  //         final min = _convertValue(entry.key, fieldData['min'], unit);
  //         final max = _convertValue(entry.key, fieldData['max'], unit);
  //         selectedOption = 'min $min\nmax $max';
  //       } else if (fieldData['max'] != null) {
  //         final max = _convertValue(entry.key, fieldData['max'], unit);
  //         selectedOption = 'max $max';
  //       }

  //       final predictedRaw = fieldData['actual'];
  //       String predicted =
  //           entry.key.contains('timeOfDay')
  //               ? 'N/A'
  //               : entry.key.contains('temperature_trend') ||
  //                   entry.key.contains('thunderstorm_today') ||
  //                   entry.key.contains('thunderstorm_tomorrow') ||
  //                   entry.key.contains('increasing_chance_of_precipitation') ||
  //                   entry.key.contains('moon_phase')
  //               ? fieldData['label']
  //               : (predictedRaw != null
  //                   ? '${_convertValue(entry.key, predictedRaw, unit)} $unit'
  //                   : '-');

  //       final preferred =
  //           entry.key.contains('thunderstorm_today') ||
  //                   entry.key.contains('thunderstorm_tomorrow')
  //               ? (fieldData['expected'] == true ? 'Expected' : 'Not Expected')
  //               : selectedOption.isNotEmpty
  //               ? selectedOption
  //               : '-';

  //       final points = fieldData['points'] ?? 0;
  //       final maxPoints = fieldData['maxPoints'] ?? 0;

  //       // Add sub-row with field name as → Field
  //       rows.add(
  //         _buildTableRow([
  //           '${_formatFieldName(fieldData['field'])}',
  //           preferred,
  //           predicted,
  //           points.toString(),
  //           maxPoints.toString(),
  //         ]),
  //       );
  //     }
  //   });

  //   return rows;
  // }

  // List<TableRow> _buildVariableRows({
  //   required String tempUnit,
  //   required String windUnit,
  //   required String pressureUnit,
  // }) {
  //   final Map<String, dynamic>? summaryData =
  //       widget.slotResult?.summary ??
  //       widget.currentScoreModel?.summary.map(
  //         (k, v) => MapEntry(k, v.toJson()),
  //       );
  //   print("SUMMARY");
  //   log(summaryData.toString());
  //   if (summaryData!.isEmpty) {
  //     log("No summary data available.");
  //     return [];
  //   }

  //   // log("Summary fields: ${summaryData.keys.join(', ')}");
  //   bool _isNumeric(String value) {
  //     final regex = RegExp(r'[-+]?\d*\.?\d+');
  //     return regex.hasMatch(value);
  //   }

  //   String formatMultiLineWithRoundedNumberAndUnit(String value, String unit) {
  //     final lines = value.split('\n');
  //     List<String> formattedLines = [];

  //     final regex = RegExp(r'([-+]?\d*\.?\d+)');

  //     for (var line in lines) {
  //       final match = regex.firstMatch(line);
  //       if (match != null) {
  //         String prefix = line.substring(0, match.start).trim();
  //         double parsed = double.parse(match.group(0)!);
  //         double rounded = double.parse(parsed.toStringAsFixed(1));
  //         formattedLines.add("$prefix $rounded $unit");
  //       } else {
  //         formattedLines.add(line); // keep as-is if no number found
  //       }
  //     }

  //     return formattedLines.join('\n');
  //   }

  //   print('isBestFishing ${widget.isBestFishing}');

  //   return summaryData.entries
  //       .where((entry) => !(widget.isBestFishing && entry.key == 'uv'))
  //       .map((entry) {
  //         final field = entry.key;
  //         final fieldData = entry.value;

  //         final unit = _getUnitForField(
  //           field,
  //           tempUnit,
  //           windUnit,
  //           pressureUnit,
  //         );

  //         String selectedOption = '';
  //         if (fieldData['selectedOption'] != null) {
  //           selectedOption = fieldData['selectedOption'].toString();
  //         } else if (fieldData['min'] != null && fieldData['max'] != null) {
  //           final min = _convertValue(field, fieldData['min'], unit);
  //           final max = _convertValue(field, fieldData['max'], unit);
  //           selectedOption = 'min $min\nmax $max';
  //         } else if (fieldData['max'] != null) {
  //           final max = _convertValue(field, fieldData['max'], unit);
  //           selectedOption = 'max $max';
  //         }

  //         final predictedRaw = fieldData['actual'];
  //         // final predicted =
  //         //     predictedRaw != null
  //         //         ? '${_convertValue(field, predictedRaw, unit)} $unit'
  //         //         : '-';
  //         // final predicted =
  //         //     field == 'timeOfDay'
  //         //         ? 'N/A'
  //         //         : (predictedRaw != null
  //         //             ? '${_convertValue(field, predictedRaw, unit)} $unit'
  //         //             : '-');
  //         final predicted =
  //             field == 'timeOfDay'
  //                 ? 'N/A'
  //                 : field == 'temperature_trend' ||
  //                     field == 'thunderstorm_today' ||
  //                     field == 'thunderstorm_tomorrow' ||
  //                     field == 'increasing_chance_of_precipitation' ||
  //                     field == 'moon_phase'
  //                 ? fieldData['label']
  //                 : (predictedRaw != null
  //                     ? '${_convertValue(field, predictedRaw, unit)} $unit'
  //                     : '-');

  //         // final preferred =
  //         //     selectedOption.isNotEmpty ? '$selectedOption $unit' : '-';
  //         // final preferred =
  //         //     field == 'thunderstorm_today' || field == 'thunderstorm_tomorrow'
  //         //         ? (fieldData['expected'] == true
  //         //             ? 'Expected'
  //         //             : 'Not Expected')
  //         //         : selectedOption.isNotEmpty
  //         //         ? _isNumeric(selectedOption)
  //         //             ? '$selectedOption $unit'
  //         //             : selectedOption
  //         //         : '-';
  //         final preferred =
  //             field == 'thunderstorm_today' || field == 'thunderstorm_tomorrow'
  //                 ? (fieldData['expected'] == true
  //                     ? 'Expected'
  //                     : 'Not Expected')
  //                 : selectedOption.isNotEmpty
  //                 ? _isNumeric(selectedOption)
  //                     ? formatMultiLineWithRoundedNumberAndUnit(
  //                       selectedOption,
  //                       unit,
  //                     )
  //                     : selectedOption
  //                 : '-';
  //         final points = fieldData['points'] ?? 0;
  //         final maxPoints = fieldData['maxPoints'] ?? 0;

  //         return _buildTableRow([
  //           _formatFieldName(field),
  //           preferred,
  //           predicted,
  //           points.toString(),
  //           maxPoints.toString(),
  //         ]);
  //       })
  //       .toList();
  // }

  // TableRow _buildTableRow(List<String> cells, {bool isHeader = false}) {
  //   return TableRow(
  //     children:
  //         cells.map((cell) {
  //           return Padding(
  //             padding: const EdgeInsets.symmetric(
  //               vertical: 10.0,
  //               horizontal: 5,
  //             ),
  //             child: Text(
  //               cell,
  //               style: TextStyle(
  //                 fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
  //                 fontSize: isHeader ? 15 : 13,
  //                 color: Colors.white,
  //               ),
  //             ),
  //           );
  //         }).toList(),
  //   );
  // }
}
