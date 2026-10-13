import 'package:flutter/material.dart';

import '../../../data/models/database_codes.dart';
import '../../../data/models/household.dart';
import '../../../data/models/member.dart';
import '../../../data/repositories/household_repository.dart';
import '../../../data/repositories/member_repository.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/member_general_details_service.dart';
import '../domain/household_edit_service.dart';
import '../domain/member_health_marriage_service.dart';
import '../domain/member_management_service.dart';
import '../domain/member_relationship_service.dart';
import '../domain/child_birth_details_service.dart';
import '../domain/family_planning_service.dart';
import '../domain/pregnancy_details_service.dart';
import 'household_localization_labels.dart';
import 'household_edit_screen.dart';
import 'member_general_details_screen.dart';
import 'member_health_marriage_screen.dart';
import 'member_relationships_screen.dart';
import 'member_form_screen.dart';
import 'pregnancy_details_screen.dart';
import 'child_birth_details_screen.dart';
import 'family_planning_screen.dart';

class HouseholdProfileScreen extends StatefulWidget {
  const HouseholdProfileScreen({
    required this.household,
    required this.householdRepository,
    required this.memberRepository,
    required this.memberService,
    super.key,
  });

  final Household household;
  final HouseholdRepository householdRepository;
  final MemberRepository memberRepository;
  final MemberManagementService memberService;

  @override
  State<HouseholdProfileScreen> createState() => _HouseholdProfileScreenState();
}

class _HouseholdProfileScreenState extends State<HouseholdProfileScreen> {
  late Household _household;
  late Future<List<Member>> _members;
  bool _showArchived = false;

  @override
  void initState() {
    super.initState();
    _household = widget.household;
    _showArchived = widget.household.isArchived;
    _members = _loadMembers();
  }

  Future<List<Member>> _loadMembers() => widget.memberRepository
      .listForHousehold(_household.id, includeArchived: _showArchived);

  Future<void> _refresh() async {
    setState(() => _members = _loadMembers());
  }

