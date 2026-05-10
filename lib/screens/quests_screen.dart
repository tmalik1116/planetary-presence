import 'package:flutter/material.dart';
import '../models/quest.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
    });
  }

  void _refreshPending() {
    setState(() {
      _pendingKey++;
    });
  }

  Future<void> _showCreateQuestScreen() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreateQuestScreen(onCreated: _refresh),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quests'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Active'),
              Tab(text: 'Pending'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _QuestList(
              key: ValueKey('active-$_activeKey'),
              fetchQuests: () => QuestService().getActiveQuests(),
              onVoted: _refresh,
            ),
            _QuestList(
              key: ValueKey('pending-$_pendingKey'),
              fetchQuests: () => QuestService().getPendingQuests(),
              onVoted: _refreshPending,
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showCreateQuestScreen,
          tooltip: 'Create Quest',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class _QuestList extends StatelessWidget {
  final Future<List<Quest>> Function() fetchQuests;
  final VoidCallback onVoted;

  const _QuestList({
    super.key,
    required this.fetchQuests,
    required this.onVoted,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Quest>>(
      future: fetchQuests(),
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
        if (quests.isEmpty) {
          return const Center(child: Text('No quests found.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: quests.length,
          itemBuilder: (context, index) => QuestCard(
            quest: quests[index],
            onVoted: onVoted,
          ),
        );
      },
    );
  }
}

