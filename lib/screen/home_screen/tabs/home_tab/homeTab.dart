import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:fish_caster/api_services/criteria_services/criteriaServices.dart';
import 'package:fish_caster/api_services/location_service/locationService.dart';
import 'package:fish_caster/api_services/weatherbit_service/weatherBitService.dart';
import 'package:fish_caster/bloc/criteria/criteria_bloc.dart';
import 'package:fish_caster/bloc/criteria/criteria_event.dart';
import 'package:fish_caster/bloc/criteria/criteria_state.dart';
import 'package:fish_caster/bloc/location/location_bloc.dart';
import 'package:fish_caster/bloc/location/location_event.dart';
import 'package:fish_caster/bloc/location/location_state.dart';
import 'package:fish_caster/bloc/token/token_bloc.dart';
import 'package:fish_caster/bloc/token/token_event.dart';
import 'package:fish_caster/bloc/token/token_state.dart';
import 'package:fish_caster/core/screenShotservice.dart';
import 'package:fish_caster/import_file.dart';
import 'package:fish_caster/model/criteria_model/criteriaModel.dart';
import 'package:fish_caster/model/location_model/locationModel.dart';
import 'package:fish_caster/model/weatherbit_model/currentScoreModel.dart';
import 'package:fish_caster/model/weatherbit_model/weatherBitModel.dart';
import 'package:fish_caster/screen/criteria_screen/components/customCompass.dart';
import 'package:fish_caster/screen/criteria_screen/create_criteria_screen.dart';
import 'package:fish_caster/screen/home_screen/criteriaDialogue.dart';
import 'package:fish_caster/screen/home_screen/tabs/home_tab/sub_screen/score_detail_screen.dart';
import 'package:fish_caster/screen/home_screen/tabs/home_tab/sub_screen/location_screen/select_location.dart';
import 'package:fish_caster/screen/home_screen/tabs/setting_tab/sub_screens/notification_screen.dart';
import 'package:fish_caster/screen/home_screen/tabs/setting_tab/sub_screens/profile/profile_setting.dart';
import 'package:fish_caster/widgets/Buttons/custom_button_textfield.dart';
import 'package:fish_caster/widgets/Text/customTextnew.dart';
import 'package:fish_caster/widgets/gifLoader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Hometab extends StatefulWidget {
  final ScreenshotController controller;
  final bool isTakingScreenshot;
  final bool? isLoadAPi;
  Hometab({
    super.key,
    this.isTakingScreenshot = false,
    required this.controller,
    this.isLoadAPi = false,
  });

  @override
  State<Hometab> createState() => _HometabState();
}

class _HometabState extends State<Hometab> with SingleTickerProviderStateMixin {
  final ScreenshotService screenshotService = ScreenshotService();
  bool _isRefreshing = false;
  String token = "";
  int bodyTypeIndex = -1;
  // bool _isRefreshing = false;

  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    final tokenState = context.read<TokenBloc>().state;
    String? tokenVal;

