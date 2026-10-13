import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../data/models/member.dart';
import '../../../data/models/pregnancy_record.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/pregnancy_details_input.dart';
import '../domain/pregnancy_details_service.dart';

class PregnancyDetailsScreen extends StatefulWidget {
  const PregnancyDetailsScreen({
    required this.member,
    required this.service,
    super.key,
  });

  final Member member;
  final PregnancyDetailsService service;

  @override
  State<PregnancyDetailsScreen> createState() => _PregnancyDetailsScreenState();
}

class _PregnancyDetailsScreenState extends State<PregnancyDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _abaController = TextEditingController();
  final _hospitalController = TextEditingController();
  final _previousCountController = TextEditingController();
  late final Future<void> _load;
  PregnancyRecord? _record;
  DateTime? _lmp;
  DateTime? _lastLiveBirth;
  bool _saving = false;
  Object? _loadError;

  @override
  void initState() {
    super.initState();
    _load = _loadRecord();
  }

  @override
  void dispose() {
    _abaController.dispose();
    _hospitalController.dispose();
    _previousCountController.dispose();
    super.dispose();
  }

  Future<void> _loadRecord() async {
    try {
      _record = await widget.service.getCurrent(widget.member.id);
      final record = _record;
      if (!mounted || record == null) return;
      _abaController.text = record.abaId ?? '';
      _hospitalController.text = record.consultingHospital ?? '';
      _previousCountController.text =
          record.previousPregnancyCount?.toString() ?? '';
      _lmp = record.lastMensesDate;
      _lastLiveBirth = record.lastLiveBirthDate;
    } catch (error) {
      _loadError = error;
      rethrow;
    }
  }

  Future<DateTime?> _selectDate(DateTime? initialDate) async {
    final today = DateUtils.dateOnly(DateTime.now());
    return showDatePicker(
      context: context,
      initialDate: initialDate ?? today,
      firstDate: DateTime(1900),
      lastDate: today,
    );
  }

  Future<void> _selectLmp() async {
    final selected = await _selectDate(_lmp);
    if (selected != null && mounted) setState(() => _lmp = selected);
  }

  Future<void> _selectLastLiveBirth() async {
    final selected = await _selectDate(_lastLiveBirth);
    if (selected != null && mounted) {
      setState(() => _lastLiveBirth = selected);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await widget.service.save(
        memberId: widget.member.id,
        input: PregnancyDetailsInput(
          abaId: _abaController.text,
          lastMensesDate: _lmp,
          consultingHospital: _hospitalController.text,
          previousPregnancyCount: int.tryParse(
            _previousCountController.text.trim(),
          ),
          lastLiveBirthDate: _lastLiveBirth,
        ),
        now: DateTime.now(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.pregnancyDetailsSaved),
        ),
      );
      Navigator.of(context).pop();
    } on PregnancyDetailsValidationException catch (error) {
      _showValidationError(error);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.pregnancyDetailsSaveFailed,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showValidationError(PregnancyDetailsValidationException error) {
    final strings = AppLocalizations.of(context)!;
    for (final entry in error.issues.entries) {
      final message = switch (entry.key) {
        PregnancyDetailsField.lastMensesDate ||
        PregnancyDetailsField.lastLiveBirthDate => strings.pregnancyFutureDate,
        PregnancyDetailsField.previousPregnancyCount =>
          strings.pregnancyCountInvalid,
      };
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
      break;
    }
  }

  String _estimateLabel(AppLocalizations strings, DateTime today) {
    final estimate = estimatePregnancy(_lmp, today);
    if (estimate == null) return strings.pregnancyEstimateUnavailable;
    final trimesterLabel = switch (estimate.trimester) {
      EstimatedTrimester.first => strings.pregnancyFirstTrimester,
      EstimatedTrimester.second => strings.pregnancySecondTrimester,
      EstimatedTrimester.third => strings.pregnancyThirdTrimester,
    };
    return strings.pregnancyEstimate(estimate.completedWeeks, trimesterLabel);
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final today = DateUtils.dateOnly(DateTime.now());
    final previousPregnancyCount = int.tryParse(_previousCountController.text);
    return Scaffold(
      appBar: AppBar(title: Text(strings.pregnancyDetailsTitle)),
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
                  strings.pregnancyDetailsLoadFailed,
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
                        controller: _abaController,
                        decoration: InputDecoration(
                          labelText: strings.pregnancyAbaId,
                          helperText: strings.optionalField,
                        ),
                        textCapitalization: TextCapitalization.characters,
                      ),
                      const SizedBox(height: 12),
                      _DateField(
                        label: strings.pregnancyLmp,
                        value: _lmp,
                        onSelect: _selectLmp,
                        onClear: _lmp == null
                            ? null
                            : () => setState(() => _lmp = null),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _estimateLabel(strings, today),
                        key: const Key('pregnancy-estimate'),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(strings.pregnancyEstimateDisclaimer),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _hospitalController,
                        decoration: InputDecoration(
                          labelText: strings.pregnancyHospital,
                          helperText: strings.optionalField,
                        ),
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _previousCountController,
                        decoration: InputDecoration(
                          labelText: strings.previousPregnancyCount,
                          helperText: strings.previousPregnancyCountHelp,
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (_) => setState(() {}),
                      ),
                      if (previousPregnancyCount != null &&
                          previousPregnancyCount > 0) ...[
                        const SizedBox(height: 12),
                        _DateField(
                          label: strings.lastLiveBirthDate,
                          value: _lastLiveBirth,
                          onSelect: _selectLastLiveBirth,
                          onClear: _lastLiveBirth == null
                              ? null
                              : () => setState(() => _lastLiveBirth = null),
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
                            : Text(strings.savePregnancyDetails),
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

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onSelect,
    required this.onClear,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onSelect;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final material = MaterialLocalizations.of(context);
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onClear != null)
              IconButton(
                tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
                onPressed: onClear,
                icon: const Icon(Icons.clear),
              ),
            IconButton(
              tooltip: label,
              onPressed: onSelect,
              icon: const Icon(Icons.calendar_today_outlined),
            ),
          ],
        ),
      ),
      child: InkWell(
        onTap: onSelect,
        child: Text(
          value == null
              ? AppLocalizations.of(context)!.optionalField
              : material.formatMediumDate(value!),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