  Future<void> _openMemberForm({Member? member}) async {
    final saved = await Navigator.of(context).push<Member>(
      MaterialPageRoute(
        builder: (_) => MemberFormScreen(
          householdId: _household.id,
          memberService: widget.memberService,
          member: member,
        ),
      ),
    );
    if (!mounted || saved == null) return;
    await _refresh();
    if (!mounted) return;
    final strings = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          member == null ? strings.memberAdded : strings.memberUpdated,
        ),
      ),
    );
  }

  Future<void> _openGeneralDetails(Member member) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => MemberGeneralDetailsScreen(
          member: member,
          service: MemberGeneralDetailsService(widget.memberRepository),
        ),
      ),
    );
  }

  Future<void> _openPregnancyDetails(Member member) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => PregnancyDetailsScreen(
          member: member,
          service: PregnancyDetailsService(widget.memberRepository),
        ),
      ),
    );
  }

  Future<void> _openChildBirthDetails(Member member) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => ChildBirthDetailsScreen(
          member: member,
          service: ChildBirthDetailsService(widget.memberRepository),
        ),
      ),
    );
  }

  Future<void> _openHealthMarriageDetails(Member member) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => MemberHealthMarriageScreen(
          member: member,
          service: MemberHealthMarriageService(widget.memberRepository),
        ),
      ),
    );
  }

  Future<void> _openFamilyPlanning(Member member) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => FamilyPlanningScreen(
          member: member,
          service: FamilyPlanningService(widget.memberRepository),
        ),
      ),
    );
  }

  Future<void> _openRelationships(Member member) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => MemberRelationshipsScreen(
          member: member,
          service: MemberRelationshipService(widget.memberRepository),
        ),
      ),
    );
  }

  Future<void> _editHousehold() async {
    final updated = await Navigator.of(context).push<Household>(
      MaterialPageRoute(
        builder: (_) => HouseholdEditScreen(
          household: _household,
          service: HouseholdEditService(widget.householdRepository),
        ),
      ),
    );
    if (!mounted || updated == null) return;
    setState(() => _household = updated);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.householdChangesSaved),
      ),
    );
  }

  Future<bool> _confirmHouseholdAction({
    required String title,
    required String message,
    required String confirmLabel,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  Future<void> _archiveHousehold() async {
    final strings = AppLocalizations.of(context)!;
    if (!await _confirmHouseholdAction(
      title: strings.archiveHouseholdTitle,
      message: strings.archiveHouseholdMessage,
      confirmLabel: strings.archiveHouseholdAction,
    )) {
      return;
    }
    try {
      final archived = await widget.householdRepository.archive(_household.id);
      if (!archived) throw StateError('Household is no longer active.');
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(strings.householdActionFailed)));
    }
  }

  Future<void> _restoreHousehold() async {
    final strings = AppLocalizations.of(context)!;
    if (!await _confirmHouseholdAction(
      title: strings.restoreHouseholdTitle,
      message: strings.restoreHouseholdMessage,
      confirmLabel: strings.restoreHouseholdAction,
    )) {
      return;
    }
    try {
      final restored = await widget.householdRepository.restore(_household.id);
      if (!restored) throw StateError('Household is no longer archived.');
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(strings.householdActionFailed)));
    }
  }

  Future<void> _reviewRationCard() async {
    final strings = AppLocalizations.of(context)!;
    final selected = await showDialog<RationCardType>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(strings.reviewRationCardTitle),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Text(
              strings.reviewRationCardMessage(
                rationCardLabel(strings, _household.rationCardType),
              ),
            ),
          ),
          for (final type in RationCardType.selectableValues)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, type),
              child: Text(rationCardLabel(strings, type)),
            ),
        ],
      ),
    );
    if (selected == null) return;

    try {
      final updated = await widget.householdRepository.updateRationCardType(
        _household.id,
        selected,
      );
      if (!updated) throw StateError('Household is no longer active.');
      if (!mounted) return;
      setState(() {
        _household = _household.copyWith(
          rationCardType: selected,
          rationCardReviewRequired: false,
          updatedAt: DateTime.now().toUtc(),
        );
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(strings.rationCardUpdated)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.rationCardUpdateFailed)));
    }
  }

  Future<bool> _confirmArchive() async {
    final strings = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.removeMemberTitle),
        content: Text(strings.removeMemberMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(strings.cancel),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, true),
            child: Text(strings.confirmRemoveMember),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  Future<void> _archiveMember(Member member) async {
    if (!await _confirmArchive()) return;
    try {
      await widget.memberService.archiveMember(member);
      await _refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.memberRemoved)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.memberActionFailed),
        ),
      );
    }
  }

  Future<void> _restoreMember(Member member) async {
    try {
      await widget.memberService.restoreMember(member);
      await _refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.memberRestored)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.memberActionFailed),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _household.houseName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          PopupMenuButton<_HouseholdAction>(
            onSelected: (action) {
              switch (action) {
                case _HouseholdAction.edit:
                  _editHousehold();
                case _HouseholdAction.archive:
                  _archiveHousehold();
                case _HouseholdAction.restore:
                  _restoreHousehold();
              }
            },
            itemBuilder: (context) => [
              if (!_household.isArchived)
                PopupMenuItem(
                  value: _HouseholdAction.edit,
                  child: Text(strings.editHouseholdTitle),
                ),
              PopupMenuItem(
                value: _household.isArchived
                    ? _HouseholdAction.restore
                    : _HouseholdAction.archive,
                child: Text(
                  _household.isArchived
                      ? strings.restoreHouseholdAction
                      : strings.archiveHouseholdAction,
                ),
              ),
            ],
          ),
        ],
      ),
      body: FutureBuilder<List<Member>>(
        future: _members,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  strings.memberActionFailed,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final members = snapshot.data ?? const <Member>[];
          final activeMembers = members
              .where((member) => !member.isArchived)
              .toList(growable: false);
          final archivedMembers = members
              .where((member) => member.isArchived)
              .toList(growable: false);
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            children: [
              _householdDetails(context),
              const SizedBox(height: 24),
              Text(
                strings.familyMembers,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              for (final member in activeMembers) _memberTile(context, member),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: Text(strings.showArchivedMembers),
                value: _showArchived,
                onChanged: (value) {
                  setState(() {
                    _showArchived = value;
                    _members = _loadMembers();
                  });
                },
              ),
              if (_showArchived && archivedMembers.isNotEmpty) ...[
                const Divider(height: 24),
                Text(
                  strings.archivedMembers,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                for (final member in archivedMembers)
                  _memberTile(context, member, archived: true),
              ],
            ],
          );
        },
      ),
      floatingActionButton: _household.isArchived
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _openMemberForm(),
              icon: const Icon(Icons.person_add_alt_1),
              label: Text(strings.addMemberAction),
            ),
    );
  }

  Widget _householdDetails(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final household = _household;
    final lines = <String>[
      if (household.houseNumber != null)
        '${strings.houseNumberLabel}: ${household.houseNumber}',
      household.addressLine,
      if (household.locality != null) household.locality!,
      '${rationCardLabel(strings, household.rationCardType)} · '
          '${houseTypeLabel(strings, household.houseType)} · '
          '${strings.wellOwnership}: '
          '${household.hasOwnWell ? strings.yes : strings.no}',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          household.houseName,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        for (final line in lines)
          Padding(padding: const EdgeInsets.only(bottom: 4), child: Text(line)),
        if (household.rationCardReviewRequired && !household.isArchived) ...[
          const SizedBox(height: 8),
          Text(
            strings.rationCardReviewRequired,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              onPressed: _reviewRationCard,
              icon: const Icon(Icons.fact_check_outlined),
              label: Text(strings.reviewRationCardAction),
            ),
          ),
        ],
      ],
    );
  }

  Widget _memberTile(
    BuildContext context,
    Member member, {
    bool archived = false,
  }) {
    final strings = AppLocalizations.of(context)!;
    final details = <String>[
      MaterialLocalizations.of(context).formatMediumDate(member.dateOfBirth),
      genderLabel(strings, member.gender),
      relationshipLabel(strings, member.relationshipToHead),
      if (member.personPhone != null) member.personPhone!,
    ];
    return ListTile(
      key: ValueKey('member-${member.id}'),
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: CircleAvatar(
        backgroundColor: member.isHead
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Icon(member.isHead ? Icons.star_outline : Icons.person_outline),
      ),
      title: Text(
        member.fullName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        details.join(' · '),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: archived
          ? IconButton(
              tooltip: strings.restoreMemberAction,
              onPressed: () => _restoreMember(member),
              icon: const Icon(Icons.restore),
            )
          : PopupMenuButton<_MemberAction>(
              tooltip: strings.editMemberTitle,
              onSelected: (action) {
                if (action == _MemberAction.edit) {
                  _openMemberForm(member: member);
                } else if (action == _MemberAction.generalDetails) {
                  _openGeneralDetails(member);
                } else if (action == _MemberAction.pregnancyDetails) {
                  _openPregnancyDetails(member);
                } else if (action == _MemberAction.childBirthDetails) {
                  _openChildBirthDetails(member);
                } else if (action == _MemberAction.healthMarriageDetails) {
                  _openHealthMarriageDetails(member);
                } else if (action == _MemberAction.familyPlanning) {
                  _openFamilyPlanning(member);
                } else if (action == _MemberAction.relationships) {
                  _openRelationships(member);
                } else {
                  _archiveMember(member);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: _MemberAction.edit,
                  child: Text(strings.editMemberTitle),
                ),
                PopupMenuItem(
                  value: _MemberAction.generalDetails,
                  child: Text(strings.memberGeneralDetailsTitle),
                ),
                PopupMenuItem(
                  value: _MemberAction.pregnancyDetails,
                  child: Text(strings.pregnancyDetailsTitle),
                ),
                PopupMenuItem(
                  value: _MemberAction.childBirthDetails,
                  child: Text(strings.childBirthDetailsTitle),
                ),
                PopupMenuItem(
                  value: _MemberAction.healthMarriageDetails,
                  child: Text(strings.healthMarriageDetailsTitle),
                ),
                PopupMenuItem(
                  value: _MemberAction.familyPlanning,
                  child: Text(strings.familyPlanningTitle),
                ),
                PopupMenuItem(
                  value: _MemberAction.relationships,
                  child: Text(strings.memberRelationshipsTitle),
                ),
                if (!member.isHead)
                  PopupMenuItem(
                    value: _MemberAction.archive,
                    child: Text(strings.removeMemberAction),
                  ),
              ],
            ),
    );
  }
}

enum _MemberAction {
  edit,
  generalDetails,
  pregnancyDetails,
  childBirthDetails,
  healthMarriageDetails,
  familyPlanning,
  relationships,
  archive,
}

enum _HouseholdAction { edit, archive, restore }
