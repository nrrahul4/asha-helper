import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:sqflite_sqlcipher/sqflite.dart' as sqlcipher;

import 'data/database/app_database.dart';
import 'data/database/database_key_store.dart';
import 'data/repositories/household_repository.dart';
import 'data/repositories/family_report_repository.dart';
import 'data/repositories/member_repository.dart';
import 'data/repositories/local_backup_repository.dart';
import 'features/backup/domain/encrypted_backup_service.dart';
import 'features/households/domain/household_registration_service.dart';
import 'features/households/domain/member_management_service.dart';
import 'features/households/domain/member_search_service.dart';
import 'features/households/presentation/household_list_screen.dart';
import 'l10n/generated/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    final databaseDirectory = await sqlcipher.getDatabasesPath();
    final databasePath = '$databaseDirectory/family_tracker.db';
    final databaseExists = await File(databasePath).exists();
    final encryptionKey = await DatabaseKeyStore(FlutterSecureValueStore())
        .readOrCreate(databaseExists: databaseExists);
    final database = AppDatabase(
      path: databasePath,
      encryptionKey: encryptionKey,
    );
    await database.database;

    final householdRepository = HouseholdRepository(database);
    final memberRepository = MemberRepository(database);
    runApp(
      MyApp(
        householdRepository: householdRepository,
        reportsRepository: FamilyReportRepository(database),
        memberRepository: memberRepository,
        registrationService: HouseholdRegistrationService(householdRepository),
        memberService: MemberManagementService(memberRepository),
        memberSearchService: MemberSearchService(memberRepository),
        backupRepository: LocalBackupRepository(database),
        backupEncryptionService: EncryptedBackupService(),
      ),
    );
  } catch (_) {
    runApp(const _DatabaseUnavailableApp());
  }
}

class MyApp extends StatefulWidget {
  const MyApp({
    required this.householdRepository,
    required this.reportsRepository,
    required this.registrationService,
    required this.memberRepository,
    required this.memberService,
    required this.memberSearchService,
    required this.backupRepository,
    required this.backupEncryptionService,
    super.key,
  });

  final HouseholdRepository householdRepository;
  final FamilyReportRepository reportsRepository;
  final HouseholdRegistrationService registrationService;
  final MemberRepository memberRepository;
  final MemberManagementService memberService;
  final MemberSearchService memberSearchService;
  final LocalBackupRepository backupRepository;
  final EncryptedBackupService backupEncryptionService;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final LocalAuthentication _localAuthentication = LocalAuthentication();
  bool _isUnlocked = false;
  bool _isAuthenticating = false;
  bool _storageProtectionReady = !Platform.isIOS;
  bool _storageProtectionFailed = false;
  String? _authenticationError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (Platform.isIOS) _configureIosStorageProtection();
  }

  Future<void> _configureIosStorageProtection() async {
    try {
      await const MethodChannel('family_tracker/storage_security')
          .invokeMethod<void>('excludePrivateDataFromBackup');
      if (mounted) setState(() => _storageProtectionReady = true);
    } on PlatformException {
      if (mounted) setState(() => _storageProtectionFailed = true);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed && _isUnlocked) {
      setState(() {
        _isUnlocked = false;
        _authenticationError = null;
      });
    }
  }

  Future<void> _authenticate(AppLocalizations strings) async {
    if (_isAuthenticating) return;
    setState(() {
      _isAuthenticating = true;
      _authenticationError = null;
    });

    try {
      final authenticated = await _localAuthentication.authenticate(
        localizedReason: strings.unlockReason,
        persistAcrossBackgrounding: true,
      );
      if (!mounted) return;
      setState(() {
        _isUnlocked = authenticated;
        if (!authenticated) {
          _authenticationError = strings.authenticationNotCompleted;
        }
      });
    } on LocalAuthException catch (error) {
      if (!mounted) return;
      setState(() {
        _authenticationError = switch (error.code) {
          LocalAuthExceptionCode.noCredentialsSet ||
          LocalAuthExceptionCode.noBiometricHardware ||
          LocalAuthExceptionCode.noBiometricsEnrolled =>
            strings.deviceAuthenticationUnavailable,
          LocalAuthExceptionCode.userCanceled ||
          LocalAuthExceptionCode.systemCanceled => null,
          _ => strings.authenticationFailed,
        };
      });
    } on PlatformException {
      if (!mounted) return;
      setState(() => _authenticationError = strings.authenticationFailed);
    } finally {
      if (mounted) setState(() => _isAuthenticating = false);
    }
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: _appTheme,
    home: Builder(
      builder: (context) {
        final strings = AppLocalizations.of(context)!;
        if (_storageProtectionFailed) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  strings.databaseUnavailable,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }
        if (!_storageProtectionReady) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return _isUnlocked
            ? HouseholdListScreen(
                householdRepository: widget.householdRepository,
                reportsRepository: widget.reportsRepository,
                registrationService: widget.registrationService,
                memberRepository: widget.memberRepository,
                memberService: widget.memberService,
                memberSearchService: widget.memberSearchService,
                backupRepository: widget.backupRepository,
                backupEncryptionService: widget.backupEncryptionService,
              )
            : _AppLockScreen(
                isAuthenticating: _isAuthenticating,
                errorMessage: _authenticationError,
                onUnlock: () => _authenticate(strings),
              );
      },
    ),
  );
}

class _AppLockScreen extends StatelessWidget {
  const _AppLockScreen({
    required this.isAuthenticating,
    required this.errorMessage,
    required this.onUnlock,
  });

  final bool isAuthenticating;
  final String? errorMessage;
  final VoidCallback onUnlock;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    strings.appLocked,
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  if (errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: isAuthenticating ? null : onUnlock,
                    icon: isAuthenticating
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.fingerprint),
                    label: Text(
                      isAuthenticating
                          ? strings.authenticating
                          : strings.unlockApp,
                    ),
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

class _DatabaseUnavailableApp extends StatelessWidget {
  const _DatabaseUnavailableApp();

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: _appTheme,
      home: Scaffold(
        appBar: AppBar(title: Text(strings.appTitle)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.storage_rounded,
                  size: 40,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(strings.databaseUnavailable, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final ThemeData _appTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xff27695f),
    brightness: Brightness.light,
  ),
  scaffoldBackgroundColor: const Color(0xfff6f8f6),
  appBarTheme: const AppBarTheme(centerTitle: false),
  inputDecorationTheme: const InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(6)),
    ),
  ),
);
