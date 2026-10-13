import 'package:flutter/material.dart';

import '../../../data/models/database_codes.dart';
import '../../../data/models/member.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/member_form_input.dart';
import '../domain/member_management_service.dart';
import 'household_localization_labels.dart';

class MemberFormScreen extends StatefulWidget {
  const MemberFormScreen({
    required this.householdId,
    required this.memberService,
    this.member,
    super.key,
  });

  final String householdId;
  final MemberManagementService memberService;
  final Member? member;

  @override
  State<MemberFormScreen> createState() => _MemberFormScreenState();
}

class _MemberFormScreenState extends State<MemberFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _dateController;
  DateTime? _dateOfBirth;
  Gender? _gender;
  RelationshipToHead? _relationship;
  bool _saving = false;

  bool get _isHead => widget.member?.isHead ?? false;

  @override
  void initState() {
    super.initState();
    final member = widget.member;
    _nameController = TextEditingController(text: member?.fullName ?? '');
    _phoneController = TextEditingController(text: member?.personPhone ?? '');
    _dateOfBirth = member?.dateOfBirth;
    _gender = member?.gender;
    _relationship = member?.relationshipToHead;
    _dateController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final date = _dateOfBirth;
    if (date != null && _dateController.text.isEmpty) {
      _dateController.text = MaterialLocalizations.of(context)
          .formatMediumDate(date);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  MemberFormInput _input() => MemberFormInput(
    fullName: _nameController.text,
    dateOfBirth: _dateOfBirth,
    gender: _gender,
    relationshipToHead: _isHead ? RelationshipToHead.head : _relationship,
    phone: _phoneController.text,
  );

  Future<void> _selectDateOfBirth() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final initialDate = _dateOfBirth ?? DateTime(today.year - 18, 1, 1);
    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate.isAfter(today) ? today : initialDate,
      firstDate: DateTime(1900),
      lastDate: today,
      helpText: AppLocalizations.of(context)!.selectDate,
    );
    if (selected == null) return;
    setState(() {
      _dateOfBirth = selected;
      _dateController.text = MaterialLocalizations.of(context)
          .formatMediumDate(selected);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final input = _input();
      final member = widget.member == null
          ? await widget.memberService.addMember(
              householdId: widget.householdId,
              input: input,
            )
          : await widget.memberService.updateMember(
              existing: widget.member!,
              input: input,
            );
      if (mounted) Navigator.of(context).pop(member);
    } on MemberValidationException {
      _formKey.currentState!.validate();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.memberSaveFailed),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String? _required(String? value) => value == null || value.trim().isEmpty
      ? AppLocalizations.of(context)!.requiredField
      : null;

  String? _validateDate() {
    final strings = AppLocalizations.of(context)!;
    final date = _dateOfBirth;
    if (date == null) return strings.requiredField;
    if (DateUtils.dateOnly(date).isAfter(DateUtils.dateOnly(DateTime.now()))) {
      return strings.futureDateError;
    }
    return null;
  }

  String? _validatePhone(String? value) {
    final phone = value?.trim() ?? '';
    if (phone.isEmpty) return null;
    if (!RegExp(r'^\+?[0-9(). -]+$').hasMatch(phone) ||
        !RegExp(r'[0-9]').hasMatch(phone)) {
      return AppLocalizations.of(context)!.memberPhoneInvalid;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final member = widget.member;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isHead
              ? strings.editMemberTitle
              : member == null
              ? strings.addMemberTitle
              : strings.editMemberTitle,
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      key: const Key('member-name-field'),
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      validator: _required,
                      decoration: InputDecoration(
                        labelText: strings.memberName,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      key: const Key('member-dob-field'),
                      controller: _dateController,
                      readOnly: true,
                      onTap: _selectDateOfBirth,
                      validator: (_) => _validateDate(),
                      decoration: InputDecoration(
                        labelText: strings.dateOfBirth,
                        hintText: strings.selectDate,
                        suffixIcon: const Icon(Icons.calendar_month_outlined),
                      ),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<Gender>(
                      key: const Key('member-gender-field'),
                      initialValue: _gender,
                      isExpanded: true,
                      decoration: InputDecoration(labelText: strings.gender),
                      hint: Text(strings.selectOption),
                      items: [
                        for (final gender in Gender.values)
                          DropdownMenuItem(
                            value: gender,
                            child: Text(genderLabel(strings, gender)),
                          ),
                      ],
                      validator: (value) =>
                          value == null ? strings.requiredField : null,
                      onChanged: (value) => setState(() => _gender = value),
                    ),
                    const SizedBox(height: 14),
                    if (_isHead)
                      InputDecorator(
                        decoration: InputDecoration(
                          labelText: strings.relationshipToHead,
                        ),
                        child: Text(strings.relationshipHead),
                      )
                    else
                      DropdownButtonFormField<RelationshipToHead>(
                        key: const Key('member-relationship-field'),
                        initialValue: _relationship,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: strings.relationshipToHead,
                        ),
                        hint: Text(strings.selectRelationship),
                        items: [
                          for (final relation
                              in RelationshipToHead.values.where(
                                (relation) =>
                                    relation != RelationshipToHead.head,
                              ))
                            DropdownMenuItem(
                              value: relation,
                              child: Text(relationshipLabel(strings, relation)),
                            ),
                        ],
                        validator: (value) =>
                            value == null ? strings.requiredField : null,
                        onChanged: (value) =>
                            setState(() => _relationship = value),
                      ),
                    const SizedBox(height: 14),
                    TextFormField(
                      key: const Key('member-phone-field'),
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      validator: _validatePhone,
                      decoration: InputDecoration(
                        labelText: strings.personPhone,
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      key: const Key('save-member-button'),
                      onPressed: _saving ? null : _submit,
                      icon: _saving
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save_outlined),
                      label: Text(
                        _saving ? strings.saving : strings.saveMember,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
