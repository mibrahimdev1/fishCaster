import 'dart:convert';

import 'package:fish_caster/api_services/location_service/locationService.dart';
import 'package:fish_caster/bloc/location/location_bloc.dart';
import 'package:fish_caster/bloc/location/location_event.dart';
import 'package:fish_caster/bloc/location/location_state.dart';
import 'package:fish_caster/bloc/token/token_bloc.dart';
import 'package:fish_caster/bloc/token/token_event.dart';
import 'package:fish_caster/bloc/token/token_state.dart';
import 'package:fish_caster/import_file.dart';
import 'package:fish_caster/model/location_model/locationModel.dart';
import 'package:fish_caster/screen/home_screen/homeScreen.dart';
import 'package:fish_caster/screen/home_screen/tabs/home_tab/sub_screen/location_screen/pick_location.dart';
import 'package:fish_caster/widgets/Buttons/custom_button_textfield.dart';
import 'package:fish_caster/widgets/gifLoader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geocoding/geocoding.dart' as geocoding;

class LocationScreen extends StatefulWidget {
  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lonController = TextEditingController();

  String token = "";
  Location? selectedLocation;

  @override
  void initState() {
    super.initState();
    context.read<LocationBloc>().add(FetchLocationEvent());
    context.read<TokenBloc>().add(GetTokenEvent());
    _loadCachedLocation();
  }

  // Future<void> _loadCachedLocation() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final data = prefs.getString('selected_location');
  //   if (data != null) {
  //     final json = jsonDecode(data);
  //     final location = Location.fromJson(json);
  //     setState(() {
  //       selectedLocation = location;
  //     });
  //   }
  // }

