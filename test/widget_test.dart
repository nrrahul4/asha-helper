// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:family_tracker/data/database/app_database.dart';
import 'package:family_tracker/data/models/database_codes.dart';
import 'package:family_tracker/data/models/member.dart';
import 'package:family_tracker/data/repositories/household_repository.dart';
import 'package:family_tracker/data/repositories/member_repository.dart';
import 'package:family_tracker/features/households/domain/household_registration_service.dart';
import 'package:family_tracker/features/households/domain/member_management_service.dart';
import 'package:family_tracker/features/households/domain/member_search_service.dart';
import 'package:family_tracker/features/households/presentation/household_registration_screen.dart';
import 'package:family_tracker/features/households/presentation/member_search_screen.dart';
import 'package:family_tracker/features/households/presentation/member_form_screen.dart';
import 'package:family_tracker/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('registration form shows all required field errors', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_registrationApp());
    final strings = AppLocalizations.of(
      tester.element(find.byType(HouseholdRegistrationScreen)),
    )!;

    await tester.ensureVisible(find.byKey(const Key('save-household-button')));
    await tester.tap(find.byKey(const Key('save-household-button')));
    await tester.pumpAndSettle();

    expect(find.text(strings.requiredField), findsNWidgets(8));
    expect(find.text(strings.futureDateError), findsNothing);
  });

  testWidgets('registration form presents Malayalam labels', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_registrationApp(locale: const Locale('ml')));

    expect(find.text('വീട്ടുപേര്'), findsOneWidget);
    expect(find.text('കുടുംബനാഥൻ / നാഥ'), findsOneWidget);
  });

  testWidgets(
    'member form validates required fields and leaves phone optional',
    (WidgetTester tester) async {
      await tester.pumpWidget(_memberApp());
      final strings = AppLocalizations.of(
        tester.element(find.byType(MemberFormScreen)),
      )!;

      await tester.ensureVisible(find.byKey(const Key('save-member-button')));
      await tester.tap(find.byKey(const Key('save-member-button')));
      await tester.pumpAndSettle();

      expect(find.text(strings.requiredField), findsNWidgets(4));
      expect(find.text(strings.memberPhoneInvalid), findsNothing);
    },
  );

  testWidgets('member form validates non-empty phone text', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_memberApp());
    final strings = AppLocalizations.of(
      tester.element(find.byType(MemberFormScreen)),
    )!;

    await tester.ensureVisible(find.byKey(const Key('member-phone-field')));
    await tester.enterText(
      find.byKey(const Key('member-phone-field')),
      'call me',
    );
    await tester.ensureVisible(find.byKey(const Key('save-member-button')));
    await tester.tap(find.byKey(const Key('save-member-button')));
    await tester.pumpAndSettle();

    expect(find.text(strings.memberPhoneInvalid), findsOneWidget);
  });

  testWidgets('head relationship is fixed and cannot be changed', (
    WidgetTester tester,
  ) async {
    final head = Member.createHead(
      householdId: 'household-1',
      fullName: 'Family head',
      dateOfBirth: DateTime(1970, 1, 1),
      gender: Gender.female,
    );
    await tester.pumpWidget(_memberApp(member: head));
    final strings = AppLocalizations.of(
      tester.element(find.byType(MemberFormScreen)),
    )!;

    expect(find.text(strings.relationshipToHead), findsOneWidget);
    expect(find.text(strings.relationshipHead), findsOneWidget);
    expect(find.byKey(const Key('member-relationship-field')), findsNothing);
  });

  testWidgets('search filters render and reset all selected criteria', (
    WidgetTester tester,
  ) async {
    sqfliteFfiInit();
    final database = AppDatabase(
      path: inMemoryDatabasePath,
      encryptionKey: 'widget-test-key',
      opener: _openFfiDatabase,
    );
    addTearDown(database.close);
    final householdRepository = HouseholdRepository(database);
    final memberRepository = MemberRepository(database);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MemberSearchScreen(
          householdRepository: householdRepository,
          memberRepository: memberRepository,
          memberSearchService: MemberSearchService(memberRepository),
          memberService: MemberManagementService(memberRepository),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('people-search-field')), findsOneWidget);
    expect(find.byKey(const Key('minimum-age-field')), findsOneWidget);
    expect(find.byKey(const Key('maximum-age-field')), findsOneWidget);
    expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);

    final pregnancyFilter = find.byKey(const Key('currently-pregnant-filter'));
    expect(pregnancyFilter, findsOneWidget);
    await tester.ensureVisible(pregnancyFilter);
    await tester.pumpAndSettle();
    await tester.tap(pregnancyFilter);
    await tester.pumpAndSettle();
    expect(tester.widget<FilterChip>(pregnancyFilter).selected, isTrue);

    final femaleFilter = find.byKey(const Key('gender-filter-female'));
    await tester.ensureVisible(femaleFilter);
    await tester.tap(femaleFilter);
    await tester.enterText(find.byKey(const Key('people-search-field')), 'Anu');
    expect(tester.widget<FilterChip>(femaleFilter).selected, isTrue);

    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    final resetButton = find.byKey(const Key('reset-search-filters-button'));
    await tester.scrollUntilVisible(
      resetButton,
      100,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(resetButton);
    await tester.pumpAndSettle();

    expect(tester.widget<FilterChip>(femaleFilter).selected, isFalse);
    expect(tester.widget<FilterChip>(pregnancyFilter).selected, isFalse);
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('people-search-field')))
          .controller
          ?.text,
      isEmpty,
    );
  });
}

Widget _registrationApp({Locale? locale}) {
  final repository = HouseholdRepository(
    AppDatabase(path: 'unused', encryptionKey: 'unused'),
  );
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: HouseholdRegistrationScreen(
      registrationService: HouseholdRegistrationService(repository),
    ),
  );
}

Widget _memberApp({Member? member, Locale? locale}) {
  final repository = MemberRepository(
    AppDatabase(path: 'unused', encryptionKey: 'unused'),
  );
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: MemberFormScreen(
      householdId: 'household-1',
      memberService: MemberManagementService(repository),
      member: member,
    ),
  );
}

Future<Database> _openFfiDatabase(
  String path, {
  required String password,
  required int version,
  OnDatabaseConfigureFn? onConfigure,
  OnDatabaseCreateFn? onCreate,
  OnDatabaseVersionChangeFn? onUpgrade,
}) => databaseFactoryFfi.openDatabase(
  path,
  options: OpenDatabaseOptions(
    version: version,
    onConfigure: onConfigure,
    onCreate: onCreate,
    onUpgrade: onUpgrade,
  ),
);
