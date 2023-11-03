import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geodesy/geodesy.dart';
import 'package:latlong2/latlong.dart';

class ZoomLevel {
  double level;

  ZoomLevel(this.level);
}

class GeoLocation extends StatefulWidget {
  const GeoLocation({super.key});

  @override
  _GeoLocationState createState() => _GeoLocationState();
}

class _GeoLocationState extends State<GeoLocation> {
  bool isExpanded = false;
  MapController mapController = MapController();
  LatLng circledomain = LatLng(14.338108384922228, 121.0604459579977);
  LatLng circledomaintwo = LatLng(14.339345344389676, 121.05441635213224);
  LatLng thirdcircle = LatLng(14.3390743, 121.0610688);

  LatLng currentLocation = LatLng(14.338108384922228, 121.0604459579977);
  LatLng manuallySelectedLocation = LatLng(14.3390743, 121.0610688);

  TextEditingController locationTextController = TextEditingController();
  List<LatLng> savedLocations = [];
  List<LatLng> bookmarkedLocations = [];
  //zoom
  ZoomLevel zoomLevel = ZoomLevel(18.0);
  bool isStatusButtonEnabled = false; // New variable for button status

  @override
  void initState() {
    super.initState();
  }

  void _selectLocation(LatLng location) {
    setState(() {
      manuallySelectedLocation = location;
      _updateLocationText(location);
    });
  }

  void _centerMapToDefaultLocation() {
    LatLng targetLocation = LatLng(14.3390743, 121.0610688);
    mapController.move(targetLocation, zoomLevel.level);
    setState(() {
      manuallySelectedLocation = targetLocation;
    });
  }

  void _updateLocationText(LatLng location) {
    locationTextController.text =
        'Latitude: ${location.latitude}, Longitude: ${location.longitude}';
  }

  void _centerMapToSelectedLocation(LatLng location) {
    if (location != currentLocation) {
      mapController.move(location, zoomLevel.level);
      setState(() {
        currentLocation = location;
      });
    }
  }

  void _bookmarkLocation() {
    setState(() {
      savedLocations.add(manuallySelectedLocation);
    });

    _showBookmarkedLocations();

    // Create a dialog to display the coordinates
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Location Coordinates"),
          content: Text(
            'Latitude: ${manuallySelectedLocation.latitude}, Longitude: ${manuallySelectedLocation.longitude}',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Close"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  void _showBookmarkedLocations() {
    setState(() {
      bookmarkedLocations = savedLocations;
    });
  }

  void _changeZoomLevel(double newZoom) {
    setState(() {
      zoomLevel.level = newZoom;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Map Example'),
        actions: [
          IconButton(
            icon: const Icon(Icons.location_searching),
            tooltip: 'Center map',
            onPressed: _centerMapToDefaultLocation,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ExpansionTile(
              initiallyExpanded: isExpanded,
              onExpansionChanged: (expanded) {
                setState(() {
                  isExpanded = expanded;
                });
              },
              title: const Text('View Bookmarked Locations'),
              children: <Widget>[
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: bookmarkedLocations.length,
                  itemBuilder: (context, index) {
                    final location = bookmarkedLocations[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          title: Text(
                            'Latitude: ${location.latitude}, Longitude: ${location.longitude}',
                          ),
                          onTap: () {
                            _centerMapToSelectedLocation(location);
                            setState(() {
                              manuallySelectedLocation = location;
                              _changeZoomLevel(zoomLevel
                                  .level); // Optional: Update zoom when selecting bookmark
                            });
                          },
                        ),
                        const Divider(),
                      ],
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: isStatusButtonEnabled
                ? () {
                    // Show a dialog with the coordinates
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Location Coordinates"),
                          content: Text(
                            'Latitude: ${currentLocation.latitude}, Longitude: ${currentLocation.longitude}',
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: const Text("Close"),
                              onPressed: () {
                                Navigator.of(context).pop(); // Close the dialog
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }
                : null, // Enable/disable the button
            child: const Text('Status'),
          ),
          const Center(child: Text('data')),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: locationTextController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Selected Location',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: FlutterMap(
              mapController: mapController,
              options: MapOptions(
                center: currentLocation,
                zoom: zoomLevel.level,
                onTap: (point, latLng) {
                  _selectLocation(latLng);

                  // Check if the selected location is inside circledomain, circledomaintwo, or thirdcircle
                  final distanceToDomain = const Distance()
                      .as(LengthUnit.Meter, circledomain, latLng);
                  final distanceToDomainTwo = const Distance()
                      .as(LengthUnit.Meter, circledomaintwo, latLng);
                  final distanceToThirdCircle = const Distance()
                      .as(LengthUnit.Meter, thirdcircle, latLng);

                  if (distanceToDomain <= 100.0 ||
                      distanceToDomainTwo <= 100.0 ||
                      distanceToThirdCircle <= 100.0) {
                    // Enable the "Status" button
                    setState(() {
                      isStatusButtonEnabled = true;
                    });
                  } else {
                    // Disable the "Status" button
                    setState(() {
                      isStatusButtonEnabled = false;
                    });
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _bookmarkLocation,
        child: const Text('Bookmark'),
      ),
    );
  }
}
