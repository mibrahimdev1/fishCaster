import 'dart:convert';
import 'package:fish_caster/api_services/location_service/locationService.dart';
import 'package:fish_caster/bloc/location/location_bloc.dart';
import 'package:fish_caster/bloc/location/location_event.dart'
    show FetchLocationEvent, SelectLocationEvent;
import 'package:fish_caster/bloc/token/token_bloc.dart';
import 'package:fish_caster/import_file.dart';
import 'package:fish_caster/screen/home_screen/homeScreen.dart';
import 'package:fish_caster/widgets/gifLoader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PickLocation extends StatefulWidget {
  final String token;
  const PickLocation({Key? key, required this.token}) : super(key: key);

  @override
  State<PickLocation> createState() => _PickLocationState();
}

class _PickLocationState extends State<PickLocation> {
  late GoogleMapController _mapController;
  LatLng _selectedLocation = LatLng(40.7128, -74.0060); // Default: New York
  TextEditingController searchController = TextEditingController();
  // List<String> _suggestions = []; // Holds the search
  List<Map<String, String>> _suggestions = [];

  String selectedLocation = '';
  bool _isLoadingLocation = false;

  final String apiKey =
      "AIzaSyA-1lugwohhbHfOxBqW4efmRKpd8j7Jnyo"; // Your actual API key

  @override
  void initState() {
    super.initState();
    // Fetch city name for the initial location
    _getAreaName(_selectedLocation);
  }

