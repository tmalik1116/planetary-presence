import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../config/app_theme.dart';
import '../models/quest.dart';
import '../services/city_service.dart';
import '../services/quest_service.dart';
import '../widgets/quest_card.dart';
import 'create_quest_screen.dart';
import 'quest_detail_screen.dart';

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
  Map<String, int> _questCounts = {};
  bool _loading = true;
  CityData? _selectedCity;
  List<Quest> _cityQuests = [];

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

  Future<void> _loadCityQuests(String cityId) async {
    try {
      final quests = await QuestService().getActiveQuests(cityId: cityId);
      if (mounted) {
        setState(() {
          _cityQuests = quests.where((q) => q.lat != null && q.lng != null).toList();
        });
      }
    } catch (_) {
      if (mounted) setState(() => _cityQuests = []);
    }
  }

  Future<void> _loadCities() async {
    try {
      final results = await Future.wait([
        _cityService.getCities(),
        _cityService.getActiveQuestCounts(),
      ]);
      if (mounted) {
        setState(() {
          _cities = results[0] as List<CityData>;
          _questCounts = results[1] as Map<String, int>;
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
    setState(() {
      _selectedCity = city;
      _cityQuests = [];
    });
    _panelController.forward();
    _loadCityQuests(city.id);
  }

  void _dismissCity() {
    _panelController.reverse().then((_) {
      if (mounted) setState(() {
        _selectedCity = null;
        _cityQuests = [];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                    Positioned.fill(
                      child: ColoredBox(
                        color: isDark ? Colors.black : Colors.white,
                      ),
                    ),
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _initialCenter,
                        initialZoom: _initialZoom,
                        minZoom: 2.5,
                        cameraConstraint: CameraConstraint.contain(
                          bounds: LatLngBounds(
                            const LatLng(-85.0, -179.9),
                            const LatLng(85.0, 179.9),
                          ),
                        ),
                        onTap: (_, __) => _dismissCity(),
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.drag |
                              InteractiveFlag.pinchZoom |
                              InteractiveFlag.doubleTapZoom |
                              InteractiveFlag.scrollWheelZoom |
                              InteractiveFlag.flingAnimation,
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: isDark
                              ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
                              : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          subdomains: isDark
                              ? const ['a', 'b', 'c', 'd']
                              : const [],
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
                                      questCount: _questCounts[city.id] ?? 0,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                        MarkerLayer(
                          markers: _cityQuests.map((quest) => Marker(
                            point: LatLng(quest.lat!, quest.lng!),
                            width: 28,
                            height: 28,
                            child: GestureDetector(
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => QuestDetailScreen(quest: quest),
                                ),
                              ),
                              child: _QuestPin(
                                category: quest.category,
                                isDark: isDark,
                              ),
                            ),
                          )).toList(),
                        ),
                      ],
                    ),
                    if (_loading)
                      const Center(child: CircularProgressIndicator()),
                    Positioned(
                      top: MediaQuery.of(context).padding.top + AppSpacing.base,
                      right: AppSpacing.base,
                      child: _ZoomControls(
                        onZoomIn: _zoomIn,
                        onZoomOut: _zoomOut,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
              ),
              if (_selectedCity != null)
                Expanded(
                  child: ColoredBox(
                    color: isDark ? AppColors.dmCard : Colors.white,
                    child: SlideTransition(
                      position: _panelSlide,
                      child: _CityQuestPanel(
                        city: _selectedCity!,
                        onDismiss: _dismissCity,
                        isDark: isDark,
                      ),
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
  const _CityPin({required this.selected, required this.questCount});

  final bool selected;
  final int questCount;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
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
        ),
        if (questCount > 0)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white, width: 1),
              ),
              child: Text(
                '$questCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Zoom controls overlay
// ---------------------------------------------------------------------------

class _ZoomControls extends StatelessWidget {
  const _ZoomControls({
    required this.onZoomIn,
    required this.onZoomOut,
    required this.isDark,
  });

  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark ? AppColors.dmCard : Colors.white;
    final borderColor = isDark ? AppColors.dmBorder : AppColors.cardBorder;
    final dividerColor = isDark ? AppColors.dmBorder : AppColors.divider;
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.button),
        border: Border.all(color: borderColor),
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
          _ZoomButton(icon: Icons.add, onTap: onZoomIn, isDark: isDark),
          SizedBox(
            width: 32,
            child: Divider(height: 1, thickness: 1, color: dividerColor),
          ),
          _ZoomButton(icon: Icons.remove, onTap: onZoomOut, isDark: isDark),
        ],
      ),
    );
  }
}

class _ZoomButton extends StatelessWidget {
  const _ZoomButton({
    required this.icon,
    required this.onTap,
    required this.isDark,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final iconColor = isDark ? AppColors.dmTextPrimary : AppColors.textPrimary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.button),
      child: SizedBox(
        width: 40,
        height: 40,
        child: Icon(icon, size: 20, color: iconColor),
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
    required this.isDark,
  });

  final CityData city;
  final VoidCallback onDismiss;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark ? AppColors.dmCard : Colors.white;
    final borderColor = isDark ? AppColors.dmBorder : AppColors.cardBorder;
    final dividerColor = isDark ? AppColors.dmBorder : AppColors.divider;
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          top: BorderSide(color: borderColor),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PanelHeader(city: city, onDismiss: onDismiss, isDark: isDark),
          Divider(height: 1, thickness: 1, color: dividerColor),
          Expanded(
            child: _QuestList(city: city),
          ),
        ],
      ),
    );
  }
}

class _PanelHeader extends StatelessWidget {
  const _PanelHeader({
    required this.city,
    required this.onDismiss,
    required this.isDark,
  });

  final CityData city;
  final VoidCallback onDismiss;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final secondaryTextColor =
        isDark ? AppColors.dmTextSecondary : AppColors.textSecondary;
    final closeButtonBg = isDark
        ? AppColors.dmSecondaryBackground
        : AppColors.secondaryBackground;
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
                Text(
                  'Active Quests',
                  style: TextStyle(
                    fontSize: 13,
                    color: secondaryTextColor,
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
              decoration: BoxDecoration(
                color: closeButtonBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                size: 16,
                color: secondaryTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Quest pin marker
// ---------------------------------------------------------------------------

class _QuestPin extends StatelessWidget {
  const _QuestPin({required this.category, required this.isDark});

  final QuestCategory category;
  final bool isDark;

  IconData get _icon {
    switch (category) {
      case QuestCategory.nature:
        return Icons.eco;
      case QuestCategory.culture:
        return Icons.museum;
      case QuestCategory.food:
        return Icons.restaurant;
      case QuestCategory.landmark:
        return Icons.star;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = AppColors.categoryColor(category.value, darkMode: isDark);
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.9),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x44000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Icon(_icon, size: 13, color: Colors.white),
    );
  }
}

// ---------------------------------------------------------------------------
// Split-view quest list
// ---------------------------------------------------------------------------

class _QuestList extends StatelessWidget {
  const _QuestList({required this.city});

  final CityData city;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Quest>>(
      future: QuestService().getActiveQuests(cityId: city.id),
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
                    'No active quests in ${city.name}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextButton.icon(
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => CreateQuestScreen(
                        initialCity: city,
                        onCreated: () {},
                      ),
                    )),
                    icon: const Icon(Icons.add_circle_outline, size: 18),
                    label: const Text('Be the first — add a quest'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
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
