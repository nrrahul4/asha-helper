import 'package:flutter/material.dart';

import '../../../data/models/member.dart';
import '../../../data/models/member_health_details.dart';
import '../../../data/models/member_marriage_details.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/member_health_marriage_input.dart';
import '../domain/member_health_marriage_service.dart';

class MemberHealthMarriageScreen extends StatefulWidget {
  const MemberHealthMarriageScreen({
    required this.member,
    required this.service,
    super.key,
  });

  final Member member;
  final MemberHealthMarriageService service;

  @override
  State<MemberHealthMarriageScreen> createState() =>
      _MemberHealthMarriageScreenState();
}

class _MemberHealthMarriageScreenState
    extends State<MemberHealthMarriageScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otherIllnessController = TextEditingController();
  final _specialCareController = TextEditingController();
  late final Future<void> _load;
  final _illnesses = <IllnessCode>{};
  HealthAnswer _hasCancer = HealthAnswer.unknown;
  HealthAnswer _hasAsthma = HealthAnswer.unknown;
  HealthAnswer _hasHeartDisease = HealthAnswer.unknown;
  MaritalStatus _maritalStatus = MaritalStatus.unknown;
  CounsellingAnswer _counselling = CounsellingAnswer.unknown;
  DateTime? _marriageDate;
  bool? _specialCareRequired;
  bool _saving = false;
  Object? _loadError;

  @override
  void initState() {
    super.initState();
    _load = _loadDetails();
  }

  @override
  void dispose() {
    _otherIllnessController.dispose();
    _specialCareController.dispose();
    super.dispose();
  }

  Future<void> _loadDetails() async {
    try {
      final details = await widget.service.get(widget.member.id);
      if (!mounted) return;
      final health = details.health;
      final marriage = details.marriage;
      if (health != null) {
        _illnesses
          ..clear()
          ..addAll(health.illnesses);
        _otherIllnessController.text = health.otherIllnessText ?? '';
        _hasCancer = health.hasCancer ?? HealthAnswer.unknown;
        _hasAsthma = health.hasAsthma ?? HealthAnswer.unknown;
        _hasHeartDisease = health.hasHeartDisease ?? HealthAnswer.unknown;
      }
      if (marriage != null) {
        _maritalStatus = marriage.maritalStatus;
        _marriageDate = marriage.marriageDate;
        _specialCareRequired = marriage.specialCareRequired;
        _specialCareController.text = marriage.specialCareDetails ?? '';
        _counselling =
            marriage.premaritalCounsellingReceived ?? CounsellingAnswer.unknown;
      }
    } catch (error) {
      _loadError = error;
      rethrow;
    }
  }

  void _setMaritalStatus(MaritalStatus? value) {
    if (value == null) return;
    setState(() {
      _maritalStatus = value;
      if (value != MaritalStatus.yes) {
        _marriageDate = null;
        _specialCareRequired = null;
        _specialCareController.clear();
        _counselling = CounsellingAnswer.unknown;
      }
    });
  }

  Future<void> _selectMarriageDate() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final selected = await showDatePicker(
      context: context,
      initialDate: _marriageDate ?? today,
      firstDate: DateTime(1900),
      lastDate: today,
    );
    if (selected != null && mounted) {
      setState(() => _marriageDate = selected);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await widget.service.save(
        memberId: widget.member.id,
        now: DateTime.now(),
        input: MemberHealthMarriageInput(
          illnesses: Set.unmodifiable(_illnesses),
          otherIllnessText: _otherIllnessController.text,
          hasCancer: _hasCancer,
          hasAsthma: _hasAsthma,
          hasHeartDisease: _hasHeartDisease,
          maritalStatus: _maritalStatus,
          marriageDate: _marriageDate,
          specialCareRequired: _specialCareRequired,
          specialCareDetails: _specialCareController.text,
          premaritalCounsellingReceived: _counselling,
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.healthMarriageDetailsSaved,
          ),
        ),
      );
      Navigator.of(context).pop();
    } on MemberHealthMarriageValidationException catch (error) {
      _showValidationError(error);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.healthMarriageDetailsSaveFailed,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showValidationError(MemberHealthMarriageValidationException error) {
    final strings = AppLocalizations.of(context)!;
    final issue = error.issues.values.first;
    final message = switch (issue) {
      MemberHealthMarriageIssue.otherIllnessTextRequired =>
        strings.otherIllnessRequired,
      MemberHealthMarriageIssue.futureMarriageDate =>
        strings.marriageFutureDate,
      MemberHealthMarriageIssue.specialCareAnswerRequired =>
        strings.specialCareAnswerRequired,
      MemberHealthMarriageIssue.specialCareDetailsRequired =>
        strings.specialCareDetailsRequired,
    };
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  String _illnessLabel(AppLocalizations strings, IllnessCode illness) =>
      switch (illness) {
        IllnessCode.diabetic => strings.illnessDiabetes,
        IllnessCode.bloodPressure => strings.illnessBloodPressure,
        IllnessCode.cholesterol => strings.illnessCholesterol,
        IllnessCode.other => strings.illnessOther,
      };

  String _healthAnswerLabel(AppLocalizations strings, HealthAnswer answer) =>
      switch (answer) {
        HealthAnswer.yes => strings.yes,
        HealthAnswer.no => strings.no,
        HealthAnswer.unknown => strings.unknown,
      };

  String _maritalLabel(AppLocalizations strings, MaritalStatus status) =>
      switch (status) {
        MaritalStatus.yes => strings.yes,
        MaritalStatus.no => strings.no,
        MaritalStatus.unknown => strings.unknown,
      };

  String _counsellingLabel(
    AppLocalizations strings,
    CounsellingAnswer answer,
  ) => switch (answer) {
    CounsellingAnswer.yes => strings.yes,
    CounsellingAnswer.no => strings.no,
    CounsellingAnswer.notApplicable => strings.notApplicable,
    CounsellingAnswer.unknown => strings.unknown,
  };

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(strings.healthMarriageDetailsTitle)),
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
                  strings.healthMarriageDetailsLoadFailed,
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
                        strings.existingIllnesses,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      for (final illness in IllnessCode.values)
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(_illnessLabel(strings, illness)),
                          value: _illnesses.contains(illness),
                          onChanged: (selected) {
                            setState(() {
                              if (selected == true) {
                                _illnesses.add(illness);
                              } else {
                                _illnesses.remove(illness);
                                if (illness == IllnessCode.other) {
                                  _otherIllnessController.clear();
                                }
                              }
                            });
                          },
                        ),
                      if (_illnesses.contains(IllnessCode.other))
                        TextFormField(
                          controller: _otherIllnessController,
                          decoration: InputDecoration(
                            labelText: strings.otherIllnessDetails,
                          ),
                          maxLines: 2,
                        ),
                      const SizedBox(height: 16),
                      _healthAnswerDropdown(
                        label: strings.hasCancer,
                        value: _hasCancer,
                        strings: strings,
                        onChanged: (answer) =>
                            setState(() => _hasCancer = answer),
                      ),
                      const SizedBox(height: 12),
                      _healthAnswerDropdown(
                        label: strings.hasAsthma,
                        value: _hasAsthma,
                        strings: strings,
                        onChanged: (answer) =>
                            setState(() => _hasAsthma = answer),
                      ),
                      const SizedBox(height: 12),
                      _healthAnswerDropdown(
                        label: strings.hasHeartDisease,
                        value: _hasHeartDisease,
                        strings: strings,
                        onChanged: (answer) =>
                            setState(() => _hasHeartDisease = answer),
                      ),
                      const Divider(height: 32),
                      DropdownButtonFormField<MaritalStatus>(
                        initialValue: _maritalStatus,
                        decoration: InputDecoration(
                          labelText: strings.maritalStatus,
                        ),
                        items: MaritalStatus.values
                            .map(
                              (status) => DropdownMenuItem(
                                value: status,
                                child: Text(_maritalLabel(strings, status)),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: _setMaritalStatus,
                      ),
                      if (_maritalStatus == MaritalStatus.yes) ...[
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: _selectMarriageDate,
                          icon: const Icon(Icons.calendar_today_outlined),
                          label: Text(
                            _marriageDate == null
                                ? strings.marriageDateUnknown
                                : MaterialLocalizations.of(context)
                                      .formatMediumDate(_marriageDate!),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          strings.specialCareRequired,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Wrap(
                          spacing: 8,
                          children: [
                            ChoiceChip(
                              label: Text(strings.yes),
                              selected: _specialCareRequired == true,
                              onSelected: (selected) => setState(
                                () => _specialCareRequired = selected
                                    ? true
                                    : null,
                              ),
                            ),
                            ChoiceChip(
                              label: Text(strings.no),
                              selected: _specialCareRequired == false,
                              onSelected: (selected) => setState(
                                () => _specialCareRequired = selected
                                    ? false
                                    : null,
                              ),
                            ),
                          ],
                        ),
                        if (_specialCareRequired == true) ...[
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _specialCareController,
                            decoration: InputDecoration(
                              labelText: strings.specialCareDetails,
                            ),
                            maxLines: 3,
                          ),
                        ],
                        const SizedBox(height: 12),
                        DropdownButtonFormField<CounsellingAnswer>(
                          initialValue: _counselling,
                          decoration: InputDecoration(
                            labelText: strings.premaritalCounselling,
                          ),
                          items: CounsellingAnswer.values
                              .map(
                                (answer) => DropdownMenuItem(
                                  value: answer,
                                  child: Text(
                                    _counsellingLabel(strings, answer),
                                  ),
                                ),
                              )
                              .toList(growable: false),
                          onChanged: (answer) {
                            if (answer != null) {
                              setState(() => _counselling = answer);
                            }
                          },
                        ),
                      ],
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
                            : Text(strings.saveHealthMarriageDetails),
                      ),
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

  Widget _healthAnswerDropdown({
    required String label,
    required HealthAnswer value,
    required AppLocalizations strings,
    required ValueChanged<HealthAnswer> onChanged,
  }) => DropdownButtonFormField<HealthAnswer>(
    initialValue: value,
    decoration: InputDecoration(labelText: label),
    items: HealthAnswer.values
        .map(
          (answer) => DropdownMenuItem(
            value: answer,
            child: Text(_healthAnswerLabel(strings, answer)),
          ),
        )
        .toList(growable: false),
    onChanged: (answer) {
      if (answer != null) onChanged(answer);
    },
  );
}
