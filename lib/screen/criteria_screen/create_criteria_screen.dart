import 'dart:developer';

import 'package:fish_caster/api_services/criteria_services/criteriaServices.dart';
import 'package:fish_caster/bloc/prefrences/prefrences_bloc.dart';
import 'package:fish_caster/bloc/prefrences/prefrences_event.dart';
import 'package:fish_caster/bloc/prefrences/prefrences_state.dart';
import 'package:fish_caster/import_file.dart';
import 'package:fish_caster/screen/home_screen/homeScreen.dart';
import 'package:fish_caster/widgets/Buttons/custom_button_textfield.dart';
import 'package:fish_caster/widgets/Text/customTextnew.dart';
import 'package:fish_caster/widgets/gifLoader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateCriteriaScreen extends StatefulWidget {
  final String token;
  final String? criteriaId; // For editing mode
  final Map<String, dynamic>? existingData; // For editing mode
  final bool isEditMode; // To distinguish between create and edit
  
  const CreateCriteriaScreen({
    super.key, 
    required this.token,
    this.criteriaId,
    this.existingData,
    this.isEditMode = false,
  });

  @override
  State<CreateCriteriaScreen> createState() => _CreateCriteriaScreenState();
}

class _CreateCriteriaScreenState extends State<CreateCriteriaScreen> {
  final TextEditingController _nameController = TextEditingController();

  // int selectedTimeOfDay = -1;
  // int selectedTimeofDayPoints = -1;
  // int totalCriteriasSelectedCount = 0;
  // Time of Day
  Set<int> selectedTimeOfDayIndexes = {};
  int? selectedMorningPoints;
  int? selectedLateMorningPoints;
  int? selectedLateAfternoonPoints;
  int? selectedTimeOfDayPoints;

  // Temperature
  // Temperature Range
  int selectedTempIndex = -1;
  Set<int> selectedTempIndexes = {};
  RangeValues tempRange = const RangeValues(65, 80);

  double? selectedTemRangeStart;
  double? selectedTemRangeEnd;
  int? selectedTempPoints;

  // Temperature Trend
  int? selectedTempTrendPoints;
  int? selectedTempTrendSubIndex;

  // Barometric Pressure
  // int? selectedBioIndex;
  Set<int> selectedBioIndexes = {};
  int? selectedBioPoints;
  int? selectedBioSubIndex;

  //  Barometric Trend

  int? selectedBioTrenPoints;
  int? selectedBioSubTrendIndex;

  // Cloud
  bool isCloudsSelected = false;
  RangeValues cloudRange = const RangeValues(20, 80);
  int? selectedCloudPoints;

  // Winds
  // Wind Direction
  Set<int> selectedWindsIndex = {};

  // Wind Speed
  int? selectedWindSpeedPoints;
  RangeValues windRange = const RangeValues(0, 22);

  //  Wind Direction Consistency
  int? selectedWindTrendPoints;
  int? selectedWindTrendSubIndex;
  int? selectedWindDirectionConsistencyPoints;

  // Wind Direction
  int? selectedWindDirectionPoints;
  int? selectedWindDirectionSubIndex;

  // Precipitation
  Set<int> selectedPercipitationIndex = {};
  int? selectedPercipitationPoints;
  int? selectedPercipitationSubIndex;

  // Precipitation Trend
  int? selectedPercipitationTrendPoints;
  int? selectedPercipitationTrendSubIndex;

  // Precipitation Range
  RangeValues percipitationRange = const RangeValues(30, 70);

  // Thunderstorm
  Set<int> selectedThunderIndex = {};
  int? selectedThunderPointsCurrentDay;
  int? selectedThunderPointNextDay;

  double apiTempRangeStart = -17.778;
  double apiTempRangeEnd = 32.22;

  // UV
  bool isUvSelected = false;
  RangeValues uvRange = const RangeValues(0, 11);
  int? selectedUVPoints;

  // Moon Phase
  // int selectedMoonIndex = -1;

  Set<int> selectedMoonIndex = {};
  int? selectedMoonFeedingPoints;
  int? selectedMoonNewPoints;
  int? selectedMoonFullPoints;

  String responseMessage = '';

