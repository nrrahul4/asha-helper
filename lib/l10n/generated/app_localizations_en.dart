// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Asha Helper';

  @override
  String get householdsTitle => 'Households';

  @override
  String get registerHouseholdTitle => 'Register household';

  @override
  String get registerHouseholdAction => 'Register household';

  @override
  String get householdDetails => 'Household details';

  @override
  String get headDetails => 'Head of family';

  @override
  String get houseName => 'House name';

  @override
  String get houseNumber => 'House number';

  @override
  String get addressLine => 'Address';

  @override
  String get locality => 'Locality / ward';

  @override
  String get postOffice => 'Post office';

  @override
  String get pincode => 'PIN code';

  @override
  String get contactPhone => 'Household contact phone';

  @override
  String get rationCardType => 'Ration card type';

  @override
  String get rationBpl => 'BPL';

  @override
  String get rationApl => 'APL';

  @override
  String get rationAay => 'AAY';

  @override
  String get rationCardReviewRequired => 'Ration-card category needs review';

  @override
  String get reviewRationCardTitle => 'Review ration-card category';

  @override
  String reviewRationCardMessage(Object category) {
    return 'The previous category was $category. Choose the correct BPL, APL, or AAY category; no category has been assigned automatically.';
  }

  @override
  String get reviewRationCardAction => 'Review category';

  @override
  String get rationCardUpdated => 'Ration-card category updated.';

  @override
  String get rationCardUpdateFailed =>
      'Could not update the ration-card category. Existing data is unchanged.';

  @override
  String get memberGeneralDetailsTitle => 'General member details';

  @override
  String get aadhaarNumber => 'Aadhaar number (optional)';

  @override
  String get aadhaarRevealTitle => 'Reveal Aadhaar number?';

  @override
  String get aadhaarRevealMessage =>
      'The full Aadhaar number will be visible on this screen until hidden or closed.';

  @override
  String get revealAadhaar => 'Reveal';

  @override
  String get hideAadhaar => 'Hide Aadhaar number';

  @override
  String get aadhaarInvalid => 'Enter exactly 12 digits.';

  @override
  String get optionalField => 'Optional';

  @override
  String get educationLevel => 'Education';

  @override
  String get jobTitle => 'Job / occupation';

  @override
  String get currentlyWorkingAbroad => 'Currently working abroad';

  @override
  String get bloodGroup => 'Blood group';

  @override
  String get pregnancyDetailsTitle => 'Pregnancy details';

  @override
  String get pregnancyAbaId => 'ABA ID (optional)';

  @override
  String get pregnancyLmp => 'First day of last menstrual period (LMP)';

  @override
  String get pregnancyHospital => 'Consulting hospital (optional)';

  @override
  String get previousPregnancyCount => 'Previous pregnancy count';

  @override
  String get previousPregnancyCountHelp =>
      'Include all previous pregnancies, excluding the current one.';

  @override
  String get lastLiveBirthDate => 'Most recent live-birth date (optional)';

  @override
  String get pregnancyFirstTrimester => 'First trimester';

  @override
  String get pregnancySecondTrimester => 'Second trimester';

  @override
  String get pregnancyThirdTrimester => 'Third trimester';

  @override
  String pregnancyEstimate(int weeks, String trimester) {
    return 'Approximate: $weeks completed weeks — $trimester';
  }

  @override
  String get pregnancyEstimateUnavailable =>
      'Unable to calculate an estimate from this LMP.';

  @override
  String get pregnancyEstimateDisclaimer =>
      'This is an approximate administrative estimate, not a clinical determination. Please confirm with a health professional.';

  @override
  String get pregnancyFutureDate => 'The date cannot be in the future.';

  @override
  String get pregnancyCountInvalid => 'Enter a non-negative whole number.';

  @override
  String get savePregnancyDetails => 'Save pregnancy details';

  @override
  String get pregnancyDetailsSaved => 'Pregnancy details saved.';

  @override
  String get pregnancyDetailsLoadFailed =>
      'Pregnancy details could not be loaded. Existing data is unchanged.';

  @override
  String get pregnancyDetailsSaveFailed =>
      'Pregnancy details could not be saved. Existing data is unchanged.';

  @override
  String get childBirthDetailsTitle => 'Child birth details';

  @override
  String get childBirthDetailsAgeNotice =>
      'Birth details are collected for children under five. Any previously saved details are retained.';

  @override
  String get childBirthWeight => 'Birth weight (kg, optional)';

  @override
  String get childBirthWeightHelp => 'Accepted range: 0.3–8.0 kg.';

  @override
  String get childBirthTime => 'Birth time (optional)';

  @override
  String get childDeliveryType => 'Delivery type';

  @override
  String get deliveryVaginal => 'Vaginal';

  @override
  String get deliveryCaesarean => 'Caesarean';

  @override
  String get childSpecialCareRequired =>
      'Special care required (under one year)';

  @override
  String get childSpecialCareDetails => 'Special care details';

  @override
  String get childBirthWeightOutOfRange =>
      'Enter a birth weight from 0.3 to 8.0 kg.';

  @override
  String get childBirthTimeInvalid => 'Enter a valid birth time.';

  @override
  String get childSpecialCareAnswerRequired =>
      'Choose yes or no for special care.';

  @override
  String get childSpecialCareDetailsRequired =>
      'Describe the special care required.';

  @override
  String get saveChildBirthDetails => 'Save child details';

  @override
  String get childBirthDetailsSaved => 'Child birth details saved.';

  @override
  String get childBirthDetailsLoadFailed =>
      'Child birth details could not be loaded. Existing data is unchanged.';

  @override
  String get childBirthDetailsSaveFailed =>
      'Child birth details could not be saved. Existing data is unchanged.';

  @override
  String get healthMarriageDetailsTitle => 'Health and marriage details';

  @override
  String get existingIllnesses => 'Existing illnesses';

  @override
  String get illnessDiabetes => 'Diabetes';

  @override
  String get illnessBloodPressure => 'Blood pressure';

  @override
  String get illnessCholesterol => 'Cholesterol';

  @override
  String get illnessOther => 'Other';

  @override
  String get otherIllnessDetails => 'Other illness details';

  @override
  String get otherIllnessRequired =>
      'Describe the illness when Other is selected.';

  @override
  String get hasCancer => 'Cancer';

  @override
  String get hasAsthma => 'Asthma';

  @override
  String get hasHeartDisease => 'Heart disease';

  @override
  String get maritalStatus => 'Marital status';

  @override
  String get marriageDateUnknown => 'Marriage date (optional)';

  @override
  String get marriageFutureDate => 'Marriage date cannot be in the future.';

  @override
  String get specialCareRequired => 'Special care required';

  @override
  String get specialCareDetails => 'Special care details';

  @override
  String get specialCareAnswerRequired => 'Choose yes or no for special care.';

  @override
  String get specialCareDetailsRequired =>
      'Describe the special care required.';

  @override
  String get premaritalCounselling => 'Premarital counselling received';

  @override
  String get notApplicable => 'Not applicable';

  @override
  String get saveHealthMarriageDetails => 'Save health and marriage details';

  @override
  String get healthMarriageDetailsSaved => 'Health and marriage details saved.';

  @override
  String get healthMarriageDetailsLoadFailed =>
      'Health and marriage details could not be loaded. Existing data is unchanged.';

  @override
  String get healthMarriageDetailsSaveFailed =>
      'Health and marriage details could not be saved. Existing data is unchanged.';

  @override
  String get familyPlanningTitle => 'Family planning';

  @override
  String get familyPlanningIntention => 'Intention to avoid a future pregnancy';

  @override
  String get notDecided => 'Not decided';

  @override
  String get currentFamilyPlanningMethod =>
      'Currently using a family-planning method?';

  @override
  String get familyPlanningType => 'Method type';

  @override
  String get familyPlanningTemporary => 'Temporary';

  @override
  String get familyPlanningPermanent => 'Permanent';

  @override
  String get familyPlanningMethod => 'Temporary method';

  @override
  String get methodCuT => 'CU-T';

  @override
  String get methodPpiucd => 'PPIUCD';

  @override
  String get methodPaiucd => 'PAIUCD';

  @override
  String get familyPlanningActionDate => 'Insertion / procedure date';

  @override
  String get familyPlanningRemarks => 'Remarks (optional)';

  @override
  String get familyPlanningTypeRequired => 'Choose temporary or permanent.';

  @override
  String get familyPlanningMethodRequired => 'Choose a temporary method.';

  @override
  String get familyPlanningDateRequired =>
      'Choose the insertion or procedure date.';

  @override
  String get familyPlanningDateFuture =>
      'The insertion or procedure date cannot be in the future.';

  @override
  String get familyPlanningHistory => 'Previous entries';

  @override
  String get saveFamilyPlanning => 'Save family-planning details';

  @override
  String get familyPlanningSaved => 'Family-planning details saved.';

  @override
  String get familyPlanningLoadFailed =>
      'Family-planning details could not be loaded. Existing data is unchanged.';

  @override
  String get familyPlanningSaveFailed =>
      'Family-planning details could not be saved. Existing data is unchanged.';

  @override
  String get memberRelationshipsTitle => 'Family relationships';

  @override
  String get relationshipsSameHouseholdNotice =>
      'Links can only be made between active members of this household.';

  @override
  String get relationshipType => 'Relationship type';

  @override
  String get relationshipMotherOf => 'Mother of';

  @override
  String get relationshipIsMotherOf => 'Is mother of';

  @override
  String get relationshipSpouseOf => 'Spouse of';

  @override
  String get memberIsMother => 'This member is the mother';

  @override
  String get relationshipOtherMember => 'Other household member';

  @override
  String get addRelationship => 'Add relationship';

  @override
  String get relationshipActive => 'Active';

  @override
  String relationshipEnded(String date) {
    return 'Ended $date';
  }

  @override
  String get endRelationship => 'End relationship';

  @override
  String get unknownMember => 'Member no longer available';

  @override
  String get relationshipSaved => 'Relationship saved.';

  @override
  String get relationshipLoadFailed =>
      'Relationships could not be loaded. Existing data is unchanged.';

  @override
  String get relationshipSaveFailed =>
      'Relationship could not be saved. Check for an existing link and ensure both members are active in this household.';

  @override
  String get relationshipUpdateFailed =>
      'Relationship could not be updated. Existing data is unchanged.';

  @override
  String get editHouseholdTitle => 'Edit household';

  @override
  String get saveHouseholdChanges => 'Save household changes';

  @override
  String get householdChangesSaved => 'Household details updated.';

  @override
  String get householdEditFailed =>
      'Household details could not be saved. Existing data is unchanged.';

  @override
  String get rationCardEditUseReview =>
      'Use the separate review action to explicitly choose a new category.';

  @override
  String get archiveHouseholdTitle => 'Archive household?';

  @override
  String get archiveHouseholdMessage =>
      'The household and its active members will be hidden from normal lists. Member records remain recoverable.';

  @override
  String get archiveHouseholdAction => 'Archive household';

  @override
  String get restoreHouseholdTitle => 'Restore household?';

  @override
  String get restoreHouseholdMessage =>
      'The household will return to the active list. Its members remain archived until restored individually.';

  @override
  String get restoreHouseholdAction => 'Restore household';

  @override
  String get householdActionFailed =>
      'The household could not be updated. Existing data is unchanged.';

  @override
  String get showArchivedHouseholds => 'Show archived households';

  @override
  String get hideArchivedHouseholds => 'Hide archived households';

  @override
  String get archivedStatus => 'Archived';

  @override
  String get notes => 'Notes';

  @override
  String get reportsTitle => 'Reports';

  @override
  String get refreshReports => 'Refresh reports';

  @override
  String get reportsLoadFailed => 'Reports could not be loaded.';

  @override
  String get ageBandDistribution => 'People by age';

  @override
  String get ageBandZeroToFive => '0–5 years';

  @override
  String get ageBandSixToSeventeen => '6–17 years';

  @override
  String get ageBandEighteenToFiftyNine => '18–59 years';

  @override
  String get ageBandSixtyPlus => '60 years and over';

  @override
  String get reportsArchiveNotice =>
      'Counts include active members in complete, active households only. Archived records and drafts are excluded.';

  @override
  String get saveGeneralDetails => 'Save details';

  @override
  String get generalDetailsSaved => 'Member details saved.';

  @override
  String get generalDetailsLoadFailed =>
      'Member details could not be loaded. Existing data is unchanged.';

  @override
  String get generalDetailsSaveFailed =>
      'Member details could not be saved. Existing data is unchanged.';

  @override
  String get appLocked => 'Family records are protected';

  @override
  String get unlockReason => 'Authenticate to access family records.';

  @override
  String get unlockApp => 'Unlock';

  @override
  String get authenticating => 'Authenticating…';

  @override
  String get authenticationNotCompleted =>
      'Authentication was not completed. The app remains locked.';

  @override
  String get deviceAuthenticationUnavailable =>
      'Set up device biometrics or a device passcode to access this app.';

  @override
  String get authenticationFailed =>
      'Could not authenticate. The app remains locked; please try again.';

  @override
  String get hasOwnWell => 'Own well';

  @override
  String get houseType => 'House type';

  @override
  String get headFullName => 'Full name';

  @override
  String get dateOfBirth => 'Date of birth';

  @override
  String get gender => 'Gender';

  @override
  String get personPhone => 'Personal phone (optional)';

  @override
  String get selectOption => 'Select an option';

  @override
  String get selectDate => 'Select date';

  @override
  String get requiredField => 'This field is required.';

  @override
  String get futureDateError => 'Date of birth cannot be in the future.';

  @override
  String get save => 'Save household';

  @override
  String get saving => 'Saving…';

  @override
  String get cancel => 'Cancel';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get draftStatus => 'Draft';

  @override
  String get completeStatus => 'Complete';

  @override
  String get noHouseholds => 'No households registered yet.';

  @override
  String get addFirstHousehold => 'Register the first household';

  @override
  String get registrationFailed =>
      'Could not save the household. Your existing records are unchanged.';

  @override
  String get possibleDuplicatesTitle => 'Possible matching households';

  @override
  String get possibleDuplicatesMessage =>
      'A household with this name and house number or phone may already exist. Review the matches before continuing.';

  @override
  String get continueRegistration => 'Continue anyway';

  @override
  String get reviewMatches => 'Review matches';

  @override
  String get householdSaved => 'Household registered.';

  @override
  String houseNumberSummary(Object houseNumber) {
    return 'House number: $houseNumber';
  }

  @override
  String get rationYellow => 'Yellow';

  @override
  String get rationPink => 'Pink';

  @override
  String get rationBlue => 'Blue';

  @override
  String get rationWhite => 'White';

  @override
  String get other => 'Other';

  @override
  String get unknown => 'Unknown';

  @override
  String get houseTiledRoof => 'Tiled roof';

  @override
  String get houseConcreteTerrace => 'Concrete / terrace';

  @override
  String get houseSheetRoof => 'Sheet roof';

  @override
  String get genderFemale => 'Female';

  @override
  String get genderMale => 'Male';

  @override
  String get genderPreferNotToSay => 'Prefer not to say';

  @override
  String get addressRequired => 'Enter an address.';

  @override
  String get headRoleDescription =>
      'This person will be saved as the household head.';

  @override
  String get requiredFieldShort => 'Required';

  @override
  String get databaseUnavailable =>
      'The local database could not be opened. Existing data has been left unchanged. Contact an administrator before reinstalling the app.';

  @override
  String get householdListLoadFailed =>
      'Households could not be loaded. Existing data has not been changed.';

  @override
  String get householdProfileTitle => 'Household profile';

  @override
  String get familyMembers => 'Family members';

  @override
  String get addMemberAction => 'Add member';

  @override
  String get addMemberTitle => 'Add family member';

  @override
  String get editMemberTitle => 'Edit family member';

  @override
  String get memberName => 'Full name';

  @override
  String get relationshipToHead => 'Relationship to head';

  @override
  String get selectRelationship => 'Select relationship';

  @override
  String get relationshipHead => 'Head of family';

  @override
  String get relationshipSpouse => 'Spouse';

  @override
  String get relationshipSon => 'Son';

  @override
  String get relationshipDaughter => 'Daughter';

  @override
  String get relationshipParent => 'Parent';

  @override
  String get relationshipSibling => 'Sibling';

  @override
  String get relationshipGrandparent => 'Grandparent';

  @override
  String get relationshipInLaw => 'In-law';

  @override
  String get relationshipOther => 'Other';

  @override
  String get memberPhoneInvalid => 'Enter a valid phone number.';

  @override
  String get saveMember => 'Save member';

  @override
  String get memberAdded => 'Member added.';

  @override
  String get memberUpdated => 'Member details updated.';

  @override
  String get memberSaveFailed =>
      'Member details could not be saved. Existing records are unchanged.';

  @override
  String get removeMemberAction => 'Remove member';

  @override
  String get removeMemberTitle => 'Remove this member?';

  @override
  String get removeMemberMessage =>
      'This member will be archived and hidden from the active household. You can restore them later.';

  @override
  String get confirmRemoveMember => 'Remove member';

  @override
  String get memberRemoved => 'Member removed from the active household.';

  @override
  String get archivedMembers => 'Archived members';

  @override
  String get showArchivedMembers => 'Show archived members';

  @override
  String get restoreMemberAction => 'Restore member';

  @override
  String get memberRestored => 'Member restored.';

  @override
  String get memberActionFailed => 'That member action could not be completed.';

  @override
  String get houseNumberLabel => 'House number';

  @override
  String get houseTypeLabel => 'House type';

  @override
  String get wellOwnership => 'Own well';

  @override
  String get searchPeopleTitle => 'Search people';

  @override
  String get searchPeopleHint => 'Name, house, number, or phone';

  @override
  String get ageRange => 'Age range';

  @override
  String get minimumAge => 'Minimum age';

  @override
  String get maximumAge => 'Maximum age';

  @override
  String get rationCardTypes => 'Ration card types';

  @override
  String get pregnancyStatus => 'Pregnancy status';

  @override
  String get currentlyPregnant => 'Currently pregnant';

  @override
  String get householdFilter => 'Household';

  @override
  String get allHouseholds => 'All households';

  @override
  String get applyFilters => 'Apply filters';

  @override
  String get resetFilters => 'Reset';

  @override
  String get noSearchResults => 'No matching people found.';

  @override
  String searchAge(Object age) {
    return 'Age $age';
  }

  @override
  String get matchingPeople => 'Matching people';

  @override
  String get invalidAge => 'Enter a non-negative whole number.';

  @override
  String get invalidAgeRange => 'Minimum age cannot exceed maximum age.';

  @override
  String get memberSearchFailed =>
      'People could not be searched. Existing data has not been changed.';

  @override
  String get backupTitle => 'Backup and restore';

  @override
  String get backupPrivacyNotice =>
      'Backups contain all household, member, health, and reproductive details. They are encrypted with a passphrase you create. Keep the passphrase safe; it is never stored in this app.';

  @override
  String get backupCreateAction => 'Create encrypted backup';

  @override
  String get backupRestoreAction => 'Restore backup';

  @override
  String get backupCreateTitle => 'Protect the backup';

  @override
  String get backupPassphraseTitle => 'Enter backup passphrase';

  @override
  String get backupPassphraseHint =>
      'Use at least 12 characters. The passphrase cannot be recovered if lost.';

  @override
  String get backupPassphraseLabel => 'Passphrase';

  @override
  String get backupPassphraseConfirm => 'Confirm passphrase';

  @override
  String get backupPassphraseInvalid =>
      'Use a passphrase between 12 and 1024 characters.';

  @override
  String get backupPassphraseMismatch => 'Passphrases do not match.';

  @override
  String get backupShareMessage => 'Encrypted family-details backup';

  @override
  String get backupOperationFailed =>
      'The backup operation failed. Your existing local data has not been changed.';

  @override
  String get backupFileReadFailed =>
      'The selected backup file could not be read.';

  @override
  String get backupFileInvalid =>
      'The backup file is invalid or is not compatible with this app version.';

  @override
  String get backupAuthenticationFailed =>
      'The passphrase is incorrect or the backup file has been modified.';

  @override
  String get backupRestorePreviewTitle => 'Review backup contents';

  @override
  String backupRestorePreview(
    int households,
    int members,
    int householdConflicts,
    int memberConflicts,
  ) {
    return 'Backup contains $households households and $members members. Existing ID conflicts: $householdConflicts households and $memberConflicts members. Merge keeps local rows for ID conflicts; replace deletes all current local records.';
  }

  @override
  String get backupMergeAction => 'Merge';

  @override
  String get backupReplaceAction => 'Replace all local data';

  @override
  String get backupReplaceConfirmTitle => 'Replace all local data?';

  @override
  String get backupReplaceConfirmMessage =>
      'This permanently replaces every current local household and member record with the selected backup. This cannot be undone.';

  @override
  String backupRestoreComplete(int imported, int skipped) {
    return 'Restore complete. Imported $imported records; skipped $skipped records.';
  }

  @override
  String get continueAction => 'Continue';

  @override
  String get csvExportTitle => 'Export selected fields as CSV';

  @override
  String get csvPrivacyNotice =>
      'Exports contain currently active households and active members. Aadhaar, health, pregnancy, child and family-planning details are excluded by default. CSV is unencrypted once shared. Review the selected fields before exporting.';

  @override
  String get csvExportAction => 'Export selected fields';

  @override
  String get csvShareMessage => 'Family-details CSV export';

  @override
  String get csvSelectHouseholdsTitle => 'Choose households';

  @override
  String get csvSelectHouseholdsHint =>
      'Choose all or only selected active households to include.';

  @override
  String get csvSelectAll => 'Select all active households';

  @override
  String get csvNoHouseholds => 'There are no active households to export.';

  @override
  String get csvSensitiveConfirmTitle => 'Export sensitive information?';

  @override
  String get csvSensitiveConfirmMessage =>
      'You selected sensitive Aadhaar, health, marriage, pregnancy, child or family-planning fields. The CSV is not encrypted and may be accessible to other apps after sharing. Continue only if you are authorized and need these fields.';

  @override
  String get csvSensitiveConfirmAction => 'Export sensitive fields';

  @override
  String get csvExportMatchesTitle => 'Export matching people';
}
