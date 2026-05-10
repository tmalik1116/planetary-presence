import 'package:flutter/material.dart';
import '../models/quest.dart';
import '../services/auth_service.dart';
import '../services/quest_service.dart';
import '../widgets/quest_card.dart';

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

  Future<void> _showCreateQuestSheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _CreateQuestSheet(onCreated: _refresh),
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
          onPressed: _showCreateQuestSheet,
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

class _CreateQuestSheet extends StatefulWidget {
  final VoidCallback onCreated;

  const _CreateQuestSheet({required this.onCreated});

  @override
  State<_CreateQuestSheet> createState() => _CreateQuestSheetState();
}

class _CreateQuestSheetState extends State<_CreateQuestSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _cityIdController = TextEditingController();

  QuestCategory _selectedCategory = QuestCategory.nature;
  bool _loading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _cityIdController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final uid = AuthService.currentUser?.id;
    if (uid == null) return;

    setState(() => _loading = true);
    try {
      await QuestService().createQuest(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        category: _selectedCategory,
        cityId: _cityIdController.text.trim(),
        createdBy: uid,
      );
      widget.onCreated();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create quest: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 24, 16, 24 + bottomInset),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Create Quest',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Title is required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<QuestCategory>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: QuestCategory.nature,
                    child: Text('🌿 Nature'),
                  ),
                  DropdownMenuItem(
                    value: QuestCategory.culture,
                    child: Text('🎭 Culture'),
                  ),
                  DropdownMenuItem(
                    value: QuestCategory.food,
                    child: Text('🍜 Food'),
                  ),
                  DropdownMenuItem(
                    value: QuestCategory.landmark,
                    child: Text('🏛️ Landmark'),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _selectedCategory = v);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cityIdController,
                decoration: const InputDecoration(
                  labelText: 'City ID',
                  border: OutlineInputBorder(),
                  helperText: 'Replace with real ID from Supabase',
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'City ID is required' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Create Quest'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