  bool _isLoading = false;
  void createCriteria() async {
    final CriteriaService criteriaService = CriteriaService();
    final List<String> errors = [];

    //------------------------ VALIDATIONS--------------------------

    //Name Controller
    if (_nameController.text.trim().isEmpty) {
      errors.add('Please enter a criteria name.');
    }

    //Time of Day
    if (selectedTimeOfDayIndexes.contains(0) && selectedMorningPoints == null) {
      errors.add('Please select Morning Points');
    }
    if (selectedTimeOfDayIndexes.contains(1) &&
        selectedLateMorningPoints == null) {
      errors.add('Please select Late Morning Points');
    }
    if (selectedTimeOfDayIndexes.contains(2) &&
        selectedLateAfternoonPoints == null) {
      errors.add('Please select Late Afternoon Points');
    }

    //Temperature Points
    if (selectedTempIndexes.contains(0) && selectedTempPoints == null) {
      errors.add('Please select Temperature Range points.');
    }
    if (selectedTempIndexes.contains(1) && selectedTempTrendPoints == null) {
      errors.add('Please select Temperature Trend points.');
    }

    //Biometric Pressure
    if (selectedBioIndexes.contains(0) && selectedBioPoints == null) {
      errors.add('Please select Barometric Pressure Points.');
    }
    if (selectedBioIndexes.contains(1) && selectedBioTrenPoints == null) {
      errors.add('Please select Barometric Trend Points.');
    }

    //Clouds
    if (isCloudsSelected == true && selectedCloudPoints == null) {
      errors.add('Please assign points for Cloud coverage.');
    }

    //Winds
    if (selectedWindsIndex.contains(0) && selectedWindSpeedPoints == null) {
      errors.add('Please assign points for Wind Speed Range.');
    }
    if (selectedWindsIndex.contains(1) &&
        selectedWindDirectionConsistencyPoints == null) {
      errors.add('Please assign points for Wind Direction Consistency Points.');
    }
    if (selectedWindsIndex.contains(2) &&
        (selectedWindDirectionPoints == null ||
            selectedWindDirectionSubIndex == null)) {
      errors.add('Please assign points for Wind Speed Range.');
    }

    //Precipitation
    if (selectedPercipitationIndex.contains(0) &&
        selectedPercipitationPoints == null) {
      errors.add('Please assign points for Precipitation Chance.');
    }

    if (selectedPercipitationIndex.contains(1) &&
        selectedPercipitationTrendPoints == null) {
      log(selectedPercipitationIndex.toString());
      errors.add(
        'Please select points for Increasing Chance of Precipitation .',
      );
    }

    //Thunderstorms
    if (selectedThunderIndex.contains(0) &&
        selectedThunderPointsCurrentDay == null) {
      errors.add('Please assign points for Thunderstorm Today.');
    }
    if (selectedThunderIndex.contains(1) &&
        selectedThunderPointNextDay == null) {
      errors.add('Please assign points for Thunderstorm Tomorrow.');
    }

    //UV
    if (isUvSelected == true && selectedUVPoints == null) {
      errors.add('Please assign points for UV Index.');
    }

    //MOON
    if ((selectedMoonIndex == 0 && selectedMoonFeedingPoints == null) ||
        (selectedMoonIndex == 1 && selectedMoonNewPoints == null) ||
        (selectedMoonIndex == 2 && selectedMoonFullPoints == null)) {
      errors.add('Please assign points for Moon Phase.');
    }

    // if (
    //     selectedMoonFeedingPoints == null) {
    //   errors.add('Please assign points for Moon Phase.');
    // }

    if (errors.isNotEmpty) {
      log("❌ Validation failed");
      globalSnack.showErrorSnackBar(context, errors.join('\n'));
      return;

      /// 🚫 This must stop execution
    }
    log("✅ Validation passed. Proceeding to API.");

    setState(() {
      _isLoading = true;
    });
    List<Map<String, dynamic>> dynamicVariables = [];
    final timeOptions = ['morning', 'late_morning_afternoon', 'evening'];
    final barometricTrendOptions = [];

    //------------------Criteria Creation----------------------
    // Time of Day Create
    // if (selectedTimeOfDay != -1 || selectedTimeofDayPoints != -1) {
    //   String? selectedTimeofDayIndex;
    //   int? points;
    //   bool? autoRedFlag;

    //   switch (selectedTimeofDayPoints) {
    //     case 0: // High
    //       points = 1;

    //       break;
    //     case 1: // Normal
    //       points = 2;

    //       break;
    //     case 2: // Low
    //       points = 3;

    //       break;
    //     case 3: // Low
    //       points = 1;
    //       autoRedFlag = true;

    //       break;
    //   }

    //   switch (selectedTimeOfDay) {
    //     case 0: // Morning
    //       selectedTimeofDayIndex = 'morning';
    //       break;
    //     case 1: // Late morning - Early afternoon
    //       selectedTimeofDayIndex = 'late_morning';
    //       break;
    //     case 2: // Late afternoon - Evening
    //       selectedTimeofDayIndex = 'late_afternoon';
    //       break;
    //   }

    //   dynamicVariables.add({
    //     'field': 'timeOfDay',
    //     'selectedOption': selectedTimeofDayIndex,
    //     'points': points,
    //     if (autoRedFlag == true) 'autoRedFlag': autoRedFlag,
    //   });
    // }

    // Time of Day Create
    //Morning
    if (selectedTimeOfDayIndexes.contains(0)) {
      int? points;
      bool? autoRedFlag;

      switch (selectedMorningPoints) {
        case 0: // High
          points = 1;

          break;
        case 1: // Normal
          points = 2;

          break;
        case 2: // Low
          points = 3;

          break;
        case 3: // Low
          points = 1;
          autoRedFlag = true;

          break;
      }

      dynamicVariables.add({
        'field': 'timeOfDay',
        'points': points,
        'selectedOption': 'morning',
        'expected': true,
        if (autoRedFlag == true) 'autoRedFlag': autoRedFlag,
      });
    }
    //Late Morning
    if (selectedTimeOfDayIndexes.contains(1)) {
      int? points;
      bool? autoRedFlag;

      switch (selectedLateMorningPoints) {
        case 0: // High
          points = 1;

          break;
        case 1: // Normal
          points = 2;

          break;
        case 2: // Low
          points = 3;

          break;
        case 3: // Low
          points = 1;
          autoRedFlag = true;

          break;
      }

      dynamicVariables.add({
        'field': 'timeOfDay',
        'points': points,
        'selectedOption': 'late_morning',
        'expected': true,
        if (autoRedFlag == true) 'autoRedFlag': autoRedFlag,
      });
    }
    //Late Afternoon
    if (selectedTimeOfDayIndexes.contains(2)) {
      int? points;
      bool? autoRedFlag;

      switch (selectedLateAfternoonPoints) {
        case 0: // High
          points = 1;

          break;
        case 1: // Normal
          points = 2;

          break;
        case 2: // Low
          points = 3;

          break;
        case 3: // Low
          points = 1;
          autoRedFlag = true;

          break;
      }

      dynamicVariables.add({
        'field': 'timeOfDay',
        'points': points,
        'selectedOption': 'late_afternoon',
        'expected': true,
        if (autoRedFlag == true) 'autoRedFlag': autoRedFlag,
      });
    }

    // Temperature Create
    // Temperature Range
    if (selectedTempIndexes.contains(0) && selectedTempPoints != null) {
      int? min;
      int? max;
      int? points;
      bool? autoRedFlag;

      switch (selectedTempPoints) {
        case 0: // High
          points = 1;

          break;
        case 1: // Normal
          points = 2;

          break;
        case 2: // Low
          points = 3;

          break;
        case 3: // Low
          points = 1;
          autoRedFlag = true;

          break;
      }

      dynamicVariables.add({
        'field': 'temp',
        'min': apiTempRangeStart,
        'max': apiTempRangeEnd,
        'points': points ?? 2,
        if (autoRedFlag == true) 'autoRedFlag': autoRedFlag,
      });
    }

    // Temperature Trend
    if (selectedTempIndexes.contains(1) && selectedTempTrendSubIndex != null) {
      String? TempTrend;
      int? points;
      bool? autoRedFlag;

      // selectedTempTrendSubIndex?

      switch (selectedTempTrendSubIndex) {
        case 0: // High
          TempTrend = 'warming';

          break;
        case 1: // Normal
          TempTrend = 'cooling';

          break;
        case 2: // Low
          TempTrend = 'steady';

          break;
      }

      switch (selectedTempTrendPoints) {
        case 0: // High
          points = 1;

          break;
        case 1: // Normal
          points = 2;

          break;
        case 2: // Low
          points = 3;

          break;
        case 3: // Low
          points = 1;
          autoRedFlag = true;

          break;
      }

      dynamicVariables.add({
        'field': 'temperature_trend',
        'selectedOption': TempTrend,
        'points': points ?? 2,
        if (autoRedFlag == true) 'autoRedFlag': autoRedFlag,
      });
    }

    //  Barometric Pressure Create
    if (selectedBioIndexes.contains(0) && selectedBioSubIndex != null) {
      // Define min and max based on selected subindex
      double? min;
      double? max;
      int? points;
      bool? autoRedFlag;

      switch (selectedBioPoints) {
        case 0: // High
          points = 1;

          break;
        case 1: // Normal
          points = 2;

          break;
        case 2: // Low
          points = 3;

          break;
        case 3: // Low
          points = 1;
          autoRedFlag = true;

          break;
      }

      switch (selectedBioSubIndex) {
        case 0: // High
          min = 30.2;
          max = 100;
          break;
        case 1: // Normal
          min = 29.8;
          max = 30.2;
          break;
        case 2: // Low
          min = 0;
          max = 29.8;
          break;
      }

      dynamicVariables.add({
        'field': 'barometric_pressure_level',
        // 'selectedOption': barometricTrendOptions[selectedBioSubIndex!],
        'min': min,
        'max': max,
        'points': points ?? 2,
        if (autoRedFlag == true) 'autoRedFlag': autoRedFlag,
      });
    }

    // Barometric Trend
    if (selectedBioIndexes.contains(1) && selectedBioSubTrendIndex != null) {
      String? selectedBarometricTrendIndex;
      int? points;
      bool? autoRedFlag;

      switch (selectedBioTrenPoints) {
        case 0: // High
          points = 1;

          break;
        case 1: // Normal
          points = 2;

          break;
        case 2: // Low
          points = 3;

          break;
        case 3: // Low
          points = 1;
          autoRedFlag = true;

          break;
      }

      switch (selectedBioSubTrendIndex) {
        case 0: // High
          selectedBarometricTrendIndex = 'rising';
          break;
        case 1: // Normal
          selectedBarometricTrendIndex = 'falling';

          break;
        case 2: // Low
          selectedBarometricTrendIndex = 'steady';

          break;
      }

      dynamicVariables.add({
        'field': 'barometric_trend',
        'selectedOption': selectedBarometricTrendIndex,
        'points': points ?? 2,
        if (autoRedFlag == true) 'autoRedFlag': autoRedFlag,
      });
    }

    // Cloud Create
    if (isCloudsSelected == true) {
      int? points;
      bool? autoRedFlag;

      switch (selectedCloudPoints) {
        case 0: // High
          points = 1;

          break;
        case 1: // Normal
          points = 2;

          break;
        case 2: // Low
          points = 3;

          break;
        case 3: // Low
          points = 1;
          autoRedFlag = true;

          break;
      }

      dynamicVariables.add({
        'field': 'clouds',
        'min': cloudRange.start,
        'max': cloudRange.end,
        'points': points,
        if (autoRedFlag == true) 'autoRedFlag': autoRedFlag,
      });
    }

    // Wind Create

    if (selectedWindsIndex.contains(2) && selectedWindDirectionPoints != null) {
      String? selectedWindDirection;
      int? points;
      bool? autoRedFlag;

      // Map the 8 wind directions to 4 backend values
      switch (selectedWindDirectionSubIndex) {
        case 0: // North
          selectedWindDirection = 'north';
          break;
        case 1: // Northeast
          selectedWindDirection = 'north';
          break;
        case 2: // East
          selectedWindDirection = 'east';
          break;
        case 3: // Southeast
          selectedWindDirection = 'south';
          break;
        case 4: // South
          selectedWindDirection = 'south';
          break;
        case 5: // Southwest
          selectedWindDirection = 'south';
          break;
        case 6: // West
          selectedWindDirection = 'west';
          break;
        case 7: // Northwest
          selectedWindDirection = 'north';
          break;
      }

      switch (selectedWindDirectionPoints) {
        case 0: // High
          points = 1;

          break;
        case 1: // Normal
          points = 2;

          break;
        case 2: // Low
          points = 3;

          break;
        case 3: // Low
          points = 1;
          autoRedFlag = true;

          break;
      }

      dynamicVariables.add({
        'field': 'wind_dir',
        'selectedOption': selectedWindDirection,
        'points': points,
        if (autoRedFlag == true) 'autoRedFlag': autoRedFlag,
      });
    }

    // Wind Speed
    if (selectedWindsIndex.contains(0) && selectedWindSpeedPoints != null) {
      int? points;
      bool? autoRedFlag;

      switch (selectedWindSpeedPoints) {
        case 0: // High
          points = 1;

          break;
        case 1: // Normal
          points = 2;

          break;
        case 2: // Low
          points = 3;

          break;
        case 3: // Low
          points = 1;
          autoRedFlag = true;

          break;
      }

      dynamicVariables.add({
        'field': 'wind_spd',
        'min': windRange.start,
        'max': windRange.end,
        'points': points,
        if (autoRedFlag == true) 'autoRedFlag': autoRedFlag,
      });
    }

    // Wind Trend
    if (selectedWindsIndex.contains(1) &&
        selectedWindDirectionConsistencyPoints != null) {
      String? selectedWindTrend;
      int? points;
      bool? autoRedFlag;

      // switch (selectedWindTrendSubIndex) {
      //   case 0:
      //     selectedWindTrend = 'calm';
      //     break;
      //   case 1:
      //     selectedWindTrend = 'light';
      //     break;
      //   case 2:
      //     selectedWindTrend = 'moderate';
      //     break;
      //   case 3:
      //     selectedWindTrend = 'strong';
      //     break;
      // }

      switch (selectedWindDirectionConsistencyPoints) {
        case 0: // High
          points = 1;

          break;
        case 1: // Normal
          points = 2;

          break;
        case 2: // Low
          points = 3;

          break;
        case 3: // Low
          points = 1;
          autoRedFlag = true;

          break;
      }

      dynamicVariables.add({
        'field': 'wind_direction_consistency',
        // 'selectedOption': selectedWindTrend,
        'expected': true,
        'points': points,
        if (autoRedFlag == true) 'autoRedFlag': autoRedFlag,
      });
    }

    // Precipitation Create
    // Precipitation Chance
    if (selectedPercipitationIndex.contains(0) &&
        selectedPercipitationPoints != null) {
      int? max;
      int? min;
      int? points;
      bool? autoRedFlag;

      switch (selectedPercipitationPoints) {
        case 0: // High
          points = 1;

          break;
        case 1: // Normal
          points = 2;

          break;
        case 2: // Low
          points = 3;

          break;
        case 3: // Low
          points = 1;
          autoRedFlag = true;

          break;
      }

      dynamicVariables.add({
        'field': 'precipitation_chance',
        'min': percipitationRange.start,
        'max': percipitationRange.end,
        'points': points,
        if (autoRedFlag == true) 'autoRedFlag': autoRedFlag,
      });
    }
    // Precipitation Trend
    if (selectedPercipitationIndex.contains(1) &&
        selectedPercipitationTrendSubIndex != null) {
      String? selectedPrecipitation;
      int? points;
      bool? autoRedFlag;

      switch (selectedPercipitationTrendPoints) {
        case 0: // High
          points = 1;

          break;
        case 1: // Normal
          points = 2;

          break;
        case 2: // Low
          points = 3;

          break;
        case 3: // Low
          points = 1;
          autoRedFlag = true;

          break;
      }

      switch (selectedPercipitationTrendSubIndex) {
        case 0: // High
          selectedPrecipitation = 'yes';

          break;
        case 1: // Normal
          selectedPrecipitation = 'no';

          break;
      }

      dynamicVariables.add({
        'field': 'increasing_chance_of_precipitation',
        'selectedOption': selectedPrecipitation,
        'points': points,
        if (autoRedFlag == true) 'autoRedFlag': autoRedFlag,
      });
    }

    // Thunderstorm Create
    if (selectedThunderIndex.contains(0)) {
      int? points;
      bool? autoRedFlag;

      switch (selectedThunderPointsCurrentDay) {
        case 0: // High
          points = 1;

          break;
        case 1: // Normal
          points = 2;

          break;
        case 2: // Low
          points = 3;

          break;
        case 3: // Low
          points = 1;
          autoRedFlag = true;

          break;
      }

      dynamicVariables.add({
        'field': 'thunderstorm_today',
        'points': points,
        'expected': true,
        if (autoRedFlag == true) 'autoRedFlag': autoRedFlag,
      });
    }

    // Thunderstorm Next Day
    if (selectedThunderIndex.contains(1)) {
      int? points;
      bool? autoRedFlag;

      switch (selectedThunderPointNextDay) {
        case 0: // High
          points = 1;

          break;
        case 1: // Normal
          points = 2;

          break;
        case 2: // Low
          points = 3;

          break;
        case 3: // Low
          points = 1;
          autoRedFlag = true;

          break;
      }

      dynamicVariables.add({
        'field': 'thunderstorm_tomorrow',
        'points': points,
        'expected': true,
        if (autoRedFlag == true) 'autoRedFlag': autoRedFlag,
      });
    }

    // UV Create
    if (isUvSelected == true) {
      int? points;
      bool? autoRedFlag;

      switch (selectedUVPoints) {
        case 0: // High
          points = 1;

          break;
        case 1: // Normal
          points = 2;

          break;
        case 2: // Low
          points = 3;

          break;
        case 3: // Low
          points = 1;
          autoRedFlag = true;

          break;
      }

      dynamicVariables.add({
        'field': 'uv',
        'min': uvRange.start,
        'max': uvRange.end,
        'points': points,
        if (autoRedFlag == true) 'autoRedFlag': autoRedFlag,
      });
    }

    //Moon Create
    //Feeding Moon
    if (selectedMoonIndex.contains(0)) {
      int? points;
      bool? autoRedFlag;

      switch (selectedMoonFeedingPoints) {
        case 0: // High
          points = 1;

          break;
        case 1: // Normal
          points = 2;

          break;
        case 2: // Low
          points = 3;

          break;
        case 3: // Low
          points = 1;
          autoRedFlag = true;

          break;
      }

      dynamicVariables.add({
        'field': 'moon_phase',
        'points': points,
        'selectedOption': 'feeding_moon',
        'expected': true,
        if (autoRedFlag == true) 'autoRedFlag': autoRedFlag,
      });
    }
    //New Moon
    if (selectedMoonIndex.contains(1)) {
      int? points;
      bool? autoRedFlag;

      switch (selectedMoonNewPoints) {
        case 0: // High
          points = 1;

          break;
        case 1: // Normal
          points = 2;

          break;
        case 2: // Low
          points = 3;

          break;
        case 3: // Low
          points = 1;
          autoRedFlag = true;

          break;
      }

      dynamicVariables.add({
        'field': 'moon_phase',
        'points': points,
        'selectedOption': 'new_moon',
        'expected': true,
        if (autoRedFlag == true) 'autoRedFlag': autoRedFlag,
      });
    }
    //Full Moon
    if (selectedMoonIndex.contains(2)) {
      int? points;
      bool? autoRedFlag;

      switch (selectedMoonFullPoints) {
        case 0: // High
          points = 1;

          break;
        case 1: // Normal
          points = 2;

          break;
        case 2: // Low
          points = 3;

          break;
        case 3: // Low
          points = 1;
          autoRedFlag = true;

          break;
      }

      dynamicVariables.add({
        'field': 'moon_phase',
        'points': points,
        'selectedOption': 'full_moon',
        // 'expected': true,
        if (autoRedFlag == true) 'autoRedFlag': autoRedFlag,
      });
    }
    // if (selectedMoonIndex == 0 ||
    //     selectedMoonIndex == 1 ||
    //     selectedMoonIndex == 2) {
    //   String? selectedMoonKey;
    //   int? points;
    //   bool? autoRedFlag;

    //   int? selectedPoints;
    //   switch (selectedMoonIndex) {
    //     case 0:
    //       selectedMoonKey = 'feeding_moon';
    //       selectedPoints = selectedMoonFeedingPoints;
    //       break;
    //     case 1:
    //       selectedMoonKey = 'new_moon';
    //       selectedPoints = selectedMoonNewPoints;
    //       break;
    //     case 2:
    //       selectedMoonKey = 'full_moon';
    //       selectedPoints = selectedMoonFullPoints;
    //       break;
    //   }

    //   switch (selectedPoints) {
    //     case 0:
    //       points = 1;
    //       break;
    //     case 1:
    //       points = 2;
    //       break;
    //     case 2:
    //       points = 3;
    //       break;
    //     case 3:
    //       points = 1;
    //       autoRedFlag = true;
    //       break;
    //   }

    //   dynamicVariables.add({
    //     'field': 'moon_phase',
    //     'selectedOption': selectedMoonKey,
    //     'points': points ?? 2,
    //     if (autoRedFlag == true) 'autoRedFlag': autoRedFlag,
    //   });
    // }

    if (errors.isNotEmpty == false) {
      Map<String, dynamic>? result;
      
      if (widget.isEditMode && widget.criteriaId != null) {
        // Update existing criteria
        result = await criteriaService.updateCriteria(
          token: widget.token,
          id: widget.criteriaId!,
          name: _nameController.text.trim(),
          variables: dynamicVariables,
          context: context,
        );
      } else {
        // Create new criteria
        result = await criteriaService.createCriteria(
          token: widget.token,
          name: _nameController.text.trim(),
          variables: dynamicVariables,
        );
      }

      setState(() {
        _isLoading = false;
      });

      final int statusCode = result?['code'] ?? 0;
      final body = result?['body'] ?? {};
      final message = result?['message'] ?? 'An unexpected error occurred.';

      if (widget.isEditMode) {
        // For edit mode: check if the message indicates success
        if (message.toLowerCase().contains('successfully')) {
          final successMessage = 'Criteria Updated Successfully';
          globalSnack.showSnackBar(context, successMessage);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        } else {
          globalSnack.showErrorSnackBar(context, message);
        }
      } else {
        // For create mode: use the original status code condition
        if (statusCode == 200 || statusCode == 201) {
          final successMessage = 'Criteria Created Successfully';
          globalSnack.showSnackBar(context, successMessage);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        } else {
          // Extract error message from the nested body structure
          final errorMessage = body['message'] ?? message;
          globalSnack.showErrorSnackBar(context, errorMessage);
        }
      }

      setState(() {
        responseMessage = result != null
            ? widget.isEditMode 
                ? 'Criteria Updated Successfully'
                : 'Criteria Created with ID: ${result['id']}'
            : widget.isEditMode 
                ? 'Failed to update criteria.'
                : 'Failed to create criteria.';
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool useCelsius = false;
  bool usembar = false;
  String usekmh = 'mph';

  String formatTemperature(double valueF, bool useCelsius) {
    if (useCelsius) {
      double celsius = (valueF - 32) * 5 / 9;
      return '${celsius.toStringAsFixed(1)} °C';
    }
    return '${valueF.toStringAsFixed(1)} °F';
  }

  String getCompassDirection(double degrees) {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    int index = ((degrees + 22.5) % 360 ~/ 45) % 8;
    return directions[index];
  }

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final preferencesState = BlocProvider.of<PreferencesBloc>(context).state;
      final windSpeedUnit = preferencesState.preferences.windSpeedUnit;

      setState(() {
        if (windSpeedUnit == 'm/s') {
          windRange = const RangeValues(0, 14);
        } else if (windSpeedUnit == 'km/h') {
          windRange = const RangeValues(0, 35);
        } else {
          windRange = const RangeValues(0, 22);
        }
      });
      
      // If in edit mode, populate form with existing data after widget is ready
      if (widget.isEditMode && widget.existingData != null) {
        print('Widget is ready, now populating form...');
        // Add a small delay to ensure widget is fully built
        Future.delayed(Duration(milliseconds: 100), () {
          if (mounted) {
            _populateFormWithExistingData();
          }
        });
      }
    });
  }

  // Populate form with existing data from API
  void _populateFormWithExistingData() {
    try {
      print('Starting form population with data: ${widget.existingData}');
      
      if (widget.existingData == null || widget.existingData!.isEmpty) {
        print('No existing data provided for editing');
        return;
      }
      
      final data = widget.existingData!;
      print('Processing data: $data');
      
      // Debug: Print all keys in the data
      print('All keys in data: ${data.keys.toList()}');
      
      // Extract the actual criteria data from the response
      final criteriaData = data['criteria'] as Map<String, dynamic>? ?? data;
      print('Criteria data: $criteriaData');
      
      // Set name with null safety
      _nameController.text = criteriaData['name']?.toString() ?? '';
      print('Set name to: ${_nameController.text}');
      
      // Parse variables to populate form fields with null safety
      final variables = criteriaData['variables'] as List<dynamic>? ?? [];
      print('Found ${variables.length} variables to process');
      
              for (var variable in variables) {
          print('Processing variable: $variable');
          
          if (variable == null || variable is! Map<String, dynamic>) {
            print('Invalid variable data: $variable');
            continue;
          }
          
                   final field = variable['field']?.toString();
         final selectedOption = variable['selectedOption']?.toString();
         final points = variable['points'] as int?;
         final min = variable['min'] != null ? (variable['min'] as num).toDouble() : null;
         final max = variable['max'] != null ? (variable['max'] as num).toDouble() : null;
         final expected = variable['expected'] as bool?;
          
          print('Field: $field, Option: $selectedOption, Points: $points, Min: $min, Max: $max');
          
          if (field == null || field.isEmpty) {
            print('Field is null or empty: $variable');
            continue;
          }
        
        switch (field) {
          case 'timeOfDay':
            _populateTimeOfDay(selectedOption, points);
            break;
          case 'temp':
            _populateTemperature(min, max, points);
            break;
          case 'temperature_trend':
            // This is a temperature trend option
            _populateTemperatureTrend(selectedOption, points);
            break;
          case 'barometric_pressure_level':
            _populateBarometricPressure(min, max, points);
            break;
          case 'barometric_trend':
            _populateBarometricTrend(selectedOption, points);
            break;
          case 'clouds':
            _populateClouds(min, max, points);
            break;
          case 'wind_spd':
            _populateWindSpeed(min, max, points);
            break;
          case 'wind_direction_consistency':
            _populateWindDirectionConsistency(points);
            break;
          case 'wind_dir':
            _populateWindDirection(selectedOption, points);
            break;
          case 'wind_trend':
            _populateWindTrend(selectedOption, points);
            break;
          case 'precipitation_chance':
            _populatePrecipitation(min, max, points);
            break;
          case 'precipitation_trend':
            _populatePrecipitationTrend(selectedOption, points);
            break;
          case 'increasing_chance_of_precipitation':
            _populatePrecipitationTrend(selectedOption, points);
            break;
          case 'thunderstorm_today':
            _populateThunderstormToday(points);
            break;
          case 'thunderstorm_tomorrow':
            _populateThunderstormTomorrow(points);
            break;
          case 'uv':
            _populateUV(min, max, points);
            break;
          case 'moon_phase':
            _populateMoonPhase(selectedOption, points);
            break;
          default:
            print('Unknown field: $field');
            break;
        }
      }
      
      // Force UI update after populating form
      if (mounted) {
        print('Form population completed');
        print('Final form state:');
        print('- selectedTimeOfDayIndexes: $selectedTimeOfDayIndexes');
        print('- selectedTempIndexes: $selectedTempIndexes');
        print('- selectedBioIndexes: $selectedBioIndexes');
        print('- selectedWindsIndex: $selectedWindsIndex');
        print('- selectedPercipitationIndex: $selectedPercipitationIndex');
        print('- selectedThunderIndex: $selectedThunderIndex');
        print('- isCloudsSelected: $isCloudsSelected');
        print('- isUvSelected: $isUvSelected');
        print('- selectedMoonIndex: $selectedMoonIndex');
        
        // Force multiple setState calls to ensure UI updates
        setState(() {});
        Future.delayed(Duration(milliseconds: 50), () {
          if (mounted) {
            setState(() {});
            print('Second setState called');
          }
        });
        Future.delayed(Duration(milliseconds: 100), () {
          if (mounted) {
            setState(() {});
            print('Third setState called');
          }
        });
      }
      
    } catch (e) {
      print('Error populating form with existing data: $e');
      // Don't throw error, just log it and continue with empty form
    }
  }

  // Helper methods to populate specific fields
  void _populateTimeOfDay(String? selectedOption, int? points) {
    print('Populating Time of Day: $selectedOption, points: $points');
    if (selectedOption == null || selectedOption.isEmpty) return;
    
    if (selectedOption == 'morning') {
      selectedTimeOfDayIndexes.add(0);
      selectedMorningPoints = _getPointsIndex(points);
      print('Added morning with points: $selectedMorningPoints');
      print('selectedTimeOfDayIndexes now contains: $selectedTimeOfDayIndexes');
    } else if (selectedOption == 'late_morning') {
      selectedTimeOfDayIndexes.add(1);
      selectedLateMorningPoints = _getPointsIndex(points);
      print('Added late morning with points: $selectedLateMorningPoints');
      print('selectedTimeOfDayIndexes now contains: $selectedTimeOfDayIndexes');
    } else if (selectedOption == 'late_afternoon') {
      selectedTimeOfDayIndexes.add(2);
      selectedLateAfternoonPoints = _getPointsIndex(points);
      print('Added late afternoon with points: $selectedLateAfternoonPoints');
      print('selectedTimeOfDayIndexes now contains: $selectedTimeOfDayIndexes');
    }
  }

  void _populateTemperature(double? min, double? max, int? points) {
    print('Populating Temperature: min=$min, max=$max, points=$points');
    selectedTempIndexes.add(0);
    if (min != null && max != null) {
      tempRange = RangeValues(min.toDouble(), max.toDouble());
      selectedTemRangeStart = min;
      selectedTemRangeEnd = max;
      print('Set temperature range: $tempRange');
    }
    selectedTempPoints = _getPointsIndex(points);
    print('Set temperature points: $selectedTempPoints');
    print('selectedTempIndexes now contains: $selectedTempIndexes');
  }

  void _populateTemperatureTrend(String? selectedOption, int? points) {
    selectedTempIndexes.add(1);
    if (selectedOption == null || selectedOption.isEmpty) return;
    
    if (selectedOption == 'warming') {
      selectedTempTrendSubIndex = 0;
    } else if (selectedOption == 'cooling') {
      selectedTempTrendSubIndex = 1;
    } else if (selectedOption == 'steady') {
      selectedTempTrendSubIndex = 2;
    }
    selectedTempTrendPoints = _getPointsIndex(points);
  }

  void _populateBarometricPressure(double? min, double? max, int? points) {
    print('Populating Barometric Pressure: min=$min, max=$max, points=$points');
    selectedBioIndexes.add(0);
    if (min != null && max != null) {
      if (min >= 30.2) {
        selectedBioSubIndex = 0; // High
      } else if (min >= 29.8 && max <= 30.2) {
        selectedBioSubIndex = 1; // Normal
      } else {
        selectedBioSubIndex = 2; // Low
      }
    }
    selectedBioPoints = _getPointsIndex(points);
    print('Set barometric pressure points: $selectedBioPoints, subIndex: $selectedBioSubIndex');
    print('selectedBioIndexes now contains: $selectedBioIndexes');
  }

  void _populateBarometricTrend(String? selectedOption, int? points) {
    selectedBioIndexes.add(1);
    if (selectedOption == null || selectedOption.isEmpty) return;
    
    print('Populating barometric trend: $selectedOption');
    
    if (selectedOption == 'rising') {
      selectedBioSubTrendIndex = 0;
    } else if (selectedOption == 'falling') {
      selectedBioSubTrendIndex = 1;
    } else if (selectedOption == 'steady') {
      selectedBioSubTrendIndex = 2;
    }
    selectedBioTrenPoints = _getPointsIndex(points);
    print('Set barometric trend index to: $selectedBioSubTrendIndex');
  }

  void _populateClouds(double? min, double? max, int? points) {
    print('Populating Clouds: min=$min, max=$max, points=$points');
    isCloudsSelected = true;
    if (min != null && max != null) {
      cloudRange = RangeValues(min.toDouble(), max.toDouble());
      print('Set cloud range: $cloudRange');
    }
    selectedCloudPoints = _getPointsIndex(points);
    print('Set cloud points: $selectedCloudPoints, isCloudsSelected: $isCloudsSelected');
  }

  void _populateWindSpeed(double? min, double? max, int? points) {
    print('Populating Wind Speed: min=$min, max=$max, points=$points');
    selectedWindsIndex.add(0);
    if (min != null && max != null) {
      windRange = RangeValues(min.toDouble(), max.toDouble());
      print('Set wind range: $windRange');
    }
    selectedWindSpeedPoints = _getPointsIndex(points);
    print('Set wind speed points: $selectedWindSpeedPoints');
    print('selectedWindsIndex now contains: $selectedWindsIndex');
  }

  void _populateWindDirectionConsistency(int? points) {
    selectedWindsIndex.add(1);
    selectedWindDirectionConsistencyPoints = _getPointsIndex(points);
    print('Set wind direction consistency points to: $selectedWindDirectionConsistencyPoints');
  }

  void _populateWindTrend(String? selectedOption, int? points) {
    selectedWindsIndex.add(1);
    if (selectedOption == null || selectedOption.isEmpty) return;
    
    print('Populating wind trend: $selectedOption');
    
    // Map wind trend options to consistency
    if (selectedOption == 'light' || selectedOption == 'decreasing' || selectedOption == 'steady') {
      selectedWindDirectionConsistencyPoints = _getPointsIndex(points);
    }
    print('Set wind trend points to: $selectedWindDirectionConsistencyPoints');
  }

  void _populateWindDirection(String? selectedOption, int? points) {
    selectedWindsIndex.add(2);
    if (selectedOption == null || selectedOption.isEmpty) return;
    
    print('Populating wind direction: $selectedOption');
    
    if (selectedOption == 'north' || selectedOption == 'N') {
      selectedWindDirectionSubIndex = 0;
    } else if (selectedOption == 'northeast' || selectedOption == 'NE') {
      selectedWindDirectionSubIndex = 1;
    } else if (selectedOption == 'east' || selectedOption == 'E') {
      selectedWindDirectionSubIndex = 2;
    } else if (selectedOption == 'southeast' || selectedOption == 'SE') {
      selectedWindDirectionSubIndex = 3;
    } else if (selectedOption == 'south' || selectedOption == 'S') {
      selectedWindDirectionSubIndex = 4;
    } else if (selectedOption == 'southwest' || selectedOption == 'SW') {
      selectedWindDirectionSubIndex = 5;
    } else if (selectedOption == 'west' || selectedOption == 'W') {
      selectedWindDirectionSubIndex = 6;
    } else if (selectedOption == 'northwest' || selectedOption == 'NW') {
      selectedWindDirectionSubIndex = 7;
    }
    selectedWindDirectionPoints = _getPointsIndex(points);
    print('Set wind direction index to: $selectedWindDirectionSubIndex');
  }

  void _populatePrecipitation(double? min, double? max, int? points) {
    print('Populating Precipitation: min=$min, max=$max, points=$points');
    selectedPercipitationIndex.add(0);
    if (min != null && max != null) {
      percipitationRange = RangeValues(min.toDouble(), max.toDouble());
      print('Set precipitation range: $percipitationRange');
    }
    selectedPercipitationPoints = _getPointsIndex(points);
    print('Set precipitation points: $selectedPercipitationPoints');
    print('selectedPercipitationIndex now contains: $selectedPercipitationIndex');
  }

  void _populatePrecipitationTrend(String? selectedOption, int? points) {
    selectedPercipitationIndex.add(1);
    if (selectedOption == null || selectedOption.isEmpty) return;
    
    print('Populating precipitation trend: $selectedOption');
    
    if (selectedOption == 'yes' || selectedOption == 'slight' || selectedOption == 'increasing' || selectedOption == 'moderate') {
      selectedPercipitationTrendSubIndex = 0;
    } else if (selectedOption == 'no' || selectedOption == 'decreasing') {
      selectedPercipitationTrendSubIndex = 1;
    }
    selectedPercipitationTrendPoints = _getPointsIndex(points);
    print('Set precipitation trend index to: $selectedPercipitationTrendSubIndex');
  }

  void _populateThunderstormToday(int? points) {
    selectedThunderIndex.add(0);
    selectedThunderPointsCurrentDay = _getPointsIndex(points);
  }

  void _populateThunderstormTomorrow(int? points) {
    selectedThunderIndex.add(1);
    selectedThunderPointNextDay = _getPointsIndex(points);
  }

  void _populateUV(double? min, double? max, int? points) {
    isUvSelected = true;
    if (min != null && max != null) {
      uvRange = RangeValues(min.toDouble(), max.toDouble());
    }
    selectedUVPoints = _getPointsIndex(points);
  }

  void _populateMoonPhase(String? selectedOption, int? points) {
    if (selectedOption == 'feeding_moon') {
      selectedMoonIndex.add(0);
      selectedMoonFeedingPoints = _getPointsIndex(points);
    } else if (selectedOption == 'new_moon') {
      selectedMoonIndex.add(1);
      selectedMoonNewPoints = _getPointsIndex(points);
    } else if (selectedOption == 'full_moon') {
      selectedMoonIndex.add(2);
      selectedMoonFullPoints = _getPointsIndex(points);
    }
  }

  // Helper method to convert points to index
  int? _getPointsIndex(int? points) {
    if (points == null) return null;
    switch (points) {
      case 1:
        print('Converting points 1 to index 0 (High)');
        return 0; // High
      case 2:
        print('Converting points 2 to index 1 (Normal)');
        return 1; // Normal
      case 3:
        print('Converting points 3 to index 2 (Low)');
        return 2; // Low
      default:
        print('Converting points $points to index 0 (default)');
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Debug logging for checkbox states
    if (widget.isEditMode) {
      print('Build method - Checkbox states:');
      print('- selectedTempIndexes.contains(0): ${selectedTempIndexes.contains(0)}');
      print('- selectedTempIndexes.contains(1): ${selectedTempIndexes.contains(1)}');
      print('- selectedBioIndexes.contains(0): ${selectedBioIndexes.contains(0)}');
      print('- selectedBioIndexes.contains(1): ${selectedBioIndexes.contains(1)}');
      print('- selectedWindsIndex.contains(0): ${selectedWindsIndex.contains(0)}');
      print('- selectedWindsIndex.contains(1): ${selectedWindsIndex.contains(1)}');
      print('- selectedWindsIndex.contains(2): ${selectedWindsIndex.contains(2)}');
      print('- selectedPercipitationIndex.contains(0): ${selectedPercipitationIndex.contains(0)}');
      print('- selectedPercipitationIndex.contains(1): ${selectedPercipitationIndex.contains(1)}');
      print('- isCloudsSelected: $isCloudsSelected');
    }
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        elevation: 0,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child:
                _isLoading
                    ? FastGifWidget(size: 30)
                    : GestureDetector(
                      onTap: createCriteria,
                      child: Icon(
                        Icons.save,
                        color: ClrCons.whiteColor,
                        size: 30,
                      ),
                    ),
          ),
        ],
      ),
      body: ThemedBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: Container(
                width: SizeCons.getWidth(context) * 0.9,

                child: Column(
                  children: [
                    SizedBox(height: 20),
                    CustomTextNew(
                      text: widget.isEditMode ? "Edit Criteria" : "Create Criteria",
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                    SizedBox(height: 20),
                    Container(
                      width: SizeCons.getWidth(context) * 0.7,
                      child: CustomTextField(
                        controller: _nameController,
                        hintText: 'Enter criteria name',
                      ),
                    ),
                    SizedBox(height: 20),
                    //TIME OF DAY
                    CustomButtonTextField(
                      // height: 400,
                      isHeight: true,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(ImgCons.sunIcon),
                                      ),
                                    ),
                                  ),
                                  CustomTextNew(
                                    text: 'Time of Day',
                                    fontSize: 20,
                                  ),
                                  Container(width: 20, height: 20),
                                ],
                              ),

