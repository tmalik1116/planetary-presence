import 'package:flutter/material.dart';
import '../models/quest.dart';
import '../services/city_service.dart';
import '../services/location_service.dart';
import '../services/quest_service.dart';
import '../widgets/quest_card.dart';
import 'create_quest_screen.dart';

class QuestsScreen extends StatefulWidget {
  const QuestsScreen({super.key});

  @override
  State<QuestsScreen> createState() => _QuestsScreenState();
}

class _QuestsScreenState extends State<QuestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  int _activeKey = 0;
  int _pendingKey = 0;
  int _completedKey = 0;

  // Filter state
  String? _cityId;
  CityData? _nearestCity;
  QuestCategory? _category;
  bool _sortPopular = false;
  bool _friendsOnly = false;
  
  bool _isLoadingLocation = false;
  double? _userToCityKm;
  int _activeQuestCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initLocation();
  }

  Future<void> _initLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });
    try {
      final position = await LocationService.getCurrentPosition();
      if (position != null) {
        final city = await CityService().getNearestCity(
          position.latitude,
          position.longitude,
        );
        if (city != null && mounted) {
          setState(() {
            _cityId = city.id;
            _nearestCity = city;
            _userToCityKm = CityService.haversineMeters(
              position.latitude, position.longitude,
              city.lat, city.lng,
            ) / 1000;
            _activeQuestCount = 0;
            _refresh();
          });
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _refresh() {
    setState(() {
      _activeKey++;
      _pendingKey++;
      _completedKey++;
    });
  }

  void _refreshPending() {
    setState(() {
      _pendingKey++;
    });
  }

  void _refreshCompleted() {
    setState(() {
      _completedKey++;
    });
  }

  Future<void> _showCreateQuestScreen() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreateQuestScreen(onCreated: _refresh),
      ),
    );
  }

  Widget _buildFilterBar() {
    final colorScheme = Theme.of(context).colorScheme;
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          PopupMenuButton<dynamic>(
            initialValue: _category ?? 'all',
            onSelected: (val) {
              setState(() {
                if (val == 'all') {
                  _category = null;
                } else {
                  _category = val as QuestCategory;
                }
                _refresh();
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All Categories')),
              ...QuestCategory.values.map(
                (c) {
                  final name = c.name[0].toUpperCase() + c.name.substring(1);
                  return PopupMenuItem(value: c, child: Text(name));
                },
              ),
            ],
            child: IgnorePointer(
              child: FilterChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _category == null
                          ? 'Category'
                          : _category!.name[0].toUpperCase() + _category!.name.substring(1),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_drop_down, 
                      size: 18,
                      color: _category != null ? colorScheme.onPrimary : colorScheme.onSurface,
                    ),
                  ],
                ),
                selected: _category != null,
                selectedColor: colorScheme.primary,
                labelStyle: TextStyle(
                  color: _category != null ? colorScheme.onPrimary : colorScheme.onSurface,
                ),
                onSelected: (_) {},
              ),
            ),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: _isLoadingLocation 
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 14, 
                        height: 14, 
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('Locating...'),
                    ],
                  )
                : const Text('Nearest City'),
            selected: _cityId != null || _isLoadingLocation,
            showCheckmark: !_isLoadingLocation,
            selectedColor: colorScheme.primary,
            checkmarkColor: colorScheme.onPrimary,
            labelStyle: TextStyle(
              color: (_cityId != null || _isLoadingLocation) ? colorScheme.onPrimary : colorScheme.onSurface,
            ),
            onSelected: (val) {
              if (_isLoadingLocation) return;
              if (val) {
                _initLocation();
              } else {
                setState(() {
                  _cityId = null;
                  _nearestCity = null;
                  _userToCityKm = null;
                  _activeQuestCount = 0;
                  _refresh();
                });
              }
            },
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Popular'),
            selected: _sortPopular,
            selectedColor: colorScheme.primary,
            checkmarkColor: colorScheme.onPrimary,
            labelStyle: TextStyle(
              color: _sortPopular ? colorScheme.onPrimary : colorScheme.onSurface,
            ),
            onSelected: (val) {
              setState(() {
                _sortPopular = val;
                _refresh();
              });
            },
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Friends'),
            selected: _friendsOnly,
            selectedColor: colorScheme.primary,
            checkmarkColor: colorScheme.onPrimary,
            labelStyle: TextStyle(
              color: _friendsOnly ? colorScheme.onPrimary : colorScheme.onSurface,
            ),
            onSelected: (val) {
              setState(() {
                _friendsOnly = val;
                _refresh();
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quests'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Pending'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildFilterBar(),
          if (_nearestCity != null)
            _NearestCityBanner(
              cityName: _nearestCity!.name,
              distanceKm: _userToCityKm,
              questCount: _activeQuestCount,
            ),
          const Divider(height: 1),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _QuestList(
                  key: ValueKey('active-$_activeKey'),
                  fetchQuests: () => QuestService().fetchQuests(
                    status: 'active',
                    cityId: _cityId,
                    category: _category,
                    isCompleted: false, // Only uncompleted tasks here
                    sortPopular: _sortPopular,
                    friendsOnly: _friendsOnly,
                  ),
                  onVoted: _refresh,
                  onLoaded: (count) => setState(() => _activeQuestCount = count),
                ),
                _QuestList(
                  key: ValueKey('pending-$_pendingKey'),
                  fetchQuests: () => QuestService().fetchQuests(
                    status: 'pending',
                    cityId: _cityId,
                    category: _category,
                    isCompleted: false, // Uncompleted only
                    sortPopular: _sortPopular,
                    friendsOnly: _friendsOnly,
                  ),
                  onVoted: _refreshPending,
                ),
                _QuestList(
                  key: ValueKey('completed-$_completedKey'),
                  fetchQuests: () => QuestService().fetchQuests(
                    status: 'active', // Completed quests are usually active
                    cityId: _cityId,
                    category: _category,
                    isCompleted: true, // Only completed here!
                    sortPopular: _sortPopular,
                    friendsOnly: _friendsOnly,
                  ),
                  onVoted: _refreshCompleted,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateQuestScreen,
        tooltip: 'Create Quest',
        child: Icon(
          Icons.add,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : null,
        ),
      ),
    );
  }
}

class _NearestCityBanner extends StatelessWidget {
  const _NearestCityBanner({
    required this.cityName,
    required this.distanceKm,
    required this.questCount,
  });
  final String cityName;
  final double? distanceKm;
  final int questCount;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final distStr = distanceKm != null ? '~${distanceKm!.round()}km from' : 'in';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: colorScheme.primaryContainer.withValues(alpha: 0.4),
      child: Row(
        children: [
          Icon(Icons.location_on, size: 14, color: colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            'Showing $questCount quests $distStr $cityName',
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestList extends StatefulWidget {
  final Future<List<Quest>> Function() fetchQuests;
  final VoidCallback onVoted;
  final void Function(int count)? onLoaded;

  const _QuestList({
    super.key,
    required this.fetchQuests,
    required this.onVoted,
    this.onLoaded,
  });

  @override
  State<_QuestList> createState() => _QuestListState();
}

class _QuestListState extends State<_QuestList> {
  late Future<List<Quest>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.fetchQuests();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Quest>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        final quests = snapshot.data ?? [];
        if (snapshot.connectionState == ConnectionState.done) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.onLoaded?.call(quests.length);
          });
        }
        if (quests.isEmpty) {
          return const Center(child: Text('No quests found.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: quests.length,
          itemBuilder: (context, index) => QuestCard(
            quest: quests[index],
            onVoted: widget.onVoted,
          ),
        );
      },
    );
  }
}

