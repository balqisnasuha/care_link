import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyPage extends StatefulWidget {
  const EmergencyPage({super.key});

  @override
  _EmergencyPageState createState() => _EmergencyPageState();
}

class _EmergencyPageState extends State<EmergencyPage> {
  late GoogleMapController _mapController;
  LocationData? _currentLocation;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    var location = Location();
    try {
      var currentLocation = await location.getLocation();
      setState(() {
        _currentLocation = currentLocation;
      });
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  void _openWhatsApp() async {
    if (_currentLocation != null) {
      String message =
          "Emergency! My current location is: https://maps.google.com/?q=${_currentLocation!.latitude},${_currentLocation!.longitude}";
      String phoneNumber =
          "+60149701560"; // Replace with the correct phone number
      String url = "https://wa.me/$phoneNumber?text=${Uri.encodeFull(message)}";
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        print('Could not launch $url');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Emergency Page'),
      ),
      body: _currentLocation == null
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: GoogleMap(
                    onMapCreated: (controller) {
                      setState(() {
                        _mapController = controller;
                      });
                    },
                    initialCameraPosition: CameraPosition(
                      target: LatLng(_currentLocation!.latitude!,
                          _currentLocation!.longitude!),
                      zoom: 14.0,
                    ),
                    markers: {
                      Marker(
                        markerId: MarkerId("currentLocation"),
                        position: LatLng(_currentLocation!.latitude!,
                            _currentLocation!.longitude!),
                        infoWindow: InfoWindow(title: "Your Location"),
                      ),
                    },
                  ),
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    _openWhatsApp();
                  },
                  child: Text('Send Location via WhatsApp'),
                ),
              ],
            ),
    );
  }
}
