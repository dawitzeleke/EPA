import 'package:eprs/app/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class OfficeDetailMapView extends StatefulWidget {
  final String officeName;
  const OfficeDetailMapView({super.key, required this.officeName});

  @override
  State<OfficeDetailMapView> createState() => _OfficeDetailMapViewState();
}

class _OfficeDetailMapViewState extends State<OfficeDetailMapView> {
  GoogleMapController? _mapController;

  static final Map<String, LatLng> _officeCoords = {
    'Addis Ketema': LatLng(9.0265, 38.7538),
    'Kolfe Keraniyo': LatLng(9.0046, 38.7350),
    'Bole': LatLng(8.9915, 38.8039),
    'Lideta': LatLng(9.0157, 38.7459),
    'Arada': LatLng(9.0152, 38.7489),
    'Yeka': LatLng(9.0474, 38.7775),
    'Lemi Kura': LatLng(9.0300, 38.7500),
  };

  late LatLng _initialLatLng;
  late Marker _marker;

  @override
  void initState() {
    super.initState();
    _initialLatLng = _officeCoords[widget.officeName] ?? const LatLng(9.0285, 38.7610);
    _marker = Marker(
      markerId: MarkerId(widget.officeName),
      position: _initialLatLng,
      infoWindow: InfoWindow(title: widget.officeName),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Offices', showBack: true),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _initialLatLng, zoom: 15),
            onMapCreated: (controller) => _mapController = controller,
            markers: {_marker},
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapType: MapType.normal,
          ),

          // Floating marker label at center (optional visual)
          Positioned(
            bottom: MediaQuery.of(context).size.height / 2 - 40,
            left: MediaQuery.of(context).size.width / 2 - 24,
            child: const Icon(Icons.location_on, size: 48, color: Colors.redAccent),
          ),

          // Info overlay card (right side)
          Positioned(
            right: 18,
            top: 80,
            child: Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 260,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(widget.officeName, style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    const Text('Addis Ketema Subcity Woreda 1 Office\nAdministrative Location: Merkato area', style: TextStyle(fontSize: 12, color: Colors.black54)),
                    const SizedBox(height: 8),
                    Row(children: const [Icon(Icons.call, size: 18), SizedBox(width: 8), Text('+251 09 5432 1234', style: TextStyle(fontSize: 12))]),
                    const SizedBox(height: 6),
                    Row(children: const [Icon(Icons.email, size: 18), SizedBox(width: 8), Text('info@epa.com.au', style: TextStyle(fontSize: 12))]),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () async {
                            // Animate camera to marker
                            await _mapController?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: _initialLatLng, zoom: 17)));
                          },
                          icon: const Icon(Icons.map, size: 16),
                          label: const Text('Center'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            // placeholder: launch dialer or email
                            Get.snackbar('Contact', 'Dial +251 09 5432 1234 or email info@epa.com.au', snackPosition: SnackPosition.BOTTOM);
                          },
                          icon: const Icon(Icons.call, size: 16),
                          label: const Text('Call'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}





