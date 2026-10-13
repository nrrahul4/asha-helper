import 'package:flutter/material.dart';

import '../../../data/models/database_codes.dart';
import '../../../data/models/household.dart';
import '../../../data/repositories/household_repository.dart';
import '../../../data/repositories/local_backup_repository.dart';
import '../../../data/repositories/member_repository.dart';
import '../../backup/domain/encrypted_backup_service.dart';
import '../../backup/presentation/backup_screen.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/member_management_service.dart';
import '../domain/member_search_filters.dart';
import '../domain/member_search_result.dart';
import '../domain/member_search_service.dart';
import 'household_localization_labels.dart';
import 'household_profile_screen.dart';

class MemberSearchScreen extends StatefulWidget {
  const MemberSearchScreen({
    required this.householdRepository,
    required this.memberRepository,
    required this.memberSearchService,
    required this.memberService,
    this.backupRepository,
    this.backupEncryptionService,
    super.key,
  });

  final HouseholdRepository householdRepository;
  final MemberRepository memberRepository;
  final MemberSearchService memberSearchService;
  final MemberManagementService memberService;
  final LocalBackupRepository? backupRepository;
  final EncryptedBackupService? backupEncryptionService;

  @override
  State<MemberSearchScreen> createState() => _MemberSearchScreenState();
}

