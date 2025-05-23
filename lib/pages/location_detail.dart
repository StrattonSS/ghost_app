import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart' show rootBundle;

class LocationDetailPage extends StatefulWidget {
  final String locationId;

  const LocationDetailPage({Key? key, required this.locationId})
      : super(key: key);

  @override
  _LocationDetailPageState createState() => _LocationDetailPageState();
}

class _LocationDetailPageState extends State<LocationDetailPage> {
  DocumentSnapshot? locationData;
  bool isLoading = true;
  late GoogleMapController mapController;
  LatLng? locationCoords;
  String? mapStyle;

  @override
  void initState() {
    super.initState();
    fetchLocationDetails();
    loadMapStyle();
  }

  Future<void> loadMapStyle() async {
    mapStyle = await rootBundle.loadString('assets/map_style_dark.json');
  }

  Future<void> fetchLocationDetails() async {
    final doc = await FirebaseFirestore.instance
        .collection('locations')
        .doc(widget.locationId)
        .get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['coordinates'] != null && data['coordinates'].contains(';')) {
        final parts = data['coordinates'].split(';');
        final lat = double.tryParse(parts[0].trim());
        final lng = double.tryParse(parts[1].trim());
        if (lat != null && lng != null) {
          locationCoords = LatLng(lat, lng);
        }
      }
      setState(() {
        locationData = doc;
        isLoading = false;
      });
    }
  }

  Future<void> _openMap() async {
    if (locationCoords == null) return;
    final lat = locationCoords!.latitude;
    final lng = locationCoords!.longitude;
    final uri = Uri.parse(
        "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Could not open map'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final terminalText = const TextStyle(
      color: Colors.greenAccent,
      fontFamily: 'Courier',
      fontSize: 18,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.greenAccent),
        backgroundColor: Colors.black,
        title: const Text("Location Details",
            style: TextStyle(color: Colors.greenAccent, fontFamily: 'Courier')),
      ),
      body: isLoading
          ? Center(
              child: Text("> Loading details for ${widget.locationId}...",
                  style: terminalText))
          : locationData == null
              ? Center(
                  child: Text("> Location not found.", style: terminalText))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: DefaultTextStyle(
                      style: terminalText,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("> Name: ${locationData!['name'] ?? 'N/A'}"),
                          const SizedBox(height: 10),
                          Text("> State: ${locationData!['state'] ?? 'N/A'}"),
                          const SizedBox(height: 10),
                          Text("> City: ${locationData!['city'] ?? 'N/A'}"),
                          const SizedBox(height: 10),
                          Text("> Type: ${locationData!['type'] ?? 'N/A'}"),
                          const SizedBox(height: 10),
                          Text(
                              "> Activity: ${locationData!['activity'] ?? 'N/A'}"),
                          const SizedBox(height: 10),
                          Text("> Description:"),
                          const SizedBox(height: 6),
                          Text(locationData!['description'] ?? 'N/A'),
                          const SizedBox(height: 20),
                          if (locationCoords != null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("> Location on Map:"),
                                const SizedBox(height: 10),
                                Container(
                                  height: 200,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.greenAccent)),
                                  child: GestureDetector(
                                    onTap: _openMap,
                                    child: AbsorbPointer(
                                      child: GoogleMap(
                                        initialCameraPosition: CameraPosition(
                                          target: locationCoords!,
                                          zoom: 14.0,
                                        ),
                                        markers: {
                                          Marker(
                                            markerId: MarkerId("location"),
                                            position: locationCoords!,
                                            infoWindow: InfoWindow(
                                              title: locationData!['name'],
                                            ),
                                          )
                                        },
                                        onMapCreated: (controller) {
                                          mapController = controller;
                                          if (mapStyle != null) {
                                            mapController.setMapStyle(mapStyle);
                                          }
                                        },
                                        zoomControlsEnabled: false,
                                        myLocationButtonEnabled: false,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text("> Tap map for directions"),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }
}
