import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../config/app_theme.dart';
import '../services/city_service.dart';
import '../services/quest_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final CityService _cityService = CityService();

  static const LatLng _initialCenter = LatLng(20.0, 0.0);
  static const double _initialZoom = 2.5;

  List<CityData> _cities = [];
  bool _loading = true;
  CityData? _selectedCity;

  @override
  void initState() {
    super.initState();
    _loadCities();
  }

  Future<void> _loadCities() async {
    try {
      final cities = await _cityService.getCities();
      if (mounted) {
        setState(() {
          _cities = cities;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load cities. Please try again later.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

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

  void _selectCity(CityData city) {
    setState(() => _selectedCity = city);
  }

  void _dismissCity() {
    setState(() => _selectedCity = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _initialCenter,
              initialZoom: _initialZoom,
              onTap: (_, __) => _dismissCity(),
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
                        point: LatLng(city.lat, city.lng),
                        width: 32,
                        height: 32,
                        child: GestureDetector(
                          onTap: () => _selectCity(city),
                          child: _CityPin(
                            selected: _selectedCity?.id == city.id,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
          if (_loading)
            const Center(
              child: CircularProgressIndicator(),
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
            child: _selectedCity != null
                ? _CityInfoCard(
                    city: _selectedCity!,
                    onDismiss: _dismissCity,
                  )
                : const _CityPlaceholderCard(),
          ),
        ],
      ),
    );
  }
}

class _CityPin extends StatelessWidget {
  const _CityPin({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : AppColors.primaryLight,
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColors.primaryDark : AppColors.primary,
          width: 1.5,
        ),
      ),
      child: Icon(
        Icons.place,
        color: selected ? Colors.white : AppColors.primary,
        size: 18,
      ),
    );
  }
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

class _CityPlaceholderCard extends StatelessWidget {
  const _CityPlaceholderCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 2),
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

class _CityInfoCard extends StatefulWidget {
  const _CityInfoCard({required this.city, required this.onDismiss});

  final CityData city;
  final VoidCallback onDismiss;

  @override
  State<_CityInfoCard> createState() => _CityInfoCardState();
}

class _CityInfoCardState extends State<_CityInfoCard> {
  final QuestService _questService = QuestService();

  bool _loadingQuests = true;
  int? _questCount;

  @override
  void initState() {
    super.initState();
    _loadQuestCount();
  }

  @override
  void didUpdateWidget(_CityInfoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.city.id != widget.city.id) {
      setState(() {
        _loadingQuests = true;
        _questCount = null;
      });
      _loadQuestCount();
    }
  }

  Future<void> _loadQuestCount() async {
    try {
      final quests =
          await _questService.getActiveQuests(cityId: widget.city.id);
      if (mounted) {
        setState(() {
          _questCount = quests.length;
          _loadingQuests = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _questCount = 0;
          _loadingQuests = false;
        });
      }
    }
  }

  String get _questLabel {
    if (_questCount == null || _questCount == 0) return 'No quests yet';
    if (_questCount == 1) return '1 active quest';
    return '$_questCount active quests';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.city.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  widget.city.country,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _loadingQuests
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      )
                    : Row(
                        children: [
                          Icon(
                            Icons.explore_outlined,
                            size: 14,
                            color: _questCount != null && _questCount! > 0
                                ? AppColors.primary
                                : AppColors.textTertiary,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            _questLabel,
                            style: TextStyle(
                              color: _questCount != null && _questCount! > 0
                                  ? AppColors.primary
                                  : AppColors.textTertiary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
              ],
            ),
          ),
          GestureDetector(
            onTap: widget.onDismiss,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.secondaryBackground,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
