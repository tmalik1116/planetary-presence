import 'dart:async';

import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/supabase_service.dart';
import '../../services/logger_service.dart';
import '../../widgets/bottom_nav.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();

  String? _selectedCityId;
  String? _cityError;
  bool _loading = false;

  Timer? _debounce;
  bool _querying = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _queryCities(String query) async {
    if (query.length < 2) return [];
    final results = await SupabaseService.client
        .from('cities')
        .select('id, name, country')
        .ilike('name', '%$query%')
        .limit(10);
    return List<Map<String, dynamic>>.from(results as List);
  }

  Future<String> _insertCity(String cityName) async {
    AppLogger.i('Onboarding: inserting new city "$cityName"');
    final inserted = await SupabaseService.client
        .from('cities')
        .insert({'name': cityName, 'country': 'Unknown'})
        .select('id')
        .single();
    return inserted['id'] as String;
  }

  Future<void> _submit() async {
    final formValid = _formKey.currentState!.validate();

    if (_selectedCityId == null) {
      setState(() => _cityError = 'Please select a city from the list');
    } else {
      setState(() => _cityError = null);
    }

    if (!formValid || _selectedCityId == null) return;

    setState(() => _loading = true);
    try {
      await AuthService.createProfile(
        username: _usernameController.text.trim(),
        homeCityId: _selectedCityId!,
      );

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainShell()),
        (_) => false,
      );
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = isDark ? AppColors.dmPrimary : AppColors.primary;
    final subtitleColor =
        isDark ? AppColors.dmTextSecondary : AppColors.textSecondary;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.xl,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Welcome!',
                    style: theme.textTheme.displayMedium?.copyWith(
                      color: primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Set up your profile to get started',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: subtitleColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      prefixIcon: Icon(Icons.person_outlined),
                      helperText: 'Min 3 characters, no spaces',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Username is required';
                      }
                      if (v.contains(' ')) {
                        return 'Username cannot contain spaces';
                      }
                      if (v.trim().length < 3) {
                        return 'Username must be at least 3 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _CityAutocomplete(
                    isDark: isDark,
                    querying: _querying,
                    errorText: _cityError,
                    onQueryingChanged: (v) => setState(() => _querying = v),
                    onCitySelected: (id) {
                      setState(() {
                        _selectedCityId = id;
                        _cityError = null;
                      });
                    },
                    onCityCleared: () {
                      setState(() => _selectedCityId = null);
                    },
                    queryCities: _queryCities,
                    insertCity: _insertCity,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Continue'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CityAutocomplete extends StatefulWidget {
  const _CityAutocomplete({
    required this.isDark,
    required this.querying,
    required this.errorText,
    required this.onQueryingChanged,
    required this.onCitySelected,
    required this.onCityCleared,
    required this.queryCities,
    required this.insertCity,
  });

  final bool isDark;
  final bool querying;
  final String? errorText;
  final ValueChanged<bool> onQueryingChanged;
  final ValueChanged<String> onCitySelected;
  final VoidCallback onCityCleared;
  final Future<List<Map<String, dynamic>>> Function(String) queryCities;
  final Future<String> Function(String) insertCity;

  @override
  State<_CityAutocomplete> createState() => _CityAutocompleteState();
}

