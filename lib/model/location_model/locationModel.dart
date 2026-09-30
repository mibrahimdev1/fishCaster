// class Location {
//   final String id;
//   final String user;
//   final double lat;
//   final double lon;
//   final String locationName;
//   final String city;
//   final DateTime? fetchedAt;

//   Location({
//     required this.id,
//     required this.user,
//     required this.lat,
//     required this.lon,
//     required this.locationName,
//     required this.city,
//     this.fetchedAt,
//   });

//   factory Location.fromJson(Map<String, dynamic> json) {
//     return Location(
//       id: json['id'],
//       user: json['user'],
//       lat: json['lat'],
//       lon: json['lon'],
//       locationName: json['locationName'] ?? "",
//       city: json['city'] ?? "",
//       fetchedAt: json['fetchedAt'] != null ? DateTime.parse(json['fetchedAt']) : null,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'user': user,
//       'lat': lat,
//       'lon': lon,
//       'locationName': locationName,
//       'city': city,
//       'fetchedAt': fetchedAt?.toIso8601String(),
//     };
//   }
// }

class Location {
  final String id;
  final String user;
  final double lat;
  final double lon;
  final String locationName;
  final String city;
  final DateTime? fetchedAt;

  Location({
    required this.id,
    required this.user,
    required this.lat,
    required this.lon,
    required this.locationName,
    required this.city,
    this.fetchedAt,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      user: json['user'],
      lat: json['lat'],
      lon: json['lon'],
      locationName: json['locationName'] ?? '',
      city: json['city'] ?? '',
      fetchedAt:
          json['fetchedAt'] != null ? DateTime.parse(json['fetchedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user,
      'lat': lat,
      'lon': lon,
      'locationName': locationName,
      'city': city,
      'fetchedAt': fetchedAt?.toIso8601String(),
    };
  }
}

class LocationResponse {
  final String message; // This is the message field
  final List<Location> locations;

  LocationResponse({
    required this.message, // This is initialized in the constructor
    required this.locations,
  });

  factory LocationResponse.fromJson(Map<String, dynamic> json) {
    return LocationResponse(
      message: json['message'] ?? '', // Parsing message from JSON
      locations:
          (json['locations'] as List)
              .map((locationJson) => Location.fromJson(locationJson))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message, // Converting message back to JSON
      'locations': locations.map((location) => location.toJson()).toList(),
    };
  }
}
