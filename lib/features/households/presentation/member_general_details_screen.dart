import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../data/models/database_codes.dart';
import '../../../data/models/member.dart';
import '../../../data/models/member_general_details.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/member_general_details_input.dart';
import '../domain/member_general_details_service.dart';

class MemberGeneralDetailsScreen extends StatefulWidget {
  const MemberGeneralDetailsScreen({
    required this.member,
    required this.service,
    super.key,
  });

  final Member member;
  final MemberGeneralDetailsService service;

  @override
  State<MemberGeneralDetailsScreen> createState() =>
      _MemberGeneralDetailsScreenState();
}

class _MemberGeneralDetailsScreenState
    extends State<MemberGeneralDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _aadhaarController = TextEditingController();
  final _educationController = TextEditingController();
  final _jobController = TextEditingController();
  late final Future<void> _load;
  bool _aadhaarVisible = false;
  bool? _isCurrentlyWorkingAbroad;
  BloodGroup? _bloodGroup;
  bool _saving = false;
  Object? _loadError;

  @override
  void initState() {
    super.initState();
    _load = _loadDetails();
  }

  @override
  void dispose() {
    _aadhaarController.dispose();
    _educationController.dispose();
    _jobController.dispose();
    super.dispose();
  }

  Future<void> _loadDetails() async {
    try {
      final details = await widget.service.get(widget.member.id);
      if (!mounted || details == null) return;
      _applyDetails(details);
    } catch (error) {
      _loadError = error;
      rethrow;
    }
  }

  void _applyDetails(MemberGeneralDetails details) {
    _aadhaarController.text = details.aadhaarNumber ?? '';
    _educationController.text = details.educationLevel ?? '';
    _jobController.text = details.jobTitle ?? '';
    _isCurrentlyWorkingAbroad = details.isCurrentlyWorkingAbroad;
    _bloodGroup = details.bloodGroup;
  }

  Future<bool> _confirmAadhaarReveal() async {
    final strings = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.aadhaarRevealTitle),
        content: Text(strings.aadhaarRevealMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(strings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(strings.revealAadhaar),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  Future<void> _toggleAadhaarVisibility() async {
    if (_aadhaarVisible) {
      setState(() => _aadhaarVisible = false);
    } else if (await _confirmAadhaarReveal() && mounted) {
      setState(() => _aadhaarVisible = true);
    }
  }

  String? _validateAadhaar(String? value) {
    if (value == null || value.isEmpty) return null;
    if (!RegExp(r'^[0-9]{12}$').hasMatch(value)) {
      return AppLocalizations.of(context)!.aadhaarInvalid;
    }
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await widget.service.save(
        memberId: widget.member.id,
        input: MemberGeneralDetailsInput(
          aadhaarNumber: _aadhaarController.text,
          educationLevel: _educationController.text,
          jobTitle: _jobController.text,
          isCurrentlyWorkingAbroad: _isCurrentlyWorkingAbroad,
          bloodGroup: _bloodGroup,
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.generalDetailsSaved),
        ),
      );
      Navigator.of(context).pop();
    } on MemberGeneralDetailsValidationException {
      _formKey.currentState!.validate();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.generalDetailsSaveFailed),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(strings.memberGeneralDetailsTitle)),
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
                  strings.generalDetailsLoadFailed,
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
                        key: const Key('member-aadhaar-field'),
                        controller: _aadhaarController,
                        obscureText: !_aadhaarVisible,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(12),
                        ],
                        validator: _validateAadhaar,
                        decoration: InputDecoration(
                          labelText: strings.aadhaarNumber,
                          helperText: strings.optionalField,
                          suffixIcon: IconButton(
                            tooltip: _aadhaarVisible
                                ? strings.hideAadhaar
                                : strings.revealAadhaar,
                            onPressed: _toggleAadhaarVisibility,
                            icon: Icon(
                              _aadhaarVisible
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        key: const Key('member-education-field'),
                        controller: _educationController,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          labelText: strings.educationLevel,
                          helperText: strings.optionalField,
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        key: const Key('member-job-field'),
                        controller: _jobController,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          labelText: strings.jobTitle,
                          helperText: strings.optionalField,
                        ),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<bool>(
                        key: const Key('member-abroad-field'),
                        initialValue: _isCurrentlyWorkingAbroad,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: strings.currentlyWorkingAbroad,
                        ),
                        hint: Text(strings.selectOption),
                        items: [
                          DropdownMenuItem(
                            value: true,
                            child: Text(strings.yes),
                          ),
                          DropdownMenuItem(
                            value: false,
                            child: Text(strings.no),
                          ),
                        ],
                        onChanged: (value) =>
                            setState(() => _isCurrentlyWorkingAbroad = value),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<BloodGroup>(
                        key: const Key('member-blood-group-field'),
                        initialValue: _bloodGroup,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: strings.bloodGroup,
                        ),
                        hint: Text(strings.selectOption),
                        items: [
                          for (final value in BloodGroup.values)
                            DropdownMenuItem(
                              value: value,
                              child: Text(_bloodGroupLabel(strings, value)),
                            ),
                        ],
                        onChanged: (value) =>
                            setState(() => _bloodGroup = value),
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        key: const Key('save-general-details-button'),
                        onPressed: _saving ? null : _save,
                        icon: _saving
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.save_outlined),
                        label: Text(
                          _saving ? strings.saving : strings.saveGeneralDetails,
                        ),
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

String _bloodGroupLabel(AppLocalizations strings, BloodGroup value) =>
    switch (value) {
      BloodGroup.aPositive => 'A+',
      BloodGroup.aNegative => 'A-',
      BloodGroup.bPositive => 'B+',
      BloodGroup.bNegative => 'B-',
      BloodGroup.abPositive => 'AB+',
      BloodGroup.abNegative => 'AB-',
      BloodGroup.oPositive => 'O+',
      BloodGroup.oNegative => 'O-',
      BloodGroup.unknown => strings.unknown,
    };
