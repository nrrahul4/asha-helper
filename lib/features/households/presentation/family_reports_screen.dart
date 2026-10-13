import 'package:flutter/material.dart';

import '../../../data/models/database_codes.dart';
import '../../../data/models/family_report_summary.dart';
import '../../../data/repositories/family_report_repository.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'household_localization_labels.dart';

class FamilyReportsScreen extends StatefulWidget {
  const FamilyReportsScreen({required this.repository, super.key});

  final FamilyReportRepository repository;

  @override
  State<FamilyReportsScreen> createState() => _FamilyReportsScreenState();
}

class _FamilyReportsScreenState extends State<FamilyReportsScreen> {
  late Future<FamilyReportSummary> _summary;

  @override
  void initState() {
    super.initState();
    _summary = widget.repository.load();
  }

  void _refresh() {
    setState(() => _summary = widget.repository.load());
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.reportsTitle),
        actions: [
          IconButton(
            tooltip: strings.refreshReports,
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<FamilyReportSummary>(
        future: _summary,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || snapshot.data == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  strings.reportsLoadFailed,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          final summary = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              Row(
                children: [
                  Expanded(
                    child: _TotalCard(
                      label: strings.householdsTitle,
                      value: summary.householdCount,
                      icon: Icons.home_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TotalCard(
                      label: strings.familyMembers,
                      value: summary.memberCount,
                      icon: Icons.people_outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _countSection<Gender>(
                title: strings.gender,
                values: summary.genderCounts,
                labelFor: (gender) => genderLabel(strings, gender),
              ),
              _countSection<FamilyAgeBand>(
                title: strings.ageBandDistribution,
                values: summary.ageBandCounts,
                labelFor: (band) => switch (band) {
                  FamilyAgeBand.zeroToFive => strings.ageBandZeroToFive,
                  FamilyAgeBand.sixToSeventeen => strings.ageBandSixToSeventeen,
                  FamilyAgeBand.eighteenToFiftyNine =>
                    strings.ageBandEighteenToFiftyNine,
                  FamilyAgeBand.sixtyPlus => strings.ageBandSixtyPlus,
                },
              ),
              _countSection<RationCardType>(
                title: strings.rationCardType,
                values: summary.rationCardCounts,
                labelFor: (card) => rationCardLabel(strings, card),
              ),
              _countSection<HouseType>(
                title: strings.houseType,
                values: summary.houseTypeCounts,
                labelFor: (type) => houseTypeLabel(strings, type),
              ),
              _countSection<bool>(
                title: strings.wellOwnership,
                values: summary.wellOwnershipCounts,
                labelFor: (hasWell) => hasWell ? strings.yes : strings.no,
              ),
              const SizedBox(height: 12),
              Text(
                strings.reportsArchiveNotice,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _countSection<T>({
    required String title,
    required Map<T, int> values,
    required String Function(T value) labelFor,
  }) => Card(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          for (final entry in values.entries)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(labelFor(entry.key)),
              trailing: Text('${entry.value}'),
            ),
        ],
      ),
    ),
  );
}

class _TotalCard extends StatelessWidget {
  const _TotalCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final int value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 12),
          Text('$value', style: Theme.of(context).textTheme.headlineMedium),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    ),
  );
}