  Future<void> _loadCachedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('selected_location');
    if (data != null) {
      final json = jsonDecode(data);
      final location = Location.fromJson(json);
      setState(() {
        selectedLocation = location;
      });
    } else {
      // Auto-select first location if none is selected
      context.read<LocationBloc>().add(FetchLocationEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TokenBloc, TokenState>(
      listener: (context, state) {
        if (state is TokenLoaded) {
          token = state.token;
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          centerTitle: true,
          leading: InkWell(
            onTap: () {
              // Navigator.of(context).pop();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeScreen(initialIndex: 0),
                ),
              );
            },
            child: Icon(Icons.arrow_back_ios_new, color: ClrCons.whiteColor),
          ),
          title: CustomText(
            text: 'Select Location',
            fontSize: 20,
            color: ClrCons.whiteColor,
            fontWeight: FontWeight.bold,
          ),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PickLocation(token: token),
                        ),
                      );
                    },
                    child: Container(
                      width: 30,
                      height: 30,
                      child: Icon(
                        Icons.add_location,
                        size: 30,
                        color: ClrCons.whiteColor,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      _showBottomSheet(context);
                    },
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(ImgCons.locationIcon),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: BlocBuilder<LocationBloc, LocationState>(
          builder: (context, state) {
            if (state is LocationLoading) {
              return ThemedBackground(
                child: Center(
                  child: CircularProgressIndicator(color: ClrCons.blueColor),
                ),
              );
            } else if (state is LocationListLoaded) {
              final locations = state.locations;

              // Auto-select first location if none is selected
              if (selectedLocation == null && locations.isNotEmpty) {
                SharedPreferences.getInstance().then((prefs) {
                  final saved = prefs.getString('selected_location');
                  if (saved == null) {
                    final loc = locations[0];
                    setState(() {
                      selectedLocation = loc;
                    });
                    context.read<LocationBloc>().add(SelectLocationEvent(loc));
                    prefs.setString(
                      'selected_location',
                      jsonEncode(loc.toJson()),
                    );
                  }
                });
              }

              if (locations.isEmpty) {
                return ThemedBackground(
                  child: Center(
                    child: Container(
                      height: 250,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => PickLocation(token: token),
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
                    ),
                  ),
                );
              }

              return ThemedBackground(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: ListView.builder(
                    itemCount: locations.length,
                    itemBuilder: (context, index) {
                      // final location = locations[index];
                      final reversedIndex = locations.length - 1 - index;
                      final location = locations[reversedIndex];
                      final isSelected = selectedLocation?.id == location.id;

                      return Dismissible(
                        key: Key(location.id ?? index.toString()),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(right: 20),
                          color: Colors.red,
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (direction) async {
                          return await showDialog(
                            context: context,
                            builder:
                                (ctx) => AlertDialog(
                                  title: Text('Confirm Delete'),
                                  content: Text(
                                    'Are you sure you want to delete ${location.city}?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () => Navigator.of(ctx).pop(false),
                                      child: Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed:
                                          () => Navigator.of(ctx).pop(true),
                                      child: Text('Delete'),
                                    ),
                                  ],
                                ),
                          );
                        },
                        onDismissed: (_) async {
                          try {
                            final service = LocationService(
                              tokenBloc: TokenBloc(),
                              context: context,
                            );
                            await service.deleteLocationById(
                              location.id!,
                            ); // Ensure location.id is non-null

                            globalSnack.showSnackBar(
                              context,
                              'Deleted ${location.city}',
                            );

                            // Optionally refresh list
                            context.read<LocationBloc>().add(
                              FetchLocationEvent(),
                            );
                          } catch (e) {
                            globalSnack.showSnackBar(
                              context,
                              'Failed to delete: $e',
                            );
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: GestureDetector(
                            onTap: () async {
                              // Select the location in the Bloc
                              context.read<LocationBloc>().add(
                                SelectLocationEvent(location),
                              );

                              // Save the selected location to SharedPreferences
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              prefs.setString(
                                'selected_location',
                                jsonEncode(location.toJson()),
                              );

                              // Set the selected location immediately in the UI
                              setState(() {
                                selectedLocation = location;
                              });

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => HomeScreen(
                                        initialIndex: 0,
                                        isLoad: true,
                                      ),
                                ),
                              );

                              globalSnack.showSnackBar(
                                context,
                                'Location Selected ${location.city}',
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color:
                                          isSelected
                                              ? Colors.grey
                                              : ClrCons.primaryColor,
                                      width: 2,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(3.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color:
                                            isSelected
                                                ? Colors.white
                                                : ClrCons.primaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                CustomButtonTextField(
                                  isHeight: true,
                                  width: SizeCons.getWidth(context) * 0.8,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 10,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CustomText(
                                          text:
                                              'Location Name: ${location.locationName ?? "-"}',

                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        SizedBox(height: 5),
                                        CustomText(
                                          text:
                                              'City: ${location.city ?? "N/A"}',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            } else if (state is LocationError) {
              return ThemedBackground(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.grey[600]!,
                            width: 2,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.add_location_outlined,
                            size: 40,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      CustomText(
                        text: 'ADD LOCATION',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600]!,
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return Center(child: Text('Press button to fetch location'));
            }
          },
        ),
      ),
    );
  }

  void _showBottomSheet(BuildContext context) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: CustomText(
            text: 'Location services are disabled.',
            color: ClrCons.whiteColor,
          ),
        ),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Location permission denied')));
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location permissions are permanently denied')),
      );
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    _latController.text = position.latitude.toString();
    _lonController.text = position.longitude.toString();

    // Fetch city name using reverse geocoding
    List<geocoding.Placemark> placemarks = await geocoding
        .GeocodingPlatform
        .instance!
        .placemarkFromCoordinates(position.latitude, position.longitude);

    // Assuming you want to fetch the city name
    if (placemarks.isNotEmpty) {
      geocoding.Placemark placemark = placemarks[0];
      _nameController.text =
          placemark.locality ??
          'Unnamed Location'; // Set city name or default name
    }

    bool isLoading = false;
    bool isName = false;

    showModalBottomSheet(
      backgroundColor: ClrCons.primaryColor,
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                top: 16.0,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () async {
                      Position position = await Geolocator.getCurrentPosition(
                        desiredAccuracy: LocationAccuracy.high,
                      );
                      _latController.text = position.latitude.toString();
                      _lonController.text = position.longitude.toString();

                      // Fetch city name again when tapped
                      List<geocoding.Placemark> placemarks = await geocoding
                          .GeocodingPlatform
                          .instance!
                          .placemarkFromCoordinates(
                            position.latitude,
                            position.longitude,
                          );
                      if (placemarks.isNotEmpty) {
                        geocoding.Placemark placemark = placemarks[0];
                        _nameController.text =
                            placemark.locality ?? 'Unnamed Location';
                      }
                    },
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(ImgCons.locationIcon),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  CustomText(
                    text: 'Get Current Location',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ClrCons.whiteColor,
                  ),
                  SizedBox(height: 30),
                  CustomTextField(
                    controller: _locationController,
                    hintText: 'Location Name',
                    onChanged: (value) {
                      setModalState(() {
                        isName = value.trim().isEmpty;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  CustomTextField(
                    controller: _nameController,
                    hintText: 'City Name',
                    readOnly: true,
                    onChanged: (value) {
                      setModalState(() {
                        isName = value.trim().isEmpty;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  Visibility(
                    visible: false,
                    child: Column(
                      children: [
                        CustomTextField(
                          controller: _latController,
                          hintText: 'Latitude',
                          enabled: false,
                        ),
                        SizedBox(height: 20),
                        CustomTextField(
                          controller: _lonController,
                          hintText: 'Longitude',
                          enabled: false,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),
                  if (isName)
                    Column(
                      children: [
                        CustomText(
                          text: "Please Fill All Fields",
                          color: Colors.redAccent,
                          fontSize: 12,
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  isLoading
                      ? FastGifWidget(size: 30)
                      : _locationController.text.trim().isNotEmpty
                      ? CustomButton(
                        text: 'Save Location',
                        onPressed: () async {
                          setModalState(() {
                            isLoading = true;
                          });

                          try {
                            final locationData = await LocationService(
                              tokenBloc: context.read<TokenBloc>(),
                              context: context,
                            ).saveLocation(
                              locationName: _locationController.text.trim(),
                              city: _nameController.text.trim(),
                              lat: _latController.text.trim(),
                              lon: _lonController.text.trim(),
                            );
                            if (locationData != null) {
                              final location =
                                  locationData;

                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              prefs.setString(
                                'selected_location',
                                jsonEncode(location.toJson()),
                              );

                              context.read<LocationBloc>().add(
                                SelectLocationEvent(location),
                              );
                              _nameController.clear();

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => HomeScreen(
                                        initialIndex: 0,
                                        isLoad: true,
                                      ),
                                ),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Location saved successfully'),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to save location'),
                                ),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: ${e.toString()}')),
                            );
                          } finally {
                            setModalState(() {
                              isLoading = false;
                            });
                          }
                        },
                      )
                      : CustomButton(
                        text: 'Save Location',
                        fillColor: [
                          Color.fromARGB(255, 9, 19, 27),
                          Color.fromARGB(255, 43, 51, 59),
                        ],
                        onPressed: () {
                          setModalState(() {
                            isName = true;
                          });
                        },
                        fontColor: Colors.grey,
                        borderColor: Colors.grey,
                      ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
