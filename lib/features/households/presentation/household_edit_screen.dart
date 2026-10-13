import 'package:flutter/material.dart';

import '../../../data/models/database_codes.dart';
import '../../../data/models/household.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/household_edit_input.dart';
import '../domain/household_edit_service.dart';
import 'household_localization_labels.dart';

class HouseholdEditScreen extends StatefulWidget {
  const HouseholdEditScreen({
    required this.household,
    required this.service,
    super.key,
  });

  final Household household;
  final HouseholdEditService service;

  @override
  State<HouseholdEditScreen> createState() => _HouseholdEditScreenState();
}

class _HouseholdEditScreenState extends State<HouseholdEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _houseName;
  late final TextEditingController _houseNumber;
  late final TextEditingController _addressLine;
  late final TextEditingController _locality;
  late final TextEditingController _postOffice;
  late final TextEditingController _pincode;
  late final TextEditingController _contactPhone;
  late final TextEditingController _notes;
  late bool? _hasOwnWell;
  late HouseType? _houseType;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final household = widget.household;
    _houseName = TextEditingController(text: household.houseName);
    _houseNumber = TextEditingController(text: household.houseNumber ?? '');
    _addressLine = TextEditingController(text: household.addressLine);
    _locality = TextEditingController(text: household.locality ?? '');
    _postOffice = TextEditingController(text: household.postOffice ?? '');
    _pincode = TextEditingController(text: household.pincode ?? '');
    _contactPhone = TextEditingController(text: household.contactPhone ?? '');
    _notes = TextEditingController(text: household.notes ?? '');
    _hasOwnWell = household.hasOwnWell;
    _houseType = household.houseType;
  }

  @override
  void dispose() {
    _houseName.dispose();
    _houseNumber.dispose();
    _addressLine.dispose();
    _locality.dispose();
    _postOffice.dispose();
    _pincode.dispose();
    _contactPhone.dispose();
    _notes.dispose();
    super.dispose();
  }

  String? _required(String? value) => value == null || value.trim().isEmpty
      ? AppLocalizations.of(context)!.requiredField
      : null;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final updated = await widget.service.update(
        household: widget.household,
        input: HouseholdEditInput(
          houseName: _houseName.text,
          houseNumber: _houseNumber.text,
          addressLine: _addressLine.text,
          locality: _locality.text,
          postOffice: _postOffice.text,
          pincode: _pincode.text,
          contactPhone: _contactPhone.text,
          notes: _notes.text,
          hasOwnWell: _hasOwnWell,
          houseType: _houseType,
        ),
      );
      if (mounted) Navigator.of(context).pop(updated);
    } on HouseholdEditValidationException {
      _formKey.currentState!.validate();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.householdEditFailed),
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
      appBar: AppBar(title: Text(strings.editHouseholdTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                children: [
                  TextFormField(
                    controller: _houseName,
                    decoration: InputDecoration(labelText: strings.houseName),
                    textCapitalization: TextCapitalization.words,
                    validator: _required,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _houseNumber,
                    decoration: InputDecoration(labelText: strings.houseNumber),
                    textCapitalization: TextCapitalization.characters,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _addressLine,
                    decoration: InputDecoration(labelText: strings.addressLine),
                    maxLines: 2,
                    textCapitalization: TextCapitalization.words,
                    validator: _required,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _locality,
                    decoration: InputDecoration(labelText: strings.locality),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _postOffice,
                    decoration: InputDecoration(labelText: strings.postOffice),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _pincode,
                    decoration: InputDecoration(labelText: strings.pincode),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _contactPhone,
                    decoration: InputDecoration(
                      labelText: strings.contactPhone,
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  InputDecorator(
                    decoration: InputDecoration(
                      labelText: strings.rationCardType,
                      helperText: widget.household.rationCardReviewRequired
                          ? strings.rationCardEditUseReview
                          : null,
                    ),
                    child: Text(
                      rationCardLabel(strings, widget.household.rationCardType),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<bool>(
                    initialValue: _hasOwnWell,
                    decoration: InputDecoration(labelText: strings.hasOwnWell),
                    items: [
                      DropdownMenuItem(value: true, child: Text(strings.yes)),
                      DropdownMenuItem(value: false, child: Text(strings.no)),
                    ],
                    validator: (value) =>
                        value == null ? strings.requiredField : null,
                    onChanged: (value) => setState(() => _hasOwnWell = value),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<HouseType>(
                    initialValue: _houseType,
                    decoration: InputDecoration(labelText: strings.houseType),
                    items: HouseType.values
                        .map(
                          (type) => DropdownMenuItem(
                            value: type,
                            child: Text(houseTypeLabel(strings, type)),
                          ),
                        )
                        .toList(growable: false),
                    validator: (value) =>
                        value == null ? strings.requiredField : null,
                    onChanged: (value) => setState(() => _houseType = value),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _notes,
                    decoration: InputDecoration(labelText: strings.notes),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(strings.saveHouseholdChanges),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
