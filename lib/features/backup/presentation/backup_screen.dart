import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../data/models/backup_snapshot.dart';
import '../../../data/repositories/local_backup_repository.dart'
    show
        BackupExportHousehold,
        BackupRestoreMode,
        BackupRestorePreview,
        CsvExportField,
        LocalBackupRepository;
import '../../../l10n/generated/app_localizations.dart';
import '../domain/encrypted_backup_service.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({
    required this.repository,
    required this.encryptionService,
    this.selectedMemberIds,
    this.csvOnly = false,
    super.key,
  });

  final LocalBackupRepository repository;
  final EncryptedBackupService encryptionService;
  final Set<String>? selectedMemberIds;
  final bool csvOnly;

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  bool _busy = false;

  Future<void> _exportCsv() async {
    final strings = AppLocalizations.of(context)!;
    Set<String> householdIds = const {};
    if (widget.selectedMemberIds == null) {
      final households = await widget.repository
          .listActiveHouseholdsForExport();
      if (!mounted) return;
      if (households.isEmpty) {
        _showMessage(strings.csvNoHouseholds);
        return;
      }
      final selected = await _chooseHouseholds(strings, households);
      if (selected == null || !mounted) return;
      householdIds = selected;
    }
    final fields = await _chooseCsvFields(strings);
    if (fields == null || !mounted) return;
    if (fields.any((field) => field.isSensitive) &&
        !await _confirmSensitiveExport(strings)) {
      return;
    }
    if (!mounted) return;
    setState(() => _busy = true);
    File? exportFile;
    try {
      final csv = await widget.repository.exportCsv(
        fields,
        householdIds: householdIds,
        memberIds: widget.selectedMemberIds,
        headers: {
          for (final field in fields) field: _csvFieldLabel(strings, field),
        },
      );
      final directory = await getTemporaryDirectory();
      final file = File(
        '${directory.path}/family_tracker_export_${DateTime.now().toUtc().millisecondsSinceEpoch}.csv',
      );
      exportFile = file;
      await file.writeAsString(csv, flush: true);
      if (!mounted) return;
      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)], text: strings.csvShareMessage),
      );
    } catch (_) {
      if (mounted) _showMessage(strings.backupOperationFailed);
    } finally {
      await _deleteTemporaryExport(exportFile);
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<Set<String>?> _chooseHouseholds(
    AppLocalizations strings,
    List<BackupExportHousehold> households,
  ) {
    final selected = households.map((household) => household.id).toSet();
    return showDialog<Set<String>>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(strings.csvSelectHouseholdsTitle),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(strings.csvSelectHouseholdsHint),
                const SizedBox(height: 8),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(strings.csvSelectAll),
                        value: selected.length == households.length,
                        onChanged: (checked) => setDialogState(() {
                          if (checked == true) {
                            selected.addAll(
                              households.map((household) => household.id),
                            );
                          } else {
                            selected.clear();
                          }
                        }),
                      ),
                      const Divider(),
                      for (final household in households)
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(household.displayName),
                          value: selected.contains(household.id),
                          onChanged: (checked) => setDialogState(() {
                            if (checked == true) {
                              selected.add(household.id);
                            } else {
                              selected.remove(household.id);
                            }
                          }),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(strings.cancel),
            ),
            FilledButton(
              onPressed: selected.isEmpty
                  ? null
                  : () => Navigator.pop(dialogContext, {...selected}),
              child: Text(strings.continueAction),
            ),
          ],
        ),
      ),
    );
  }

  Future<Set<CsvExportField>?> _chooseCsvFields(
    AppLocalizations strings,
  ) async {
    final selected = CsvExportField.values
        .where((field) => !field.isSensitive)
        .toSet();
    return showDialog<Set<CsvExportField>>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(strings.csvExportTitle),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(strings.csvPrivacyNotice),
                const SizedBox(height: 8),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (final field in CsvExportField.values)
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          title: Text(_csvFieldLabel(strings, field)),
                          value: selected.contains(field),
                          onChanged: (checked) => setDialogState(() {
                            if (checked == true) {
                              selected.add(field);
                            } else {
                              selected.remove(field);
                            }
                          }),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(strings.cancel),
            ),
            FilledButton(
              onPressed: selected.isEmpty
                  ? null
                  : () => Navigator.pop(dialogContext, selected),
              child: Text(strings.csvExportAction),
            ),
          ],
        ),
      ),
    );
  }

  String _csvFieldLabel(
    AppLocalizations strings,
    CsvExportField field,
  ) => switch (field) {
    CsvExportField.householdName => strings.houseName,
    CsvExportField.houseNumber => strings.houseNumberLabel,
    CsvExportField.address => strings.addressLine,
    CsvExportField.locality => strings.locality,
    CsvExportField.postOffice => strings.postOffice,
    CsvExportField.pincode => strings.pincode,
    CsvExportField.householdPhone => strings.contactPhone,
    CsvExportField.rationCardType => strings.rationCardType,
    CsvExportField.wellOwnership => strings.wellOwnership,
    CsvExportField.houseType => strings.houseTypeLabel,
    CsvExportField.memberName => strings.memberName,
    CsvExportField.dateOfBirth => strings.dateOfBirth,
    CsvExportField.gender => strings.gender,
    CsvExportField.relationshipToHead => strings.relationshipToHead,
    CsvExportField.memberPhone => strings.personPhone,
    CsvExportField.aadhaar => strings.aadhaarNumber,
    CsvExportField.cancerStatus => strings.hasCancer,
    CsvExportField.asthmaStatus => strings.hasAsthma,
    CsvExportField.heartDiseaseStatus => strings.hasHeartDisease,
    CsvExportField.otherIllnesses => strings.existingIllnesses,
    CsvExportField.marriageStatus => strings.maritalStatus,
    CsvExportField.marriageDate => strings.marriageDateUnknown,
    CsvExportField.premaritalCounselling => strings.premaritalCounselling,
    CsvExportField.pregnancyLastMenses => strings.pregnancyLmp,
    CsvExportField.pregnancyAbaId => strings.pregnancyAbaId,
    CsvExportField.pregnancyHospital => strings.pregnancyHospital,
    CsvExportField.previousPregnancies => strings.previousPregnancyCount,
    CsvExportField.childBirthWeight => strings.childBirthWeight,
    CsvExportField.childDeliveryType => strings.childDeliveryType,
    CsvExportField.familyPlanningIntention => strings.familyPlanningIntention,
    CsvExportField.familyPlanningMethod => strings.familyPlanningMethod,
    CsvExportField.familyPlanningActionDate => strings.familyPlanningActionDate,
    CsvExportField.specialCareDetails => strings.specialCareDetails,
  };

  Future<bool> _confirmSensitiveExport(AppLocalizations strings) async =>
      await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(strings.csvSensitiveConfirmTitle),
          content: Text(strings.csvSensitiveConfirmMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(strings.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(strings.csvSensitiveConfirmAction),
            ),
          ],
        ),
      ) ??
      false;

  Future<void> _createBackup() async {
    final strings = AppLocalizations.of(context)!;
    final passphrase = await _requestPassphrase(strings, confirm: true);
    if (passphrase == null || !mounted) return;
    setState(() => _busy = true);
    File? backupFile;
    try {
      final snapshot = await widget.repository.capture();
      final contents = await widget.encryptionService.encrypt(
        snapshot,
        passphrase,
      );
      final directory = await getTemporaryDirectory();
      final file = File(
        '${directory.path}/family_tracker_${DateTime.now().toUtc().millisecondsSinceEpoch}.ftbackup',
      );
      backupFile = file;
      await file.writeAsBytes(contents, flush: true);
      if (!mounted) return;
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: strings.backupShareMessage,
        ),
      );
    } catch (_) {
      if (mounted) _showMessage(strings.backupOperationFailed);
    } finally {
      await _deleteTemporaryExport(backupFile);
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _deleteTemporaryExport(File? file) async {
    if (file == null) return;
    try {
      if (await file.exists()) await file.delete();
    } on FileSystemException {
      if (mounted) {
        _showMessage(AppLocalizations.of(context)!.backupOperationFailed);
      }
    }
  }

  Future<void> _restoreBackup() async {
    final strings = AppLocalizations.of(context)!;
    try {
      final picked = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['ftbackup'],
      );
      if (picked.isEmpty || !mounted) return;
      final fileLength = await picked.single.length();
      if (fileLength == null ||
          fileLength > EncryptedBackupService.maxBackupFileBytes) {
        _showMessage(strings.backupFileInvalid);
        return;
      }
      final contents = await picked.single.readAsBytes();
      if (!mounted) return;
      if (contents.isEmpty) {
        _showMessage(strings.backupFileReadFailed);
        return;
      }
      final passphrase = await _requestPassphrase(strings);
      if (passphrase == null || !mounted) return;
      setState(() => _busy = true);
      await _restoreContents(contents, passphrase, strings);
    } catch (_) {
      if (mounted) _showMessage(strings.backupFileReadFailed);
    }
  }

  Future<void> _restoreContents(
    List<int> contents,
    String passphrase,
    AppLocalizations strings,
  ) async {
    try {
      final snapshot = await widget.encryptionService.decrypt(
        contents,
        passphrase,
      );
      final preview = await widget.repository.preview(snapshot);
      if (!mounted) return;
      final mode = await _chooseRestoreMode(strings, preview);
      if (mode == null || !mounted) return;
      if (mode == BackupRestoreMode.replace &&
          !await _confirmReplace(strings)) {
        return;
      }
      final result = await widget.repository.restore(snapshot, mode);
      if (mounted) {
        _showMessage(
          strings.backupRestoreComplete(
            result.importedRows,
            result.skippedRows,
          ),
        );
      }
    } on BackupAuthenticationException {
      if (mounted) _showMessage(strings.backupAuthenticationFailed);
    } on BackupFormatException {
      if (mounted) _showMessage(strings.backupFileInvalid);
    } catch (_) {
      if (mounted) _showMessage(strings.backupOperationFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<String?> _requestPassphrase(
    AppLocalizations strings, {
    bool confirm = false,
  }) async {
    final controller = TextEditingController();
    final confirmationController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          confirm ? strings.backupCreateTitle : strings.backupPassphraseTitle,
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(strings.backupPassphraseHint),
              const SizedBox(height: 16),
              TextFormField(
                controller: controller,
                obscureText: true,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: strings.backupPassphraseLabel,
                ),
                validator: (value) {
                  final length = value?.length ?? 0;
                  if (length < 12 || length > 1024) {
                    return strings.backupPassphraseInvalid;
                  }
                  return null;
                },
              ),
              if (confirm) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: confirmationController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: strings.backupPassphraseConfirm,
                  ),
                  validator: (value) => value == controller.text
                      ? null
                      : strings.backupPassphraseMismatch,
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(strings.cancel),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(dialogContext, controller.text);
              }
            },
            child: Text(strings.continueAction),
          ),
        ],
      ),
    );
    controller.dispose();
    confirmationController.dispose();
    return result;
  }

  Future<BackupRestoreMode?> _chooseRestoreMode(
    AppLocalizations strings,
    BackupRestorePreview preview,
  ) => showDialog<BackupRestoreMode>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(strings.backupRestorePreviewTitle),
      content: Text(
        strings.backupRestorePreview(
          preview.householdsInBackup,
          preview.membersInBackup,
          preview.householdIdConflicts,
          preview.memberIdConflicts,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text(strings.cancel),
        ),
        OutlinedButton(
          onPressed: () =>
              Navigator.pop(dialogContext, BackupRestoreMode.merge),
          child: Text(strings.backupMergeAction),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.pop(dialogContext, BackupRestoreMode.replace),
          child: Text(strings.backupReplaceAction),
        ),
      ],
    ),
  );

  Future<bool> _confirmReplace(AppLocalizations strings) async =>
      await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(strings.backupReplaceConfirmTitle),
          content: Text(strings.backupReplaceConfirmMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(strings.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(strings.backupReplaceAction),
            ),
          ],
        ),
      ) ??
      false;

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.csvOnly ? strings.csvExportMatchesTitle : strings.backupTitle,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (!widget.csvOnly) ...[
            Text(strings.backupPrivacyNotice),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _busy ? null : _createBackup,
              icon: const Icon(Icons.lock_outline),
              label: Text(strings.backupCreateAction),
            ),
            const SizedBox(height: 12),
          ],
          OutlinedButton.icon(
            onPressed: _busy ? null : _exportCsv,
            icon: const Icon(Icons.table_view_outlined),
            label: Text(strings.csvExportTitle),
          ),
          if (!widget.csvOnly) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _busy ? null : _restoreBackup,
              icon: const Icon(Icons.restore),
              label: Text(strings.backupRestoreAction),
            ),
          ],
          if (_busy) ...[
            const SizedBox(height: 24),
            const Center(child: CircularProgressIndicator()),
          ],
        ],
      ),
    );
  }
}
