import 'package:flutter/material.dart';

import '../../../data/models/database_codes.dart';
import '../../../data/models/household.dart';
import '../../../data/repositories/member_repository.dart';
import '../../../data/repositories/household_repository.dart';
import '../../../data/repositories/family_report_repository.dart';
import '../../../data/repositories/local_backup_repository.dart';
import '../../backup/domain/encrypted_backup_service.dart';
import '../../backup/presentation/backup_screen.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/household_registration_service.dart';
import '../domain/member_management_service.dart';
import '../domain/member_search_service.dart';
import 'household_localization_labels.dart';
import 'household_profile_screen.dart';
import 'member_search_screen.dart';
import 'household_registration_screen.dart';
import 'family_reports_screen.dart';

class HouseholdListScreen extends StatefulWidget {
  const HouseholdListScreen({
    required this.householdRepository,
    required this.registrationService,
    required this.memberRepository,
    required this.memberService,
    required this.memberSearchService,
    required this.reportsRepository,
    required this.backupRepository,
    required this.backupEncryptionService,
    super.key,
  });

  final HouseholdRepository householdRepository;
  final HouseholdRegistrationService registrationService;
  final MemberRepository memberRepository;
  final MemberManagementService memberService;
  final MemberSearchService memberSearchService;
  final FamilyReportRepository reportsRepository;
  final LocalBackupRepository backupRepository;
  final EncryptedBackupService backupEncryptionService;

  @override
  State<HouseholdListScreen> createState() => _HouseholdListScreenState();
}

class _HouseholdListScreenState extends State<HouseholdListScreen> {
  late Future<List<Household>> _households;
  bool _showArchived = false;

  @override
  void initState() {
    super.initState();
    _households = widget.householdRepository.list();
  }

  Future<void> _openRegistration() async {
    final household = await Navigator.of(context).push<Household>(
      MaterialPageRoute(
        builder: (_) => HouseholdRegistrationScreen(
          registrationService: widget.registrationService,
        ),
      ),
    );
    if (!mounted || household == null) return;
    setState(() {
      _households = widget.householdRepository.list(
        includeArchived: _showArchived,
      );
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.householdSaved)),
    );
  }

  Future<void> _openProfile(Household household) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => HouseholdProfileScreen(
          household: household,
          householdRepository: widget.householdRepository,
          memberRepository: widget.memberRepository,
          memberService: widget.memberService,
        ),
      ),
    );
    if (!mounted || changed != true) return;
    setState(() {
      _households = widget.householdRepository.list(
        includeArchived: _showArchived,
      );
    });
  }

  void _toggleArchived() {
    setState(() {
      _showArchived = !_showArchived;
      _households = widget.householdRepository.list(
        includeArchived: _showArchived,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.householdsTitle),
        actions: [
          IconButton(
            tooltip: strings.backupTitle,
            onPressed: () => Navigator.of(context).push<void>(
              MaterialPageRoute(
                builder: (_) => BackupScreen(
                  repository: widget.backupRepository,
                  encryptionService: widget.backupEncryptionService,
                ),
              ),
            ),
            icon: const Icon(Icons.security_outlined),
          ),
          IconButton(
            tooltip: strings.reportsTitle,
            onPressed: () => Navigator.of(context).push<void>(
              MaterialPageRoute(
                builder: (_) =>
                    FamilyReportsScreen(repository: widget.reportsRepository),
              ),
            ),
            icon: const Icon(Icons.bar_chart_outlined),
          ),
          IconButton(
            tooltip: _showArchived
                ? strings.hideArchivedHouseholds
                : strings.showArchivedHouseholds,
            onPressed: _toggleArchived,
            icon: Icon(
              _showArchived
                  ? Icons.inventory_2_outlined
                  : Icons.archive_outlined,
            ),
          ),
          IconButton(
            tooltip: strings.searchPeopleTitle,
            onPressed: () => Navigator.of(context).push<void>(
              MaterialPageRoute(
                builder: (_) => MemberSearchScreen(
                  householdRepository: widget.householdRepository,
                  memberRepository: widget.memberRepository,
                  memberSearchService: widget.memberSearchService,
                  memberService: widget.memberService,
                  backupRepository: widget.backupRepository,
                  backupEncryptionService: widget.backupEncryptionService,
                ),
              ),
            ),
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: FutureBuilder<List<Household>>(
        future: _households,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  strings.householdListLoadFailed,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final households = snapshot.data ?? const <Household>[];
          if (households.isEmpty) {
            return _EmptyHouseholdList(
              message: strings.noHouseholds,
              actionLabel: strings.addFirstHousehold,
              onAdd: _openRegistration,
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            itemCount: households.length,
            separatorBuilder: (_, _) => const Divider(height: 1, indent: 72),
            itemBuilder: (context, index) => _HouseholdListTile(
              household: households[index],
              onTap: () => _openProfile(households[index]),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openRegistration,
        icon: const Icon(Icons.add),
        label: Text(strings.registerHouseholdAction),
      ),
    );
  }
}

class _HouseholdListTile extends StatelessWidget {
  const _HouseholdListTile({required this.household, required this.onTap});

  final Household household;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final details = <String>[
      if (household.houseNumber != null)
        strings.houseNumberSummary(household.houseNumber!),
      household.addressLine,
      rationCardLabel(strings, household.rationCardType),
    ];
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      leading: const CircleAvatar(child: Icon(Icons.home_outlined)),
      title: Text(
        household.houseName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        details.join(' · '),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: household.isArchived
          ? Tooltip(
              message: strings.archivedStatus,
              child: const Icon(Icons.archive_outlined, size: 20),
            )
          : household.rationCardReviewRequired
          ? Tooltip(
              message: strings.rationCardReviewRequired,
              child: Icon(
                Icons.warning_amber_rounded,
                color: Theme.of(context).colorScheme.error,
              ),
            )
          : household.recordStatus == HouseholdRecordStatus.draft
          ? Text(
              strings.draftStatus,
              style: Theme.of(context).textTheme.labelMedium,
            )
          : Tooltip(
              message: strings.completeStatus,
              child: const Icon(Icons.check_circle_outline, size: 20),
            ),
    );
  }
}

class _EmptyHouseholdList extends StatelessWidget {
  const _EmptyHouseholdList({
    required this.message,
    required this.actionLabel,
    required this.onAdd,
  });

  final String message;
  final String actionLabel;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.holiday_village_outlined,
            size: 40,
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: Text(actionLabel),
          ),
        ],
      ),
    ),
  );
}
