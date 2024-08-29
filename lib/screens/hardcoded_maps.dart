import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapsPage extends StatefulWidget {
  const MapsPage({Key? key}) : super(key: key);

  @override
  _MapsPageState createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  late GoogleMapController googleMapController;
  Position? currentPosition;
  bool showGetDirectionIcon = false;

  static const CameraPosition initialCameraPosition = CameraPosition(
      target: LatLng(37.42796133580664, -122.085749655962), zoom: 14);

  Set<Marker> markers = {};
  Set<Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];

  final LatLng healthcareLocation =
      LatLng(2.3049829727398152, 102.42854912806172);

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
                        target: LatLng(currentPosition!.latitude,
                            currentPosition!.longitude),
                        zoom: 14)));

                markers.clear();
                markers.add(Marker(
                  markerId: const MarkerId('currentLocation'),
                  position: LatLng(
                      currentPosition!.latitude, currentPosition!.longitude),
                  infoWindow: const InfoWindow(title: 'You'),
                ));
                markers.add(Marker(
                  markerId: const MarkerId('hospital'),
                  position: healthcareLocation,
                  infoWindow: InfoWindow(
                    title: 'Hospital Jasin',
                    onTap: () {
                      setState(() {
                        showGetDirectionIcon = true;
                      });
                      getDirections(
                        LatLng(currentPosition!.latitude,
                            currentPosition!.longitude),
                        healthcareLocation,
                      );
                    },
                  ),
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
                  healthcareLocation,
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
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
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
          print('Error fetching directions: ${data['status']}');
        }
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to load directions: $e');
    }
  }
}
