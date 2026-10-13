import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../data/models/child_birth_details.dart';
import '../../../data/models/member.dart';
import '../../../domain/age_calculator.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/child_birth_details_input.dart';
import '../domain/child_birth_details_service.dart';

class ChildBirthDetailsScreen extends StatefulWidget {
  const ChildBirthDetailsScreen({
    required this.member,
    required this.service,
    super.key,
  });

  final Member member;
  final ChildBirthDetailsService service;

  @override
  State<ChildBirthDetailsScreen> createState() =>
      _ChildBirthDetailsScreenState();
}

class _ChildBirthDetailsScreenState extends State<ChildBirthDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _specialCareController = TextEditingController();
  late final Future<void> _load;
  ChildBirthDetails? _details;
  ChildDeliveryType? _deliveryType;
  bool? _specialCareRequired;
  TimeOfDay? _birthTime;
  bool _saving = false;
  Object? _loadError;

  int get _age =>
      AgeCalculator.completedYears(widget.member.dateOfBirth, DateTime.now());

  @override
  void initState() {
    super.initState();
    _load = _loadDetails();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _specialCareController.dispose();
    super.dispose();
  }

  Future<void> _loadDetails() async {
    try {
      _details = await widget.service.get(widget.member.id);
      final details = _details;
      if (!mounted || details == null) return;
      _weightController.text = details.birthWeightKg?.toString() ?? '';
      _specialCareController.text = details.specialCareDetails ?? '';
      _deliveryType = details.deliveryType;
      _specialCareRequired = details.specialCareRequired;
      if (details.birthTime case final time?) {
        final parts = time.split(':');
        _birthTime = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
    } catch (error) {
      _loadError = error;
      rethrow;
    }
  }

  Future<void> _selectBirthTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: _birthTime ?? TimeOfDay.now(),
    );
    if (selected != null && mounted) {
      setState(() => _birthTime = selected);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final priorDetails = _details;
    final requireCareAnswer = _age < 1;
    try {
      await widget.service.save(
        memberId: widget.member.id,
        now: DateTime.now(),
        input: ChildBirthDetailsInput(
          birthWeightKg: double.tryParse(_weightController.text.trim()),
          birthTime: _birthTime == null
              ? null
              : '${_birthTime!.hour.toString().padLeft(2, '0')}:'
                    '${_birthTime!.minute.toString().padLeft(2, '0')}',
          deliveryType: _deliveryType,
          specialCareRequired: requireCareAnswer
              ? _specialCareRequired
              : priorDetails?.specialCareRequired,
          specialCareDetails: requireCareAnswer
              ? _specialCareController.text
              : priorDetails?.specialCareDetails,
          requiresSpecialCareAnswer: requireCareAnswer,
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.childBirthDetailsSaved),
        ),
      );
      Navigator.of(context).pop();
    } on ChildBirthDetailsValidationException catch (error) {
      _showValidationError(error);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.childBirthDetailsSaveFailed,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showValidationError(ChildBirthDetailsValidationException error) {
    final strings = AppLocalizations.of(context)!;
    final issue = error.issues.values.first;
    final message = switch (issue) {
      ChildBirthDetailsIssue.weightOutOfRange =>
        strings.childBirthWeightOutOfRange,
      ChildBirthDetailsIssue.invalidTime => strings.childBirthTimeInvalid,
      ChildBirthDetailsIssue.careAnswerRequired =>
        strings.childSpecialCareAnswerRequired,
      ChildBirthDetailsIssue.careDetailsRequired =>
        strings.childSpecialCareDetailsRequired,
    };
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  String _deliveryLabel(
    AppLocalizations strings,
    ChildDeliveryType deliveryType,
  ) => switch (deliveryType) {
    ChildDeliveryType.vaginal => strings.deliveryVaginal,
    ChildDeliveryType.caesarean => strings.deliveryCaesarean,
  };

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final underFive = _age < 5;
    final underOne = _age < 1;
    return Scaffold(
      appBar: AppBar(title: Text(strings.childBirthDetailsTitle)),
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
                  strings.childBirthDetailsLoadFailed,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (!underFive) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  strings.childBirthDetailsAgeNotice,
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
                      TextFormField(
                        controller: _weightController,
                        decoration: InputDecoration(
                          labelText: strings.childBirthWeight,
                          helperText: strings.childBirthWeightHelp,
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(strings.childBirthTime),
                        subtitle: Text(
                          _birthTime == null
                              ? strings.optionalField
                              : MaterialLocalizations.of(context)
                                    .formatTimeOfDay(_birthTime!),
                        ),
                        trailing: const Icon(Icons.schedule),
                        onTap: _selectBirthTime,
                      ),
                      DropdownButtonFormField<ChildDeliveryType>(
                        initialValue: _deliveryType,
                        decoration: InputDecoration(
                          labelText: strings.childDeliveryType,
                        ),
                        items: ChildDeliveryType.values
                            .map(
                              (type) => DropdownMenuItem(
                                value: type,
                                child: Text(_deliveryLabel(strings, type)),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: (value) =>
                            setState(() => _deliveryType = value),
                      ),
                      if (underOne) ...[
                        const SizedBox(height: 16),
                        Text(
                          strings.childSpecialCareRequired,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        RadioGroup<bool>(
                          groupValue: _specialCareRequired,
                          onChanged: (value) =>
                              setState(() => _specialCareRequired = value),
                          child: Column(
                            children: [
                              RadioListTile<bool>(
                                value: true,
                                title: Text(strings.yes),
                              ),
                              RadioListTile<bool>(
                                value: false,
                                title: Text(strings.no),
                              ),
                            ],
                          ),
                        ),
                        if (_specialCareRequired == true) ...[
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _specialCareController,
                            decoration: InputDecoration(
                              labelText: strings.childSpecialCareDetails,
                            ),
                            maxLines: 3,
                          ),
                        ],
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
                            : Text(strings.saveChildBirthDetails),
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
}
