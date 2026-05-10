import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../models/quest.dart';
import '../services/auth_service.dart';
import '../services/city_service.dart';
import '../services/quest_service.dart';

class CreateQuestScreen extends StatefulWidget {
  final VoidCallback onCreated;

  const CreateQuestScreen({super.key, required this.onCreated});

  @override
  State<CreateQuestScreen> createState() => _CreateQuestScreenState();
}

class _CreateQuestScreenState extends State<CreateQuestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _hintsController = TextEditingController();

  QuestCategory _selectedCategory = QuestCategory.nature;
  String _selectedDifficulty = 'medium';
  CityData? _selectedCity;
  List<CityData> _cities = [];
  bool _loading = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadCities();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _hintsController.dispose();
    super.dispose();
  }

  Future<void> _loadCities() async {
    setState(() => _loading = true);
    try {
      final cities = await CityService().getCities();
      cities.sort((a, b) => a.name.compareTo(b.name));
      if (mounted) setState(() => _cities = cities);
    } catch (_) {
      // Cities will just be empty; user sees empty dropdown
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCity == null) return;
    final uid = AuthService.currentUser?.id;
    if (uid == null) return;

    setState(() => _submitting = true);
    try {
      await QuestService().createQuest(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        category: _selectedCategory,
        cityId: _selectedCity!.id,
        createdBy: uid,
      );
      widget.onCreated();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Quest'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SectionHeader('Title'),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'What should explorers find or do?',
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Title is required' : null,
              ),
              const SizedBox(height: AppSpacing.lg),
              _SectionHeader('Description (optional)'),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  hintText: 'Describe the quest...',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: AppSpacing.lg),
              _SectionHeader('Category'),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: AppSpacing.sm,
                mainAxisSpacing: AppSpacing.sm,
                childAspectRatio: 2.0,
                children: [
                  _CategoryCard(
                    category: QuestCategory.nature,
                    emoji: '🌿',
                    label: 'Nature',
                    isSelected: _selectedCategory == QuestCategory.nature,
                    onTap: () =>
                        setState(() => _selectedCategory = QuestCategory.nature),
                  ),
                  _CategoryCard(
                    category: QuestCategory.culture,
                    emoji: '🎭',
                    label: 'Culture',
                    isSelected: _selectedCategory == QuestCategory.culture,
                    onTap: () =>
                        setState(() => _selectedCategory = QuestCategory.culture),
                  ),
                  _CategoryCard(
                    category: QuestCategory.food,
                    emoji: '🍜',
                    label: 'Food',
                    isSelected: _selectedCategory == QuestCategory.food,
                    onTap: () =>
                        setState(() => _selectedCategory = QuestCategory.food),
                  ),
                  _CategoryCard(
                    category: QuestCategory.landmark,
                    emoji: '🏛️',
                    label: 'Landmark',
                    isSelected: _selectedCategory == QuestCategory.landmark,
                    onTap: () =>
                        setState(() => _selectedCategory = QuestCategory.landmark),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              _SectionHeader('Difficulty'),
              Row(
                children: [
                  _DifficultyPill(
                    label: 'Easy',
                    color: const Color(0xFF2E9B1F),
                    isSelected: _selectedDifficulty == 'easy',
                    onTap: () => setState(() => _selectedDifficulty = 'easy'),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _DifficultyPill(
                    label: 'Medium',
                    color: const Color(0xFFFF9800),
                    isSelected: _selectedDifficulty == 'medium',
                    onTap: () => setState(() => _selectedDifficulty = 'medium'),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _DifficultyPill(
                    label: 'Hard',
                    color: const Color(0xFFE53935),
                    isSelected: _selectedDifficulty == 'hard',
                    onTap: () => setState(() => _selectedDifficulty = 'hard'),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _DifficultyPill(
                    label: 'Epic',
                    color: const Color(0xFFA855F7),
                    isSelected: _selectedDifficulty == 'epic',
                    onTap: () => setState(() => _selectedDifficulty = 'epic'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              _SectionHeader('City'),
              _loading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : DropdownButtonFormField<CityData>(
                      value: _selectedCity,
                      decoration: const InputDecoration(
                        hintText: 'Select a city',
                      ),
                      items: _cities
                          .map(
                            (city) => DropdownMenuItem<CityData>(
                              value: city,
                              child: Text('${city.name}, ${city.country}'),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedCity = v),
                      validator: (v) =>
                          v == null ? 'Please select a city' : null,
                    ),
              const SizedBox(height: AppSpacing.lg),
              _SectionHeader('Hints (optional)'),
              TextFormField(
                controller: _hintsController,
                decoration: const InputDecoration(
                  hintText: 'e.g. Look for the blue door on the east side',
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Submit Quest'),
                ),
              ),
              const SizedBox(height: AppSpacing.base),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;

  const _SectionHeader(this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final QuestCategory category;
  final String emoji;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.emoji,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.cardBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DifficultyPill extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _DifficultyPill({
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs + 2,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: isSelected ? color : AppColors.cardBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? color : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
