import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../config/app_theme.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  static const LatLng _initialCenter = LatLng(20.0, 0.0);
  static const double _initialZoom = 2.5;

  static const List<_CityMarker> _cities = [
    _CityMarker('Toronto', LatLng(43.6532, -79.3832)),
    _CityMarker('Paris', LatLng(48.8566, 2.3522)),
    _CityMarker('Tokyo', LatLng(35.6762, 139.6503)),
    _CityMarker('Sydney', LatLng(-33.8688, 151.2093)),
    _CityMarker('Nairobi', LatLng(-1.2921, 36.8219)),
  ];

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _zoomIn() {
    final current = _mapController.camera;
    _mapController.move(current.center, current.zoom + 1);
  }

  void _zoomOut() {
    final current = _mapController.camera;
    _mapController.move(current.center, current.zoom - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: _initialCenter,
              initialZoom: _initialZoom,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.planetary_presence.app',
              ),
              MarkerLayer(
                markers: _cities
                    .map(
                      (city) => Marker(
                        point: city.latLng,
                        width: 32,
                        height: 32,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.place,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + AppSpacing.base,
            right: AppSpacing.base,
            child: _ZoomControls(onZoomIn: _zoomIn, onZoomOut: _zoomOut),
          ),
          Positioned(
            left: AppSpacing.base,
            right: AppSpacing.base,
            bottom: AppSpacing.base,
            child: const _CityInfoCard(),
          ),
        ],
      ),
    );
  }
}

class _CityMarker {
  final String name;
  final LatLng latLng;

  const _CityMarker(this.name, this.latLng);
}

class _ZoomControls extends StatelessWidget {
  const _ZoomControls({required this.onZoomIn, required this.onZoomOut});

  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.button),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ZoomButton(icon: Icons.add, onTap: onZoomIn),
          const SizedBox(
            width: 32,
            child: Divider(height: 1, thickness: 1, color: AppColors.divider),
          ),
          _ZoomButton(icon: Icons.remove, onTap: onZoomOut),
        ],
      ),
    );
  }
}

class _ZoomButton extends StatelessWidget {
  const _ZoomButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.button),
      child: SizedBox(
        width: 40,
        height: 40,
        child: Icon(icon, size: 20, color: AppColors.textPrimary),
      ),
    );
  }
}

class _CityInfoCard extends StatelessWidget {
  const _CityInfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: const Text(
        'Tap a city to explore quests',
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
