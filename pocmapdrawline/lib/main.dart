import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

const double CAMERA_ZOOM = 13;
const double CAMERA_TILT = 0;
const double CAMERA_BEARING = 30;
const PointLatLng SOURCE_LOCATION = PointLatLng(42.7477863, -71.1699932);
const PointLatLng DEST_LOCATION = PointLatLng(42.6871386, -71.2143403);

const LatLng SORCE = LatLng(42.7477863, -71.1699932);
const LatLng DEST = LatLng(42.6871386, -71.2143403);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Completer<GoogleMapController> _controller;
  Set<Marker> _markers = {};
  // isto manterá as polilinhas geradas
  Set<Polyline> _polylines = {};
  // isto manterá cada coordenada de polilinha como pares Lat e Lng
  List<LatLng> polylineCoordinates = [];
  // este é o objeto chave - o PolylinePoints
  // que gera cada polilinha entre o início e o fim
  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPIKey = 'AIzaSyDQCZtpEAddNrE0CVK4qTYr3t52lZ8BJM8';

// para meus ícones personalizados
  late BitmapDescriptor sourceIcon;
  late BitmapDescriptor destinationIcon;

  void setSourceAndDestinationIcons() async {
    sourceIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(devicePixelRatio: 2.5),
        'assets/driving_pin.png');
    destinationIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(devicePixelRatio: 2.5),
        'assets/destination_map_marker.png');
  }

  void onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
    setMapPins();
    setPolylines();
  }

  setPolylines() async {
    var result = await polylinePoints.getRouteBetweenCoordinates(
        googleAPIKey, SOURCE_LOCATION, DEST_LOCATION);
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    setState(() {
      Polyline polyline = Polyline(
          polylineId: const PolylineId(''),
          color: const Color.fromARGB(255, 40, 122, 198),
          points: polylineCoordinates);

      _polylines.add(polyline);
    });
  }

  void setMapPins() {
    setState(() {
      // source pin
      _markers.add(Marker(
        markerId: MarkerId(''), position: SORCE,
        //   icon: sourceIcon
      ));
      // destination pin
      _markers.add(const Marker(
        markerId: MarkerId(''), position: DEST,
        //icon: destinationIcon
      ));
    });
  }

  @override
  void initState() {
    _controller = Completer();
    // setSourceAndDestinationIcons();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    CameraPosition initialLocation = const CameraPosition(
        zoom: CAMERA_ZOOM,
        bearing: CAMERA_BEARING,
        tilt: CAMERA_TILT,
        target: SORCE);

    return Scaffold(
        appBar: AppBar(),
        body: Center(
            child: GoogleMap(
                myLocationEnabled: true,
                compassEnabled: true,
                tiltGesturesEnabled: false,
                markers: _markers,
                polylines: _polylines,
                mapType: MapType.normal,
                initialCameraPosition: initialLocation,
                onMapCreated: onMapCreated)));
  }
}