    if (tokenState is TokenLoaded) {
      tokenVal = tokenState.token;
    }
    context.read<LocationBloc>().add(FetchLocationEvent());
    _loadCachedLocation();
    context.read<TokenBloc>().add(GetTokenEvent());
    _rotationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..repeat(); // We'll stop it initially
    if (tokenVal != "") {
      _initializeData();
    }
    _rotationController.stop(); // Start paused
  }

  Future<void> _initializeData() async {
    if (widget.isLoadAPi == true) {
      final result = await CriteriaEvaluationService().evaluateHourlySlots(
        authToken: token,
        locationId: locationId ?? "",
        criteriaId: criteriaId,
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKeyResult, jsonEncode(result.toJson()));
      await prefs.setString(
        _cacheKeyTimestamp,
        DateTime.now().toIso8601String(),
      );

      setState(() {
        _criteriaResultModel = result;
      });

      await _fetchCriteriaScore();
    }
  }

  Future<void> _loadCachedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedLocation = prefs.getString('selected_location');
    if (cachedLocation != null) {
      final loc = Location.fromJson(jsonDecode(cachedLocation));
      locationId = loc.id.toString();
      locationIdText = loc.city ?? 'Select Location';
      context.read<LocationBloc>().add(SelectLocationEvent(loc));
    } else {
      context.read<LocationBloc>().add(FetchLocationEvent());
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> data = [];
  String? locationIdText;
  String criteriaIdText = 'Select Criteria';
  String criteriaId = '';
  String? locationId;

  CriteriaResultModel? _criteriaResultModel;

  String _cacheKeyResult = 'criteria_result_cache';
  String _cacheKeyTimestamp = 'criteria_result_timestamp';
  String _cacheKeyScore = 'criteria_score';
  String _cacheKeyScoreColor = 'criteria_score_color';

  Future<void> _checkAndAutoSelectCriteria() async {
    final state = context.read<CriteriaBloc>().state;

    if (state is! CriteriaSelected || state.criteriaProfile == null) {
      try {
        final service = CriteriaService(
          // tokenBloc: context.read<TokenBloc>(),
          // context: context,
        );
        final profiles = await service.getAllProfiles(
          token,
        ); // use your actual token
        if (profiles.isNotEmpty) {
          final firstProfile = profiles[0];
          context.read<CriteriaBloc>().add(SaveSelectedCriteria(firstProfile));
        }
      } catch (e) {
        debugPrint("Auto-select criteria failed: $e");
      }
    }
  }

  Future<void> loadOrRefreshData() async {
    if (selectedLocation == 'Selected Location') {
      return null;
    }
    setState(() {
      _isRefreshing = true;
    });

    _rotationController.repeat();

    final prefs = await SharedPreferences.getInstance();
    final cachedJson = prefs.getString(_cacheKeyResult);
    final timestampStr = prefs.getString(_cacheKeyTimestamp);

    bool usedCache = false;

    try {
      if (cachedJson != null && timestampStr != null) {
        final cacheTime = DateTime.tryParse(timestampStr);
        final now = DateTime.now();

        if (cacheTime != null && now.difference(cacheTime).inMinutes < 60) {
          final jsonData = jsonDecode(cachedJson);
          _criteriaResultModel = CriteriaResultModel.fromJson(jsonData);

          final cachedScore = prefs.getString(_cacheKeyScore);
          final cachedColorValue = prefs.getString(_cacheKeyScoreColor);

          if (cachedScore != null && cachedColorValue != null) {
            setState(() {
              score = cachedScore;
              scoreColor = Color(int.parse(cachedColorValue));
            });
            usedCache = true;
          }
        }
      }

      if (!usedCache) {
        await Future.delayed(Duration(seconds: 2));

        _fetchCriteriaScore();

        final result = await CriteriaEvaluationService().evaluateHourlySlots(
          authToken: token,
          locationId: locationId ?? "",
          criteriaId: criteriaId,
        );

        await prefs.setString(_cacheKeyResult, jsonEncode(result.toJson()));
        await prefs.setString(
          _cacheKeyTimestamp,
          DateTime.now().toIso8601String(),
        );

        setState(() {
          data.shuffle();
          _criteriaResultModel = result;
        });
      }

      // 👇 Always wait some time for animation, even if cache was used
      await Future.delayed(Duration(seconds: 2));
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      _rotationController.stop();
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  double? lat;
  double? lon;

  String selectedLocation = "Location";

  CriteriaProfile? _selectedCriteria;

  String score = '0';
  Color scoreColor = Color(0xffBA6E12);

  Color _getScoreColor(double score) {
    if (score >= 80) return Color(0xff565F27); // Green
    if (score >= 45) return Color(0xffBA6E12); // Orange
    return Color(0xff87132C); // Red
  }

  bool _isHotLoading = false;

  void _createAndSelectHotFishingCriteria({
    required String name,
    required String description,
    required String species,
    required String presentation,
    required String waterTemp,
    required int bodyTypeIndex,
  }) async {
    try {
      setState(() {
        _isHotLoading = true;
      });

      final service = CriteriaService();
      late String waterBodyType;
      //Inland lake, Inland river, Estuary/Brackish, Saltwater nearshore, Saltwater offshore.
      switch (bodyTypeIndex) {
        case 0:
          waterBodyType = 'inland_lake';
        case 1:
          waterBodyType = 'inland_river';
        case 2:
          waterBodyType = 'estuary/brackish';
        case 3:
          waterBodyType = 'saltwater_nearshore';
        case 4:
          waterBodyType = 'saltwater_offshore';
      }

      final profile = await service.createHotFishingCriteria(
        authToken: token,
        locationId: locationId ?? '',
        name: name,
        description: description,
        species: species,
        presentation: presentation,
        waterTemp: waterTemp,
        context: context,
        waterBodyType: waterBodyType,
      );

      if (profile != null) {
        globalSnack.showSnackBar(
          context,
          'Hot Fishing criteria created successfully!',
        );

        print('Hot Fishing criteria created and score loaded');
      }
    } catch (e) {
      globalSnack.showErrorSnackBar(context, e.toString());
    } finally {
      setState(() {
        _isHotLoading = false;
      });
    }
  }

  void _showHotFishingBottomSheet() {
    final nameController = TextEditingController(
      text: "${DateFormat('M/d/yy HH:mm').format(DateTime.now())} Hot Fishing",
    );
    final descriptionController = TextEditingController();
    final speciesController = TextEditingController();
    final presentationController = TextEditingController();
    final waterTempController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: ClrCons.primaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        bool isName = false;
        bool isDescription = false;
        bool isSpecies = false;
        bool isPresentation = false;
        bool isWaterTemp = false;
        bool isWaterBodyType = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 20),
                    CustomText(
                      text: 'Create Hot Fishing Criteria',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    SizedBox(height: 20),

                    if (isName)
                      Column(
                        children: [
                          CustomText(
                            text:
                                'Please enter a name for the hot fishing criteria',
                            color: Colors.red,
                            fontSize: 16,
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    CustomTextField(
                      controller: nameController,
                      hintText: 'Hot Fishing Name',
                      onChanged: (val) {
                        if (isName && val.trim().isNotEmpty) {
                          setState(() {
                            isName = false;
                          });
                        }
                      },
                    ),

                    SizedBox(height: 20),
                    if (isDescription)
                      Column(
                        children: [
                          CustomText(
                            text: 'Please enter a description',
                            color: Colors.red,
                            fontSize: 16,
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    CustomTextField(
                      controller: descriptionController,
                      hintText: 'Hot Fishing Description',
                      onChanged: (val) {
                        if (isDescription && val.trim().isNotEmpty) {
                          setState(() {
                            isDescription = false;
                          });
                        }
                      },
                    ),
                    SizedBox(height: 20),
                    if (isSpecies)
                      Column(
                        children: [
                          CustomText(
                            text: 'Please enter a species',
                            color: Colors.red,
                            fontSize: 16,
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    CustomTextField(
                      controller: speciesController,
                      hintText: 'Species',
                      onChanged: (val) {
                        if (isSpecies && val.trim().isNotEmpty) {
                          setState(() {
                            isSpecies = false;
                          });
                        }
                      },
                    ),
                    SizedBox(height: 20),
                    if (isPresentation)
                      Column(
                        children: [
                          CustomText(
                            text: 'Please enter a Lures, bait, presentation',
                            color: Colors.red,
                            fontSize: 16,
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    CustomTextField(
                      controller: presentationController,
                      hintText: 'Lures, bait, presentation',
                      onChanged: (val) {
                        if (isPresentation && val.trim().isNotEmpty) {
                          setState(() {
                            isPresentation = false;
                          });
                        }
                      },
                    ),
                    SizedBox(height: 20),
                    if (isWaterTemp)
                      Column(
                        children: [
                          CustomText(
                            text: 'Please enter a Water Temperature',
                            color: Colors.red,
                            fontSize: 16,
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    CustomTextField(
                      controller: waterTempController,
                      hintText: 'Water temperature',
                      onChanged: (val) {
                        if (isWaterTemp && val.trim().isNotEmpty) {
                          setState(() {
                            isWaterTemp = false;
                          });
                        }
                      },
                    ),
                    SizedBox(height: 20),
                    if (isWaterBodyType)
                      Column(
                        children: [
                          CustomText(
                            text: 'Please pick water body type',
                            color: Colors.red,
                            fontSize: 16,
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextNew(
                          text: "Type of Water Body:",
                          fontSize: 18,
                        ),
                        SizedBox(height: 5),
                        CustomCheckBoxList(
                          onChanged: (index) {
                            setState(() {
                              bodyTypeIndex = index;
                            });
                          },
                          labels: [
                            CustomTextNew(text: 'Inland lake'),
                            CustomTextNew(text: 'Inland river'),
                            CustomTextNew(text: 'Estuary/Brackish'),
                            CustomTextNew(text: 'Saltwater nearshore'),
                            CustomTextNew(text: 'Saltwater offshore'),
                          ],
                          isRadio: true,
                          isRow: true,
                          isRound: true,
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    //Inland lake, Inland river, Estuary/Brackish, Saltwater nearshore, Saltwater offshore.
                    CustomButton(
                      text: 'Create Hot Fishing',
                      onPressed: () async {
                        if (nameController.text.trim().isEmpty) {
                          setState(() {
                            isName = true;
                          });
                          return;
                        }
                        if (descriptionController.text.trim().isEmpty) {
                          setState(() {
                            isDescription = true;
                          });
                          return;
                        }
                        if (speciesController.text.trim().isEmpty) {
                          setState(() {
                            isSpecies = true;
                          });
                          return;
                        }
                        if (presentationController.text.trim().isEmpty) {
                          setState(() {
                            isPresentation = true;
                          });
                          return;
                        }
                        if (waterTempController.text.trim().isEmpty) {
                          setState(() {
                            isWaterTemp = true;
                          });
                          return;
                        }
                        if (bodyTypeIndex == -1) {
                          setState(() {
                            isWaterBodyType = true;
                          });
                          return;
                        }

                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString(
                          _cacheKeyHotFishingCreatedAt,
                          DateTime.now()
                              .toIso8601String(), // Save current time here
                        );

                        Navigator.pop(context);

                        _createAndSelectHotFishingCriteria(
                          name: nameController.text.trim(),
                          description: descriptionController.text.trim(),
                          species: speciesController.text.trim(),
                          presentation: presentationController.text.trim(),
                          waterTemp: waterTempController.text.trim(),
                          bodyTypeIndex: bodyTypeIndex,
                        );
                      },
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<Map<String, dynamic>?> _fetchCriteriaScore() async {
    try {
      CriteriaEvaluationService service = CriteriaEvaluationService();
      final CurrentScoreModel data = await service.getCriteriaEvaluation(
        locationId: locationId ?? "",
        criteriaId: criteriaId,
        authToken: token,
      );

      setState(() {
        currentModel = data; // Set currentModel here
        score = data.percentage.toStringAsFixed(0);
        scoreColor = data.scoreColor;
        log(currentModel!.summary.toString());
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKeyScore, score);
      await prefs.setString(_cacheKeyScoreColor, scoreColor.value.toString());

      return {'score': score, 'color': scoreColor};
    } catch (e) {
      print('Error fetching score: $e');
      return null;
    }
  }

  void _selectCriteria() async {
    final selectedProfile = await showModalBottomSheet<CriteriaProfile>(
      context: context,
      isScrollControlled: true,
      backgroundColor: ClrCons.primaryColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => CriteriaBottomSheet(authToken: token),
    );

    if (selectedProfile != null) {
      setState(() {
        _selectedCriteria = selectedProfile;
        criteriaId = selectedProfile.id ?? '';
        criteriaIdText = selectedProfile.name ?? 'Select Criteria';

        _isRefreshing = true;
      });

      final prefs = await SharedPreferences.getInstance();

      // 🔁 Evaluate slots and save result to cache
      final result = await CriteriaEvaluationService().evaluateHourlySlots(
        authToken: token,
        locationId: locationId ?? "",
        criteriaId: criteriaId,
      );

      await prefs.setString(_cacheKeyResult, jsonEncode(result.toJson()));
      await prefs.setString(
        _cacheKeyTimestamp,
        DateTime.now().toIso8601String(),
      );

      setState(() {
        _criteriaResultModel = result;
      });

      // 📊 Get score and save to cache
      final scoreData = await _fetchCriteriaScore(); // already handles cache

      setState(() {
        _isRefreshing = false;
      });
      // 👇 Reload data based on new criteria
      // await loadOrRefreshData();
    }
  }

  String _cacheKeyHotFishingCreatedAt = 'hot_fishing_created_at';

  CurrentScoreModel? currentModel;

  bool isBestFishing = false;
  bool isComfortAndSafety = false;
  @override
  Widget build(BuildContext context) {
    return BlocListener<TokenBloc, TokenState>(
      listener: (context, state) async {
        if (state is TokenLoaded) {
          token = state.token;

          if (criteriaId != 'Select Criteria' &&
              (locationId != 'Select Location' && locationId != null)) {
            _checkAndAutoSelectCriteria();
            _initializeData();
            // _loadCachedData();
            await loadOrRefreshData();
          }
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: AppBar(
            toolbarHeight: 80,
            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: false,
            elevation: 0,
            flexibleSpace: Padding(
              padding: const EdgeInsets.only(top: 0), // for status bar spacing
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ), // Optional inner padding
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(ImgCons.small_logo),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        Container(
                          width: SizeCons.getWidth(context) * 0.6,
                          height: 90,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(ImgCons.name_logo),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        Container(height: 50, width: 50),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 1,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ],
              ),
            ),
          ),
        ),

        body: ThemedBackground(
          child: SafeArea(
            child: RefreshIndicator(
              onRefresh: loadOrRefreshData,
              color: ClrCons.whiteColor, // Customize if needed
              backgroundColor: Colors.transparent,
              child: SingleChildScrollView(
                child: Center(
                  child: Container(
                    width: SizeCons.getWidth(context) * 0.95,
                    child: Column(
                      children: [
                        SizedBox(height: 20),
                        CustomText(text: "Selected Location"),
                        SizedBox(height: 2),

                        BlocBuilder<LocationBloc, LocationState>(
                          builder: (context, state) {
                            if (state is LocationListLoaded) {
                              // Auto-select first location if none is selected
                              if (state.selectedLocation == null &&
                                  state.locations.isNotEmpty) {
                                final firstLocation = state.locations[0];
                                context.read<LocationBloc>().add(
                                  SelectLocationEvent(firstLocation),
                                );

                                SharedPreferences.getInstance().then((prefs) {
                                  prefs.setString(
                                    'selected_location',
                                    jsonEncode(firstLocation.toJson()),
                                  );
                                });

                                locationIdText = firstLocation.city;
                                locationId = firstLocation.id.toString();
                              }

                              if (state.selectedLocation != null) {
                                locationIdText =
                                    state.selectedLocation!.locationName;
                                locationId =
                                    state.selectedLocation!.id.toString();
                              } else {
                                locationIdText = "Selected Location";
                              }
                            }

                            return GestureDetector(
                              onTap: () async {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LocationScreen(),
                                  ),
                                );
                              },
                              child: CustomButtonTextField(
                                width: SizeCons.getWidth(context) * 0.7,
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 5,
                                    ),
                                    child: CustomText(
                                      text: '${locationIdText}',
                                      fontSize: 16,
                                      // maxline: 1,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        SizedBox(height: 20),
                        CustomText(text: "Selected Criteria"),
                        SizedBox(height: 2),
                        BlocBuilder<CriteriaBloc, CriteriaState>(
                          builder: (context, state) {
                            if (state is CriteriaSelected &&
                                state.criteriaProfile != null) {
                              criteriaIdText =
                                  state.criteriaProfile.name.toString();
                              criteriaId = state.criteriaProfile.id.toString();
                              // log("Before Criteria ${isBestFishing}");
                              if (criteriaIdText == 'Best Fishing Conditions') {
                                print('Condition Criteria ${criteriaIdText}');
                                isBestFishing = true;
                              } else if (criteriaIdText ==
                                  'Comfort and safety') {
                                isComfortAndSafety = true;
                              } else {
                                isBestFishing = false;
                                isComfortAndSafety = false;
                              }

                              // log("After Criteria ${isBestFishing}");
                            }

                            return CustomButtonTextField(
                              ontap: _selectCriteria,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomText(
                                      text: criteriaIdText,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    Icon(
                                      Icons.keyboard_arrow_down,
                                      size: 28,
                                      color: ClrCons.whiteColor,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,

                          children: [
                            GestureDetector(
                              // onTap:
                              //     _isHotLoading
                              //         ? () {}
                              //         : _showHotFishingBottomSheet,
                              onTap:
                                  _isHotLoading
                                      ? () {}
                                      : () async {
                                        // final prefs =
                                        //     await SharedPreferences.getInstance();
                                        // final createdAtStr = prefs.getString(
                                        //   _cacheKeyHotFishingCreatedAt,
                                        // );

                                        // if (createdAtStr != null) {
                                        //   final createdAt = DateTime.parse(
                                        //     createdAtStr,
                                        //   );
                                        //   final now = DateTime.now();
                                        //   final diff = now.difference(
                                        //     createdAt,
                                        //   );

                                        //   if (diff.inHours < 3) {
                                        //     final remaining =
                                        //         Duration(hours: 3) - diff;
                                        //     final hours = remaining.inHours;
                                        //     final minutes =
                                        //         remaining.inMinutes % 60;

                                        //     final timeText =
                                        //         hours > 0
                                        //             ? "${hours}h ${minutes}m"
                                        //             : "${minutes}m";

                                        //     globalSnack.showErrorSnackBar(
                                        //       context,
                                        //       "Please wait $timeText to create a new Hot Fishing.",
                                        //     );
                                        //     return; // ⛔ Stop here, don't open dialog
                                        //   }
                                        // }

                                        _showHotFishingBottomSheet(); // ✅ Open only if 4 minutes passed
                                      },

                              child: Row(
                                children: [
                                  _isHotLoading
                                      ? Container(
                                        width: 25,
                                        height: 25,
                                        child: CircularProgressIndicator(
                                          color: ClrCons.whiteColor,
                                          strokeWidth: 1,
                                        ),
                                      )
                                      : Container(
                                        width: 25,
                                        height: 25,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: ClrCons.whiteColor,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(3.0),
                                          child: Image.asset(ImgCons.fireIcon),
                                        ),
                                      ),
                                  SizedBox(width: 5),
                                  CustomText(text: 'Hot Fishing', fontSize: 16),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                        // CustomCompass(),
                                        CreateCriteriaScreen(token: token),
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  CustomText(
                                    text: 'Create Criteria',
                                    fontSize: 16,
                                  ),
                                  SizedBox(width: 5),

                                  Container(
                                    width: 25,
                                    height: 25,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: ClrCons.whiteColor,
                                      ),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Icon(
                                      Icons.add,
                                      color: ClrCons.whiteColor,
                                      size: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 20),

                        Screenshot(
                          controller: widget.controller,
                          child: Container(
                            color:
                                widget.isTakingScreenshot
                                    ? ClrCons.primaryColor
                                    : Colors.transparent,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: widget.isTakingScreenshot ? 10 : 0,
                              ),
                              child: Column(
                                children: [
                                  widget.isTakingScreenshot
                                      ? Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12.0,
                                        ),
                                        child: Column(
                                          children: [
                                            // CustomText(
                                            //   text: 'Performance Summary',
                                            //   fontSize: 22,
                                            //   fontWeight: FontWeight.bold,
                                            //   color: ClrCons.whiteColor,
                                            // ),
                                            Container(
                                              width:
                                                  SizeCons.getWidth(context) *
                                                  0.6,
                                              height: 90,
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                  image: AssetImage(
                                                    ImgCons.name_logo,
                                                  ),
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                            ),
                                            CustomText(
                                              text: DateFormat(
                                                'yyyy-MM-dd – kk:mm',
                                              ).format(DateTime.now()),
                                              fontSize: 14,
                                              color: ClrCons.whiteColor,
                                            ),
                                          ],
                                        ),
                                      )
                                      : SizedBox(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CustomButtonTextField(
                                        width: SizeCons.getWidth(context) * 0.4,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              CustomText(
                                                text: 'Current',
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              scoreWidget(
                                                score:
                                                    currentModel != null
                                                        ? currentModel!
                                                            .percentage
                                                            .toStringAsFixed(0)
                                                        : "0",
                                                color:
                                                    currentModel != null
                                                        ? currentModel!
                                                            .scoreColor
                                                        : scoreColor,
                                                ontap: () {
                                                  if (currentModel != null) {
                                                    // log("currentModel is not null ${currentModel!.toJson()}");
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder:
                                                            (
                                                              context,
                                                            ) => ScoreDetailScreen(
                                                              title:
                                                                  'Current Score',
                                                              score: currentModel!
                                                                  .percentage
                                                                  .toStringAsFixed(
                                                                    0,
                                                                  ),
                                                              color:
                                                                  currentModel!
                                                                      .scoreColor,
                                                              day: 'Current',
                                                              currentScoreModel:
                                                                  currentModel,
                                                              isBestFishing:
                                                                  isBestFishing,
                                                              isComfortAndSafety:
                                                                  isComfortAndSafety,
                                                            ),
                                                      ),
                                                    );
                                                  } else {
                                                    globalSnack.showSnackBar(
                                                      context,
                                                      'No score data available',
                                                    );
                                                  }
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 30),
                                      widget.isTakingScreenshot
                                          ? SizedBox(width: 30, height: 30)
                                          : GestureDetector(
                                            onTap: () {
                                              if (!_isRefreshing) {
                                                loadOrRefreshData();
                                              }
                                            },
                                            child:
                                                _isRefreshing
                                                    ? FastGifWidget(size: 30)
                                                    : AnimatedBuilder(
                                                      animation:
                                                          _rotationController,
                                                      builder: (_, child) {
                                                        return Transform.rotate(
                                                          angle:
                                                              _rotationController
                                                                  .value *
                                                              6.3, // Full rotation
                                                          child: child,
                                                        );
                                                      },
                                                      child: Icon(
                                                        Icons.refresh,
                                                        size: 30,
                                                        color:
                                                            ClrCons.whiteColor,
                                                      ),
                                                    ),
                                          ),
                                    ],
                                  ),
                                  SizedBox(height: 20),
                                  // CustomColorTable(),
                                  if (_criteriaResultModel != null) ...[
                                    CustomColorTable(
                                      model: _criteriaResultModel!,
                                      isBestFishing: isBestFishing,
                                      isComfortAndSafety: isComfortAndSafety,
                                    ),
                                  ] else if (_isRefreshing) ...[
                                    // CircularProgressIndicator(),
                                    Container(
                                      height: 250,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          FastGifWidget(),
                                          SizedBox(height: 10),
                                          CustomText(
                                            text: "Loading...",
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: ClrCons.fontGreyColor,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ] else ...[
                                    selectedLocation == "Location"
                                        ? Container(
                                          height: 250,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder:
                                                          (context) =>
                                                              LocationScreen(),
                                                    ),
                                                  );
                                                },
                                                child: Icon(
                                                  Icons.add_location_outlined,
                                                  size: 50,
                                                  color: ClrCons.fontGreyColor,
                                                ),
                                              ),
                                              SizedBox(height: 10),
                                              CustomText(
                                                text: "Please Select Location",
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: ClrCons.fontGreyColor,
                                              ),
                                            ],
                                          ),
                                        )
                                        : Container(
                                          height: 250,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  if (!_isRefreshing) {
                                                    loadOrRefreshData();
                                                  }
                                                },
                                                child: AnimatedBuilder(
                                                  animation:
                                                      _rotationController,
                                                  builder: (_, child) {
                                                    return Transform.rotate(
                                                      angle:
                                                          _rotationController
                                                              .value *
                                                          6.3, // Full rotation
                                                      child: child,
                                                    );
                                                  },
                                                  child: Icon(
                                                    Icons.refresh,
                                                    size: 50,
                                                    color:
                                                        ClrCons.fontGreyColor,
                                                  ),
                                                ),
                                              ),
                                              CustomText(
                                                text: "No data Please Refresh!",
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: ClrCons.fontGreyColor,
                                              ),
                                            ],
                                          ),
                                        ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class scoreWidget extends StatelessWidget {
  final String score;
  final Color color;
  final Function() ontap;
  const scoreWidget({
    super.key,
    required this.score,
    required this.color,
    required this.ontap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontap,
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: color,
        ),
        child: Center(child: CustomText(text: score, fontSize: 20)),
      ),
    );
  }
}

class CustomColorTable extends StatelessWidget {
  final CriteriaResultModel? model;
  final bool isBestFishing;
  final bool isComfortAndSafety;
  CustomColorTable({
    super.key,
    this.model,
    required this.isBestFishing,
    required this.isComfortAndSafety,
  });

  final List<String> headers = [
    "Early morning",
    "Late morning to \nearly afternoon",
    "Late afternoon to \nevening",
  ];

  Color getColor(value) {
    int val = int.tryParse(value.toString().replaceAll('!', '')) ?? 0;
    if (val >= 80) return Color(0xff565F27);
    if (val >= 45) return Color(0xffBA6E12);
    return Color(0xff87132C);
  }

  dynamic _getSlotValue(
    bool isToday,
    DateTime now,
    List<SlotResult> slots,
    List<Map<String, String>?> slotOptions,
  ) {
    SlotResult? slotResult;

    for (var slotRange in slotOptions) {
      if (slotRange == null) continue;

      final startParts = slotRange['start']!.split(":").map(int.parse).toList();
      final endParts = slotRange['end']!.split(":").map(int.parse).toList();

      final slotStart = DateTime(
        now.year,
        now.month,
        now.day,
        startParts[0],
        startParts[1],
        startParts[2],
      );
      final slotEnd = DateTime(
        now.year,
        now.month,
        now.day,
        endParts[0],
        endParts[1],
        endParts[2],
      );

      if (!isToday || now.isBefore(slotEnd)) {
        final match = slots.firstWhere(
          (slot) => slot.hour == slotRange['start'],
          orElse: () => slotResult!,
        );
        return match.percentage;
      }
    }

    return "-";
  }

  Map<String, Map<String, String>> SLOT_RANGES = {
    'earlyMorning': {'start': '05:00:00', 'end': '08:00:00'},
    'morning': {'start': '08:00:00', 'end': '11:00:00'},
    'lateMorning': {'start': '11:00:00', 'end': '14:00:00'},
    'afternoon': {'start': '14:00:00', 'end': '17:00:00'},
    'lateAfternoon': {'start': '17:00:00', 'end': '20:00:00'},
    'evening': {'start': '20:00:00', 'end': '23:59:59'},
  };

  List<Map<String, dynamic>> get tableDataWithIndex {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return model!.results
        .asMap()
        .entries
        .where((entry) {
          final resultDay = entry.value;
          DateTime date = DateTime.tryParse(resultDay.date) ?? today;
          return date.isAfter(today.subtract(Duration(days: 1))) &&
              date.isBefore(today.add(Duration(days: 7)));
        })
        .map((entry) {
          int originalIndex = entry.key;
          final resultDay = model!.results[originalIndex];
          String label = _formatDateLabel(resultDay.date);
          List<dynamic> row = [label];

          bool isToday = resultDay.date.startsWith(
            DateTime.now().toIso8601String().split("T").first,
          );
          DateTime nowTime = DateTime.now();

          row.add(
            _getSlotValue(isToday, nowTime, resultDay.slots, [
              SLOT_RANGES['earlyMorning'],
              SLOT_RANGES['morning'],
            ]),
          );

          row.add(
            _getSlotValue(isToday, nowTime, resultDay.slots, [
              SLOT_RANGES['lateMorning'],
              SLOT_RANGES['afternoon'],
            ]),
          );

          row.add(
            _getSlotValue(isToday, nowTime, resultDay.slots, [
              SLOT_RANGES['lateAfternoon'],
              SLOT_RANGES['evening'],
            ]),
          );

          return {"row": row, "originalIndex": originalIndex};
        })
        .toList();
  }

  static String _formatDateLabel(String isoDate) {
    DateTime date = DateTime.tryParse(isoDate) ?? DateTime.now();
    DateTime today = DateTime.now();

    if (date.year == today.year &&
        date.month == today.month &&
        date.day == today.day) {
      return "Today";
    }

    String weekday = _weekdayLabel(date.weekday);
    return "$weekday\n${date.month}/${date.day}";
  }

  static String _weekdayLabel(int weekday) {
    const weekdays = ["Mon", "Tues", "Wed", "Thurs", "Fri", "Sat", "Sun"];
    return weekdays[(weekday - 1) % 7];
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> dataWithIndex = tableDataWithIndex;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        children: [
          // Header Row
          Row(
            children: [
              _buildFixedCell(
                width: SizeCons.getWidth(context) * 0.23,
                height: 60,
                bgColor: Colors.transparent,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                ),
                child: const CustomText(
                  text: "Date",
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ClrCons.whiteColor,
                ),
              ),
              ...headers.asMap().entries.map((entry) {
                int i = entry.key;
                return _buildFixedCell(
                  width: SizeCons.getWidth(context) * 0.23,
                  height: 60,
                  bgColor: Colors.transparent,
                  borderRadius:
                      i == headers.length - 1
                          ? const BorderRadius.only(
                            topRight: Radius.circular(12),
                          )
                          : null,
                  child: CustomText(
                    text: entry.value,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: ClrCons.whiteColor,
                    textAlign: TextAlign.center,
                  ),
                );
              }).toList(),
            ],
          ),

          // Data Rows
          ...dataWithIndex.asMap().entries.map((entry) {
            int rowIndex = entry.key;
            List<dynamic> row = entry.value["row"];
            int originalIndex = entry.value["originalIndex"];

            return Row(
              children: [
                _buildFixedCell(
                  width: SizeCons.getWidth(context) * 0.23,
                  height: 60,
                  bgColor: Colors.transparent,
                  borderRadius:
                      rowIndex == dataWithIndex.length - 1
                          ? const BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                          )
                          : null,
                  child: Center(
                    child: CustomText(
                      text: row[0],
                      fontWeight: FontWeight.bold,
                      color: ClrCons.whiteColor,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                ...List.generate(3, (i) {
                  final cellData = row[i + 1].toString();

                  return GestureDetector(
                    onTap: () {
                      if (cellData == "-") {
                        globalSnack.showSnackBar(
                          context,
                          'Slot time has likely passed or data not available',
                        );
                        return;
                      }

                      // SlotResult? slotResult;
                      // if (i < model!.results[originalIndex].slots.length) {
                      //   slotResult = model!.results[originalIndex].slots[i];
                      // }
                      SlotResult? slotResult;

                      if (i < model!.results[originalIndex].slots.length) {
                        if (i == 0) {
                          if (cellData ==
                              model!
                                  .results[originalIndex]
                                  .slots[0]
                                  .percentage) {
                            slotResult = model!.results[originalIndex].slots[0];
                          } else if (cellData ==
                              model!
                                  .results[originalIndex]
                                  .slots[1]
                                  .percentage) {
                            slotResult = model!.results[originalIndex].slots[1];
                          }
                        } else if (i == 1) {
                          if (cellData ==
                              model!
                                  .results[originalIndex]
                                  .slots[2]
                                  .percentage) {
                            slotResult = model!.results[originalIndex].slots[2];
                          } else if (cellData ==
                              model!
                                  .results[originalIndex]
                                  .slots[3]
                                  .percentage) {
                            slotResult = model!.results[originalIndex].slots[3];
                          }
                        } else if (i == 2) {
                          if (cellData ==
                              model!
                                  .results[originalIndex]
                                  .slots[4]
                                  .percentage) {
                            print(
                              model!.results[originalIndex].slots[0].percentage,
                            );
                            slotResult = model!.results[originalIndex].slots[4];
                          } else if (cellData ==
                              model!
                                  .results[originalIndex]
                                  .slots[5]
                                  .percentage) {
                            slotResult = model!.results[originalIndex].slots[5];
                          }
                        }
                      }
                      log("Slot result: ${slotResult?.percentage}");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => ScoreDetailScreen(
                                title: row[0],
                                score: slotResult?.percentage.toString() ?? "-",
                                color: getColor(slotResult?.percentage ?? 0),
                                day: headers[i],
                                slotResult: slotResult,
                                isBestFishing: isBestFishing,
                                isComfortAndSafety: isComfortAndSafety,
                              ),
                        ),
                      );
                    },
                    child: _buildFixedCell(
                      width: SizeCons.getWidth(context) * 0.23,
                      height: 60,
                      bgColor: getColor(cellData),
                      borderRadius:
                          (rowIndex == dataWithIndex.length - 1 && i == 2)
                              ? const BorderRadius.only(
                                bottomRight: Radius.circular(12),
                              )
                              : null,
                      child: Text(
                        cellData,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: ClrCons.whiteColor,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildFixedCell({
    required double width,
    required double height,
    required Widget child,
    required Color bgColor,
    BorderRadius? borderRadius,
  }) {
    return Container(
      width: width,
      constraints: const BoxConstraints(minHeight: 80),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: borderRadius ?? BorderRadius.zero,
        border: Border.all(color: ClrCons.whiteColor, width: 1),
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}