class _CityAutocompleteState extends State<_CityAutocomplete> {
  final _controller = TextEditingController();
  Timer? _debounce;
  List<Map<String, dynamic>> _options = [];
  String _lastQuery = '';
  bool _hasSelection = false;

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String value) {
    if (_hasSelection && value != _lastQuery) {
      _hasSelection = false;
      widget.onCityCleared();
    }

    _debounce?.cancel();
    if (value.length < 2) {
      setState(() => _options = []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      widget.onQueryingChanged(true);
      try {
        final results = await widget.queryCities(value);
        if (mounted) {
          setState(() {
            _options = results;
            _lastQuery = value;
          });
        }
      } finally {
        if (mounted) widget.onQueryingChanged(false);
      }
    });
  }

  Future<void> _handleAddNew(String cityName) async {
    widget.onQueryingChanged(true);
    try {
      final id = await widget.insertCity(cityName);
      widget.onCitySelected(id);
      _hasSelection = true;
      _lastQuery = cityName;
      if (mounted) setState(() => _options = []);
    } catch (e) {
      AppLogger.e('Onboarding: failed to insert city', error: e);
    } finally {
      if (mounted) widget.onQueryingChanged(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = widget.isDark;
    final borderColor = isDark ? AppColors.dmBorder : AppColors.cardBorder;
    final focusedColor = isDark ? AppColors.dmPrimary : AppColors.primary;
    final fillColor = isDark ? AppColors.dmInput : AppColors.background;
    final labelColor =
        isDark ? AppColors.dmTextSecondary : AppColors.textSecondary;
    final hintColor = isDark ? AppColors.dmTextMuted : AppColors.textTertiary;
    final errorColor = widget.errorText != null ? Colors.red : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Autocomplete<Map<String, dynamic>>(
          optionsBuilder: (textEditingValue) async {
            final query = textEditingValue.text;
            if (query.length < 2) return const [];
            return _options;
          },
          displayStringForOption: (option) {
            final name = option['name'] as String? ?? '';
            final country = option['country'] as String? ?? '';
            return '$name, $country';
          },
          onSelected: (option) {
            _hasSelection = true;
            _lastQuery = _controller.text;
            widget.onCitySelected(option['id'] as String);
            setState(() => _options = []);
          },
          fieldViewBuilder: (context, fieldController, focusNode, onSubmit) {
            _controller.value = fieldController.value;
            return TextField(
              controller: fieldController,
              focusNode: focusNode,
              onChanged: (v) {
                _onChanged(v);
              },
              decoration: InputDecoration(
                labelText: 'Home City',
                hintText: 'Search for your city...',
                prefixIcon: const Icon(Icons.location_city_outlined),
                suffixIcon: widget.querying
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : null,
                filled: true,
                fillColor: fillColor,
                labelStyle: TextStyle(color: labelColor),
                hintStyle: TextStyle(color: hintColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.input),
                  borderSide: BorderSide(
                    color: errorColor ?? borderColor,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.input),
                  borderSide: BorderSide(
                    color: errorColor ?? borderColor,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.input),
                  borderSide: BorderSide(
                    color: errorColor ?? focusedColor,
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.base,
                  vertical: AppSpacing.md,
                ),
              ),
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            final query = _controller.text.trim();
            final showAddNew = query.isNotEmpty &&
                !options.any(
                  (o) =>
                      (o['name'] as String).toLowerCase() ==
                      query.toLowerCase(),
                );
            final allItems = [
              ...options,
              if (showAddNew) {'__add_new__': true, 'name': query},
            ];

            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(AppRadius.input),
                color: isDark ? AppColors.dmCard : AppColors.background,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 240),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: allItems.length,
                    itemBuilder: (context, index) {
                      final item = allItems.elementAt(index);
                      final isAddNew = item['__add_new__'] == true;

                      if (isAddNew) {
                        final cityName = item['name'] as String;
                        return ListTile(
                          leading: Icon(
                            Icons.add_location_alt_outlined,
                            color: isDark
                                ? AppColors.dmPrimary
                                : AppColors.primary,
                          ),
                          title: Text(
                            "Add '$cityName' as new city",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isDark
                                  ? AppColors.dmPrimary
                                  : AppColors.primary,
                            ),
                          ),
                          onTap: () async {
                            _controller.text = cityName;
                            await _handleAddNew(cityName);
                          },
                        );
                      }

                      final name = item['name'] as String? ?? '';
                      final country = item['country'] as String? ?? '';
                      return ListTile(
                        leading: Icon(
                          Icons.location_city_outlined,
                          color: isDark
                              ? AppColors.dmTextSecondary
                              : AppColors.textSecondary,
                        ),
                        title: Text(
                          name,
                          style: theme.textTheme.bodyMedium,
                        ),
                        subtitle: Text(
                          country,
                          style: theme.textTheme.bodySmall,
                        ),
                        onTap: () => onSelected(item),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
        if (widget.errorText != null)
          Padding(
            padding: const EdgeInsets.only(
              top: AppSpacing.xs,
              left: AppSpacing.base,
            ),
            child: Text(
              widget.errorText!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.red.shade700,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}