                              SizedBox(height: 20),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomCheckBoxList(
                                    selectedIndexes: selectedTimeOfDayIndexes,
                                    onChanged: (index) {
                                      setState(() {
                                        if (selectedTimeOfDayIndexes.contains(
                                          index,
                                        )) {
                                          selectedTimeOfDayIndexes.remove(
                                            index,
                                          );
                                          if (index == 0) {
                                            selectedMorningPoints = null;
                                          }
                                          if (index == 1) {
                                            selectedLateMorningPoints = null;
                                          }
                                          if (index == 2) {
                                            selectedLateAfternoonPoints = null;
                                          }
                                        } else {
                                          selectedTimeOfDayIndexes.add(index);
                                        }
                                      });
                                    },
                                    labels: [
                                      Column(
                                        children: [
                                          Column(
                                            children: [
                                              SizedBox(
                                                width:
                                                    SizeCons.getWidth(context) *
                                                    0.65,
                                                child: CustomTextNew(
                                                  text: 'Morning',
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                            ],
                                          ),
                                          // if (selectedTimeOfDayIndexes.contains(
                                          //   0,
                                          // ))
                                          //   Column(
                                          //     children: [
                                          //       SizedBox(height: 10),
                                          //       Container(
                                          //         height: 1,
                                          //         width:
                                          //             SizeCons.getWidth(
                                          //               context,
                                          //             ) *
                                          //             0.6,
                                          //         color: Colors.grey[400]!,
                                          //       ),
                                          //       SizedBox(height: 10),
                                          //       SizedBox(
                                          //         width:
                                          //             SizeCons.getWidth(
                                          //               context,
                                          //             ) *
                                          //             0.65,
                                          //         child: CustomCheckBoxList(
                                          //           onChanged: (index) {
                                          //             setState(() {
                                          //               selectedMorningPoints =
                                          //                   index;
                                          //             });
                                          //           },
                                          //           labels: [
                                          //             Row(
                                          //               children: [
                                          //                 CustomTextNew(
                                          //                   text: '1',
                                          //                 ),
                                          //                 CustomTextNew(
                                          //                   text: 'pt',
                                          //                 ),
                                          //               ],
                                          //             ),
                                          //             CustomTextNew(
                                          //               text: '2pts',
                                          //             ),
                                          //             CustomTextNew(
                                          //               text: '3pts',
                                          //             ),
                                          //             CustomTextNew(
                                          //               text:
                                          //                   'Automatic red period (safety alert)',
                                          //             ),
                                          //           ],
                                          //           isRadio: true,
                                          //           isRow: true,
                                          //           isRound: true,
                                          //         ),
                                          //       ),
                                          //     ],
                                          //   ),
                                        ],
                                      ),

                                      Column(
                                        children: [
                                          SizedBox(
                                            width:
                                                SizeCons.getWidth(context) *
                                                0.65,
                                            child: CustomTextNew(
                                              text:
                                                  'Late morning - Early afternoon',
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          // if (selectedTimeOfDayIndexes.contains(
                                          //   1,
                                          // ))
                                          //   Column(
                                          //     children: [
                                          //       SizedBox(height: 10),
                                          //       Container(
                                          //         height: 1,
                                          //         width:
                                          //             SizeCons.getWidth(
                                          //               context,
                                          //             ) *
                                          //             0.6,
                                          //         color: Colors.grey[400]!,
                                          //       ),
                                          //       SizedBox(height: 10),
                                          //       SizedBox(
                                          //         width:
                                          //             SizeCons.getWidth(
                                          //               context,
                                          //             ) *
                                          //             0.65,
                                          //         child: CustomCheckBoxList(
                                          //           onChanged: (index) {
                                          //             setState(() {
                                          //               selectedLateMorningPoints =
                                          //                   index;
                                          //             });
                                          //           },
                                          //           labels: [
                                          //             Row(
                                          //               children: [
                                          //                 CustomTextNew(
                                          //                   text: '1',
                                          //                 ),
                                          //                 CustomTextNew(
                                          //                   text: 'pt',
                                          //                 ),
                                          //               ],
                                          //             ),
                                          //             CustomTextNew(
                                          //               text: '2pts',
                                          //             ),
                                          //             CustomTextNew(
                                          //               text: '3pts',
                                          //             ),
                                          //             CustomTextNew(
                                          //               text:
                                          //                   'Automatic red period (safety alert)',
                                          //             ),
                                          //           ],
                                          //           isRadio: true,
                                          //           isRow: true,
                                          //           isRound: true,
                                          //         ),
                                          //       ),
                                          //     ],
                                          //   ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          SizedBox(
                                            width:
                                                SizeCons.getWidth(context) *
                                                0.65,
                                            child: CustomTextNew(
                                              text: 'Late afternoon - Evening',
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          if (selectedTimeOfDayIndexes.contains(
                                                2,
                                              ) ||
                                              selectedTimeOfDayIndexes.contains(
                                                1,
                                              ) ||
                                              selectedTimeOfDayIndexes.contains(
                                                0,
                                              ))
                                            Column(
                                              children: [
                                                SizedBox(height: 10),
                                                Container(
                                                  height: 1,
                                                  width:
                                                      SizeCons.getWidth(
                                                        context,
                                                      ) *
                                                      0.6,
                                                  color: Colors.grey[400]!,
                                                ),
                                                SizedBox(height: 10),
                                                SizedBox(
                                                  width:
                                                      SizeCons.getWidth(
                                                        context,
                                                      ) *
                                                      0.65,
                                                  child: CustomCheckBoxList(
                                                    initialSelectedIndex: selectedMorningPoints ?? selectedLateMorningPoints ?? selectedLateAfternoonPoints ?? -1,
                                                    onChanged: (index) {
                                                      setState(() {
                                                        selectedMorningPoints =
                                                            index;
                                                        selectedLateMorningPoints =
                                                            index;
                                                        selectedLateAfternoonPoints =
                                                            index;
                                                      });
                                                    },
                                                    labels: [
                                                      Row(
                                                        children: [
                                                          CustomTextNew(
                                                            text: '1',
                                                          ),
                                                          CustomTextNew(
                                                            text: 'pt',
                                                          ),
                                                        ],
                                                      ),
                                                      CustomTextNew(
                                                        text: '2pts',
                                                      ),
                                                      CustomTextNew(
                                                        text: '3pts',
                                                      ),
                                                      CustomTextNew(
                                                        text:
                                                            'Automatic red period (safety alert)',
                                                      ),
                                                    ],
                                                    isRadio: true,
                                                    isRow: true,
                                                    isRound: true,
                                                  ),
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    BlocListener<PreferencesBloc, PreferencesState>(
                      listener: (context, state) {
                        setState(() {
                          useCelsius =
                              state.preferences.temperatureUnit == 'Celsius';
                        });
                        print(
                          "Temperature unit: ${state.preferences.temperatureUnit}",
                        );
                      },
                      child: CustomButtonTextField(
                        isHeight: true,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage(ImgCons.tempIcon),
                                        ),
                                      ),
                                    ),
                                    CustomTextNew(
                                      text: 'Temperature',
                                      fontSize: 20,
                                    ),
                                    Container(width: 20, height: 20),
                                  ],
                                ),
                                SizedBox(height: 20),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CustomCheckBoxList(
                                      selectedIndexes: selectedTempIndexes,
                                      onChanged: (index) {
                                        setState(() {
                                          if (selectedTempIndexes.contains(
                                            index,
                                          )) {
                                            selectedTempIndexes.remove(index);
                                            if (index == 0) {
                                              selectedTempPoints = null;
                                            }
                                            if (index == 1) {
                                              selectedTempTrendPoints = null;
                                              selectedTempTrendSubIndex = null;
                                            }
                                          } else {
                                            selectedTempIndexes.add(index);
                                          }
                                        });
                                      },
                                      labels: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            CustomTextNew(
                                              text: 'Temperature range',
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                            SizedBox(height: 20),
                                            if (selectedTempIndexes.contains(0))
                                              TemperatureRangeSlider(
                                                unit: useCelsius ? '°C' : '°F',
                                                min: useCelsius ? -18 : 0,
                                                max: useCelsius ? 32 : 90,
                                                initialRange: tempRange ?? RangeValues(useCelsius ? -18 : 0, useCelsius ? 32 : 90),
                                                onChanged: (range) {
                                                  setState(() {
                                                    tempRange = range;
                                                    selectedTemRangeStart =
                                                        range.start;
                                                    selectedTemRangeEnd =
                                                        range.end;

                                                    // Convert to Celsius for API
                                                    final celsiusStart =
                                                        useCelsius
                                                            ? range.start
                                                            : (range.start -
                                                                    32) *
                                                                5 /
                                                                9;
                                                    final celsiusEnd =
                                                        useCelsius
                                                            ? range.end
                                                            : (range.end - 32) *
                                                                5 /
                                                                9;

                                                    print(
                                                      'UI Temperature range: '
                                                      '${formatTemperature(range.start, useCelsius)} to '
                                                      '${formatTemperature(range.end, useCelsius)}',
                                                    );
                                                    print(
                                                      'API Temperature range (Celsius): '
                                                      '${celsiusStart}°C to ${celsiusEnd}°C',
                                                    );

                                                    // Store Celsius values for API use
                                                    apiTempRangeStart =
                                                        celsiusStart;
                                                    apiTempRangeEnd =
                                                        celsiusEnd;
                                                  });
                                                },
                                                isCelcius: useCelsius,
                                              ),
                                            if (selectedTempIndexes.contains(0))
                                              Container(
                                                width:
                                                    SizeCons.getWidth(context) *
                                                    0.65,
                                                child: CustomCheckBoxList(
                                                  initialSelectedIndex: selectedTempPoints ?? -1,
                                                  onChanged: (index) {
                                                    setState(() {
                                                      selectedTempPoints =
                                                          index;
                                                    });
                                                  },
                                                  labels: [
                                                    Row(
                                                      children: [
                                                        CustomTextNew(
                                                          text: '1',
                                                        ),
                                                        CustomTextNew(
                                                          text: 'pt',
                                                        ),
                                                      ],
                                                    ),
                                                    CustomTextNew(text: '2pts'),
                                                    CustomTextNew(text: '3pts'),
                                                    SizedBox(
                                                      width:
                                                          SizeCons.getWidth(
                                                            context,
                                                          ) *
                                                          0.5,
                                                      child: CustomTextNew(
                                                        text:
                                                            'Automatic red period (safety alert)',
                                                      ),
                                                    ),
                                                  ],
                                                  isRadio: true,
                                                  isRow: true,
                                                  isRound: true,
                                                ),
                                              ),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            CustomTextNew(
                                              text: 'Temperature trend',
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            SizedBox(height: 20),
                                            if (selectedTempIndexes.contains(1))
                                              Container(
                                                width:
                                                    SizeCons.getWidth(context) *
                                                    0.67,
                                                child: CustomCheckBoxList(
                                                  initialSelectedIndex: selectedTempTrendSubIndex ?? -1,
                                                  onChanged: (index) {
                                                    setState(() {
                                                      selectedTempTrendSubIndex =
                                                          index;
                                                    });
                                                  },
                                                  labels: [
                                                    CustomTextNew(
                                                      text: 'Warming',
                                                    ),
                                                    CustomTextNew(
                                                      text: 'Cooling',
                                                    ),
                                                    CustomTextNew(
                                                      text: 'Steady',
                                                    ),
                                                  ],
                                                  isRadio: true,
                                                  isRow: true,
                                                  isRound: true,
                                                ),
                                              ),
                                            if (selectedTempIndexes.contains(
                                                  1,
                                                ) &&
                                                selectedTempTrendSubIndex !=
                                                    null)
                                              Container(
                                                width:
                                                    SizeCons.getWidth(context) *
                                                    0.65,
                                                child: CustomCheckBoxList(
                                                  initialSelectedIndex: selectedTempTrendPoints ?? -1,
                                                  onChanged: (index) {
                                                    setState(() {
                                                      selectedTempTrendPoints =
                                                          index;
                                                    });
                                                  },
                                                  labels: [
                                                    Row(
                                                      children: [
                                                        CustomTextNew(
                                                          text: '1',
                                                        ),
                                                        CustomTextNew(
                                                          text: 'pt',
                                                        ),
                                                      ],
                                                    ),
                                                    CustomTextNew(text: '2pts'),
                                                    CustomTextNew(text: '3pts'),
                                                    SizedBox(
                                                      width:
                                                          SizeCons.getWidth(
                                                            context,
                                                          ) *
                                                          0.5,
                                                      child: CustomTextNew(
                                                        text:
                                                            'Automatic red period (safety alert)',
                                                      ),
                                                    ),
                                                  ],
                                                  isRadio: true,
                                                  isRow: true,
                                                  isRound: true,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    // Barometric
                    BlocListener<PreferencesBloc, PreferencesState>(
                      listener: (context, state) {
                        setState(() {
                          usembar = state.preferences.pressureUnit == 'inHg';
                        });
                        print(
                          "Pressure unit: ${state.preferences.pressureUnit}",
                        );
                        print("usembar: $usembar");
                      },
                      child: CustomButtonTextField(
                        // height: 400,
                        isHeight: true,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage(
                                            ImgCons.pressureIcon,
                                          ),
                                        ),
                                      ),
                                    ),
                                    CustomTextNew(
                                      text: 'Barometric Pressure',
                                      fontSize: 20,
                                    ),
                                    Container(width: 20, height: 20),
                                  ],
                                ),
                                SizedBox(height: 20),

                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CustomCheckBoxList(
                                      selectedIndexes: selectedBioIndexes,
                                      onChanged: (index) {
                                        setState(() {
                                          if (selectedBioIndexes.contains(
                                            index,
                                          )) {
                                            selectedBioIndexes.remove(index);
                                            if (index == 0) {
                                              selectedBioPoints = null;
                                              selectedBioSubIndex = null;
                                            }
                                            if (index == 1) {
                                              selectedBioTrenPoints = null;
                                              selectedBioSubTrendIndex = null;
                                            }
                                          } else {
                                            selectedBioIndexes.add(index);
                                          }
                                        });
                                      },

                                      labels: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            CustomTextNew(
                                              text: 'Barometric Pressure',
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                            SizedBox(height: 10),
                                            if (selectedBioIndexes.contains(0))
                                              CustomCheckBoxList(
                                                initialSelectedIndex: selectedBioSubIndex ?? -1,
                                                isRound: true,
                                                isRadio: true,
                                                onChanged: (index) {
                                                  setState(() {
                                                    selectedBioSubIndex = index;
                                                  });
                                                },
                                                labels: [
                                                  SizedBox(
                                                    child: RichText(
                                                      text: TextSpan(
                                                        children: [
                                                          TextSpan(
                                                            text: 'High = ',
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors
                                                                      .white, // Customize as needed
                                                              fontSize: 15,
                                                            ),
                                                          ),
                                                          TextSpan(
                                                            text:
                                                                !usembar
                                                                    ? '≥1022.69 mb'
                                                                    : '≥30.2 inHg',
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 15,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    child: RichText(
                                                      text: TextSpan(
                                                        children: [
                                                          TextSpan(
                                                            text: 'Normal= ',
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors
                                                                      .white, // Customize as needed
                                                              fontSize: 15,
                                                            ),
                                                          ),
                                                          TextSpan(
                                                            text:
                                                                !usembar
                                                                    ? '1009.14 - 1021.35 mb'
                                                                    : '29.8- 30.15 inHg',
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 15,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    child: RichText(
                                                      text: TextSpan(
                                                        children: [
                                                          TextSpan(
                                                            text: 'Low= ',
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors
                                                                      .white, // Customize as needed
                                                              fontSize: 15,
                                                            ),
                                                          ),
                                                          TextSpan(
                                                            text:
                                                                !usembar
                                                                    ? '≤1005.76 mb'
                                                                    : '≤29.7 inHg',
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 15,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            if (selectedBioIndexes.contains(
                                                  0,
                                                ) &&
                                                (selectedBioSubIndex == 0 ||
                                                    selectedBioSubIndex == 1 ||
                                                    selectedBioSubIndex == 2))
                                              Column(
                                                children: [
                                                  SizedBox(height: 10),
                                                  Container(
                                                    height: 1,
                                                    width:
                                                        SizeCons.getWidth(
                                                          context,
                                                        ) *
                                                        0.6,
                                                    color: Colors.grey[400]!,
                                                  ),
                                                  SizedBox(height: 10),
                                                  SizedBox(
                                                    width:
                                                        SizeCons.getWidth(
                                                          context,
                                                        ) *
                                                        0.65,
                                                    child: CustomCheckBoxList(
                                                      initialSelectedIndex: selectedBioPoints ?? -1,
                                                      onChanged: (index) {
                                                        setState(() {
                                                          selectedBioPoints =
                                                              index;
                                                        });
                                                      },
                                                      labels: [
                                                        CustomTextNew(
                                                          text: '1pt',
                                                        ),
                                                        CustomTextNew(
                                                          text: '2pts',
                                                        ),
                                                        CustomTextNew(
                                                          text: '3pts',
                                                        ),
                                                        CustomTextNew(
                                                          text:
                                                              'Automatic red period (safety alert)',
                                                        ),
                                                      ],
                                                      isRadio: true,
                                                      isRow: true,
                                                      isRound: true,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                          ],
                                        ),

                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            CustomTextNew(
                                              text: 'Barometric Trend',
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                            SizedBox(height: 10),
                                            if (selectedBioIndexes.contains(1))
                                              CustomCheckBoxList(
                                                initialSelectedIndex: selectedBioSubTrendIndex ?? -1,
                                                isRound: true,
                                                isRow: true,
                                                isRadio: true,
                                                onChanged: (int index) {
                                                  setState(() {
                                                    selectedBioSubTrendIndex =
                                                        index;
                                                  });
                                                },
                                                labels: [
                                                  CustomTextNew(
                                                    text: 'Rising',
                                                    color:
                                                        Colors
                                                            .white, // Customize as needed
                                                    fontSize: 15,
                                                  ),
                                                  CustomTextNew(
                                                    text: 'Falling',
                                                    color:
                                                        Colors
                                                            .white, // Customize as needed
                                                    fontSize: 15,
                                                  ),
                                                  CustomTextNew(
                                                    text: 'Steady',
                                                    color:
                                                        Colors
                                                            .white, // Customize as needed
                                                    fontSize: 15,
                                                  ),
                                                ],
                                              ),

                                            if (selectedBioIndexes.contains(
                                                  1,
                                                ) &&
                                                (selectedBioSubTrendIndex ==
                                                        0 ||
                                                    selectedBioSubTrendIndex ==
                                                        1 ||
                                                    selectedBioSubTrendIndex ==
                                                        2))
                                              Column(
                                                children: [
                                                  SizedBox(height: 10),
                                                  Container(
                                                    height: 1,
                                                    width:
                                                        SizeCons.getWidth(
                                                          context,
                                                        ) *
                                                        0.6,
                                                    color: Colors.grey[400]!,
                                                  ),
                                                  SizedBox(height: 10),
                                                  SizedBox(
                                                    width:
                                                        SizeCons.getWidth(
                                                          context,
                                                        ) *
                                                        0.65,
                                                    child: CustomCheckBoxList(
                                                      initialSelectedIndex: selectedBioTrenPoints ?? -1,
                                                      onChanged: (index) {
                                                        setState(() {
                                                          selectedBioTrenPoints =
                                                              index;
                                                        });
                                                      },
                                                      labels: [
                                                        CustomTextNew(
                                                          text: '1pt',
                                                        ),
                                                        CustomTextNew(
                                                          text: '2pts',
                                                        ),
                                                        CustomTextNew(
                                                          text: '3pts',
                                                        ),
                                                        CustomTextNew(
                                                          text:
                                                              'Automatic red period (safety alert)',
                                                        ),
                                                      ],
                                                      isRadio: true,
                                                      isRow: true,
                                                      isRound: true,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    // Clouds
                    CustomButtonTextField(
                      // width: SizeCons.getWidth(context) * 0.8,
                      // height: 400,
                      isHeight: true,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(ImgCons.cloudIcon),
                                      ),
                                    ),
                                  ),
                                  CustomTextNew(text: 'Clouds', fontSize: 20),
                                  Container(width: 20, height: 20),
                                ],
                              ),
                              SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  CustomCheckBoxList(
                                    selectedIndexes: isCloudsSelected ? {0} : {},
                                    onChanged: (index) {
                                      setState(() {
                                        isCloudsSelected = !isCloudsSelected;
                                        if (isCloudsSelected == false) {
                                          selectedCloudPoints = null;
                                        }
                                      });
                                    },
                                    labels: [
                                      CustomTextNew(
                                        text: 'Cloud Cover',
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              SizedBox(height: 20),
                              if (isCloudsSelected)
                                TemperatureRangeSlider(
                                  min: 0,
                                  max: 100,
                                  unit: '%',
                                  initialRange: cloudRange ?? RangeValues(20, 80),
                                  onChanged: (range) {
                                    setState(() {
                                      cloudRange = range;
                                      print(
                                        'Cloud cover: ${range.start} to ${range.end} %',
                                      );
                                    });
                                  },
                                ),
                              if (isCloudsSelected)
                                Column(
                                  children: [
                                    SizedBox(height: 10),
                                    Container(
                                      height: 1,
                                      width: SizeCons.getWidth(context) * 0.6,
                                      color: Colors.grey[400]!,
                                    ),
                                    SizedBox(height: 10),
                                    SizedBox(
                                      width: SizeCons.getWidth(context) * 0.65,
                                      child: CustomCheckBoxList(
                                        initialSelectedIndex: selectedCloudPoints ?? -1,
                                        onChanged: (index) {
                                          setState(() {
                                            selectedCloudPoints = index;
                                          });
                                        },
                                        labels: [
                                          Row(
                                            children: [
                                              CustomTextNew(text: '1'),
                                              CustomTextNew(text: 'pt'),
                                            ],
                                          ),
                                          CustomTextNew(text: '2pts'),
                                          CustomTextNew(text: '3pts'),
                                          CustomTextNew(
                                            text:
                                                'Automatic red period (safety alert)',
                                          ),
                                        ],
                                        isRadio: true,
                                        isRow: true,
                                        isRound: true,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    //Winds
                    BlocListener<PreferencesBloc, PreferencesState>(
                      listener: (context, state) {
                        setState(() {
                          // Update usekmh based on state.preferences.windSpeedUnit
                          usekmh =
                              state
                                  .preferences
                                  .windSpeedUnit; // Directly use the unit from state
                        });
                        print(
                          "Pressure unit: ${state.preferences.pressureUnit}",
                        );
                        print("usembar: $usembar");
                      },
                      child: CustomButtonTextField(
                        isHeight: true,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage(ImgCons.windIcon),
                                        ),
                                      ),
                                    ),
                                    CustomTextNew(text: 'Wind', fontSize: 20),
                                    Container(width: 20, height: 20),
                                  ],
                                ),
                                SizedBox(height: 20),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CustomCheckBoxList(
                                      selectedIndexes: selectedWindsIndex,
                                      onChanged: (index) {
                                        setState(() {
                                          if (selectedWindsIndex.contains(
                                            index,
                                          )) {
                                            selectedWindsIndex.remove(index);
                                            if (index == 0) {
                                              selectedWindSpeedPoints = null;
                                            }
                                            if (index == 1) {
                                              selectedWindTrendSubIndex = null;
                                              selectedWindTrendPoints = null;
                                            }
                                            if (index == 3) {
                                              selectedWindDirectionPoints =
                                                  null;
                                              selectedWindDirectionSubIndex =
                                                  null;
                                            }
                                          } else {
                                            selectedWindsIndex.add(index);
                                          }
                                        });
                                      },
                                      labels: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            CustomTextNew(
                                              text: 'Wind Speed Range',
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                            SizedBox(height: 20),
                                            if (selectedWindsIndex.contains(0))
                                              TemperatureRangeSlider(
                                                min: _getMinWindSpeed(usekmh),
                                                max: _getMaxWindSpeed(usekmh),
                                                unit: usekmh,
                                                initialRange:
                                                    _getInitialWindRange(
                                                      usekmh,
                                                    ),
                                                onChanged: (range) {
                                                  setState(() {
                                                    // Store range in m/s for internal consistency
                                                    windRange = _convertToMs(
                                                      range,
                                                      usekmh,
                                                    );
                                                    print(
                                                      'Wind speed: ${windRange.start.toStringAsFixed(2)} to '
                                                      '${windRange.end.toStringAsFixed(2)} m/s',
                                                    );
                                                  });
                                                },
                                              ),
                                            if (selectedWindsIndex.contains(0))
                                              Column(
                                                children: [
                                                  SizedBox(height: 10),
                                                  Container(
                                                    height: 1,
                                                    width:
                                                        SizeCons.getWidth(
                                                          context,
                                                        ) *
                                                        0.6,
                                                    color: Colors.grey[400]!,
                                                  ),
                                                  SizedBox(height: 10),
                                                  SizedBox(
                                                    width:
                                                        SizeCons.getWidth(
                                                          context,
                                                        ) *
                                                        0.65,
                                                    child: CustomCheckBoxList(
                                                      initialSelectedIndex: selectedWindSpeedPoints ?? -1,
                                                      onChanged: (index) {
                                                        setState(() {
                                                          selectedWindSpeedPoints =
                                                              index;
                                                        });
                                                      },
                                                      labels: [
                                                        CustomTextNew(
                                                          text: '1pt',
                                                        ),
                                                        CustomTextNew(
                                                          text: '2pts',
                                                        ),
                                                        CustomTextNew(
                                                          text: '3pts',
                                                        ),
                                                        CustomTextNew(
                                                          text:
                                                              'Automatic red period (safety alert)',
                                                        ),
                                                      ],
                                                      isRadio: true,
                                                      isRow: true,
                                                      isRound: true,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                          ],
                                        ),
                                        // Column(
                                        //   crossAxisAlignment:
                                        //       CrossAxisAlignment.start,
                                        //   children: [
                                        //     CustomTextNew(
                                        //       text: 'Wind Speed Trend',
                                        //       fontSize: 15,
                                        //       fontWeight: FontWeight.w500,
                                        //       decoration:
                                        //           TextDecoration.underline,
                                        //     ),
                                        //     SizedBox(height: 10),
                                        //     if (selectedWindsIndex.contains(1))
                                        //       Row(
                                        //         children: [
                                        //           CustomCheckBoxList(
                                        //             isRound: true,
                                        //             isRadio: true,
                                        //             onChanged: (index) {
                                        //               log(
                                        //                 "Index: ${index.toString()}",
                                        //               );
                                        //               setState(() {
                                        //                 selectedWindTrendSubIndex =
                                        //                     index;
                                        //               });
                                        //             },
                                        //             labels: _getWindTrendLabels(
                                        //               usekmh,
                                        //             ),
                                        //           ),
                                        //         ],
                                        //       ),
                                        //     if (selectedWindsIndex.contains(
                                        //           1,
                                        //         ) &&
                                        //         selectedWindTrendSubIndex !=
                                        //             null)
                                        //       Column(
                                        //         children: [
                                        //           SizedBox(height: 10),
                                        //           Container(
                                        //             height: 1,
                                        //             width:
                                        //                 SizeCons.getWidth(
                                        //                   context,
                                        //                 ) *
                                        //                 0.6,
                                        //             color: Colors.grey[400]!,
                                        //           ),
                                        //           SizedBox(height: 10),
                                        //           SizedBox(
                                        //             width:
                                        //                 SizeCons.getWidth(
                                        //                   context,
                                        //                 ) *
                                        //                 0.65,
                                        //             child: CustomCheckBoxList(
                                        //               onChanged: (index) {
                                        //                 setState(() {
                                        //                   selectedWindTrendPoints =
                                        //                       index;
                                        //                 });
                                        //               },
                                        //               labels: [
                                        //                 CustomTextNew(
                                        //                   text: '1pts',
                                        //                 ),
                                        //                 CustomTextNew(
                                        //                   text: '2pts',
                                        //                 ),
                                        //                 CustomTextNew(
                                        //                   text: '3pts',
                                        //                 ),
                                        //                 CustomTextNew(
                                        //                   text:
                                        //                       'Automatic red period (safety alert)',
                                        //                 ),
                                        //               ],
                                        //               isRadio: true,
                                        //               isRow: true,
                                        //               isRound: true,
                                        //             ),
                                        //           ),
                                        //         ],
                                        //       ),
                                        //   ],
                                        // ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            CustomTextNew(
                                              text:
                                                  'Wind Direction Consistency',
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                            SizedBox(height: 10),
                                            // SizedBox(
                                            //   width:
                                            //       SizeCons.getWidth(context) *
                                            //       0.65,
                                            //   child: CustomCheckBoxList(
                                            //     onChanged: (index) {
                                            //       setState(() {
                                            //         selectedWindDirectionConsistencyPoints =
                                            //             index;
                                            //       });
                                            //     },
                                            //     labels: [

                                            //       Row(
                                            //         children: [
                                            //           CustomTextNew(text: '1'),
                                            //           CustomTextNew(text: 'pt'),
                                            //         ],
                                            //       ),
                                            //       CustomTextNew(text: '2pts'),
                                            //       CustomTextNew(text: '3pts'),
                                            //       CustomTextNew(
                                            //         text:
                                            //             'Automatic red period (safety alert)',
                                            //       ),
                                            //     ],
                                            //     isRadio: true,
                                            //     isRow: true,
                                            //     isRound: true,
                                            //   ),
                                            // ),
                                            if (selectedWindsIndex.contains(1))
                                              Column(
                                                children: [
                                                  SizedBox(height: 10),
                                                  Container(
                                                    height: 1,
                                                    width:
                                                        SizeCons.getWidth(
                                                          context,
                                                        ) *
                                                        0.6,
                                                    color: Colors.grey[400]!,
                                                  ),
                                                  SizedBox(height: 10),
                                                  SizedBox(
                                                    width:
                                                        SizeCons.getWidth(
                                                          context,
                                                        ) *
                                                        0.65,
                                                    child: CustomCheckBoxList(
                                                      initialSelectedIndex: selectedWindDirectionConsistencyPoints ?? -1,
                                                      onChanged: (index) {
                                                        setState(() {
                                                          selectedWindDirectionConsistencyPoints =
                                                              index;
                                                        });
                                                      },
                                                      labels: [
                                                        Row(
                                                          children: [
                                                            CustomTextNew(
                                                              text: '1',
                                                            ),
                                                            CustomTextNew(
                                                              text: 'pt',
                                                            ),
                                                          ],
                                                        ),
                                                        CustomTextNew(
                                                          text: '2pts',
                                                        ),
                                                        CustomTextNew(
                                                          text: '3pts',
                                                        ),
                                                        CustomTextNew(
                                                          text:
                                                              'Automatic red period (safety alert)',
                                                        ),
                                                      ],
                                                      isRadio: true,
                                                      isRow: true,
                                                      isRound: true,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            CustomTextNew(
                                              text: 'Wind Direction',
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                            SizedBox(height: 10),
                                            if (selectedWindsIndex.contains(2))
                                              Row(
                                                children: [
                                                  SizedBox(
                                                    width:
                                                        SizeCons.getWidth(
                                                          context,
                                                        ) *
                                                        0.65,
                                                    child: CustomCheckBoxList(
                                                      initialSelectedIndex: selectedWindDirectionSubIndex ?? -1,
                                                      isRound: true,
                                                      isRadio: true,
                                                      onChanged: (index) {
                                                        setState(() {
                                                          selectedWindDirectionSubIndex =
                                                              index;
                                                        });
                                                      },
                                                      labels: [
                                                        CustomTextNew(
                                                          text: 'North',
                                                          fontSize: 15,
                                                        ),
                                                        CustomTextNew(
                                                          text: 'Northeast',
                                                          fontSize: 15,
                                                        ),
                                                        CustomTextNew(
                                                          text: 'East',
                                                          fontSize: 15,
                                                        ),
                                                        CustomTextNew(
                                                          text: 'Southeast',
                                                          fontSize: 15,
                                                        ),
                                                        CustomTextNew(
                                                          text: 'South',
                                                          fontSize: 15,
                                                        ),
                                                        CustomTextNew(
                                                          text: 'Southwest',
                                                          fontSize: 15,
                                                        ),
                                                        CustomTextNew(
                                                          text: 'West',
                                                          fontSize: 15,
                                                        ),
                                                        CustomTextNew(
                                                          text: 'Northwest',
                                                          fontSize: 15,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            if (selectedWindsIndex.contains(
                                                  2,
                                                ) &&
                                                selectedWindDirectionSubIndex !=
                                                    null)
                                              Column(
                                                children: [
                                                  SizedBox(height: 10),
                                                  Container(
                                                    height: 1,
                                                    width:
                                                        SizeCons.getWidth(
                                                          context,
                                                        ) *
                                                        0.6,
                                                    color: Colors.grey[400]!,
                                                  ),
                                                  SizedBox(height: 10),
                                                  SizedBox(
                                                    width:
                                                        SizeCons.getWidth(
                                                          context,
                                                        ) *
                                                        0.65,
                                                    child: CustomCheckBoxList(
                                                      initialSelectedIndex: selectedWindDirectionPoints ?? -1,
                                                      onChanged: (index) {
                                                        setState(() {
                                                          selectedWindDirectionPoints =
                                                              index;
                                                        });
                                                      },
                                                      labels: [
                                                        CustomTextNew(
                                                          text: '1pt',
                                                        ),
                                                        CustomTextNew(
                                                          text: '2pts',
                                                        ),
                                                        CustomTextNew(
                                                          text: '3pts',
                                                        ),
                                                        CustomTextNew(
                                                          text:
                                                              'Automatic red period (safety alert)',
                                                        ),
                                                      ],
                                                      isRadio: true,
                                                      isRow: true,
                                                      isRound: true,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    // Percipitation
                    CustomButtonTextField(
                      // height: 400,
                      isHeight: true,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(
                                          ImgCons.percipitationIcon,
                                        ),
                                      ),
                                    ),
                                  ),
                                  CustomTextNew(
                                    text: 'Precipitation',
                                    fontSize: 20,
                                  ),
                                  Container(width: 20, height: 20),
                                ],
                              ),
                              SizedBox(height: 20),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomCheckBoxList(
                                    selectedIndexes: selectedPercipitationIndex,
                                    // isRadio: true,
                                    onChanged: (index) {
                                      // setState(() {
                                      //   selectedPercipitationIndex = index;
                                      // });
                                      setState(() {
                                        if (selectedPercipitationIndex.contains(
                                          index,
                                        )) {
                                          selectedPercipitationIndex.remove(
                                            index,
                                          );
                                          if (index == 0) {
                                            selectedPercipitationPoints = null;
                                            selectedPercipitationSubIndex =
                                                null;
                                          }
                                          if (index == 1) {
                                            selectedPercipitationTrendPoints =
                                                null;
                                            selectedPercipitationTrendSubIndex =
                                                null;
                                          }
                                        } else {
                                          selectedPercipitationIndex.add(index);
                                        }
                                      });
                                    },
                                    labels: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CustomTextNew(
                                            text: 'Chance of Precipitation',
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                          SizedBox(height: 20),
                                          if (selectedPercipitationIndex
                                              .contains(0))
                                            TemperatureRangeSlider(
                                              min: 0,
                                              max: 100,
                                              unit: '%',
                                              initialRange: percipitationRange ?? RangeValues(30, 70),
                                              onChanged: (range) {
                                                setState(() {
                                                  percipitationRange = range;
                                                  print(
                                                    'percipitationRange ${percipitationRange.start} to ${percipitationRange.end} %',
                                                  );
                                                });
                                              },
                                            ),
                                          if (selectedPercipitationIndex
                                              .contains(0))
                                            Column(
                                              children: [
                                                SizedBox(height: 10),
                                                Container(
                                                  height: 1,
                                                  width:
                                                      SizeCons.getWidth(
                                                        context,
                                                      ) *
                                                      0.6,
                                                  color: Colors.grey[400]!,
                                                ),
                                                SizedBox(height: 10),
                                                SizedBox(
                                                  width:
                                                      SizeCons.getWidth(
                                                        context,
                                                      ) *
                                                      0.65,
                                                  child: CustomCheckBoxList(
                                                    initialSelectedIndex: selectedPercipitationPoints ?? -1,
                                                    onChanged: (index) {
                                                      setState(() {
                                                        selectedPercipitationPoints =
                                                            index;
                                                      });
                                                    },
                                                    labels: [
                                                      Row(
                                                        children: [
                                                          CustomTextNew(
                                                            text: '1',
                                                          ),
                                                          CustomTextNew(
                                                            text: 'pt',
                                                          ),
                                                        ],
                                                      ),
                                                      CustomTextNew(
                                                        text: '2pts',
                                                      ),
                                                      CustomTextNew(
                                                        text: '3pts',
                                                      ),
                                                      CustomTextNew(
                                                        text:
                                                            'Automatic red period (safety alert)',
                                                      ),
                                                    ],
                                                    isRadio: true,
                                                    isRow: true,
                                                    isRound: true,
                                                  ),
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CustomTextNew(
                                            text:
                                                'Increasing chance of Precipitation',
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                          SizedBox(height: 10),
                                          if (selectedPercipitationIndex
                                              .contains(1))
                                            Row(
                                              children: [
                                                CustomCheckBoxList(
                                                  initialSelectedIndex: selectedPercipitationTrendSubIndex ?? -1,
                                                  isRound: true,
                                                  isRadio: true,
                                                  onChanged: (index) {
                                                    setState(() {
                                                      selectedPercipitationTrendSubIndex =
                                                          index;
                                                    });
                                                  },
                                                  labels: [
                                                    CustomTextNew(
                                                      text: 'Yes',
                                                      fontSize: 15,
                                                    ),
                                                    CustomTextNew(
                                                      text: 'No',
                                                      fontSize: 15,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          if (selectedPercipitationIndex
                                                  .contains(1) &&
                                              selectedPercipitationTrendSubIndex !=
                                                  null)
                                            Column(
                                              children: [
                                                SizedBox(height: 10),
                                                Container(
                                                  height: 1,
                                                  width:
                                                      SizeCons.getWidth(
                                                        context,
                                                      ) *
                                                      0.6,
                                                  color: Colors.grey[400]!,
                                                ),
                                                SizedBox(height: 10),
                                                SizedBox(
                                                  width:
                                                      SizeCons.getWidth(
                                                        context,
                                                      ) *
                                                      0.65,
                                                  child: CustomCheckBoxList(
                                                    initialSelectedIndex: selectedPercipitationTrendPoints ?? -1,
                                                    onChanged: (index) {
                                                      setState(() {
                                                        selectedPercipitationTrendPoints =
                                                            index;
                                                      });
                                                    },
                                                    labels: [
                                                      Row(
                                                        children: [
                                                          CustomTextNew(
                                                            text: '1',
                                                          ),
                                                          CustomTextNew(
                                                            text: 'pt',
                                                          ),
                                                        ],
                                                      ),
                                                      CustomTextNew(
                                                        text: '2pts',
                                                      ),
                                                      CustomTextNew(
                                                        text: '3pts',
                                                      ),
                                                      CustomTextNew(
                                                        text:
                                                            'Automatic red period (safety alert)',
                                                      ),
                                                    ],
                                                    isRadio: true,
                                                    isRow: true,
                                                    isRound: true,
                                                  ),
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    // Thunderstorms
                    CustomButtonTextField(
                      // height: 400,
                      isHeight: true,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(ImgCons.thunderIcon),
                                      ),
                                    ),
                                  ),
                                  CustomTextNew(
                                    text: 'Thunderstorms',
                                    fontSize: 20,
                                  ),
                                  Container(width: 20, height: 20),
                                ],
                              ),

                              SizedBox(height: 20),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomCheckBoxList(
                                    selectedIndexes: selectedThunderIndex,
                                    onChanged: (index) {
                                      setState(() {
                                        if (selectedThunderIndex.contains(
                                          index,
                                        )) {
                                          selectedThunderIndex.remove(index);
                                          if (index == 0) {
                                            selectedThunderPointsCurrentDay =
                                                null;
                                          }
                                          if (index == 1) {
                                            selectedThunderPointNextDay = null;
                                          }
                                        } else {
                                          selectedThunderIndex.add(index);
                                        }
                                      });
                                    },
                                    labels: [
                                      Column(
                                        children: [
                                          Column(
                                            children: [
                                              SizedBox(
                                                width:
                                                    SizeCons.getWidth(context) *
                                                    0.65,
                                                child: CustomTextNew(
                                                  text:
                                                      'Thunderstorms predicted for the period.',
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                            ],
                                          ),
                                          if (selectedThunderIndex.contains(0))
                                            Column(
                                              children: [
                                                SizedBox(height: 10),
                                                Container(
                                                  height: 1,
                                                  width:
                                                      SizeCons.getWidth(
                                                        context,
                                                      ) *
                                                      0.6,
                                                  color: Colors.grey[400]!,
                                                ),
                                                SizedBox(height: 10),
                                                SizedBox(
                                                  width:
                                                      SizeCons.getWidth(
                                                        context,
                                                      ) *
                                                      0.65,
                                                  child: CustomCheckBoxList(
                                                    initialSelectedIndex: selectedThunderPointsCurrentDay ?? -1,
                                                    onChanged: (index) {
                                                      setState(() {
                                                        selectedThunderPointsCurrentDay =
                                                            index;
                                                      });
                                                    },
                                                    labels: [
                                                      Row(
                                                        children: [
                                                          CustomTextNew(
                                                            text: '1',
                                                          ),
                                                          CustomTextNew(
                                                            text: 'pt',
                                                          ),
                                                        ],
                                                      ),
                                                      CustomTextNew(
                                                        text: '2pts',
                                                      ),
                                                      CustomTextNew(
                                                        text: '3pts',
                                                      ),
                                                      CustomTextNew(
                                                        text:
                                                            'Automatic red period (safety alert)',
                                                      ),
                                                    ],
                                                    isRadio: true,
                                                    isRow: true,
                                                    isRound: true,
                                                  ),
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),

                                      Column(
                                        children: [
                                          SizedBox(
                                            width:
                                                SizeCons.getWidth(context) *
                                                0.65,
                                            child: CustomTextNew(
                                              text:
                                                  'Thunderstorms predicted the next day.',
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          if (selectedThunderIndex.contains(1))
                                            Column(
                                              children: [
                                                SizedBox(height: 10),
                                                Container(
                                                  height: 1,
                                                  width:
                                                      SizeCons.getWidth(
                                                        context,
                                                      ) *
                                                      0.6,
                                                  color: Colors.grey[400]!,
                                                ),
                                                SizedBox(height: 10),
                                                SizedBox(
                                                  width:
                                                      SizeCons.getWidth(
                                                        context,
                                                      ) *
                                                      0.65,
                                                  child: CustomCheckBoxList(
                                                    initialSelectedIndex: selectedThunderPointNextDay ?? -1,
                                                    onChanged: (index) {
                                                      setState(() {
                                                        selectedThunderPointNextDay =
                                                            index;
                                                      });
                                                    },
                                                    labels: [
                                                      Row(
                                                        children: [
                                                          CustomTextNew(
                                                            text: '1',
                                                          ),
                                                          CustomTextNew(
                                                            text: 'pt',
                                                          ),
                                                        ],
                                                      ),
                                                      CustomTextNew(
                                                        text: '2pts',
                                                      ),
                                                      CustomTextNew(
                                                        text: '3pts',
                                                      ),
                                                      CustomTextNew(
                                                        text:
                                                            'Automatic red period (safety alert)',
                                                      ),
                                                    ],
                                                    isRadio: true,
                                                    isRow: true,
                                                    isRound: true,
                                                  ),
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    // UV
                    CustomButtonTextField(
                      // height: 400,
                      isHeight: true,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(ImgCons.uvIcon),
                                      ),
                                    ),
                                  ),
                                  CustomTextNew(text: 'UV index', fontSize: 20),
                                  Container(width: 20, height: 20),
                                ],
                              ),
                              SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  CustomCheckBoxList(
                                    selectedIndexes: isUvSelected ? {0} : {},
                                    onChanged: (index) {
                                      setState(() {
                                        isUvSelected = !isUvSelected;
                                        if (isUvSelected == false) {
                                          selectedUVPoints = null;
                                        }
                                      });
                                    },
                                    labels: [
                                      CustomTextNew(
                                        text: 'UV index',
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              SizedBox(height: 20),
                              if (isUvSelected)
                                TemperatureRangeSlider(
                                  min: 0,
                                  max: 11,
                                  unit: '',
                                  initialRange: uvRange ?? RangeValues(0, 11),
                                  onChanged: (range) {
                                    setState(() {
                                      uvRange = range;
                                      print(
                                        'UV index: ${range.start} to ${range.end} %',
                                      );
                                    });
                                  },
                                ),
                              if (isUvSelected)
                                Column(
                                  children: [
                                    SizedBox(height: 10),
                                    Container(
                                      height: 1,
                                      width: SizeCons.getWidth(context) * 0.6,
                                      color: Colors.grey[400]!,
                                    ),
                                    SizedBox(height: 10),
                                    SizedBox(
                                      width: SizeCons.getWidth(context) * 0.65,
                                      child: CustomCheckBoxList(
                                        initialSelectedIndex: selectedUVPoints ?? -1,
                                        onChanged: (index) {
                                          setState(() {
                                            selectedUVPoints = index;
                                          });
                                        },
                                        labels: [
                                          Row(
                                            children: [
                                              CustomTextNew(text: '1'),
                                              CustomTextNew(text: 'pt'),
                                            ],
                                          ),
                                          CustomTextNew(text: '2pts'),
                                          CustomTextNew(text: '3pts'),
                                          CustomTextNew(
                                            text:
                                                'Automatic red period (safety alert)',
                                          ),
                                        ],
                                        isRadio: true,
                                        isRow: true,
                                        isRound: true,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    // Moon influence
                    CustomButtonTextField(
                      width: SizeCons.getWidth(context) * 0.9,

                      // height: 400,
                      isHeight: true,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(ImgCons.solunarIcon),
                                      ),
                                    ),
                                  ),
                                  CustomTextNew(
                                    text: 'Moon influence',
                                    fontSize: 20,
                                  ),
                                  Container(width: 20, height: 20),
                                ],
                              ),
                              SizedBox(height: 20),
                              CustomTextNew(
                                text: 'Periods',
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.underline,
                              ),
                              SizedBox(height: 20),
                              Row(
                                children: [
                                  CustomCheckBoxList(
                                    selectedIndexes: selectedMoonIndex,
                                    isRadio: false,
                                    // onChanged: (index) {
                                    //   setState(() {
                                    //     if (selectedMoonIndex.contains(index)) {
                                    //       selectedMoonIndex.remove(index);
                                    //     } else {
                                    //       selectedMoonIndex.add(index);
                                    //     }
                                    //   });
                                    // },
                                    onChanged: (index) {
                                      // setState(() {
                                      //   selectedMoonIndex = index;
                                      // });
                                      setState(() {
                                        if (selectedMoonIndex.contains(index)) {
                                          selectedMoonIndex.remove(index);
                                          if (index == 0) {
                                            selectedMoonFeedingPoints = null;
                                          }
                                          if (index == 1) {
                                            selectedMoonNewPoints = null;
                                          }
                                          if (index == 2) {
                                            selectedMoonFullPoints = null;
                                          }
                                        } else {
                                          selectedMoonIndex.add(index);
                                        }
                                      });
                                    },
                                    labels: [
                                      Column(
                                        children: [
                                          Column(
                                            children: [
                                              SizedBox(
                                                width:
                                                    SizeCons.getWidth(context) *
                                                    0.65,
                                                child: CustomTextNew(
                                                  text: 'Feeding periods',
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                            ],
                                          ),
                                          // if (selectedMoonIndex.contains(0))
                                          //   Column(
                                          //     children: [
                                          //       SizedBox(height: 10),
                                          //       Container(
                                          //         height: 1,
                                          //         width:
                                          //             SizeCons.getWidth(
                                          //               context,
                                          //             ) *
                                          //             0.6,
                                          //         color: Colors.grey[400]!,
                                          //       ),
                                          //       SizedBox(height: 10),
                                          //       SizedBox(
                                          //         width:
                                          //             SizeCons.getWidth(
                                          //               context,
                                          //             ) *
                                          //             0.65,
                                          //         child: CustomCheckBoxList(
                                          //           onChanged: (index) {
                                          //             setState(() {
                                          //               selectedMoonFeedingPoints =
                                          //                   index;
                                          //             });
                                          //           },
                                          //           labels: [
                                          //             Row(
                                          //               children: [
                                          //                 CustomTextNew(
                                          //                   text: '1',
                                          //                 ),
                                          //                 CustomTextNew(
                                          //                   text: 'pt',
                                          //                 ),
                                          //               ],
                                          //             ),
                                          //             CustomTextNew(
                                          //               text: '2pts',
                                          //             ),
                                          //             CustomTextNew(
                                          //               text: '3pts',
                                          //             ),
                                          //             CustomTextNew(
                                          //               text:
                                          //                   'Automatic red period (safety alert)',
                                          //             ),
                                          //           ],
                                          //           isRadio: true,
                                          //           isRow: true,
                                          //           isRound: true,
                                          //         ),
                                          //       ),
                                          //     ],
                                          //   ),
                                        ],
                                      ),

                                      Column(
                                        children: [
                                          SizedBox(
                                            width:
                                                SizeCons.getWidth(context) *
                                                0.65,
                                            child: CustomTextNew(
                                              text: 'New moon',
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          // if (selectedMoonIndex.contains(1))
                                          //   Column(
                                          //     children: [
                                          //       SizedBox(height: 10),
                                          //       Container(
                                          //         height: 1,
                                          //         width:
                                          //             SizeCons.getWidth(
                                          //               context,
                                          //             ) *
                                          //             0.6,
                                          //         color: Colors.grey[400]!,
                                          //       ),
                                          //       SizedBox(height: 10),
                                          //       SizedBox(
                                          //         width:
                                          //             SizeCons.getWidth(
                                          //               context,
                                          //             ) *
                                          //             0.65,
                                          //         child: CustomCheckBoxList(
                                          //           onChanged: (index) {
                                          //             setState(() {
                                          //               selectedMoonNewPoints =
                                          //                   index;
                                          //             });
                                          //           },
                                          //           labels: [
                                          //             Row(
                                          //               children: [
                                          //                 CustomTextNew(
                                          //                   text: '1',
                                          //                 ),
                                          //                 CustomTextNew(
                                          //                   text: 'pt',
                                          //                 ),
                                          //               ],
                                          //             ),
                                          //             CustomTextNew(
                                          //               text: '2pts',
                                          //             ),
                                          //             CustomTextNew(
                                          //               text: '3pts',
                                          //             ),
                                          //             CustomTextNew(
                                          //               text:
                                          //                   'Automatic red period (safety alert)',
                                          //             ),
                                          //           ],
                                          //           isRadio: true,
                                          //           isRow: true,
                                          //           isRound: true,
                                          //         ),
                                          //       ),
                                          //     ],
                                          //   ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          SizedBox(
                                            width:
                                                SizeCons.getWidth(context) *
                                                0.65,
                                            child: CustomTextNew(
                                              text: 'Full moon',
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          if (selectedMoonIndex.contains(2) ||
                                              selectedMoonIndex.contains(1) ||
                                              selectedMoonIndex.contains(0))
                                            Column(
                                              children: [
                                                SizedBox(height: 10),
                                                Container(
                                                  height: 1,
                                                  width:
                                                      SizeCons.getWidth(
                                                        context,
                                                      ) *
                                                      0.6,
                                                  color: Colors.grey[400]!,
                                                ),
                                                SizedBox(height: 10),
                                                SizedBox(
                                                  width:
                                                      SizeCons.getWidth(
                                                        context,
                                                      ) *
                                                      0.65,
                                                  child: CustomCheckBoxList(
                                                    initialSelectedIndex: selectedMoonFeedingPoints ?? selectedMoonNewPoints ?? selectedMoonFullPoints ?? -1,
                                                    onChanged: (index) {
                                                      setState(() {
                                                        selectedMoonNewPoints =
                                                            index;
                                                        selectedMoonFeedingPoints =
                                                            index;
                                                        selectedMoonFullPoints =
                                                            index;
                                                      });
                                                    },
                                                    labels: [
                                                      Row(
                                                        children: [
                                                          CustomTextNew(
                                                            text: '1',
                                                          ),
                                                          CustomTextNew(
                                                            text: 'pt',
                                                          ),
                                                        ],
                                                      ),
                                                      CustomTextNew(
                                                        text: '2pts',
                                                      ),
                                                      CustomTextNew(
                                                        text: '3pts',
                                                      ),
                                                      CustomTextNew(
                                                        text:
                                                            'Automatic red period (safety alert)',
                                                      ),
                                                    ],
                                                    isRadio: true,
                                                    isRow: true,
                                                    isRound: true,
                                                  ),
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ],
                                    // labels: [
                                    //   Column(
                                    //     crossAxisAlignment:
                                    //         CrossAxisAlignment.start,
                                    //     children: [
                                    //       CustomTextNew(
                                    //         text: 'Feeding periods',
                                    //         fontSize: 15,
                                    //       ),
                                    //       SizedBox(height: 5),

                                    //       if (selectedMoonIndex == 0)
                                    //         Column(
                                    //           children: [
                                    //             SizedBox(height: 10),
                                    //             Container(
                                    //               height: 1,
                                    //               width:
                                    //                   SizeCons.getWidth(
                                    //                     context,
                                    //                   ) *
                                    //                   0.6,
                                    //               color: Colors.grey[400]!,
                                    //             ),
                                    //             SizedBox(height: 10),
                                    //             SizedBox(
                                    //               width:
                                    //                   SizeCons.getWidth(
                                    //                     context,
                                    //                   ) *
                                    //                   0.65,
                                    //               child: CustomCheckBoxList(
                                    //                 onChanged: (index) {
                                    //                   setState(() {
                                    //                     selectedMoonFeedingPoints =
                                    //                         index;
                                    //                   });
                                    //                 },
                                    //                 labels: [
                                    //                   Row(
                                    //                     children: [
                                    //                       CustomTextNew(
                                    //                         text: '1',
                                    //                       ),
                                    //                       CustomTextNew(
                                    //                         text: 'pt',
                                    //                       ),
                                    //                     ],
                                    //                   ),
                                    //                   CustomTextNew(
                                    //                     text: '2pts',
                                    //                   ),
                                    //                   CustomTextNew(
                                    //                     text: '3pts',
                                    //                   ),
                                    //                   CustomTextNew(
                                    //                     text:
                                    //                         'Automatic red period (safety alert)',
                                    //                   ),
                                    //                 ],
                                    //                 isRadio: true,
                                    //                 isRow: true,
                                    //                 isRound: true,
                                    //               ),
                                    //             ),
                                    //           ],
                                    //         ),
                                    //     ],
                                    //   ),
                                    //   Column(
                                    //     crossAxisAlignment:
                                    //         CrossAxisAlignment.start,
                                    //     children: [
                                    //       CustomTextNew(
                                    //         text: 'New moon',
                                    //         fontSize: 15,
                                    //       ),
                                    //       SizedBox(height: 5),
                                    //       if (selectedMoonIndex == 1)
                                    //         Column(
                                    //           children: [
                                    //             SizedBox(height: 10),
                                    //             Container(
                                    //               height: 1,
                                    //               width:
                                    //                   SizeCons.getWidth(
                                    //                     context,
                                    //                   ) *
                                    //                   0.6,
                                    //               color: Colors.grey[400]!,
                                    //             ),
                                    //             SizedBox(height: 10),
                                    //             SizedBox(
                                    //               width:
                                    //                   SizeCons.getWidth(
                                    //                     context,
                                    //                   ) *
                                    //                   0.65,
                                    //               child: CustomCheckBoxList(
                                    //                 onChanged: (index) {
                                    //                   setState(() {
                                    //                     selectedMoonNewPoints =
                                    //                         index;
                                    //                   });
                                    //                 },
                                    //                 labels: [
                                    //                   Row(
                                    //                     children: [
                                    //                       CustomTextNew(
                                    //                         text: '1',
                                    //                       ),
                                    //                       CustomTextNew(
                                    //                         text: 'pt',
                                    //                       ),
                                    //                     ],
                                    //                   ),
                                    //                   CustomTextNew(
                                    //                     text: '2pts',
                                    //                   ),
                                    //                   CustomTextNew(
                                    //                     text: '3pts',
                                    //                   ),
                                    //                   CustomTextNew(
                                    //                     text:
                                    //                         'Automatic red period (safety alert)',
                                    //                   ),
                                    //                 ],
                                    //                 isRadio: true,
                                    //                 isRow: true,
                                    //                 isRound: true,
                                    //               ),
                                    //             ),
                                    //           ],
                                    //         ),
                                    //     ],
                                    //   ),
                                    //   Column(
                                    //     crossAxisAlignment:
                                    //         CrossAxisAlignment.start,
                                    //     children: [
                                    //       CustomTextNew(
                                    //         text: 'Full moon',
                                    //         fontSize: 15,
                                    //       ),
                                    //       SizedBox(height: 5),
                                    //       if (selectedMoonIndex == 2)
                                    //         Column(
                                    //           children: [
                                    //             SizedBox(height: 10),
                                    //             Container(
                                    //               height: 1,
                                    //               width:
                                    //                   SizeCons.getWidth(
                                    //                     context,
                                    //                   ) *
                                    //                   0.6,
                                    //               color: Colors.grey[400]!,
                                    //             ),
                                    //             SizedBox(height: 10),
                                    //             SizedBox(
                                    //               width:
                                    //                   SizeCons.getWidth(
                                    //                     context,
                                    //                   ) *
                                    //                   0.65,
                                    //               child: CustomCheckBoxList(
                                    //                 onChanged: (index) {
                                    //                   setState(() {
                                    //                     selectedMoonFullPoints =
                                    //                         index;
                                    //                   });
                                    //                 },
                                    //                 labels: [
                                    //                   Row(
                                    //                     children: [
                                    //                       CustomTextNew(
                                    //                         text: '1',
                                    //                       ),
                                    //                       CustomTextNew(
                                    //                         text: 'pt',
                                    //                       ),
                                    //                     ],
                                    //                   ),
                                    //                   CustomTextNew(
                                    //                     text: '2pts',
                                    //                   ),
                                    //                   CustomTextNew(
                                    //                     text: '3pts',
                                    //                   ),
                                    //                   CustomTextNew(
                                    //                     text:
                                    //                         'Automatic red period (safety alert)',
                                    //                   ),
                                    //                 ],
                                    //                 isRadio: true,
                                    //                 isRow: true,
                                    //                 isRound: true,
                                    //               ),
                                    //             ),
                                    //           ],
                                    //         ),
                                    //     ],
                                    //   ),
                                    // ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper functions for unit conversions and dynamic values
  double _getMinWindSpeed(String unit) {
    switch (unit) {
      case 'km/h':
        return 0; // 0 km/h
      case 'mph':
        return 0; // 0 mph
      case 'm/s':
      default:
        return 0; // 0 m/s
    }
  }

  double _getMaxWindSpeed(String unit) {
    switch (unit) {
      case 'km/h':
        return 48; // 120 mph = 192.672 km/h
      case 'mph':
        return 30; // 120 mph
      case 'm/s':
      default:
        return 14; // 120 mph = 53.6448 m/s
    }
  }

  RangeValues _getInitialWindRange(String unit) {
    // If windRange is populated, convert it to the current unit
    if (windRange != null) {
      switch (unit) {
        case 'km/h':
          return RangeValues(windRange!.start * 3.6, windRange!.end * 3.6); // m/s to km/h
        case 'mph':
          return RangeValues(windRange!.start * 2.23694, windRange!.end * 2.23694); // m/s to mph
        case 'm/s':
        default:
          return windRange!; // Already in m/s
      }
    }
    
    // Default values if windRange is not populated
    switch (unit) {
      case 'km/h':
        return RangeValues(
          0,
          36,
        ); // 15 mph = 24.14016 km/h, 75 mph = 120.7008 km/h
      case 'mph':
        return RangeValues(0, 22); // 15 mph to 75 mph
      case 'm/s':
      default:
        return RangeValues(0, 14); // 15 mph = 6.7056 m/s, 75 mph = 33.528 m/s
    }
  }

  RangeValues _convertToMs(RangeValues range, String unit) {
    switch (unit) {
      case 'km/h':
        return RangeValues(range.start / 3.6, range.end / 3.6); // km/h to m/s
      case 'mph':
        return RangeValues(
          range.start * 0.44704,
          range.end * 0.44704,
        ); // mph to m/s
      case 'm/s':
      default:
        return range; // Already in m/s
    }
  }

  List<Widget> _getWindTrendLabels(String unit) {
    switch (unit) {
      case 'km/h':
        return [
          CustomTextNew(text: 'Calm (0-4.824 km/h)', fontSize: 15),
          CustomTextNew(text: 'Light (6.444-16.092 km/h)', fontSize: 15),
          CustomTextNew(text: 'Moderate (17.712-30.564 km/h)', fontSize: 15),
          CustomTextNew(text: 'Strong (>32.184 km/h)', fontSize: 15),
        ];
      case 'mph':
        return [
          CustomTextNew(text: 'Calm (0-3 mph)', fontSize: 15),
          CustomTextNew(text: 'Light (4-10 mph)', fontSize: 15),
          CustomTextNew(text: 'Moderate (11-19 mph)', fontSize: 15),
          CustomTextNew(text: 'Strong (>20 mph)', fontSize: 15),
        ];
      case 'm/s':
      default:
        return [
          CustomTextNew(text: 'Calm (0-1.34 m/s)', fontSize: 15),
          CustomTextNew(text: 'Light (1.79-4.47 m/s)', fontSize: 15),
          CustomTextNew(text: 'Moderate (4.92-8.49 m/s)', fontSize: 15),
          CustomTextNew(text: 'Strong (>8.94 m/s)', fontSize: 15),
        ];
    }
  }

  // Static method to navigate to edit criteria screen
  static Future<void> navigateToEditCriteria({
    required BuildContext context,
    required String token,
    required String criteriaId,
    required Map<String, dynamic> criteriaData,
  }) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateCriteriaScreen(
          token: token,
          criteriaId: criteriaId,
          existingData: criteriaData,
          isEditMode: true,
        ),
      ),
    );
  }
}

class CustomCheckBoxList extends StatefulWidget {
  final List<Widget> labels; // Changed from List<String>
  final bool isRow;
  final bool isRadio;
  final double checkboxSize;
  final double fontSize;
  final bool isRound;
  final Function(int)? onChanged;
  final int initialSelectedIndex;
  final Set<int>? selectedIndexes; // Add this to accept external state

  const CustomCheckBoxList({
    super.key,
    required this.labels,
    this.isRow = false,
    this.isRadio = false,
    this.checkboxSize = 20,
    this.fontSize = 16 ,
    this.isRound = false,
    this.onChanged,
    this.initialSelectedIndex = -1,
    this.selectedIndexes, // Add this parameter
  });

  @override
  State<CustomCheckBoxList> createState() => _CustomCheckBoxListState();
}

class _CustomCheckBoxListState extends State<CustomCheckBoxList> {
  late List<bool> isSelected;

  @override
  void initState() {
    super.initState();
    isSelected = List.generate(widget.labels.length, (_) => false);
    if (widget.initialSelectedIndex >= 0 &&
        widget.initialSelectedIndex < widget.labels.length) {
      isSelected[widget.initialSelectedIndex] = true;
    }
    context.read<PreferencesBloc>().add(LoadPreferences());
  }

  @override
  void didUpdateWidget(CustomCheckBoxList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update internal state when external selectedIndexes changes
    if (widget.selectedIndexes != null) {
      for (int i = 0; i < widget.labels.length; i++) {
        isSelected[i] = widget.selectedIndexes!.contains(i);
      }
    }
  }

  void _onTap(int index) {
    setState(() {
      if (widget.isRadio) {
        for (int i = 0; i < isSelected.length; i++) {
          isSelected[i] = (i == index);
        }
        print('Selected radio index: $index');
      } else {
        isSelected[index] = !isSelected[index];
        print('Toggled checkbox index: $index (value: ${isSelected[index]})');
      }
    });

    if (widget.onChanged != null) {
      widget.onChanged!(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.isRow
        ? Container(
          alignment: Alignment.topLeft,
          child: Wrap(spacing: 10, children: _buildCheckBoxes()),
        )
        // Wrap(
        //   spacing: 12,
        //   // runSpacing: ,
        //   children: _buildCheckBoxes(),
        // )
        // Row(
        //   crossAxisAlignment: CrossAxisAlignment.start,
        //   children: _buildCheckBoxes())
        : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _buildCheckBoxes(),
        );
  }

  List<Widget> _buildCheckBoxes() {
    return List.generate(widget.labels.length, (index) {
      return GestureDetector(
        onTap: () => _onTap(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          margin: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: widget.checkboxSize,
                height: widget.checkboxSize,
                decoration: BoxDecoration(
                  color:
                      isSelected[index]
                          ? (widget.isRound ? Colors.blue : Colors.white)
                          : Colors.transparent,
                  shape: widget.isRound ? BoxShape.circle : BoxShape.rectangle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                alignment: Alignment.center,
                child:
                    isSelected[index]
                        ? Icon(
                          Icons.check,
                          size: widget.checkboxSize / 1.2,
                          color: widget.isRound ? Colors.white : Colors.black,
                        )
                        : null,
              ),
              const SizedBox(width: 12),
              Flexible(
                child: widget.labels[index], // <- now accepts any widget (text or custom)
              ),
            ],
          ),
        ),
      );
    });
  }
}

class TemperatureRangeSlider extends StatefulWidget {
  final double min;
  final double max;
  final String? unit;
  final RangeValues? initialRange;
  final Function(RangeValues)? onChanged;
  final bool? isCelcius;

  const TemperatureRangeSlider({
    Key? key,
    this.min = 0,
    this.max = 120,
    this.unit,
    this.initialRange,
    this.onChanged,
    this.isCelcius,
  }) : super(key: key);

  @override
  _TemperatureRangeSliderState createState() => _TemperatureRangeSliderState();
}

class _TemperatureRangeSliderState extends State<TemperatureRangeSlider> {
  late RangeValues _currentRange;

  @override
  void initState() {
    super.initState();
    if (widget.initialRange != null) {
      // Clamp the initial range values to be within min/max bounds
      final clampedStart = widget.initialRange!.start.clamp(widget.min, widget.max);
      final clampedEnd = widget.initialRange!.end.clamp(widget.min, widget.max);
      _currentRange = RangeValues(clampedStart, clampedEnd);
    } else {
      _currentRange = RangeValues(widget.min, widget.max);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: SizeCons.getWidth(context) * 0.65,
      child: Column(
        children: [
          CustomTextNew(
            text:
                '${_currentRange.start.toInt()}${widget.unit} - ${_currentRange.end.toInt()}${widget.unit}',
            fontSize: 15,
          ),
          const SizedBox(height: 10),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 2,
              rangeTrackShape: const RoundedRectRangeSliderTrackShape(),
              rangeThumbShape: const RoundRangeSliderThumbShape(
                enabledThumbRadius: 8,
              ),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 0),
            ),
            child: RangeSlider(
              values: _currentRange,
              min: widget.min,
              max: widget.max,
              divisions: (widget.max - widget.min).toInt(),
              activeColor: Colors.lightBlue,
              inactiveColor: Colors.white,
              onChanged: (RangeValues values) {
                setState(() => _currentRange = values);
                widget.onChanged?.call(values);
              },
            ),
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${widget.min.toInt()}${widget.unit}',
                style: const TextStyle(color: Colors.white),
              ),
              Text(
                '${widget.max.toInt()}${widget.unit}',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
