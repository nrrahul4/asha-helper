import 'package:flutter/material.dart';

import '../../../data/models/member.dart';
import '../../../data/models/member_relationship.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/member_relationship_service.dart';

class MemberRelationshipsScreen extends StatefulWidget {
  const MemberRelationshipsScreen({
    required this.member,
    required this.service,
    super.key,
  });

  final Member member;
  final MemberRelationshipService service;

  @override
  State<MemberRelationshipsScreen> createState() =>
      _MemberRelationshipsScreenState();
}

class _MemberRelationshipsScreenState extends State<MemberRelationshipsScreen> {
  late final Future<void> _load;
  List<Member> _members = const [];
  List<MemberRelationship> _relationships = const [];
  MemberRelationshipType _type = MemberRelationshipType.spouseOf;
  String? _otherMemberId;
  bool _memberIsMother = true;
  Object? _loadError;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load = _loadData();
  }

  Future<void> _loadData() async {
    try {
      _members = await widget.service.householdMembers(
        widget.member.householdId,
      );
      _relationships = await widget.service.forMember(widget.member.id);
    } catch (error) {
      _loadError = error;
      rethrow;
    }
  }

  Future<void> _refresh() async {
    setState(() {});
    await _loadData();
    if (mounted) setState(() {});
  }

  Future<void> _addRelationship() async {
    final otherId = _otherMemberId;
    if (otherId == null || otherId == widget.member.id) return;
    setState(() => _saving = true);
    try {
      await widget.service.add(
        memberId: widget.member.id,
        otherMemberId: otherId,
        type: _type,
        memberIsMother: _memberIsMother,
        now: DateTime.now(),
      );
      if (!mounted) return;
      await _refresh();
      if (!mounted) return;
      setState(() => _otherMemberId = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.relationshipSaved),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.relationshipSaveFailed),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _endRelationship(MemberRelationship relationship) async {
    try {
      final ended = await widget.service.end(relationship.id, DateTime.now());
      if (!ended) throw StateError('Relationship is no longer active.');
      if (!mounted) return;
      await _refresh();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.relationshipUpdateFailed),
        ),
      );
    }
  }

  String _typeLabel(AppLocalizations strings, MemberRelationshipType type) =>
      switch (type) {
        MemberRelationshipType.motherOf => strings.relationshipMotherOf,
        MemberRelationshipType.spouseOf => strings.relationshipSpouseOf,
      };

  String _relationshipSummary(
    AppLocalizations strings,
    MemberRelationship relationship,
    Map<String, Member> membersById,
  ) {
    final currentIsFrom = relationship.fromMemberId == widget.member.id;
    final otherId = currentIsFrom
        ? relationship.toMemberId
        : relationship.fromMemberId;
    final otherName = membersById[otherId]?.fullName ?? strings.unknownMember;
    final type =
        relationship.type == MemberRelationshipType.motherOf && !currentIsFrom
        ? strings.relationshipIsMotherOf
        : _typeLabel(strings, relationship.type);
    final date = relationship.validTo == null
        ? strings.relationshipActive
        : strings.relationshipEnded(
            MaterialLocalizations.of(context)
                .formatMediumDate(relationship.validTo!),
          );
    return '$type · $otherName · $date';
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(strings.memberRelationshipsTitle)),
      body: FutureBuilder<void>(
        future: _load,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || _loadError != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  strings.relationshipLoadFailed,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          final selectableMembers = _members
              .where((member) => member.id != widget.member.id)
              .toList(growable: false);
          final membersById = {
            for (final member in _members) member.id: member,
          };
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            children: [
              Text(
                strings.relationshipsSameHouseholdNotice,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<MemberRelationshipType>(
                initialValue: _type,
                decoration: InputDecoration(
                  labelText: strings.relationshipType,
                ),
                items: MemberRelationshipType.values
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(_typeLabel(strings, type)),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (type) {
                  if (type != null) setState(() => _type = type);
                },
              ),
              if (_type == MemberRelationshipType.motherOf) ...[
                const SizedBox(height: 12),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: Text(strings.memberIsMother),
                  value: _memberIsMother,
                  onChanged: (value) => setState(() => _memberIsMother = value),
                ),
              ],
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _otherMemberId,
                decoration: InputDecoration(
                  labelText: strings.relationshipOtherMember,
                ),
                items: selectableMembers
                    .map(
                      (member) => DropdownMenuItem(
                        value: member.id,
                        child: Text(member.fullName),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (id) => setState(() => _otherMemberId = id),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _saving ? null : _addRelationship,
                child: _saving
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(strings.addRelationship),
              ),
              if (_relationships.isNotEmpty) ...[
                const Divider(height: 32),
                Text(
                  strings.memberRelationshipsTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                for (final relationship in _relationships)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      _relationshipSummary(strings, relationship, membersById),
                    ),
                    trailing: relationship.isActive
                        ? IconButton(
                            tooltip: strings.endRelationship,
                            onPressed: () => _endRelationship(relationship),
                            icon: const Icon(Icons.link_off),
                          )
                        : null,
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}
