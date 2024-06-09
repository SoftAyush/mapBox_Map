import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class DashboardWidget extends StatefulWidget {
  const DashboardWidget({super.key});

  @override
  State<DashboardWidget> createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  final LatLng _center = const LatLng(27.670416, 85.323950);
  late String _locationMessage ;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        await Geolocator.requestPermission();
        // Handle denied permission case
        print("Permission denied");
      }
      Position currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
      List<Placemark> placeMarks = await placemarkFromCoordinates(
        currentPosition.latitude,
        currentPosition.longitude,
      );
      Placemark firstPlacemark = placeMarks.first;
      String address =
          '${firstPlacemark.subLocality}, ${firstPlacemark.locality}, ${firstPlacemark.country}';
      setState(() {
        _locationMessage = "Your Current Location is : $address";
      });
    } catch (e) {
      // Handle any errors that occur during the asynchronous operations
      print("Error: $e");
    }
  }

  _showMarkerInfo(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Marker Tapped'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Map'),
      ),
      body: SafeArea(
        child: FlutterMap(
          options: MapOptions(
            initialCenter: _center,
            initialZoom: 15.0,
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://api.mapbox.com/styles/v1/ayush459/clvjhpubp005e01pc9evedjfz/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiYXl1c2g0NTkiLCJhIjoiY2x1djhiM2RqMDBtbDJqcGJmZTNua3R1MyJ9.Izd4vw-r7CQtEA6K-1uyJQ',
              fallbackUrl:
                  'https://api.mapbox.com/styles/v1/ayush459/clvjhpubp005e01pc9evedjfz.html?title=view&access_token=pk.eyJ1IjoiYXl1c2g0NTkiLCJhIjoiY2x1djhiM2RqMDBtbDJqcGJmZTNua3R1MyJ9.Izd4vw-r7CQtEA6K-1uyJQ&zoomwheel=true&fresh=true#11/48.138/11.575', // Placeholder for error
            ),
            MarkerLayer(markers: [
              Marker(
                point: _center,
                child: Builder(
                  builder: (BuildContext context) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _showMarkerInfo(context, _locationMessage);
                        });
                      },
                      child: const Icon(
                        Icons.location_history,
                        size: 40,
                        color: Colors.red,
                      ),
                    );
                  },
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
