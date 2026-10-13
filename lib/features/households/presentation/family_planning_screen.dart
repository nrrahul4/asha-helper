import 'package:flutter/material.dart';

import '../../../data/models/family_planning_record.dart';
import '../../../data/models/member.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/family_planning_input.dart';
import '../domain/family_planning_service.dart';

class FamilyPlanningScreen extends StatefulWidget {
  const FamilyPlanningScreen({
    required this.member,
    required this.service,
    super.key,
  });

  final Member member;
  final FamilyPlanningService service;

  @override
  State<FamilyPlanningScreen> createState() => _FamilyPlanningScreenState();
}

class _FamilyPlanningScreenState extends State<FamilyPlanningScreen> {
  final _formKey = GlobalKey<FormState>();
  final _remarksController = TextEditingController();
  late final Future<void> _load;
  List<FamilyPlanningRecord> _history = const [];
  PregnancyAvoidanceIntention _intention = PregnancyAvoidanceIntention.unknown;
  CurrentMethodUseStatus _methodUseStatus = CurrentMethodUseStatus.unknown;
  FamilyPlanningType? _type;
  TemporaryFamilyPlanningMethod? _temporaryMethod;
  DateTime? _actionDate;
  bool _saving = false;
  Object? _loadError;

  @override
  void initState() {
    super.initState();
    _load = _loadHistory();
  }

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    try {
      _history = await widget.service.history(widget.member.id);
      if (!mounted || _history.isEmpty) return;
      final latest = _history.first;
      _intention = latest.intention;
      _methodUseStatus = latest.methodUseStatus;
      _type = latest.type;
      _temporaryMethod = latest.temporaryMethod;
      _actionDate = latest.actionDate;
      _remarksController.text = latest.remarks ?? '';
    } catch (error) {
      _loadError = error;
      rethrow;
    }
  }

  Future<void> _selectActionDate() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final selected = await showDatePicker(
      context: context,
      initialDate: _actionDate ?? today,
      firstDate: DateTime(1900),
      lastDate: today,
    );
    if (selected != null && mounted) {
      setState(() => _actionDate = selected);
    }
  }

  void _setMethodUseStatus(CurrentMethodUseStatus? status) {
    if (status == null) return;
    setState(() {
      _methodUseStatus = status;
      if (status != CurrentMethodUseStatus.yes) {
        _type = null;
        _temporaryMethod = null;
        _actionDate = null;
      }
    });
  }

  void _setType(FamilyPlanningType? type) {
    setState(() {
      _type = type;
      if (type != FamilyPlanningType.temporary) _temporaryMethod = null;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await widget.service.save(
        memberId: widget.member.id,
        now: DateTime.now(),
        input: FamilyPlanningInput(
          intention: _intention,
          methodUseStatus: _methodUseStatus,
          type: _type,
          temporaryMethod: _temporaryMethod,
          actionDate: _actionDate,
          remarks: _remarksController.text,
        ),
      );
      final history = await widget.service.history(widget.member.id);
      if (!mounted) return;
      setState(() => _history = history);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.familyPlanningSaved),
        ),
      );
    } on FamilyPlanningValidationException catch (error) {
      _showValidationError(error);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.familyPlanningSaveFailed),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showValidationError(FamilyPlanningValidationException error) {
    final strings = AppLocalizations.of(context)!;
    final issue = error.issues.values.first;
    final message = switch (issue) {
      FamilyPlanningIssue.typeRequired => strings.familyPlanningTypeRequired,
      FamilyPlanningIssue.temporaryMethodRequired =>
        strings.familyPlanningMethodRequired,
      FamilyPlanningIssue.actionDateRequired =>
        strings.familyPlanningDateRequired,
      FamilyPlanningIssue.futureActionDate => strings.familyPlanningDateFuture,
    };
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  String _intentionLabel(
    AppLocalizations strings,
    PregnancyAvoidanceIntention value,
  ) => switch (value) {
    PregnancyAvoidanceIntention.yes => strings.yes,
    PregnancyAvoidanceIntention.no => strings.no,
    PregnancyAvoidanceIntention.notDecided => strings.notDecided,
    PregnancyAvoidanceIntention.unknown => strings.unknown,
  };

  String _methodStatusLabel(
    AppLocalizations strings,
    CurrentMethodUseStatus value,
  ) => switch (value) {
    CurrentMethodUseStatus.yes => strings.yes,
    CurrentMethodUseStatus.no => strings.no,
    CurrentMethodUseStatus.unknown => strings.unknown,
  };

  String _typeLabel(AppLocalizations strings, FamilyPlanningType value) =>
      switch (value) {
        FamilyPlanningType.temporary => strings.familyPlanningTemporary,
        FamilyPlanningType.permanent => strings.familyPlanningPermanent,
      };

  String _methodLabel(
    AppLocalizations strings,
    TemporaryFamilyPlanningMethod value,
  ) => switch (value) {
    TemporaryFamilyPlanningMethod.cuT => strings.methodCuT,
    TemporaryFamilyPlanningMethod.ppiucd => strings.methodPpiucd,
    TemporaryFamilyPlanningMethod.paiucd => strings.methodPaiucd,
  };

  String _historySummary(
    AppLocalizations strings,
    FamilyPlanningRecord record,
  ) {
    final method = record.temporaryMethod == null
        ? record.type == null
              ? _methodStatusLabel(strings, record.methodUseStatus)
              : _typeLabel(strings, record.type!)
        : _methodLabel(strings, record.temporaryMethod!);
    return '${_intentionLabel(strings, record.intention)} · $method · '
        '${MaterialLocalizations.of(context).formatMediumDate(record.updatedAt)}';
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(strings.familyPlanningTitle)),
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
                  strings.familyPlanningLoadFailed,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                    children: [
                      Text(
                        strings.familyPlanningIntention,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      DropdownButtonFormField<PregnancyAvoidanceIntention>(
                        initialValue: _intention,
                        items: PregnancyAvoidanceIntention.values
                            .map(
                              (value) => DropdownMenuItem(
                                value: value,
                                child: Text(_intentionLabel(strings, value)),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: (value) {
                          if (value != null) setState(() => _intention = value);
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<CurrentMethodUseStatus>(
                        initialValue: _methodUseStatus,
                        decoration: InputDecoration(
                          labelText: strings.currentFamilyPlanningMethod,
                        ),
                        items: CurrentMethodUseStatus.values
                            .map(
                              (value) => DropdownMenuItem(
                                value: value,
                                child: Text(_methodStatusLabel(strings, value)),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: _setMethodUseStatus,
                      ),
                      if (_methodUseStatus == CurrentMethodUseStatus.yes) ...[
                        const SizedBox(height: 12),
                        DropdownButtonFormField<FamilyPlanningType>(
                          initialValue: _type,
                          decoration: InputDecoration(
                            labelText: strings.familyPlanningType,
                          ),
                          items: FamilyPlanningType.values
                              .map(
                                (value) => DropdownMenuItem(
                                  value: value,
                                  child: Text(_typeLabel(strings, value)),
                                ),
                              )
                              .toList(growable: false),
                          onChanged: _setType,
                        ),
                        if (_type == FamilyPlanningType.temporary) ...[
                          const SizedBox(height: 12),
                          DropdownButtonFormField<
                            TemporaryFamilyPlanningMethod
                          >(
                            initialValue: _temporaryMethod,
                            decoration: InputDecoration(
                              labelText: strings.familyPlanningMethod,
                            ),
                            items: TemporaryFamilyPlanningMethod.values
                                .map(
                                  (value) => DropdownMenuItem(
                                    value: value,
                                    child: Text(_methodLabel(strings, value)),
                                  ),
                                )
                                .toList(growable: false),
                            onChanged: (value) =>
                                setState(() => _temporaryMethod = value),
                          ),
                        ],
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: _selectActionDate,
                          icon: const Icon(Icons.calendar_today_outlined),
                          label: Text(
                            _actionDate == null
                                ? strings.familyPlanningActionDate
                                : MaterialLocalizations.of(context)
                                      .formatMediumDate(_actionDate!),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _remarksController,
                        decoration: InputDecoration(
                          labelText: strings.familyPlanningRemarks,
                          helperText: strings.optionalField,
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: _saving ? null : _save,
                        child: _saving
                            ? const SizedBox.square(
                                dimension: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(strings.saveFamilyPlanning),
                      ),
                      if (_history.length > 1) ...[
                        const Divider(height: 32),
                        Text(
                          strings.familyPlanningHistory,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        for (final record in _history.skip(1))
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(_historySummary(strings, record)),
                            subtitle: record.remarks == null
                                ? null
                                : Text(record.remarks!),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
