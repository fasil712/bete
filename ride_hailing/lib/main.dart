import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MapApp());
}

class MapApp extends StatelessWidget {
  const MapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Map Interface',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  bool _isLoading = true;
  bool _hasInternet = true;
  String? _errorMessage;
  Position? _currentPosition; // Store current location

  // Initial position set to Addis Ababa, Ethiopia
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(9.0333, 38.7000), // Coordinates for Addis Ababa
    zoom: 14,
  );

  // Markers for the location
  final Set<Marker> _markers = {};
  BitmapDescriptor? _currentLocationIcon;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _setCustomMarker();
    _getCurrentLocation(); // Fetch current location
  }

  // Get current device location
  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _errorMessage = 'Location permissions are denied';
          });
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage =
              'Location permissions are permanently denied, we cannot request permissions.';
        });
        return;
      }
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
      });
      _moveCameraToCurrentLocation();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to get location: $e';
      });
      developer.log('Location Error: $e');
    }
  }

  // Move camera to current location smoothly
  Future<void> _moveCameraToCurrentLocation() async {
    if (_currentPosition != null && _controller.isCompleted) {
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          15,
        ),
      );
    }
  }

  Future<void> _setCustomMarker() async {
    _currentLocationIcon = BitmapDescriptor.defaultMarkerWithHue(
      BitmapDescriptor.hueViolet,
    );
    if (mounted) {
      setState(() {
        _markers.add(
          Marker(
            markerId: const MarkerId('current_location'),
            position: const LatLng(9.0333, 38.7000), // Addis Ababa
            infoWindow: const InfoWindow(title: 'Current Location'),
            icon: _currentLocationIcon!,
          ),
        );
      });
    }
  }

  // Check internet connectivity
  Future<void> _checkConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (mounted) {
      setState(() {
        _hasInternet = connectivityResult != ConnectivityResult.none;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Google Map with error handling
          _hasInternet
              ? GoogleMap(
                initialCameraPosition: _initialPosition,
                markers: _markers,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                  _mapController = controller;
                  developer.log('Map controller created');
                  _mapController
                      .setMapStyle(_mapStyle)
                      .then((_) {
                        if (mounted) {
                          setState(() {
                            _isLoading = false;
                          });
                          developer.log('Map style applied successfully');
                        }
                      })
                      .catchError((error) {
                        if (mounted) {
                          setState(() {
                            _isLoading = false;
                            _errorMessage = 'Failed to load map style: $error';
                          });
                          developer.log('Map Style Error: $error');
                        }
                      });
                },
                onCameraMove: (_) => developer.log('Camera moving'),
                onCameraIdle: () {
                  if (mounted) {
                    setState(() {
                      _isLoading = false;
                    });
                    developer.log('Map loaded successfully');
                  }
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                minMaxZoomPreference: const MinMaxZoomPreference(
                  2,
                  18,
                ), // Smooth zoom limits
              )
              : const Center(
                child: Text(
                  'No Internet Connection',
                  style: TextStyle(fontSize: 18, color: Colors.red),
                ),
              ),
          // Loading indicator
          if (_isLoading && _hasInternet)
            const Center(child: CircularProgressIndicator()),
          // Error message
          if (_errorMessage != null)
            Positioned(
              top: 100,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                color: Colors.red.withOpacity(0.9),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          // Menu and clock icons
          Positioned(
            top: 60,
            left: 10,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              onPressed: () {},
              child: const Icon(Icons.menu, color: Colors.black),
            ),
          ),
          Positioned(
            top: 60,
            right: 10,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              onPressed: () {},
              child: const Icon(Icons.access_time, color: Colors.black),
            ),
          ),
          // Floating action button for recentering the map
          Positioned(
            bottom: 260,
            right: 20,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              onPressed: () async {
                if (_currentPosition != null && _controller.isCompleted) {
                  final GoogleMapController controller =
                      await _controller.future;
                  controller.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target: LatLng(
                          _currentPosition!.latitude,
                          _currentPosition!.longitude,
                        ),
                        zoom: 15,
                        tilt: 0,
                        bearing: 0,
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fetching location...')),
                  );
                }
              },
              child: const Icon(Icons.my_location),
            ),
          ),
          // Greeting and search bar
          Positioned(
            bottom: 80,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Good Morning, Fasil',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Where are you going?',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search Destination',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Recent Places button
          Positioned(
            bottom: 0,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Recent Places', style: TextStyle(fontSize: 16)),
                    Icon(
                      Icons.keyboard_arrow_up,
                      color: Colors.white,
                      size: 30,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Custom map style
  static const String _mapStyle = '''
  [
    {
      "elementType": "geometry",
      "stylers": [
        {
          "color": "#d3d3d3"
        }
      ]
    },
    {
      "elementType": "labels.text.fill",
      "stylers": [
        {
          "color": "#616161"
        }
      ]
    },
    {
      "elementType": "labels.text.stroke",
      "stylers": [
        {
          "color": "#f5f5f5"
        }
      ]
    },
    {
      "featureType": "road",
      "elementType": "geometry",
      "stylers": [
        {
          "color": "#ffffff"
        }
      ]
    },
    {
      "featureType": "road",
      "elementType": "labels.text.fill",
      "stylers": [
        {
          "color": "#9e9e9e"
        }
      ]
    }
  ]
  ''';
}