  Future<List<Map<String, String>>> getPlaceSuggestions(String input) async {
    final String baseUrl =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    final String request = '$baseUrl?input=$input&key=$apiKey';

    final response = await http.get(Uri.parse(request));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List predictions = data['predictions'];

      return predictions
          .map<Map<String, String>>(
            (p) => {'description': p['description'], 'place_id': p['place_id']},
          )
          .toList();
    } else {
      throw Exception('Failed to fetch suggestions');
    }
  }

  void _selectPrediction(String placeId, String description) async {
    final String baseUrl =
        'https://maps.googleapis.com/maps/api/place/details/json';
    final String request = '$baseUrl?place_id=$placeId&key=$apiKey';

    final response = await http.get(Uri.parse(request));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final location = data['result']['geometry']['location'];
      final LatLng newLatLng = LatLng(location['lat'], location['lng']);

      setState(() {
        _selectedLocation = newLatLng;
        searchController.text = description;
        selectedLocation = description;
        _suggestions = [];
      });

      await _getAreaName(newLatLng);

      _mapController.animateCamera(CameraUpdate.newLatLng(newLatLng));
    } else {
      throw Exception('Failed to fetch place details');
    }
  }

  void _onMapTap(LatLng position) async {
    setState(() {
      _selectedLocation = position;
    });
    await _getAreaName(position);
  }

  String _areaName = '';

  Future<void> _getAreaName(LatLng position) async {
    final String url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['results'] != null && data['results'].isNotEmpty) {
          final result = data['results'][0];
          final types = result['types'] as List<dynamic>;
          final name = result['formatted_address'];

          setState(() {
            // If it's a natural feature (like a river), just show the full address
            _areaName = name;
          });
        } else {
          setState(() {
            _areaName = 'Unknown Location';
          });
        }
      } else {
        throw Exception('Failed to get location from Google');
      }
    } catch (e) {
      print('Reverse geocoding error: $e');
      setState(() {
        _areaName = 'Unknown Location';
      });
    }
  }

  // Get current GPS location
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location services are disabled.')),
        );
        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Location permissions are denied.')),
          );
          setState(() {
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location permissions are permanently denied.')),
        );
        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      LatLng currentLocation = LatLng(position.latitude, position.longitude);
      
      setState(() {
        _selectedLocation = currentLocation;
        _isLoadingLocation = false;
      });

      // Animate camera to current location
      _mapController.animateCamera(
        CameraUpdate.newLatLngZoom(currentLocation, 15.0),
      );

      // Get area name for the current location
      await _getAreaName(currentLocation);

    } catch (e) {
      print('Error getting current location: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting current location: ${e.toString()}')),
      );
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  // Confirm the selected location
  void _confirmLocation() {
    Navigator.pop(context, _selectedLocation);
  }

  Set<Marker> _createMarker() {
    print(
      'Marker location: ${_selectedLocation.latitude}, ${_selectedLocation.longitude}',
    );

    return {
      Marker(
        markerId: MarkerId('selected-location'),
        position: _selectedLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back_ios, color: ClrCons.primaryColor),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _selectedLocation,
              zoom: 14.0,
            ),
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
            onTap: _onMapTap,
            markers: _createMarker(), // << must be a method
            myLocationEnabled: true,
            myLocationButtonEnabled: false, // We'll create our own custom button
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),

          // Search Bar
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: 120),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                child: Row(
                  children: [
                    Container(
                      width:
                          searchController.text.isEmpty
                              ? MediaQuery.of(context).size.width * 0.8
                              : MediaQuery.of(context).size.width * 0.7,

                      child: CustomTextField(
                        controller: searchController,
                        hintText: 'Search for a location',
                        onChanged: (value) async {
                          if (value.length > 2) {
                            List<Map<String, String>> suggestions =
                                await getPlaceSuggestions(value);
                            setState(() {
                              _suggestions = suggestions;
                            });
                          }
                        },
                        suffixIcon:
                            searchController.text.isEmpty
                                ? ImgCons.searchIcon
                                : null,
                      ),
                    ),
                    if (searchController.text.isNotEmpty) SizedBox(width: 10),
                    if (searchController.text.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            searchController.clear();
                            _suggestions = [];
                          });
                        },
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: ClrCons.primaryColor,
                          ),
                          child: Icon(
                            Icons.close,
                            size: 15,
                            color: ClrCons.whiteColor,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Suggestions Dropdown
          if (_suggestions.isNotEmpty)
            Positioned(
              top: 180,
              left: 15,
              right: 15,
              child: Material(
                elevation: 4.0,
                color: ClrCons.primaryColor,
                child: Container(
                  height: 200,
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: _suggestions.length,
                    itemBuilder: (context, index) {
                      final suggestion = _suggestions[index];
                      return ListTile(
                        title: CustomText(
                          text: suggestion['description'] ?? '',
                          color: ClrCons.whiteColor,
                        ),
                        onTap:
                            () => _selectPrediction(
                              suggestion['place_id']!,
                              suggestion['description']!,
                            ),
                      );
                    },
                  ),
                ),
              ),
            ),

          // GPS Location Button
          Positioned(
            bottom: 120,
            right: 20,
            child: FloatingActionButton(
              heroTag: "gps_location",
              onPressed: _isLoadingLocation ? null : _getCurrentLocation,
              backgroundColor: ClrCons.primaryColor,
              child: _isLoadingLocation
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(ClrCons.whiteColor),
                      ),
                    )
                  : Icon(
                      Icons.my_location,
                      color: ClrCons.whiteColor,
                    ),
            ),
          ),
          // if (selectedLocation.isNotEmpty)
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: CustomButton(
                width: SizeCons.getWidth(context) * 0.5,
                text: 'Confirm Location',
                onPressed: () {
                  _showLocationDialog();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLocationDialog() {
    TextEditingController _nameController = TextEditingController();
    TextEditingController _cityController = TextEditingController(
      text: _areaName,
    );
    TextEditingController _latController = TextEditingController(
      text: _selectedLocation.latitude.toStringAsFixed(6),
    );
    TextEditingController _lonController = TextEditingController(
      text: _selectedLocation.longitude.toStringAsFixed(6),
    );

    bool isLoading = false;
    bool isName = false;

    showModalBottomSheet(
      backgroundColor: ClrCons.primaryColor,
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomText(
                    text: 'Selected Location',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: ClrCons.whiteColor,
                  ),
                  SizedBox(height: 20),

                  // Editable Location Name
                  CustomTextField(
                    controller: _nameController,
                    hintText: 'Location Name',
                    onChanged: (value) {
                      setModalState(() {
                        isName = value.trim().isEmpty;
                      });
                    },
                  ),
                  SizedBox(height: 15),

                  // Read-only City
                  CustomTextField(
                    controller: _cityController,
                    hintText: 'City',
                    readOnly: true,
                  ),
                  Visibility(
                    visible: false,
                    child: Column(
                      children: [
                        SizedBox(height: 15),

                        // Read-only Latitude
                        CustomTextField(
                          controller: _latController,
                          hintText: 'Latitude',
                          readOnly: true,
                        ),
                        SizedBox(height: 15),

                        // Read-only Longitude
                        CustomTextField(
                          controller: _lonController,
                          hintText: 'Longitude',
                          readOnly: true,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 25),
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
                      : _nameController.text.trim().isNotEmpty
                      ? CustomButton(
                        text: 'Save Location',
                        onPressed: () async {
                          setModalState(() {
                            isLoading = true;
                          });

                          try {
                            final success = await LocationService(
                              tokenBloc: context.read<TokenBloc>(),
                              context: context,
                            ).saveLocation(
                              locationName: _nameController.text.trim(),
                              lat: _latController.text.trim(),
                              lon: _lonController.text.trim(),
                              city: _cityController.text.trim(),
                            );

                            if (success != null) {
                              final location =
                                  success;

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


                            //  context.read<LocationBloc>().add(FetchLocationEvent());
                            //   SharedPreferences prefs =
                            //       await SharedPreferences.getInstance();
                            //   prefs.setString(
                            //     'selected_location',
                            //     jsonEncode(location.toJson()),
                            //   );

                            //   context.read<LocationBloc>().add(
                            //     SelectLocationEvent(location),
                            //   );

                            // Navigator.of(context).pop(); 
                            // Navigator.of(context).pop(); 

                            setModalState(() {
                              isLoading = false;
                            });
                          } catch (e) {
                            Navigator.of(context).pop(); 
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: ${e.toString()}')),
                            );
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
