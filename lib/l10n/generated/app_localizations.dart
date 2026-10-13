import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ml.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ml'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Asha Helper'**
  String get appTitle;

  /// No description provided for @householdsTitle.
  ///
  /// In en, this message translates to:
  /// **'Households'**
  String get householdsTitle;

  /// No description provided for @registerHouseholdTitle.
  ///
  /// In en, this message translates to:
  /// **'Register household'**
  String get registerHouseholdTitle;

  /// No description provided for @registerHouseholdAction.
  ///
  /// In en, this message translates to:
  /// **'Register household'**
  String get registerHouseholdAction;

  /// No description provided for @householdDetails.
  ///
  /// In en, this message translates to:
  /// **'Household details'**
  String get householdDetails;

  /// No description provided for @headDetails.
  ///
  /// In en, this message translates to:
  /// **'Head of family'**
  String get headDetails;

  /// No description provided for @houseName.
  ///
  /// In en, this message translates to:
  /// **'House name'**
  String get houseName;

  /// No description provided for @houseNumber.
  ///
  /// In en, this message translates to:
  /// **'House number'**
  String get houseNumber;

  /// No description provided for @addressLine.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get addressLine;

  /// No description provided for @locality.
  ///
  /// In en, this message translates to:
  /// **'Locality / ward'**
  String get locality;

  /// No description provided for @postOffice.
  ///
  /// In en, this message translates to:
  /// **'Post office'**
  String get postOffice;

  /// No description provided for @pincode.
  ///
  /// In en, this message translates to:
  /// **'PIN code'**
  String get pincode;

  /// No description provided for @contactPhone.
  ///
  /// In en, this message translates to:
  /// **'Household contact phone'**
  String get contactPhone;

  /// No description provided for @rationCardType.
  ///
  /// In en, this message translates to:
  /// **'Ration card type'**
  String get rationCardType;

  /// No description provided for @rationBpl.
  ///
  /// In en, this message translates to:
  /// **'BPL'**
  String get rationBpl;

  /// No description provided for @rationApl.
  ///
  /// In en, this message translates to:
  /// **'APL'**
  String get rationApl;

  /// No description provided for @rationAay.
  ///
  /// In en, this message translates to:
  /// **'AAY'**
  String get rationAay;

  /// No description provided for @rationCardReviewRequired.
  ///
  /// In en, this message translates to:
  /// **'Ration-card category needs review'**
  String get rationCardReviewRequired;

  /// No description provided for @reviewRationCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Review ration-card category'**
  String get reviewRationCardTitle;

  /// No description provided for @reviewRationCardMessage.
  ///
  /// In en, this message translates to:
  /// **'The previous category was {category}. Choose the correct BPL, APL, or AAY category; no category has been assigned automatically.'**
  String reviewRationCardMessage(Object category);

  /// No description provided for @reviewRationCardAction.
  ///
  /// In en, this message translates to:
  /// **'Review category'**
  String get reviewRationCardAction;

  /// No description provided for @rationCardUpdated.
  ///
  /// In en, this message translates to:
  /// **'Ration-card category updated.'**
  String get rationCardUpdated;

  /// No description provided for @rationCardUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not update the ration-card category. Existing data is unchanged.'**
  String get rationCardUpdateFailed;

  /// No description provided for @memberGeneralDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'General member details'**
  String get memberGeneralDetailsTitle;

  /// No description provided for @aadhaarNumber.
  ///
  /// In en, this message translates to:
  /// **'Aadhaar number (optional)'**
  String get aadhaarNumber;

  /// No description provided for @aadhaarRevealTitle.
  ///
  /// In en, this message translates to:
  /// **'Reveal Aadhaar number?'**
  String get aadhaarRevealTitle;

  /// No description provided for @aadhaarRevealMessage.
  ///
  /// In en, this message translates to:
  /// **'The full Aadhaar number will be visible on this screen until hidden or closed.'**
  String get aadhaarRevealMessage;

  /// No description provided for @revealAadhaar.
  ///
  /// In en, this message translates to:
  /// **'Reveal'**
  String get revealAadhaar;

  /// No description provided for @hideAadhaar.
  ///
  /// In en, this message translates to:
  /// **'Hide Aadhaar number'**
  String get hideAadhaar;

  /// No description provided for @aadhaarInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter exactly 12 digits.'**
  String get aadhaarInvalid;

  /// No description provided for @optionalField.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optionalField;

  /// No description provided for @educationLevel.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get educationLevel;

  /// No description provided for @jobTitle.
  ///
  /// In en, this message translates to:
  /// **'Job / occupation'**
  String get jobTitle;

  /// No description provided for @currentlyWorkingAbroad.
  ///
  /// In en, this message translates to:
  /// **'Currently working abroad'**
  String get currentlyWorkingAbroad;

  /// No description provided for @bloodGroup.
  ///
  /// In en, this message translates to:
  /// **'Blood group'**
  String get bloodGroup;

  /// No description provided for @pregnancyDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Pregnancy details'**
  String get pregnancyDetailsTitle;

  /// No description provided for @pregnancyAbaId.
  ///
  /// In en, this message translates to:
  /// **'ABA ID (optional)'**
  String get pregnancyAbaId;

  /// No description provided for @pregnancyLmp.
  ///
  /// In en, this message translates to:
  /// **'First day of last menstrual period (LMP)'**
  String get pregnancyLmp;

  /// No description provided for @pregnancyHospital.
  ///
  /// In en, this message translates to:
  /// **'Consulting hospital (optional)'**
  String get pregnancyHospital;

  /// No description provided for @previousPregnancyCount.
  ///
  /// In en, this message translates to:
  /// **'Previous pregnancy count'**
  String get previousPregnancyCount;

  /// No description provided for @previousPregnancyCountHelp.
  ///
  /// In en, this message translates to:
  /// **'Include all previous pregnancies, excluding the current one.'**
  String get previousPregnancyCountHelp;

  /// No description provided for @lastLiveBirthDate.
  ///
  /// In en, this message translates to:
  /// **'Most recent live-birth date (optional)'**
  String get lastLiveBirthDate;

  /// No description provided for @pregnancyFirstTrimester.
  ///
  /// In en, this message translates to:
  /// **'First trimester'**
  String get pregnancyFirstTrimester;

  /// No description provided for @pregnancySecondTrimester.
  ///
  /// In en, this message translates to:
  /// **'Second trimester'**
  String get pregnancySecondTrimester;

  /// No description provided for @pregnancyThirdTrimester.
  ///
  /// In en, this message translates to:
  /// **'Third trimester'**
  String get pregnancyThirdTrimester;

  /// No description provided for @pregnancyEstimate.
  ///
  /// In en, this message translates to:
  /// **'Approximate: {weeks} completed weeks — {trimester}'**
  String pregnancyEstimate(int weeks, String trimester);

  /// No description provided for @pregnancyEstimateUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unable to calculate an estimate from this LMP.'**
  String get pregnancyEstimateUnavailable;

  /// No description provided for @pregnancyEstimateDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'This is an approximate administrative estimate, not a clinical determination. Please confirm with a health professional.'**
  String get pregnancyEstimateDisclaimer;

  /// No description provided for @pregnancyFutureDate.
  ///
  /// In en, this message translates to:
  /// **'The date cannot be in the future.'**
  String get pregnancyFutureDate;

  /// No description provided for @pregnancyCountInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a non-negative whole number.'**
  String get pregnancyCountInvalid;

  /// No description provided for @savePregnancyDetails.
  ///
  /// In en, this message translates to:
  /// **'Save pregnancy details'**
  String get savePregnancyDetails;

  /// No description provided for @pregnancyDetailsSaved.
  ///
  /// In en, this message translates to:
  /// **'Pregnancy details saved.'**
  String get pregnancyDetailsSaved;

  /// No description provided for @pregnancyDetailsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Pregnancy details could not be loaded. Existing data is unchanged.'**
  String get pregnancyDetailsLoadFailed;

  /// No description provided for @pregnancyDetailsSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Pregnancy details could not be saved. Existing data is unchanged.'**
  String get pregnancyDetailsSaveFailed;

  /// No description provided for @childBirthDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Child birth details'**
  String get childBirthDetailsTitle;

  /// No description provided for @childBirthDetailsAgeNotice.
  ///
  /// In en, this message translates to:
  /// **'Birth details are collected for children under five. Any previously saved details are retained.'**
  String get childBirthDetailsAgeNotice;

  /// No description provided for @childBirthWeight.
  ///
  /// In en, this message translates to:
  /// **'Birth weight (kg, optional)'**
  String get childBirthWeight;

  /// No description provided for @childBirthWeightHelp.
  ///
  /// In en, this message translates to:
  /// **'Accepted range: 0.3–8.0 kg.'**
  String get childBirthWeightHelp;

  /// No description provided for @childBirthTime.
  ///
  /// In en, this message translates to:
  /// **'Birth time (optional)'**
  String get childBirthTime;

  /// No description provided for @childDeliveryType.
  ///
  /// In en, this message translates to:
  /// **'Delivery type'**
  String get childDeliveryType;

  /// No description provided for @deliveryVaginal.
  ///
  /// In en, this message translates to:
  /// **'Vaginal'**
  String get deliveryVaginal;

  /// No description provided for @deliveryCaesarean.
  ///
  /// In en, this message translates to:
  /// **'Caesarean'**
  String get deliveryCaesarean;

  /// No description provided for @childSpecialCareRequired.
  ///
  /// In en, this message translates to:
  /// **'Special care required (under one year)'**
  String get childSpecialCareRequired;

  /// No description provided for @childSpecialCareDetails.
  ///
  /// In en, this message translates to:
  /// **'Special care details'**
  String get childSpecialCareDetails;

  /// No description provided for @childBirthWeightOutOfRange.
  ///
  /// In en, this message translates to:
  /// **'Enter a birth weight from 0.3 to 8.0 kg.'**
  String get childBirthWeightOutOfRange;

  /// No description provided for @childBirthTimeInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid birth time.'**
  String get childBirthTimeInvalid;

  /// No description provided for @childSpecialCareAnswerRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose yes or no for special care.'**
  String get childSpecialCareAnswerRequired;

  /// No description provided for @childSpecialCareDetailsRequired.
  ///
  /// In en, this message translates to:
  /// **'Describe the special care required.'**
  String get childSpecialCareDetailsRequired;

  /// No description provided for @saveChildBirthDetails.
  ///
  /// In en, this message translates to:
  /// **'Save child details'**
  String get saveChildBirthDetails;

  /// No description provided for @childBirthDetailsSaved.
  ///
  /// In en, this message translates to:
  /// **'Child birth details saved.'**
  String get childBirthDetailsSaved;

  /// No description provided for @childBirthDetailsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Child birth details could not be loaded. Existing data is unchanged.'**
  String get childBirthDetailsLoadFailed;

  /// No description provided for @childBirthDetailsSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Child birth details could not be saved. Existing data is unchanged.'**
  String get childBirthDetailsSaveFailed;

  /// No description provided for @healthMarriageDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Health and marriage details'**
  String get healthMarriageDetailsTitle;

  /// No description provided for @existingIllnesses.
  ///
  /// In en, this message translates to:
  /// **'Existing illnesses'**
  String get existingIllnesses;

  /// No description provided for @illnessDiabetes.
  ///
  /// In en, this message translates to:
  /// **'Diabetes'**
  String get illnessDiabetes;

  /// No description provided for @illnessBloodPressure.
  ///
  /// In en, this message translates to:
  /// **'Blood pressure'**
  String get illnessBloodPressure;

  /// No description provided for @illnessCholesterol.
  ///
  /// In en, this message translates to:
  /// **'Cholesterol'**
  String get illnessCholesterol;

  /// No description provided for @illnessOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get illnessOther;

  /// No description provided for @otherIllnessDetails.
  ///
  /// In en, this message translates to:
  /// **'Other illness details'**
  String get otherIllnessDetails;

  /// No description provided for @otherIllnessRequired.
  ///
  /// In en, this message translates to:
  /// **'Describe the illness when Other is selected.'**
  String get otherIllnessRequired;

  /// No description provided for @hasCancer.
  ///
  /// In en, this message translates to:
  /// **'Cancer'**
  String get hasCancer;

  /// No description provided for @hasAsthma.
  ///
  /// In en, this message translates to:
  /// **'Asthma'**
  String get hasAsthma;

  /// No description provided for @hasHeartDisease.
  ///
  /// In en, this message translates to:
  /// **'Heart disease'**
  String get hasHeartDisease;

  /// No description provided for @maritalStatus.
  ///
  /// In en, this message translates to:
  /// **'Marital status'**
  String get maritalStatus;

  /// No description provided for @marriageDateUnknown.
  ///
  /// In en, this message translates to:
  /// **'Marriage date (optional)'**
  String get marriageDateUnknown;

  /// No description provided for @marriageFutureDate.
  ///
  /// In en, this message translates to:
  /// **'Marriage date cannot be in the future.'**
  String get marriageFutureDate;

  /// No description provided for @specialCareRequired.
  ///
  /// In en, this message translates to:
  /// **'Special care required'**
  String get specialCareRequired;

  /// No description provided for @specialCareDetails.
  ///
  /// In en, this message translates to:
  /// **'Special care details'**
  String get specialCareDetails;

  /// No description provided for @specialCareAnswerRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose yes or no for special care.'**
  String get specialCareAnswerRequired;

  /// No description provided for @specialCareDetailsRequired.
  ///
  /// In en, this message translates to:
  /// **'Describe the special care required.'**
  String get specialCareDetailsRequired;

  /// No description provided for @premaritalCounselling.
  ///
  /// In en, this message translates to:
  /// **'Premarital counselling received'**
  String get premaritalCounselling;

  /// No description provided for @notApplicable.
  ///
  /// In en, this message translates to:
  /// **'Not applicable'**
  String get notApplicable;

  /// No description provided for @saveHealthMarriageDetails.
  ///
  /// In en, this message translates to:
  /// **'Save health and marriage details'**
  String get saveHealthMarriageDetails;

  /// No description provided for @healthMarriageDetailsSaved.
  ///
  /// In en, this message translates to:
  /// **'Health and marriage details saved.'**
  String get healthMarriageDetailsSaved;

  /// No description provided for @healthMarriageDetailsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Health and marriage details could not be loaded. Existing data is unchanged.'**
  String get healthMarriageDetailsLoadFailed;

  /// No description provided for @healthMarriageDetailsSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Health and marriage details could not be saved. Existing data is unchanged.'**
  String get healthMarriageDetailsSaveFailed;

  /// No description provided for @familyPlanningTitle.
  ///
  /// In en, this message translates to:
  /// **'Family planning'**
  String get familyPlanningTitle;

  /// No description provided for @familyPlanningIntention.
  ///
  /// In en, this message translates to:
  /// **'Intention to avoid a future pregnancy'**
  String get familyPlanningIntention;

  /// No description provided for @notDecided.
  ///
  /// In en, this message translates to:
  /// **'Not decided'**
  String get notDecided;

  /// No description provided for @currentFamilyPlanningMethod.
  ///
  /// In en, this message translates to:
  /// **'Currently using a family-planning method?'**
  String get currentFamilyPlanningMethod;

  /// No description provided for @familyPlanningType.
  ///
  /// In en, this message translates to:
  /// **'Method type'**
  String get familyPlanningType;

  /// No description provided for @familyPlanningTemporary.
  ///
  /// In en, this message translates to:
  /// **'Temporary'**
  String get familyPlanningTemporary;

  /// No description provided for @familyPlanningPermanent.
  ///
  /// In en, this message translates to:
  /// **'Permanent'**
  String get familyPlanningPermanent;

  /// No description provided for @familyPlanningMethod.
  ///
  /// In en, this message translates to:
  /// **'Temporary method'**
  String get familyPlanningMethod;

  /// No description provided for @methodCuT.
  ///
  /// In en, this message translates to:
  /// **'CU-T'**
  String get methodCuT;

  /// No description provided for @methodPpiucd.
  ///
  /// In en, this message translates to:
  /// **'PPIUCD'**
  String get methodPpiucd;

  /// No description provided for @methodPaiucd.
  ///
  /// In en, this message translates to:
  /// **'PAIUCD'**
  String get methodPaiucd;

  /// No description provided for @familyPlanningActionDate.
  ///
  /// In en, this message translates to:
  /// **'Insertion / procedure date'**
  String get familyPlanningActionDate;

  /// No description provided for @familyPlanningRemarks.
  ///
  /// In en, this message translates to:
  /// **'Remarks (optional)'**
  String get familyPlanningRemarks;

  /// No description provided for @familyPlanningTypeRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose temporary or permanent.'**
  String get familyPlanningTypeRequired;

  /// No description provided for @familyPlanningMethodRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose a temporary method.'**
  String get familyPlanningMethodRequired;

  /// No description provided for @familyPlanningDateRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose the insertion or procedure date.'**
  String get familyPlanningDateRequired;

  /// No description provided for @familyPlanningDateFuture.
  ///
  /// In en, this message translates to:
  /// **'The insertion or procedure date cannot be in the future.'**
  String get familyPlanningDateFuture;

  /// No description provided for @familyPlanningHistory.
  ///
  /// In en, this message translates to:
  /// **'Previous entries'**
  String get familyPlanningHistory;

  /// No description provided for @saveFamilyPlanning.
  ///
  /// In en, this message translates to:
  /// **'Save family-planning details'**
  String get saveFamilyPlanning;

  /// No description provided for @familyPlanningSaved.
  ///
  /// In en, this message translates to:
  /// **'Family-planning details saved.'**
  String get familyPlanningSaved;

  /// No description provided for @familyPlanningLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Family-planning details could not be loaded. Existing data is unchanged.'**
  String get familyPlanningLoadFailed;

  /// No description provided for @familyPlanningSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Family-planning details could not be saved. Existing data is unchanged.'**
  String get familyPlanningSaveFailed;

  /// No description provided for @memberRelationshipsTitle.
  ///
  /// In en, this message translates to:
  /// **'Family relationships'**
  String get memberRelationshipsTitle;

  /// No description provided for @relationshipsSameHouseholdNotice.
  ///
  /// In en, this message translates to:
  /// **'Links can only be made between active members of this household.'**
  String get relationshipsSameHouseholdNotice;

  /// No description provided for @relationshipType.
  ///
  /// In en, this message translates to:
  /// **'Relationship type'**
  String get relationshipType;

  /// No description provided for @relationshipMotherOf.
  ///
  /// In en, this message translates to:
  /// **'Mother of'**
  String get relationshipMotherOf;

  /// No description provided for @relationshipIsMotherOf.
  ///
  /// In en, this message translates to:
  /// **'Is mother of'**
  String get relationshipIsMotherOf;

  /// No description provided for @relationshipSpouseOf.
  ///
  /// In en, this message translates to:
  /// **'Spouse of'**
  String get relationshipSpouseOf;

  /// No description provided for @memberIsMother.
  ///
  /// In en, this message translates to:
  /// **'This member is the mother'**
  String get memberIsMother;

  /// No description provided for @relationshipOtherMember.
  ///
  /// In en, this message translates to:
  /// **'Other household member'**
  String get relationshipOtherMember;

  /// No description provided for @addRelationship.
  ///
  /// In en, this message translates to:
  /// **'Add relationship'**
  String get addRelationship;

  /// No description provided for @relationshipActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get relationshipActive;

  /// No description provided for @relationshipEnded.
  ///
  /// In en, this message translates to:
  /// **'Ended {date}'**
  String relationshipEnded(String date);

  /// No description provided for @endRelationship.
  ///
  /// In en, this message translates to:
  /// **'End relationship'**
  String get endRelationship;

  /// No description provided for @unknownMember.
  ///
  /// In en, this message translates to:
  /// **'Member no longer available'**
  String get unknownMember;

  /// No description provided for @relationshipSaved.
  ///
  /// In en, this message translates to:
  /// **'Relationship saved.'**
  String get relationshipSaved;

  /// No description provided for @relationshipLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Relationships could not be loaded. Existing data is unchanged.'**
  String get relationshipLoadFailed;

  /// No description provided for @relationshipSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Relationship could not be saved. Check for an existing link and ensure both members are active in this household.'**
  String get relationshipSaveFailed;

  /// No description provided for @relationshipUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Relationship could not be updated. Existing data is unchanged.'**
  String get relationshipUpdateFailed;

  /// No description provided for @editHouseholdTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit household'**
  String get editHouseholdTitle;

  /// No description provided for @saveHouseholdChanges.
  ///
  /// In en, this message translates to:
  /// **'Save household changes'**
  String get saveHouseholdChanges;

  /// No description provided for @householdChangesSaved.
  ///
  /// In en, this message translates to:
  /// **'Household details updated.'**
  String get householdChangesSaved;

  /// No description provided for @householdEditFailed.
  ///
  /// In en, this message translates to:
  /// **'Household details could not be saved. Existing data is unchanged.'**
  String get householdEditFailed;

  /// No description provided for @rationCardEditUseReview.
  ///
  /// In en, this message translates to:
  /// **'Use the separate review action to explicitly choose a new category.'**
  String get rationCardEditUseReview;

  /// No description provided for @archiveHouseholdTitle.
  ///
  /// In en, this message translates to:
  /// **'Archive household?'**
  String get archiveHouseholdTitle;

  /// No description provided for @archiveHouseholdMessage.
  ///
  /// In en, this message translates to:
  /// **'The household and its active members will be hidden from normal lists. Member records remain recoverable.'**
  String get archiveHouseholdMessage;

  /// No description provided for @archiveHouseholdAction.
  ///
  /// In en, this message translates to:
  /// **'Archive household'**
  String get archiveHouseholdAction;

  /// No description provided for @restoreHouseholdTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore household?'**
  String get restoreHouseholdTitle;

  /// No description provided for @restoreHouseholdMessage.
  ///
  /// In en, this message translates to:
  /// **'The household will return to the active list. Its members remain archived until restored individually.'**
  String get restoreHouseholdMessage;

  /// No description provided for @restoreHouseholdAction.
  ///
  /// In en, this message translates to:
  /// **'Restore household'**
  String get restoreHouseholdAction;

  /// No description provided for @householdActionFailed.
  ///
  /// In en, this message translates to:
  /// **'The household could not be updated. Existing data is unchanged.'**
  String get householdActionFailed;

  /// No description provided for @showArchivedHouseholds.
  ///
  /// In en, this message translates to:
  /// **'Show archived households'**
  String get showArchivedHouseholds;

  /// No description provided for @hideArchivedHouseholds.
  ///
  /// In en, this message translates to:
  /// **'Hide archived households'**
  String get hideArchivedHouseholds;

  /// No description provided for @archivedStatus.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get archivedStatus;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @reportsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reportsTitle;

  /// No description provided for @refreshReports.
  ///
  /// In en, this message translates to:
  /// **'Refresh reports'**
  String get refreshReports;

  /// No description provided for @reportsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Reports could not be loaded.'**
  String get reportsLoadFailed;

  /// No description provided for @ageBandDistribution.
  ///
  /// In en, this message translates to:
  /// **'People by age'**
  String get ageBandDistribution;

  /// No description provided for @ageBandZeroToFive.
  ///
  /// In en, this message translates to:
  /// **'0–5 years'**
  String get ageBandZeroToFive;

  /// No description provided for @ageBandSixToSeventeen.
  ///
  /// In en, this message translates to:
  /// **'6–17 years'**
  String get ageBandSixToSeventeen;

  /// No description provided for @ageBandEighteenToFiftyNine.
  ///
  /// In en, this message translates to:
  /// **'18–59 years'**
  String get ageBandEighteenToFiftyNine;

  /// No description provided for @ageBandSixtyPlus.
  ///
  /// In en, this message translates to:
  /// **'60 years and over'**
  String get ageBandSixtyPlus;

  /// No description provided for @reportsArchiveNotice.
  ///
  /// In en, this message translates to:
  /// **'Counts include active members in complete, active households only. Archived records and drafts are excluded.'**
  String get reportsArchiveNotice;

  /// No description provided for @saveGeneralDetails.
  ///
  /// In en, this message translates to:
  /// **'Save details'**
  String get saveGeneralDetails;

  /// No description provided for @generalDetailsSaved.
  ///
  /// In en, this message translates to:
  /// **'Member details saved.'**
  String get generalDetailsSaved;

  /// No description provided for @generalDetailsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Member details could not be loaded. Existing data is unchanged.'**
  String get generalDetailsLoadFailed;

  /// No description provided for @generalDetailsSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Member details could not be saved. Existing data is unchanged.'**
  String get generalDetailsSaveFailed;

  /// No description provided for @appLocked.
  ///
  /// In en, this message translates to:
  /// **'Family records are protected'**
  String get appLocked;

  /// No description provided for @unlockReason.
  ///
  /// In en, this message translates to:
  /// **'Authenticate to access family records.'**
  String get unlockReason;

  /// No description provided for @unlockApp.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlockApp;

  /// No description provided for @authenticating.
  ///
  /// In en, this message translates to:
  /// **'Authenticating…'**
  String get authenticating;

  /// No description provided for @authenticationNotCompleted.
  ///
  /// In en, this message translates to:
  /// **'Authentication was not completed. The app remains locked.'**
  String get authenticationNotCompleted;

  /// No description provided for @deviceAuthenticationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Set up device biometrics or a device passcode to access this app.'**
  String get deviceAuthenticationUnavailable;

  /// No description provided for @authenticationFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not authenticate. The app remains locked; please try again.'**
  String get authenticationFailed;

  /// No description provided for @hasOwnWell.
  ///
  /// In en, this message translates to:
  /// **'Own well'**
  String get hasOwnWell;

  /// No description provided for @houseType.
  ///
  /// In en, this message translates to:
  /// **'House type'**
  String get houseType;

  /// No description provided for @headFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get headFullName;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get dateOfBirth;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @personPhone.
  ///
  /// In en, this message translates to:
  /// **'Personal phone (optional)'**
  String get personPhone;

  /// No description provided for @selectOption.
  ///
  /// In en, this message translates to:
  /// **'Select an option'**
  String get selectOption;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get requiredField;

  /// No description provided for @futureDateError.
  ///
  /// In en, this message translates to:
  /// **'Date of birth cannot be in the future.'**
  String get futureDateError;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save household'**
  String get save;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get saving;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @draftStatus.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get draftStatus;

  /// No description provided for @completeStatus.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get completeStatus;

  /// No description provided for @noHouseholds.
  ///
  /// In en, this message translates to:
  /// **'No households registered yet.'**
  String get noHouseholds;

  /// No description provided for @addFirstHousehold.
  ///
  /// In en, this message translates to:
  /// **'Register the first household'**
  String get addFirstHousehold;

  /// No description provided for @registrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save the household. Your existing records are unchanged.'**
  String get registrationFailed;

  /// No description provided for @possibleDuplicatesTitle.
  ///
  /// In en, this message translates to:
  /// **'Possible matching households'**
  String get possibleDuplicatesTitle;

  /// No description provided for @possibleDuplicatesMessage.
  ///
  /// In en, this message translates to:
  /// **'A household with this name and house number or phone may already exist. Review the matches before continuing.'**
  String get possibleDuplicatesMessage;

  /// No description provided for @continueRegistration.
  ///
  /// In en, this message translates to:
  /// **'Continue anyway'**
  String get continueRegistration;

  /// No description provided for @reviewMatches.
  ///
  /// In en, this message translates to:
  /// **'Review matches'**
  String get reviewMatches;

  /// No description provided for @householdSaved.
  ///
  /// In en, this message translates to:
  /// **'Household registered.'**
  String get householdSaved;

  /// No description provided for @houseNumberSummary.
  ///
  /// In en, this message translates to:
  /// **'House number: {houseNumber}'**
  String houseNumberSummary(Object houseNumber);

  /// No description provided for @rationYellow.
  ///
  /// In en, this message translates to:
  /// **'Yellow'**
  String get rationYellow;

  /// No description provided for @rationPink.
  ///
  /// In en, this message translates to:
  /// **'Pink'**
  String get rationPink;

  /// No description provided for @rationBlue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get rationBlue;

  /// No description provided for @rationWhite.
  ///
  /// In en, this message translates to:
  /// **'White'**
  String get rationWhite;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @houseTiledRoof.
  ///
  /// In en, this message translates to:
  /// **'Tiled roof'**
  String get houseTiledRoof;

  /// No description provided for @houseConcreteTerrace.
  ///
  /// In en, this message translates to:
  /// **'Concrete / terrace'**
  String get houseConcreteTerrace;

  /// No description provided for @houseSheetRoof.
  ///
  /// In en, this message translates to:
  /// **'Sheet roof'**
  String get houseSheetRoof;

  /// No description provided for @genderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get genderFemale;

  /// No description provided for @genderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get genderMale;

  /// No description provided for @genderPreferNotToSay.
  ///
  /// In en, this message translates to:
  /// **'Prefer not to say'**
  String get genderPreferNotToSay;

  /// No description provided for @addressRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter an address.'**
  String get addressRequired;

  /// No description provided for @headRoleDescription.
  ///
  /// In en, this message translates to:
  /// **'This person will be saved as the household head.'**
  String get headRoleDescription;

  /// No description provided for @requiredFieldShort.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requiredFieldShort;

  /// No description provided for @databaseUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The local database could not be opened. Existing data has been left unchanged. Contact an administrator before reinstalling the app.'**
  String get databaseUnavailable;

  /// No description provided for @householdListLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Households could not be loaded. Existing data has not been changed.'**
  String get householdListLoadFailed;

  /// No description provided for @householdProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Household profile'**
  String get householdProfileTitle;

  /// No description provided for @familyMembers.
  ///
  /// In en, this message translates to:
  /// **'Family members'**
  String get familyMembers;

  /// No description provided for @addMemberAction.
  ///
  /// In en, this message translates to:
  /// **'Add member'**
  String get addMemberAction;

  /// No description provided for @addMemberTitle.
  ///
  /// In en, this message translates to:
  /// **'Add family member'**
  String get addMemberTitle;

  /// No description provided for @editMemberTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit family member'**
  String get editMemberTitle;

  /// No description provided for @memberName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get memberName;

  /// No description provided for @relationshipToHead.
  ///
  /// In en, this message translates to:
  /// **'Relationship to head'**
  String get relationshipToHead;

  /// No description provided for @selectRelationship.
  ///
  /// In en, this message translates to:
  /// **'Select relationship'**
  String get selectRelationship;

  /// No description provided for @relationshipHead.
  ///
  /// In en, this message translates to:
  /// **'Head of family'**
  String get relationshipHead;

  /// No description provided for @relationshipSpouse.
  ///
  /// In en, this message translates to:
  /// **'Spouse'**
  String get relationshipSpouse;

  /// No description provided for @relationshipSon.
  ///
  /// In en, this message translates to:
  /// **'Son'**
  String get relationshipSon;

  /// No description provided for @relationshipDaughter.
  ///
  /// In en, this message translates to:
  /// **'Daughter'**
  String get relationshipDaughter;

  /// No description provided for @relationshipParent.
  ///
  /// In en, this message translates to:
  /// **'Parent'**
  String get relationshipParent;

  /// No description provided for @relationshipSibling.
  ///
  /// In en, this message translates to:
  /// **'Sibling'**
  String get relationshipSibling;

  /// No description provided for @relationshipGrandparent.
  ///
  /// In en, this message translates to:
  /// **'Grandparent'**
  String get relationshipGrandparent;

  /// No description provided for @relationshipInLaw.
  ///
  /// In en, this message translates to:
  /// **'In-law'**
  String get relationshipInLaw;

  /// No description provided for @relationshipOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get relationshipOther;

  /// No description provided for @memberPhoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number.'**
  String get memberPhoneInvalid;

  /// No description provided for @saveMember.
  ///
  /// In en, this message translates to:
  /// **'Save member'**
  String get saveMember;

  /// No description provided for @memberAdded.
  ///
  /// In en, this message translates to:
  /// **'Member added.'**
  String get memberAdded;

  /// No description provided for @memberUpdated.
  ///
  /// In en, this message translates to:
  /// **'Member details updated.'**
  String get memberUpdated;

  /// No description provided for @memberSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Member details could not be saved. Existing records are unchanged.'**
  String get memberSaveFailed;

  /// No description provided for @removeMemberAction.
  ///
  /// In en, this message translates to:
  /// **'Remove member'**
  String get removeMemberAction;

  /// No description provided for @removeMemberTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove this member?'**
  String get removeMemberTitle;

  /// No description provided for @removeMemberMessage.
  ///
  /// In en, this message translates to:
  /// **'This member will be archived and hidden from the active household. You can restore them later.'**
  String get removeMemberMessage;

  /// No description provided for @confirmRemoveMember.
  ///
  /// In en, this message translates to:
  /// **'Remove member'**
  String get confirmRemoveMember;

  /// No description provided for @memberRemoved.
  ///
  /// In en, this message translates to:
  /// **'Member removed from the active household.'**
  String get memberRemoved;

  /// No description provided for @archivedMembers.
  ///
  /// In en, this message translates to:
  /// **'Archived members'**
  String get archivedMembers;

  /// No description provided for @showArchivedMembers.
  ///
  /// In en, this message translates to:
  /// **'Show archived members'**
  String get showArchivedMembers;

  /// No description provided for @restoreMemberAction.
  ///
  /// In en, this message translates to:
  /// **'Restore member'**
  String get restoreMemberAction;

  /// No description provided for @memberRestored.
  ///
  /// In en, this message translates to:
  /// **'Member restored.'**
  String get memberRestored;

  /// No description provided for @memberActionFailed.
  ///
  /// In en, this message translates to:
  /// **'That member action could not be completed.'**
  String get memberActionFailed;

  /// No description provided for @houseNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'House number'**
  String get houseNumberLabel;

  /// No description provided for @houseTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'House type'**
  String get houseTypeLabel;

  /// No description provided for @wellOwnership.
  ///
  /// In en, this message translates to:
  /// **'Own well'**
  String get wellOwnership;

  /// No description provided for @searchPeopleTitle.
  ///
  /// In en, this message translates to:
  /// **'Search people'**
  String get searchPeopleTitle;

  /// No description provided for @searchPeopleHint.
  ///
  /// In en, this message translates to:
  /// **'Name, house, number, or phone'**
  String get searchPeopleHint;

  /// No description provided for @ageRange.
  ///
  /// In en, this message translates to:
  /// **'Age range'**
  String get ageRange;

  /// No description provided for @minimumAge.
  ///
  /// In en, this message translates to:
  /// **'Minimum age'**
  String get minimumAge;

  /// No description provided for @maximumAge.
  ///
  /// In en, this message translates to:
  /// **'Maximum age'**
  String get maximumAge;

  /// No description provided for @rationCardTypes.
  ///
  /// In en, this message translates to:
  /// **'Ration card types'**
  String get rationCardTypes;

  /// No description provided for @pregnancyStatus.
  ///
  /// In en, this message translates to:
  /// **'Pregnancy status'**
  String get pregnancyStatus;

  /// No description provided for @currentlyPregnant.
  ///
  /// In en, this message translates to:
  /// **'Currently pregnant'**
  String get currentlyPregnant;

  /// No description provided for @householdFilter.
  ///
  /// In en, this message translates to:
  /// **'Household'**
  String get householdFilter;

  /// No description provided for @allHouseholds.
  ///
  /// In en, this message translates to:
  /// **'All households'**
  String get allHouseholds;

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply filters'**
  String get applyFilters;

  /// No description provided for @resetFilters.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetFilters;

  /// No description provided for @noSearchResults.
  ///
  /// In en, this message translates to:
  /// **'No matching people found.'**
  String get noSearchResults;

  /// No description provided for @searchAge.
  ///
  /// In en, this message translates to:
  /// **'Age {age}'**
  String searchAge(Object age);

  /// No description provided for @matchingPeople.
  ///
  /// In en, this message translates to:
  /// **'Matching people'**
  String get matchingPeople;

  /// No description provided for @invalidAge.
  ///
  /// In en, this message translates to:
  /// **'Enter a non-negative whole number.'**
  String get invalidAge;

  /// No description provided for @invalidAgeRange.
  ///
  /// In en, this message translates to:
  /// **'Minimum age cannot exceed maximum age.'**
  String get invalidAgeRange;

  /// No description provided for @memberSearchFailed.
  ///
  /// In en, this message translates to:
  /// **'People could not be searched. Existing data has not been changed.'**
  String get memberSearchFailed;

  /// No description provided for @backupTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup and restore'**
  String get backupTitle;

  /// No description provided for @backupPrivacyNotice.
  ///
  /// In en, this message translates to:
  /// **'Backups contain all household, member, health, and reproductive details. They are encrypted with a passphrase you create. Keep the passphrase safe; it is never stored in this app.'**
  String get backupPrivacyNotice;

  /// No description provided for @backupCreateAction.
  ///
  /// In en, this message translates to:
  /// **'Create encrypted backup'**
  String get backupCreateAction;

  /// No description provided for @backupRestoreAction.
  ///
  /// In en, this message translates to:
  /// **'Restore backup'**
  String get backupRestoreAction;

  /// No description provided for @backupCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Protect the backup'**
  String get backupCreateTitle;

  /// No description provided for @backupPassphraseTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter backup passphrase'**
  String get backupPassphraseTitle;

  /// No description provided for @backupPassphraseHint.
  ///
  /// In en, this message translates to:
  /// **'Use at least 12 characters. The passphrase cannot be recovered if lost.'**
  String get backupPassphraseHint;

  /// No description provided for @backupPassphraseLabel.
  ///
  /// In en, this message translates to:
  /// **'Passphrase'**
  String get backupPassphraseLabel;

  /// No description provided for @backupPassphraseConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm passphrase'**
  String get backupPassphraseConfirm;

  /// No description provided for @backupPassphraseInvalid.
  ///
  /// In en, this message translates to:
  /// **'Use a passphrase between 12 and 1024 characters.'**
  String get backupPassphraseInvalid;

  /// No description provided for @backupPassphraseMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passphrases do not match.'**
  String get backupPassphraseMismatch;

  /// No description provided for @backupShareMessage.
  ///
  /// In en, this message translates to:
  /// **'Encrypted family-details backup'**
  String get backupShareMessage;

  /// No description provided for @backupOperationFailed.
  ///
  /// In en, this message translates to:
  /// **'The backup operation failed. Your existing local data has not been changed.'**
  String get backupOperationFailed;

  /// No description provided for @backupFileReadFailed.
  ///
  /// In en, this message translates to:
  /// **'The selected backup file could not be read.'**
  String get backupFileReadFailed;

  /// No description provided for @backupFileInvalid.
  ///
  /// In en, this message translates to:
  /// **'The backup file is invalid or is not compatible with this app version.'**
  String get backupFileInvalid;

  /// No description provided for @backupAuthenticationFailed.
  ///
  /// In en, this message translates to:
  /// **'The passphrase is incorrect or the backup file has been modified.'**
  String get backupAuthenticationFailed;

  /// No description provided for @backupRestorePreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review backup contents'**
  String get backupRestorePreviewTitle;

  /// No description provided for @backupRestorePreview.
  ///
  /// In en, this message translates to:
  /// **'Backup contains {households} households and {members} members. Existing ID conflicts: {householdConflicts} households and {memberConflicts} members. Merge keeps local rows for ID conflicts; replace deletes all current local records.'**
  String backupRestorePreview(
    int households,
    int members,
    int householdConflicts,
    int memberConflicts,
  );

  /// No description provided for @backupMergeAction.
  ///
  /// In en, this message translates to:
  /// **'Merge'**
  String get backupMergeAction;

  /// No description provided for @backupReplaceAction.
  ///
  /// In en, this message translates to:
  /// **'Replace all local data'**
  String get backupReplaceAction;

  /// No description provided for @backupReplaceConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Replace all local data?'**
  String get backupReplaceConfirmTitle;

  /// No description provided for @backupReplaceConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This permanently replaces every current local household and member record with the selected backup. This cannot be undone.'**
  String get backupReplaceConfirmMessage;

  /// No description provided for @backupRestoreComplete.
  ///
  /// In en, this message translates to:
  /// **'Restore complete. Imported {imported} records; skipped {skipped} records.'**
  String backupRestoreComplete(int imported, int skipped);

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @csvExportTitle.
  ///
  /// In en, this message translates to:
  /// **'Export selected fields as CSV'**
  String get csvExportTitle;

  /// No description provided for @csvPrivacyNotice.
  ///
  /// In en, this message translates to:
  /// **'Exports contain currently active households and active members. Aadhaar, health, pregnancy, child and family-planning details are excluded by default. CSV is unencrypted once shared. Review the selected fields before exporting.'**
  String get csvPrivacyNotice;

  /// No description provided for @csvExportAction.
  ///
  /// In en, this message translates to:
  /// **'Export selected fields'**
  String get csvExportAction;

  /// No description provided for @csvShareMessage.
  ///
  /// In en, this message translates to:
  /// **'Family-details CSV export'**
  String get csvShareMessage;

  /// No description provided for @csvSelectHouseholdsTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose households'**
  String get csvSelectHouseholdsTitle;

  /// No description provided for @csvSelectHouseholdsHint.
  ///
  /// In en, this message translates to:
  /// **'Choose all or only selected active households to include.'**
  String get csvSelectHouseholdsHint;

  /// No description provided for @csvSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all active households'**
  String get csvSelectAll;

  /// No description provided for @csvNoHouseholds.
  ///
  /// In en, this message translates to:
  /// **'There are no active households to export.'**
  String get csvNoHouseholds;

  /// No description provided for @csvSensitiveConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Export sensitive information?'**
  String get csvSensitiveConfirmTitle;

  /// No description provided for @csvSensitiveConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'You selected sensitive Aadhaar, health, marriage, pregnancy, child or family-planning fields. The CSV is not encrypted and may be accessible to other apps after sharing. Continue only if you are authorized and need these fields.'**
  String get csvSensitiveConfirmMessage;

  /// No description provided for @csvSensitiveConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'Export sensitive fields'**
  String get csvSensitiveConfirmAction;

  /// No description provided for @csvExportMatchesTitle.
  ///
  /// In en, this message translates to:
  /// **'Export matching people'**
  String get csvExportMatchesTitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ml'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ml':
      return AppLocalizationsMl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
