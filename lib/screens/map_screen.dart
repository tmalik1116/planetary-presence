import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../config/app_theme.dart';
import '../models/quest.dart';
import '../services/city_service.dart';
import '../services/quest_service.dart';
import '../widgets/quest_card.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  final CityService _cityService = CityService();

  static const LatLng _initialCenter = LatLng(20.0, 0.0);
  static const double _initialZoom = 2.5;

  List<CityData> _cities = [];
  bool _loading = true;
  CityData? _selectedCity;

  late final AnimationController _panelController;
  late final Animation<Offset> _panelSlide;

  @override
  void initState() {
    super.initState();
    _panelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _panelSlide = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _panelController,
      curve: Curves.easeOutCubic,
    ));
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
    _panelController.dispose();
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
    _panelController.forward();
  }

  void _dismissCity() {
    _panelController.reverse().then((_) {
      if (mounted) setState(() => _selectedCity = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final mapHeight = _selectedCity != null
              ? constraints.maxHeight * 0.45
              : constraints.maxHeight;
          return Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                height: mapHeight,
                child: Stack(
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
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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
                      const Center(child: CircularProgressIndicator()),
                    Positioned(
                      top: MediaQuery.of(context).padding.top + AppSpacing.base,
                      right: AppSpacing.base,
                      child:
                          _ZoomControls(onZoomIn: _zoomIn, onZoomOut: _zoomOut),
                    ),
                  ],
                ),
              ),
              if (_selectedCity != null)
                Expanded(
                  child: SlideTransition(
                    position: _panelSlide,
                    child: _CityQuestPanel(
                      city: _selectedCity!,
                      onDismiss: _dismissCity,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// City pin marker
// ---------------------------------------------------------------------------

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

// ---------------------------------------------------------------------------
// Zoom controls overlay
// ---------------------------------------------------------------------------

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

// ---------------------------------------------------------------------------
// Split-view quest panel
// ---------------------------------------------------------------------------

class _CityQuestPanel extends StatelessWidget {
  const _CityQuestPanel({
    required this.city,
    required this.onDismiss,
  });

  final CityData city;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.card),
        ),
        border: Border(
          top: BorderSide(color: AppColors.cardBorder),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PanelHeader(city: city, onDismiss: onDismiss),
          const Divider(height: 1, thickness: 1, color: AppColors.divider),
          Expanded(
            child: _QuestList(cityId: city.id, cityName: city.name),
          ),
        ],
      ),
    );
  }
}

class _PanelHeader extends StatelessWidget {
  const _PanelHeader({required this.city, required this.onDismiss});

  final CityData city;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.base,
        AppSpacing.md,
        AppSpacing.base,
        AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  city.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                const Text(
                  'Active Quests',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onDismiss,
            child: Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
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

class _QuestList extends StatelessWidget {
  const _QuestList({required this.cityId, required this.cityName});

  final String cityId;
  final String cityName;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Quest>>(
      future: QuestService().getActiveQuests(cityId: cityId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(
                'Failed to load quests. Pull to retry.',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final quests = snapshot.data ?? [];

        if (quests.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.explore_outlined,
                    size: 36,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'No active quests in $cityName',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(
            top: AppSpacing.sm,
            bottom: AppSpacing.lg,
          ),
          itemCount: quests.length,
          itemBuilder: (context, index) => QuestCard(quest: quests[index]),
        );
      },
    );
  }
}
