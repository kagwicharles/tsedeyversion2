import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:craft_dynamic/craft_dynamic.dart';

class MapView extends StatefulWidget {
  bool isAtms;
  MapView({
    this.isAtms = true,
    Key? key,
  }) : super(key: key);

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  late GoogleMapController mapController;
  final _atmLocationRepository = AtmLocationRepository();
  final _branchLocationRepository = BranchLocationRepository();
  final LatLng _center = const LatLng(9.005401, 38.763611);
  final Set<Marker> _markers = {};
  List<AtmLocation> _atmLocations = [];
  List<BranchLocation> _branchLocations = [];
  List<AppLocation> _appLocations = [];
  int counter = 1;

  Future<List<AppLocation>> _getLocations() async {
    _appLocations.clear();
    if (widget.isAtms) {
      _atmLocations = await _atmLocationRepository.getAllAtmLocations();

      for (var atmLocation in _atmLocations) {
        _appLocations.add(AppLocation(
            longitude: atmLocation.longitude,
            latitude: atmLocation.latitude,
            location: atmLocation.location));
      }
    } else {
      _branchLocations =
          await _branchLocationRepository.getAllBranchLocations();
      for (var branchLocation in _branchLocations) {
        _appLocations.add(AppLocation(
            longitude: branchLocation.longitude,
            latitude: branchLocation.latitude,
            location: branchLocation.location));
      }
    }
    return _appLocations;
  }

  updateMarkers() async {
    await _getLocations();
    setState(() {
      _markers.clear();
      for (var location in _appLocations) {
        _markers.add(Marker(
          markerId: MarkerId(location.location),
          position: LatLng(location.latitude, location.longitude),
          infoWindow: InfoWindow(
            title: location.location,
          ),
        ));
        Future.delayed(const Duration(milliseconds: 500), () {});
      }
    });

    counter++;
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    updateMarkers();
  }

  @override
  void initState() {
    super.initState();
    _appLocations.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.isAtms ? "ATMs" : "Branches")),
      body: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 12.5,
            ),
            markers: _markers,
          ),
        ],
      ),
    );
  }
}
