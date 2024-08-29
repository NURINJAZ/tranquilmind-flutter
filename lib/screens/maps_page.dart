import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dio/dio.dart'; // Import the dio package
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'package:tranquil_mindv1/providers/dio_provider.dart'; // Import the logger package

class MapsPage extends StatefulWidget {
  const MapsPage({
    Key? key,
    required this.doctor,
  }) : super(key: key);

  final Map<String, dynamic> doctor;
  @override
  _MapsPageState createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  late GoogleMapController googleMapController;
  Position? currentPosition;
  bool showGetDirectionIcon = false;

  static const CameraPosition initialCameraPosition = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14,
  );

  Set<Marker> markers = {};
  Set<Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];

  LatLng? healthcareLocation;

  final Logger logger = Logger();

  dynamic _locations; // Add this line

  @override
  void initState() {
    super.initState();
    _fetchDoctorLocation();
  }

  Future<void> _fetchDoctorLocation() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    if (token == '') {
      throw Exception('Token is empty');
    }
    try {
      final response =
          await DioProvider().getAdminLocation(widget.doctor['doc_id'], token);
      print(
          'Admin location data fetched: $response'); // Print response data for debugging
      setState(() {
        _locations = response;
        print('Coordinate set: $_locations'); // Print rating data in state
      });
      if (response != 'Error') {
        String coordinate = response['coordinate'];
        List<String> coordinates = coordinate.split(',');
        double latitude = double.parse(coordinates[0].trim());
        double longitude = double.parse(coordinates[1].trim());

        healthcareLocation = LatLng(latitude, longitude);

        markers.add(Marker(
          markerId: MarkerId('Doctor Location'),
          position: healthcareLocation!,
          infoWindow: InfoWindow(
            title: 'Healthcare',
            onTap: () {
              setState(() {
                showGetDirectionIcon = true;
              });
              getDirections(
                LatLng(currentPosition!.latitude, currentPosition!.longitude),
                healthcareLocation!,
              );
            },
          ),
        ));
      } else {
        logger.e('Error getting doctor location');
      }
    } catch (error) {
      print('Locations: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Get Direction"),
        centerTitle: true,
      ),
      body: GoogleMap(
        initialCameraPosition: initialCameraPosition,
        markers: markers,
        polylines: polylines,
        zoomControlsEnabled: false,
        mapType: MapType.normal,
        onMapCreated: (GoogleMapController controller) {
          googleMapController = controller;
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 50),
            child: FloatingActionButton.extended(
              onPressed: () async {
                currentPosition = await _determinePosition();

                googleMapController.animateCamera(
                  CameraUpdate.newCameraPosition(CameraPosition(
                    target: LatLng(
                        currentPosition!.latitude, currentPosition!.longitude),
                    zoom: 12,
                  )),
                );

                markers.add(Marker(
                  markerId: const MarkerId('currentLocation'),
                  position: LatLng(
                      currentPosition!.latitude, currentPosition!.longitude),
                  infoWindow: const InfoWindow(title: 'You'),
                ));

                setState(() {});
              },
              label: const Text("Current Location"),
              icon: const Icon(Icons.location_history),
            ),
          ),
          if (showGetDirectionIcon)
            FloatingActionButton(
              onPressed: () {
                getDirections(
                  LatLng(currentPosition!.latitude, currentPosition!.longitude),
                  healthcareLocation!,
                );
              },
              child: const Icon(Icons.directions),
            ),
        ],
      ),
    );
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return Future.error('Location services are disabled');
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return Future.error("Location permission denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied');
    }

    Position position = await Geolocator.getCurrentPosition();

    return position;
  }

  Future<void> getDirections(LatLng start, LatLng destination) async {
    String url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${start.latitude},${start.longitude}&destination=${destination.latitude},${destination.longitude}&key=AIzaSyDvCS1blUCFbc12fk97YBqFQs9V60n4KgY";

    try {
      final response = await Dio().get(url);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == 'OK') {
          polylineCoordinates.clear();
          List steps = data['routes'][0]['legs'][0]['steps'];
          for (var step in steps) {
            polylineCoordinates.add(LatLng(
                step['start_location']['lat'], step['start_location']['lng']));
            polylineCoordinates.add(LatLng(
                step['end_location']['lat'], step['end_location']['lng']));
          }

          setState(() {
            polylines.add(Polyline(
              polylineId: PolylineId('route'),
              points: polylineCoordinates,
              color: Colors.blue,
              width: 6,
            ));
          });

          googleMapController.animateCamera(CameraUpdate.newLatLngBounds(
              LatLngBounds(
                southwest: LatLng(
                    data['routes'][0]['bounds']['southwest']['lat'],
                    data['routes'][0]['bounds']['southwest']['lng']),
                northeast: LatLng(
                    data['routes'][0]['bounds']['northeast']['lat'],
                    data['routes'][0]['bounds']['northeast']['lng']),
              ),
              100));
        } else {
          logger.e('Error fetching directions: ${data['status']}');
        }
      } else {
        logger.e('Error: ${response.statusCode}');
      }
    } catch (e) {
      logger.e('Failed to load directions: $e');
    }
  }
}