class _MemberSearchScreenState extends State<MemberSearchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _queryController = TextEditingController();
  final _minimumAgeController = TextEditingController();
  final _maximumAgeController = TextEditingController();
  late final Future<List<Household>> _households;
  final Set<Gender> _genders = {};
  final Set<RationCardType> _rationCardTypes = {};
  String _householdId = '';
  bool _currentlyPregnantOnly = false;
  List<MemberSearchResult> _results = const [];
  bool _hasSearched = false;
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    _households = widget.householdRepository.list();
  }

  @override
  void dispose() {
    _queryController.dispose();
    _minimumAgeController.dispose();
    _maximumAgeController.dispose();
    super.dispose();
  }

  String? _validateAge(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final age = int.tryParse(value.trim());
    if (age == null || age < 0) {
      return AppLocalizations.of(context)!.invalidAge;
    }
    return null;
  }

  String? _validateAgeRange(String? _) {
    final minimumText = _minimumAgeController.text.trim();
    final maximumText = _maximumAgeController.text.trim();
    if (minimumText.isEmpty || maximumText.isEmpty) return null;
    final minimum = int.tryParse(minimumText);
    final maximum = int.tryParse(maximumText);
    if (minimum != null && maximum != null && minimum > maximum) {
      return AppLocalizations.of(context)!.invalidAgeRange;
    }
    return null;
  }

  Future<void> _applyFilters() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _searching = true);
    try {
      final results = await widget.memberSearchService.search(
        MemberSearchFilters(
          query: _queryController.text,
          genders: Set<Gender>.of(_genders),
          minimumAge: int.tryParse(_minimumAgeController.text.trim()),
          maximumAge: int.tryParse(_maximumAgeController.text.trim()),
          rationCardTypes: Set<RationCardType>.of(_rationCardTypes),
          householdId: _householdId.isEmpty ? null : _householdId,
          currentlyPregnantOnly: _currentlyPregnantOnly,
        ),
      );
      if (!mounted) return;
      setState(() {
        _results = results;
        _hasSearched = true;
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.memberSearchFailed),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  void _resetFilters() {
    _formKey.currentState?.reset();
    setState(() {
      _queryController.clear();
      _minimumAgeController.clear();
      _maximumAgeController.clear();
      _genders.clear();
      _rationCardTypes.clear();
      _householdId = '';
      _currentlyPregnantOnly = false;
      _results = const [];
      _hasSearched = false;
    });
  }

  Future<void> _openProfile(MemberSearchResult result) async {
    final household = await widget.householdRepository.getById(
      result.member.householdId,
    );
    if (!mounted || household == null) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => HouseholdProfileScreen(
          household: household,
          householdRepository: widget.householdRepository,
          memberRepository: widget.memberRepository,
          memberService: widget.memberService,
        ),
      ),
    );
    if (mounted && _hasSearched) _applyFilters();
  }

  void _exportResults() {
    final repository = widget.backupRepository;
    final encryptionService = widget.backupEncryptionService;
    if (repository == null || encryptionService == null) return;
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => BackupScreen(
          repository: repository,
          encryptionService: encryptionService,
          selectedMemberIds: {for (final result in _results) result.member.id},
          csvOnly: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.searchPeopleTitle),
        actions: [
          if (_hasSearched &&
              _results.isNotEmpty &&
              widget.backupRepository != null &&
              widget.backupEncryptionService != null)
            IconButton(
              tooltip: strings.csvExportMatchesTitle,
              onPressed: _exportResults,
              icon: const Icon(Icons.download_outlined),
            ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              TextField(
                key: const Key('people-search-field'),
                controller: _queryController,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _applyFilters(),
                decoration: InputDecoration(
                  labelText: strings.searchPeopleTitle,
                  hintText: strings.searchPeopleHint,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    tooltip: strings.resetFilters,
                    onPressed: _queryController.clear,
                    icon: const Icon(Icons.close),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              _sectionTitle(context, strings.gender),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final gender in Gender.values)
                    FilterChip(
                      key: ValueKey('gender-filter-${gender.code}'),
                      label: Text(genderLabel(strings, gender)),
                      selected: _genders.contains(gender),
                      onSelected: (selected) => setState(() {
                        if (selected) {
                          _genders.add(gender);
                        } else {
                          _genders.remove(gender);
                        }
                      }),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              _sectionTitle(context, strings.ageRange),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      key: const Key('minimum-age-field'),
                      controller: _minimumAgeController,
                      keyboardType: TextInputType.number,
                      validator: _validateAge,
                      decoration: InputDecoration(
                        labelText: strings.minimumAge,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      key: const Key('maximum-age-field'),
                      controller: _maximumAgeController,
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          _validateAge(value) ?? _validateAgeRange(value),
                      decoration: InputDecoration(
                        labelText: strings.maximumAge,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _sectionTitle(context, strings.pregnancyStatus),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  FilterChip(
                    key: const Key('currently-pregnant-filter'),
                    label: Text(strings.currentlyPregnant),
                    selected: _currentlyPregnantOnly,
                    onSelected: (selected) =>
                        setState(() => _currentlyPregnantOnly = selected),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _sectionTitle(context, strings.rationCardTypes),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final type in RationCardType.selectableValues)
                    FilterChip(
                      key: ValueKey('card-filter-${type.code}'),
                      label: Text(rationCardLabel(strings, type)),
                      selected: _rationCardTypes.contains(type),
                      onSelected: (selected) => setState(() {
                        if (selected) {
                          _rationCardTypes.add(type);
                        } else {
                          _rationCardTypes.remove(type);
                        }
                      }),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              FutureBuilder<List<Household>>(
                future: _households,
                builder: (context, snapshot) {
                  final households = snapshot.data ?? const <Household>[];
                  return DropdownButtonFormField<String>(
                    key: ValueKey('household-filter-$_householdId'),
                    initialValue: _householdId,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: strings.householdFilter,
                    ),
                    items: [
                      DropdownMenuItem(
                        value: '',
                        child: Text(strings.allHouseholds),
                      ),
                      for (final household in households)
                        DropdownMenuItem(
                          value: household.id,
                          child: Text(
                            household.houseNumber == null
                                ? household.houseName
                                : '${household.houseName} · ${household.houseNumber}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: (value) =>
                        setState(() => _householdId = value ?? ''),
                  );
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      key: const Key('reset-search-filters-button'),
                      onPressed: _resetFilters,
                      icon: const Icon(Icons.restart_alt),
                      label: Text(strings.resetFilters),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      key: const Key('apply-search-filters-button'),
                      onPressed: _searching ? null : _applyFilters,
                      icon: _searching
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.filter_list),
                      label: Text(strings.applyFilters),
                    ),
                  ),
                ],
              ),
              if (_hasSearched) ...[
                const Divider(height: 32),
                Text(
                  strings.matchingPeople,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (_results.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      strings.noSearchResults,
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  for (final result in _results) _resultTile(context, result),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) => Padding(
    padding: const EdgeInsets.only(left: 2),
    child: Text(title, style: Theme.of(context).textTheme.titleMedium),
  );

  Widget _resultTile(BuildContext context, MemberSearchResult result) {
    final strings = AppLocalizations.of(context)!;
    final details = <String>[
      strings.searchAge(result.age),
      genderLabel(strings, result.member.gender),
      relationshipLabel(strings, result.member.relationshipToHead),
      rationCardLabel(strings, result.rationCardType),
    ];
    return ListTile(
      key: ValueKey('search-result-${result.member.id}'),
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      leading: CircleAvatar(
        child: Icon(
          result.member.isHead ? Icons.star_outline : Icons.person_outline,
        ),
      ),
      title: Text(result.member.fullName),
      subtitle: Text(
        [
          result.householdName,
          if (result.houseNumber != null) result.houseNumber!,
          details.join(' · '),
        ].join(' · '),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () => _openProfile(result),
    );
  }
}
