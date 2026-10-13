import 'package:flutter/material.dart';

import '../../../data/models/database_codes.dart';
import '../../../data/models/household.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/household_registration_input.dart';
import '../domain/household_registration_service.dart';
import 'household_localization_labels.dart';

class HouseholdRegistrationScreen extends StatefulWidget {
  const HouseholdRegistrationScreen({
    required this.registrationService,
    this.onRegistered,
    super.key,
  });

  final HouseholdRegistrationService registrationService;
  final ValueChanged<Household>? onRegistered;

  @override
  State<HouseholdRegistrationScreen> createState() =>
      _HouseholdRegistrationScreenState();
}

class _HouseholdRegistrationScreenState
    extends State<HouseholdRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _houseName = TextEditingController();
  final _houseNumber = TextEditingController();
  final _addressLine = TextEditingController();
  final _locality = TextEditingController();
  final _postOffice = TextEditingController();
  final _pincode = TextEditingController();
  final _contactPhone = TextEditingController();
  final _headName = TextEditingController();
  final _headDateController = TextEditingController();
  final _headPhone = TextEditingController();

  RationCardType? _rationCardType;
  bool? _hasOwnWell;
  HouseType? _houseType;
  DateTime? _headDateOfBirth;
  Gender? _headGender;
  bool _saving = false;

  @override
  void dispose() {
    _houseName.dispose();
    _houseNumber.dispose();
    _addressLine.dispose();
    _locality.dispose();
    _postOffice.dispose();
    _pincode.dispose();
    _contactPhone.dispose();
    _headName.dispose();
    _headDateController.dispose();
    _headPhone.dispose();
    super.dispose();
  }

  HouseholdRegistrationInput _input() => HouseholdRegistrationInput(
    houseName: _houseName.text,
    houseNumber: _houseNumber.text,
    addressLine: _addressLine.text,
    locality: _locality.text,
    postOffice: _postOffice.text,
    pincode: _pincode.text,
    contactPhone: _contactPhone.text,
    rationCardType: _rationCardType,
    hasOwnWell: _hasOwnWell,
    houseType: _houseType,
    headFullName: _headName.text,
    headDateOfBirth: _headDateOfBirth,
    headGender: _headGender,
    headPhone: _headPhone.text,
  );

  Future<void> _selectDateOfBirth() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final initialDate =
        _headDateOfBirth ?? DateTime(today.year - 18, today.month, today.day);
    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate.isAfter(today) ? today : initialDate,
      firstDate: DateTime(1900),
      lastDate: today,
      helpText: AppLocalizations.of(context)!.selectDate,
    );
    if (selected != null) {
      setState(() {
        _headDateOfBirth = selected;
        _headDateController.text = MaterialLocalizations.of(context)
            .formatMediumDate(selected);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      Household household;
      try {
        household = await widget.registrationService.register(_input());
      } on PossibleHouseholdDuplicatesException catch (exception) {
        if (!await _confirmPossibleDuplicates(exception.households)) return;
        household = await widget.registrationService.register(
          _input(),
          confirmPossibleDuplicates: true,
        );
      }

      if (!mounted) return;
      final callback = widget.onRegistered;
      if (callback != null) {
        callback(household);
      } else {
        Navigator.of(context).pop(household);
      }
    } on HouseholdRegistrationValidationException {
      _formKey.currentState!.validate();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.registrationFailed),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<bool> _confirmPossibleDuplicates(List<Household> households) async {
    final strings = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.possibleDuplicatesTitle),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440, maxHeight: 360),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(strings.possibleDuplicatesMessage),
                const SizedBox(height: 12),
                for (final household in households)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(household.houseName),
                    subtitle: household.houseNumber == null
                        ? null
                        : Text(
                            strings.houseNumberSummary(household.houseNumber!),
                          ),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(strings.reviewMatches),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(strings.continueRegistration),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  String? _required(String? value) => value == null || value.trim().isEmpty
      ? AppLocalizations.of(context)!.requiredField
      : null;

  String? _dobError() {
    final strings = AppLocalizations.of(context)!;
    final date = _headDateOfBirth;
    if (date == null) return strings.requiredField;
    if (DateUtils.dateOnly(date).isAfter(DateUtils.dateOnly(DateTime.now()))) {
      return strings.futureDateError;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(strings.registerHouseholdTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SectionHeading(
                      icon: Icons.home_outlined,
                      title: strings.householdDetails,
                      theme: theme,
                    ),
                    const SizedBox(height: 12),
                    _textField(
                      key: const Key('house-name-field'),
                      label: strings.houseName,
                      controller: _houseName,
                      validator: _required,
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 12),
                    _textField(
                      key: const Key('house-number-field'),
                      label: strings.houseNumber,
                      controller: _houseNumber,
                      textCapitalization: TextCapitalization.characters,
                    ),
                    const SizedBox(height: 12),
                    _textField(
                      key: const Key('address-field'),
                      label: strings.addressLine,
                      controller: _addressLine,
                      validator: _required,
                      textCapitalization: TextCapitalization.words,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    _textField(
                      key: const Key('locality-field'),
                      label: strings.locality,
                      controller: _locality,
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 12),
                    _textField(
                      key: const Key('post-office-field'),
                      label: strings.postOffice,
                      controller: _postOffice,
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 12),
                    _textField(
                      key: const Key('pincode-field'),
                      label: strings.pincode,
                      controller: _pincode,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    _textField(
                      key: const Key('contact-phone-field'),
                      label: strings.contactPhone,
                      controller: _contactPhone,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    _dropdown<RationCardType>(
                      key: const Key('ration-card-field'),
                      label: strings.rationCardType,
                      value: _rationCardType,
                      values: RationCardType.selectableValues,
                      labelFor: (value) => rationCardLabel(strings, value),
                      validator: (value) =>
                          value == null ? strings.requiredField : null,
                      onChanged: (value) =>
                          setState(() => _rationCardType = value),
                    ),
                    const SizedBox(height: 12),
                    _dropdown<bool>(
                      key: const Key('well-field'),
                      label: strings.hasOwnWell,
                      value: _hasOwnWell,
                      values: const [true, false],
                      labelFor: (value) => value ? strings.yes : strings.no,
                      validator: (value) =>
                          value == null ? strings.requiredField : null,
                      onChanged: (value) => setState(() => _hasOwnWell = value),
                    ),
                    const SizedBox(height: 12),
                    _dropdown<HouseType>(
                      key: const Key('house-type-field'),
                      label: strings.houseType,
                      value: _houseType,
                      values: HouseType.values,
                      labelFor: (value) => houseTypeLabel(strings, value),
                      validator: (value) =>
                          value == null ? strings.requiredField : null,
                      onChanged: (value) => setState(() => _houseType = value),
                    ),
                    const SizedBox(height: 28),
                    _SectionHeading(
                      icon: Icons.person_outline,
                      title: strings.headDetails,
                      theme: theme,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      strings.headRoleDescription,
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    _textField(
                      key: const Key('head-name-field'),
                      label: strings.headFullName,
                      controller: _headName,
                      validator: _required,
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      key: const Key('head-dob-field'),
                      readOnly: true,
                      onTap: _selectDateOfBirth,
                      decoration: InputDecoration(
                        labelText: strings.dateOfBirth,
                        hintText: strings.selectDate,
                        suffixIcon: const Icon(Icons.calendar_month_outlined),
                      ),
                      controller: _headDateController,
                      validator: (_) => _dobError(),
                    ),
                    const SizedBox(height: 12),
                    _dropdown<Gender>(
                      key: const Key('head-gender-field'),
                      label: strings.gender,
                      value: _headGender,
                      values: Gender.values,
                      labelFor: (value) => genderLabel(strings, value),
                      validator: (value) =>
                          value == null ? strings.requiredField : null,
                      onChanged: (value) => setState(() => _headGender = value),
                    ),
                    const SizedBox(height: 12),
                    _textField(
                      key: const Key('head-phone-field'),
                      label: strings.personPhone,
                      controller: _headPhone,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      key: const Key('save-household-button'),
                      onPressed: _saving ? null : _submit,
                      icon: _saving
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save_outlined),
                      label: Text(_saving ? strings.saving : strings.save),
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

  Widget _textField({
    required Key key,
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    int maxLines = 1,
  }) => TextFormField(
    key: key,
    controller: controller,
    validator: validator,
    keyboardType: keyboardType,
    textCapitalization: textCapitalization,
    maxLines: maxLines,
    decoration: InputDecoration(labelText: label),
  );

  Widget _dropdown<T>({
    required Key key,
    required String label,
    required T? value,
    required List<T> values,
    required String Function(T) labelFor,
    required String? Function(T?) validator,
    required ValueChanged<T?> onChanged,
  }) => DropdownButtonFormField<T>(
    key: key,
    initialValue: value,
    isExpanded: true,
    decoration: InputDecoration(labelText: label),
    hint: Text(AppLocalizations.of(context)!.selectOption),
    items: [
      for (final option in values)
        DropdownMenuItem<T>(value: option, child: Text(labelFor(option))),
    ],
    validator: validator,
    onChanged: onChanged,
  );
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.icon,
    required this.title,
    required this.theme,
  });

  final IconData icon;
  final String title;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 20, color: theme.colorScheme.primary),
      const SizedBox(width: 10),
      Text(title, style: theme.textTheme.titleLarge),
    ],
  );
}
