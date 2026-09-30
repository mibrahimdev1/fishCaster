import 'package:fish_caster/bloc/prefrences/prefrences_bloc.dart';
import 'package:fish_caster/bloc/prefrences/prefrences_event.dart';
import 'package:fish_caster/bloc/prefrences/prefrences_state.dart';
import 'package:flutter/material.dart';
import 'package:fish_caster/import_file.dart';
import 'package:fish_caster/widgets/Buttons/custom_button_textfield.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PreferencesScreen extends StatefulWidget {
  @override
  _PreferencesScreenState createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  String _temperatureUnit = "Fahrenheit"; // Default Temperature Unit
  String _weightUnit = "Kilograms"; // Default Weight Unit
  String _distanceUnit = "Meters"; // Default Distance Unit
  String _depthUnit = "Meters"; // Default Depth Unit
  String _cloudCondition = "Clear"; // Default Cloud Condition
  String _windSpeedUnit = "km/h"; // Default Wind Speed Unit
  String _pressureUnit = "mbar"; // Default Pressure Unit
  String _humidityUnit = "Percentage"; // Default Humidity Unit

  @override
  void initState() {
    super.initState();
    context.read<PreferencesBloc>().add(LoadPreferences());
  }

  // Function to show a bottom sheet dialog for selecting units
  void showBottomUnitSelectionDialog(
    BuildContext context,
    String settingType,
  ) async {
    showModalBottomSheet(
      backgroundColor: ClrCons.surfaceClr,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 10),
              settingType == 'Temperature'
                  ? Column(
                    children: [
                      ListTile(
                        title: CustomText(
                          text: 'Celsius',
                          color: ClrCons.whiteColor,
                        ),
                        onTap: () {
                          setState(() {
                            _temperatureUnit = 'Celsius';
                          });
                          context.read<PreferencesBloc>().add(
                            UpdatePreference('temperatureUnit', 'Celsius'),
                          );

                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        title: CustomText(
                          text: 'Fahrenheit',
                          color: ClrCons.whiteColor,
                        ),
                        onTap: () {
                          setState(() {
                            _temperatureUnit = 'Fahrenheit';
                          });
                          context.read<PreferencesBloc>().add(
                            UpdatePreference('temperatureUnit', 'Fahrenheit'),
                          );

                          Navigator.pop(context);
                        },
                      ),
                    ],
                  )
                  : settingType == 'Weight'
                  ? Column(
                    children: [
                      ListTile(
                        title: CustomText(
                          text: 'Kilograms',
                          color: ClrCons.whiteColor,
                        ),
                        onTap: () {
                          setState(() {
                            _weightUnit = 'Kilograms';
                          });

                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        title: CustomText(
                          text: 'Pounds',
                          color: ClrCons.whiteColor,
                        ),
                        onTap: () {
                          setState(() {
                            _weightUnit = 'Pounds';
                          });
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  )
                  : settingType == 'Distance'
                  ? Column(
                    children: [
                      ListTile(
                        title: CustomText(
                          text: 'Meters',
                          color: ClrCons.whiteColor,
                        ),
                        onTap: () {
                          setState(() {
                            _distanceUnit = 'Meters';
                          });
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        title: CustomText(
                          text: 'Kilometers',
                          color: ClrCons.whiteColor,
                        ),
                        onTap: () {
                          setState(() {
                            _distanceUnit = 'Kilometers';
                          });
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        title: CustomText(
                          text: 'Miles',
                          color: ClrCons.whiteColor,
                        ),
                        onTap: () {
                          setState(() {
                            _distanceUnit = 'Miles';
                          });
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  )
                  : settingType == 'Depth'
                  ? Column(
                    children: [
                      ListTile(
                        title: CustomText(
                          text: 'Meters',
                          color: ClrCons.whiteColor,
                        ),
                        onTap: () {
                          setState(() {
                            _depthUnit = 'Meters';
                          });
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        title: CustomText(
                          text: 'Feet',
                          color: ClrCons.whiteColor,
                        ),
                        onTap: () {
                          setState(() {
                            _depthUnit = 'Feet';
                          });
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  )
                  : settingType == 'Cloud'
                  ? Column(
                    children: [
                      ListTile(
                        title: CustomText(
                          text: 'Clear',
                          color: ClrCons.whiteColor,
                        ),
                        onTap: () {
                          setState(() {
                            _cloudCondition = 'Clear';
                          });
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        title: CustomText(
                          text: 'Cloudy',
                          color: ClrCons.whiteColor,
                        ),
                        onTap: () {
                          setState(() {
                            _cloudCondition = 'Cloudy';
                          });
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        title: CustomText(
                          text: 'Partly Cloudy',
                          color: ClrCons.whiteColor,
                        ),
                        onTap: () {
                          setState(() {
                            _cloudCondition = 'Partly Cloudy';
                          });
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  )
                  : settingType == 'Wind'
                  ? Column(
                    children: [
                      ListTile(
                        title: CustomText(
                          text: 'km/h',
                          color: ClrCons.whiteColor,
                        ),
                        onTap: () {
                          setState(() {
                            _windSpeedUnit = 'km/h';
                          });
                          context.read<PreferencesBloc>().add(
                            UpdatePreference('windSpeedUnit', 'km/h'),
                          );
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        title: CustomText(
                          text: 'm/s',
                          color: ClrCons.whiteColor,
                        ),
                        onTap: () {
                          setState(() {
                            _windSpeedUnit = 'm/s';
                          });
                          context.read<PreferencesBloc>().add(
                            UpdatePreference('windSpeedUnit', 'm/s'),
                          );
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        title: CustomText(
                          text: 'mph',
                          color: ClrCons.whiteColor,
                        ),
                        onTap: () {
                          setState(() {
                            _windSpeedUnit = 'mph';
                          });
                          context.read<PreferencesBloc>().add(
                            UpdatePreference('windSpeedUnit', 'mph'),
                          );
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  )
                  : settingType == 'Pressure'
                  ? Column(
                    children: [
                      ListTile(
                        title: CustomText(
                          text: 'inHg',
                          color: ClrCons.whiteColor,
                        ),
                        onTap: () {
                          setState(() {
                            _pressureUnit = 'inHg';
                          });
                          context.read<PreferencesBloc>().add(
                            UpdatePreference('pressureUnit', 'inHg'),
                          );
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        title: CustomText(
                          text: 'mb',
                          color: ClrCons.whiteColor,
                        ),
                        onTap: () {
                          setState(() {
                            _pressureUnit = 'mb';
                          });
                          context.read<PreferencesBloc>().add(
                            UpdatePreference('pressureUnit', 'mb'),
                          );
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  )
                  : settingType == 'Humidity'
                  ? Column(
                    children: [
                      ListTile(
                        title: CustomText(
                          text: 'Percentage',
                          color: ClrCons.whiteColor,
                        ),
                        onTap: () {
                          setState(() {
                            _humidityUnit = 'Percentage';
                          });
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        title: CustomText(
                          text: 'Grams per Cubic Meter',
                          color: ClrCons.whiteColor,
                        ),
                        onTap: () {
                          setState(() {
                            _humidityUnit = 'Grams per Cubic Meter';
                          });
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  )
                  : Container(),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
        title: CustomText(
          text: "Prefrences Settings",
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: BlocBuilder<PreferencesBloc, PreferencesState>(
        builder: (context, state) {
          final preferences = state.preferences;
          return ThemedBackground(
            child: SafeArea(
              child: Center(
                child: Container(
                  width: SizeCons.getWidth(context) * 0.85,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),
                      // Temperature Unit Selection
                      CustomButtonTextField(
                        isHeight: true,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              SizedBox(
                                width: SizeCons.getWidth(context) * 0.5,
                                child: CustomText(
                                  text: "Select Temperature Unit",
                                  color: Colors.white,
                                  fontSize: SizeCons.getWidth(context) * 0.035,
                                ),
                              ),
                              Spacer(),
                              GestureDetector(
                                onTap: () {
                                  showBottomUnitSelectionDialog(
                                    context,
                                    'Temperature',
                                  );
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      width: 1,
                                      color: Colors.white,
                                    ),
                                  ),
                                  child: Text(
                                    preferences.temperatureUnit,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      // Wind Speed Unit Selection
                      CustomButtonTextField(
                        isHeight: true,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              SizedBox(
                                width: SizeCons.getWidth(context) * 0.6,
                                child: CustomText(
                                  text: "Select Wind Speed Unit",
                                  color: Colors.white,
                                  fontSize: SizeCons.getWidth(context) * 0.035,
                                ),
                              ),
                              Spacer(),
                              GestureDetector(
                                onTap: () {
                                  showBottomUnitSelectionDialog(
                                    context,
                                    'Wind',
                                  );
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      width: 1,
                                      color: Colors.white,
                                    ),
                                  ),
                                  child: Text(
                                    preferences.windSpeedUnit,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      // Pressure Unit Selection
                      CustomButtonTextField(
                        isHeight: true,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              SizedBox(
                                width: SizeCons.getWidth(context) * 0.6,
                                child: CustomText(
                                  text: "Select Barometric Pressure Unit",
                                  color: Colors.white,
                                  fontSize: SizeCons.getWidth(context) * 0.035,
                                ),
                              ),
                              Spacer(),
                              GestureDetector(
                                onTap: () {
                                  showBottomUnitSelectionDialog(
                                    context,
                                    'Pressure',
                                  );
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      width: 1,
                                      color: Colors.white,
                                    ),
                                  ),
                                  child: Text(
                                    preferences.pressureUnit,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),

                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
