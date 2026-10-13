// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malayalam (`ml`).
class AppLocalizationsMl extends AppLocalizations {
  AppLocalizationsMl([String locale = 'ml']) : super(locale);

  @override
  String get appTitle => 'Asha Helper';

  @override
  String get householdsTitle => 'കുടുംബങ്ങൾ';

  @override
  String get registerHouseholdTitle => 'കുടുംബം രജിസ്റ്റർ ചെയ്യുക';

  @override
  String get registerHouseholdAction => 'കുടുംബം ചേർക്കുക';

  @override
  String get householdDetails => 'വീട്ടുവിവരങ്ങൾ';

  @override
  String get headDetails => 'കുടുംബനാഥൻ / നാഥ';

  @override
  String get houseName => 'വീട്ടുപേര്';

  @override
  String get houseNumber => 'വീട്ടുനമ്പർ';

  @override
  String get addressLine => 'വിലാസം';

  @override
  String get locality => 'പ്രദേശം / വാർഡ്';

  @override
  String get postOffice => 'പോസ്റ്റ് ഓഫീസ്';

  @override
  String get pincode => 'പിൻകോഡ്';

  @override
  String get contactPhone => 'വീട്ടിലെ ബന്ധപ്പെടാനുള്ള ഫോൺ';

  @override
  String get rationCardType => 'റേഷൻ കാർഡ് തരം';

  @override
  String get rationBpl => 'ബി.പി.എൽ';

  @override
  String get rationApl => 'എ.പി.എൽ';

  @override
  String get rationAay => 'എ.എ.വൈ';

  @override
  String get rationCardReviewRequired => 'റേഷൻ കാർഡ് വിഭാഗം പരിശോധിക്കണം';

  @override
  String get reviewRationCardTitle => 'റേഷൻ കാർഡ് വിഭാഗം പരിശോധിക്കുക';

  @override
  String reviewRationCardMessage(Object category) {
    return 'മുമ്പത്തെ വിഭാഗം $category ആയിരുന്നു. സ്വയമേവ വിഭാഗം നിശ്ചയിച്ചിട്ടില്ല; ശരിയായ ബി.പി.എൽ, എ.പി.എൽ, അല്ലെങ്കിൽ എ.എ.വൈ വിഭാഗം തിരഞ്ഞെടുക്കുക.';
  }

  @override
  String get reviewRationCardAction => 'വിഭാഗം പരിശോധിക്കുക';

  @override
  String get rationCardUpdated => 'റേഷൻ കാർഡ് വിഭാഗം പുതുക്കി.';

  @override
  String get rationCardUpdateFailed =>
      'റേഷൻ കാർഡ് വിഭാഗം പുതുക്കാനായില്ല. നിലവിലുള്ള വിവരങ്ങളിൽ മാറ്റമില്ല.';

  @override
  String get memberGeneralDetailsTitle => 'അംഗത്തിന്റെ പൊതുവിവരങ്ങൾ';

  @override
  String get aadhaarNumber => 'ആധാർ നമ്പർ (ഐച്ഛികം)';

  @override
  String get aadhaarRevealTitle => 'ആധാർ നമ്പർ കാണിക്കണോ?';

  @override
  String get aadhaarRevealMessage =>
      'മറയ്ക്കുകയോ ഈ സ്ക്രീൻ അടയ്ക്കുകയോ ചെയ്യുന്നതുവരെ പൂർണ്ണ ആധാർ നമ്പർ ഇവിടെ കാണിക്കും.';

  @override
  String get revealAadhaar => 'കാണിക്കുക';

  @override
  String get hideAadhaar => 'ആധാർ നമ്പർ മറയ്ക്കുക';

  @override
  String get aadhaarInvalid => 'കൃത്യമായി 12 അക്കങ്ങൾ നൽകുക.';

  @override
  String get optionalField => 'ഐച്ഛികം';

  @override
  String get educationLevel => 'വിദ്യാഭ്യാസം';

  @override
  String get jobTitle => 'തൊഴിൽ';

  @override
  String get currentlyWorkingAbroad => 'നിലവിൽ വിദേശത്ത് ജോലി ചെയ്യുന്നു';

  @override
  String get bloodGroup => 'രക്തഗ്രൂപ്പ്';

  @override
  String get pregnancyDetailsTitle => 'ഗർഭധാരണ വിവരങ്ങൾ';

  @override
  String get pregnancyAbaId => 'എബിഎ ഐഡി (ഐച്ഛികം)';

  @override
  String get pregnancyLmp => 'അവസാന മാസവാരിയുടെ ആദ്യ ദിവസം (LMP)';

  @override
  String get pregnancyHospital => 'ചികിത്സിക്കുന്ന ആശുപത്രി (ഐച്ഛികം)';

  @override
  String get previousPregnancyCount => 'മുൻ ഗർഭധാരണങ്ങളുടെ എണ്ണം';

  @override
  String get previousPregnancyCountHelp =>
      'നിലവിലുള്ളത് ഒഴികെ മുൻ ഗർഭധാരണങ്ങൾ എല്ലാം ഉൾപ്പെടുത്തുക.';

  @override
  String get lastLiveBirthDate =>
      'ഏറ്റവും പുതിയ ജീവനുള്ള പ്രസവ തീയതി (ഐച്ഛികം)';

  @override
  String get pregnancyFirstTrimester => 'ഒന്നാം ത്രൈമാസം';

  @override
  String get pregnancySecondTrimester => 'രണ്ടാം ത്രൈമാസം';

  @override
  String get pregnancyThirdTrimester => 'മൂന്നാം ത്രൈമാസം';

  @override
  String pregnancyEstimate(int weeks, String trimester) {
    return 'ഏകദേശ കണക്ക്: പൂർത്തിയായ $weeks ആഴ്ച — $trimester';
  }

  @override
  String get pregnancyEstimateUnavailable =>
      'ഈ LMP അടിസ്ഥാനമാക്കി കണക്ക് ലഭ്യമല്ല.';

  @override
  String get pregnancyEstimateDisclaimer =>
      'ഇത് ഏകദേശ ഭരണപരമായ കണക്കാണ്; വൈദ്യപരമായ നിർണ്ണയം അല്ല. ആരോഗ്യപ്രവർത്തകനോട് സ്ഥിരീകരിക്കുക.';

  @override
  String get pregnancyFutureDate => 'തീയതി ഭാവിയിലാകരുത്.';

  @override
  String get pregnancyCountInvalid =>
      'പൂജ്യമോ അതിലധികമോ ഉള്ള പൂർണ്ണസംഖ്യ നൽകുക.';

  @override
  String get savePregnancyDetails => 'ഗർഭധാരണ വിവരങ്ങൾ സംരക്ഷിക്കുക';

  @override
  String get pregnancyDetailsSaved => 'ഗർഭധാരണ വിവരങ്ങൾ സംരക്ഷിച്ചു.';

  @override
  String get pregnancyDetailsLoadFailed =>
      'ഗർഭധാരണ വിവരങ്ങൾ തുറക്കാനായില്ല. നിലവിലുള്ള ഡാറ്റ മാറ്റിയിട്ടില്ല.';

  @override
  String get pregnancyDetailsSaveFailed =>
      'ഗർഭധാരണ വിവരങ്ങൾ സംരക്ഷിക്കാനായില്ല. നിലവിലുള്ള ഡാറ്റ മാറ്റിയിട്ടില്ല.';

  @override
  String get childBirthDetailsTitle => 'കുട്ടിയുടെ ജനന വിവരങ്ങൾ';

  @override
  String get childBirthDetailsAgeNotice =>
      'അഞ്ച് വയസ്സിൽ താഴെയുള്ള കുട്ടികൾക്കായാണ് ജനന വിവരങ്ങൾ ശേഖരിക്കുന്നത്. മുമ്പ് സംരക്ഷിച്ച വിവരങ്ങൾ നിലനിർത്തും.';

  @override
  String get childBirthWeight => 'ജനനസമയത്തെ ഭാരം (കിലോ, ഐച്ഛികം)';

  @override
  String get childBirthWeightHelp => 'അംഗീകരിക്കുന്ന പരിധി: 0.3–8.0 കിലോ.';

  @override
  String get childBirthTime => 'ജനന സമയം (ഐച്ഛികം)';

  @override
  String get childDeliveryType => 'പ്രസവ രീതി';

  @override
  String get deliveryVaginal => 'യോനിമാർഗ്ഗ പ്രസവം';

  @override
  String get deliveryCaesarean => 'സിസേറിയൻ';

  @override
  String get childSpecialCareRequired =>
      'പ്രത്യേക പരിചരണം ആവശ്യമുണ്ടോ (ഒരു വയസ്സിൽ താഴെ)';

  @override
  String get childSpecialCareDetails => 'പ്രത്യേക പരിചരണ വിവരങ്ങൾ';

  @override
  String get childBirthWeightOutOfRange =>
      '0.3 മുതൽ 8.0 കിലോഗ്രാം വരെയുള്ള ഭാരം നൽകുക.';

  @override
  String get childBirthTimeInvalid => 'സാധുവായ ജനന സമയം നൽകുക.';

  @override
  String get childSpecialCareAnswerRequired =>
      'പ്രത്യേക പരിചരണത്തിന് അതെ അല്ലെങ്കിൽ ഇല്ല തിരഞ്ഞെടുക്കുക.';

  @override
  String get childSpecialCareDetailsRequired =>
      'ആവശ്യമായ പ്രത്യേക പരിചരണം വിവരിക്കുക.';

  @override
  String get saveChildBirthDetails => 'കുട്ടിയുടെ വിവരങ്ങൾ സംരക്ഷിക്കുക';

  @override
  String get childBirthDetailsSaved => 'കുട്ടിയുടെ ജനന വിവരങ്ങൾ സംരക്ഷിച്ചു.';

  @override
  String get childBirthDetailsLoadFailed =>
      'കുട്ടിയുടെ ജനന വിവരങ്ങൾ തുറക്കാനായില്ല. നിലവിലുള്ള ഡാറ്റ മാറ്റിയിട്ടില്ല.';

  @override
  String get childBirthDetailsSaveFailed =>
      'കുട്ടിയുടെ ജനന വിവരങ്ങൾ സംരക്ഷിക്കാനായില്ല. നിലവിലുള്ള ഡാറ്റ മാറ്റിയിട്ടില്ല.';

  @override
  String get healthMarriageDetailsTitle => 'ആരോഗ്യ-വിവാഹ വിവരങ്ങൾ';

  @override
  String get existingIllnesses => 'നിലവിലുള്ള രോഗങ്ങൾ';

  @override
  String get illnessDiabetes => 'പ്രമേഹം';

  @override
  String get illnessBloodPressure => 'രക്തസമ്മർദ്ദം';

  @override
  String get illnessCholesterol => 'കൊളസ്‌ട്രോൾ';

  @override
  String get illnessOther => 'മറ്റുള്ളവ';

  @override
  String get otherIllnessDetails => 'മറ്റ് രോഗ വിവരങ്ങൾ';

  @override
  String get otherIllnessRequired =>
      'മറ്റുള്ളവ തിരഞ്ഞെടുത്താൽ രോഗം വിവരിക്കുക.';

  @override
  String get hasCancer => 'കാൻസർ';

  @override
  String get hasAsthma => 'ആസ്ത്മ';

  @override
  String get hasHeartDisease => 'ഹൃദ്രോഗം';

  @override
  String get maritalStatus => 'വൈവാഹിക നില';

  @override
  String get marriageDateUnknown => 'വിവാഹ തീയതി (ഐച്ഛികം)';

  @override
  String get marriageFutureDate => 'വിവാഹ തീയതി ഭാവിയിലാകരുത്.';

  @override
  String get specialCareRequired => 'പ്രത്യേക പരിചരണം ആവശ്യമുണ്ടോ';

  @override
  String get specialCareDetails => 'പ്രത്യേക പരിചരണ വിവരങ്ങൾ';

  @override
  String get specialCareAnswerRequired =>
      'പ്രത്യേക പരിചരണത്തിന് അതെ അല്ലെങ്കിൽ ഇല്ല തിരഞ്ഞെടുക്കുക.';

  @override
  String get specialCareDetailsRequired =>
      'ആവശ്യമായ പ്രത്യേക പരിചരണം വിവരിക്കുക.';

  @override
  String get premaritalCounselling => 'വിവാഹപൂർവ കൗൺസലിംഗ് ലഭിച്ചിട്ടുണ്ടോ';

  @override
  String get notApplicable => 'ബാധകമല്ല';

  @override
  String get saveHealthMarriageDetails => 'ആരോഗ്യ-വിവാഹ വിവരങ്ങൾ സംരക്ഷിക്കുക';

  @override
  String get healthMarriageDetailsSaved => 'ആരോഗ്യ-വിവാഹ വിവരങ്ങൾ സംരക്ഷിച്ചു.';

  @override
  String get healthMarriageDetailsLoadFailed =>
      'ആരോഗ്യ-വിവാഹ വിവരങ്ങൾ തുറക്കാനായില്ല. നിലവിലുള്ള ഡാറ്റ മാറ്റിയിട്ടില്ല.';

  @override
  String get healthMarriageDetailsSaveFailed =>
      'ആരോഗ്യ-വിവാഹ വിവരങ്ങൾ സംരക്ഷിക്കാനായില്ല. നിലവിലുള്ള ഡാറ്റ മാറ്റിയിട്ടില്ല.';

  @override
  String get familyPlanningTitle => 'കുടുംബാസൂത്രണം';

  @override
  String get familyPlanningIntention =>
      'ഭാവിയിലെ ഗർഭധാരണം ഒഴിവാക്കാനുള്ള ഉദ്ദേശ്യം';

  @override
  String get notDecided => 'തീരുമാനിച്ചിട്ടില്ല';

  @override
  String get currentFamilyPlanningMethod =>
      'നിലവിൽ കുടുംബാസൂത്രണ മാർഗം ഉപയോഗിക്കുന്നുണ്ടോ?';

  @override
  String get familyPlanningType => 'മാർഗത്തിന്റെ തരം';

  @override
  String get familyPlanningTemporary => 'താൽക്കാലികം';

  @override
  String get familyPlanningPermanent => 'സ്ഥിരം';

  @override
  String get familyPlanningMethod => 'താൽക്കാലിക മാർഗം';

  @override
  String get methodCuT => 'CU-T';

  @override
  String get methodPpiucd => 'PPIUCD';

  @override
  String get methodPaiucd => 'PAIUCD';

  @override
  String get familyPlanningActionDate => 'ഘടിപ്പിച്ച / നടപടിക്രമ തീയതി';

  @override
  String get familyPlanningRemarks => 'കുറിപ്പുകൾ (ഐച്ഛികം)';

  @override
  String get familyPlanningTypeRequired =>
      'താൽക്കാലികമോ സ്ഥിരമോ തിരഞ്ഞെടുക്കുക.';

  @override
  String get familyPlanningMethodRequired => 'താൽക്കാലിക മാർഗം തിരഞ്ഞെടുക്കുക.';

  @override
  String get familyPlanningDateRequired =>
      'ഘടിപ്പിച്ച അല്ലെങ്കിൽ നടപടിക്രമ തീയതി തിരഞ്ഞെടുക്കുക.';

  @override
  String get familyPlanningDateFuture => 'നടപടിക്രമ തീയതി ഭാവിയിലാകരുത്.';

  @override
  String get familyPlanningHistory => 'മുൻ രേഖകൾ';

  @override
  String get saveFamilyPlanning => 'കുടുംബാസൂത്രണ വിവരങ്ങൾ സംരക്ഷിക്കുക';

  @override
  String get familyPlanningSaved => 'കുടുംബാസൂത്രണ വിവരങ്ങൾ സംരക്ഷിച്ചു.';

  @override
  String get familyPlanningLoadFailed =>
      'കുടുംബാസൂത്രണ വിവരങ്ങൾ തുറക്കാനായില്ല. നിലവിലുള്ള ഡാറ്റ മാറ്റിയിട്ടില്ല.';

  @override
  String get familyPlanningSaveFailed =>
      'കുടുംബാസൂത്രണ വിവരങ്ങൾ സംരക്ഷിക്കാനായില്ല. നിലവിലുള്ള ഡാറ്റ മാറ്റിയിട്ടില്ല.';

  @override
  String get memberRelationshipsTitle => 'കുടുംബ ബന്ധങ്ങൾ';

  @override
  String get relationshipsSameHouseholdNotice =>
      'ഈ വീട്ടിലെ സജീവ അംഗങ്ങൾക്കിടയിൽ മാത്രമേ ബന്ധം ചേർക്കാനാകൂ.';

  @override
  String get relationshipType => 'ബന്ധത്തിന്റെ തരം';

  @override
  String get relationshipMotherOf => 'അമ്മയാണ്';

  @override
  String get relationshipIsMotherOf => 'അമ്മയാണ്';

  @override
  String get relationshipSpouseOf => 'ജീവിതപങ്കാളി';

  @override
  String get memberIsMother => 'ഈ അംഗമാണ് അമ്മ';

  @override
  String get relationshipOtherMember => 'മറ്റൊരു കുടുംബാംഗം';

  @override
  String get addRelationship => 'ബന്ധം ചേർക്കുക';

  @override
  String get relationshipActive => 'നിലവിൽ';

  @override
  String relationshipEnded(String date) {
    return '$date-ൽ അവസാനിച്ചു';
  }

  @override
  String get endRelationship => 'ബന്ധം അവസാനിപ്പിക്കുക';

  @override
  String get unknownMember => 'അംഗത്തെ കണ്ടെത്താനായില്ല';

  @override
  String get relationshipSaved => 'ബന്ധം സംരക്ഷിച്ചു.';

  @override
  String get relationshipLoadFailed =>
      'ബന്ധങ്ങൾ തുറക്കാനായില്ല. നിലവിലുള്ള ഡാറ്റ മാറ്റിയിട്ടില്ല.';

  @override
  String get relationshipSaveFailed =>
      'ബന്ധം സംരക്ഷിക്കാനായില്ല. നിലവിലുള്ള ബന്ധമുണ്ടോ എന്നും അംഗങ്ങൾ സജീവമാണോ എന്നും പരിശോധിക്കുക.';

  @override
  String get relationshipUpdateFailed =>
      'ബന്ധം പുതുക്കാനായില്ല. നിലവിലുള്ള ഡാറ്റ മാറ്റിയിട്ടില്ല.';

  @override
  String get editHouseholdTitle => 'കുടുംബവിവരങ്ങൾ തിരുത്തുക';

  @override
  String get saveHouseholdChanges => 'കുടുംബവിവരങ്ങൾ സംരക്ഷിക്കുക';

  @override
  String get householdChangesSaved => 'കുടുംബവിവരങ്ങൾ പുതുക്കി.';

  @override
  String get householdEditFailed =>
      'കുടുംബവിവരങ്ങൾ സംരക്ഷിക്കാനായില്ല. നിലവിലുള്ള ഡാറ്റ മാറ്റിയിട്ടില്ല.';

  @override
  String get rationCardEditUseReview =>
      'വിഭാഗം വ്യക്തമായി തിരഞ്ഞെടുക്കാൻ പ്രത്യേക അവലോകന നടപടി ഉപയോഗിക്കുക.';

  @override
  String get archiveHouseholdTitle => 'കുടുംബം ആർക്കൈവ് ചെയ്യണോ?';

  @override
  String get archiveHouseholdMessage =>
      'കുടുംബവും സജീവ അംഗങ്ങളും സാധാരണ പട്ടികയിൽ നിന്ന് മറയ്ക്കും. അംഗങ്ങളുടെ രേഖകൾ വീണ്ടെടുക്കാം.';

  @override
  String get archiveHouseholdAction => 'കുടുംബം ആർക്കൈവ് ചെയ്യുക';

  @override
  String get restoreHouseholdTitle => 'കുടുംബം പുനഃസ്ഥാപിക്കണോ?';

  @override
  String get restoreHouseholdMessage =>
      'കുടുംബം സജീവ പട്ടികയിൽ തിരിച്ചെത്തും. അംഗങ്ങൾ വ്യക്തിഗതമായി പുനഃസ്ഥാപിക്കുന്നതുവരെ ആർക്കൈവ് നിലയിൽ തുടരും.';

  @override
  String get restoreHouseholdAction => 'കുടുംബം പുനഃസ്ഥാപിക്കുക';

  @override
  String get householdActionFailed =>
      'കുടുംബം പുതുക്കാനായില്ല. നിലവിലുള്ള ഡാറ്റ മാറ്റിയിട്ടില്ല.';

  @override
  String get showArchivedHouseholds => 'ആർക്കൈവ് ചെയ്ത കുടുംബങ്ങൾ കാണിക്കുക';

  @override
  String get hideArchivedHouseholds => 'ആർക്കൈവ് ചെയ്ത കുടുംബങ്ങൾ മറയ്ക്കുക';

  @override
  String get archivedStatus => 'ആർക്കൈവ് ചെയ്തു';

  @override
  String get notes => 'കുറിപ്പുകൾ';

  @override
  String get reportsTitle => 'റിപ്പോർട്ടുകൾ';

  @override
  String get refreshReports => 'റിപ്പോർട്ടുകൾ പുതുക്കുക';

  @override
  String get reportsLoadFailed => 'റിപ്പോർട്ടുകൾ തുറക്കാനായില്ല.';

  @override
  String get ageBandDistribution => 'പ്രായം അനുസരിച്ചുള്ള അംഗങ്ങൾ';

  @override
  String get ageBandZeroToFive => '0–5 വയസ്സ്';

  @override
  String get ageBandSixToSeventeen => '6–17 വയസ്സ്';

  @override
  String get ageBandEighteenToFiftyNine => '18–59 വയസ്സ്';

  @override
  String get ageBandSixtyPlus => '60 വയസ്സും അതിൽ കൂടുതലും';

  @override
  String get reportsArchiveNotice =>
      'സജീവമായ, പൂർത്തിയായ കുടുംബങ്ങളിലെ സജീവ അംഗങ്ങളെ മാത്രമാണ് കണക്കിൽ ഉൾപ്പെടുത്തിയിരിക്കുന്നത്. ആർക്കൈവ് ചെയ്ത രേഖകളും ഡ്രാഫ്റ്റുകളും ഒഴിവാക്കിയിട്ടുണ്ട്.';

  @override
  String get saveGeneralDetails => 'വിവരങ്ങൾ സേവ് ചെയ്യുക';

  @override
  String get generalDetailsSaved => 'അംഗത്തിന്റെ വിവരങ്ങൾ സേവ് ചെയ്തു.';

  @override
  String get generalDetailsLoadFailed =>
      'അംഗത്തിന്റെ വിവരങ്ങൾ ലോഡ് ചെയ്യാനായില്ല. നിലവിലുള്ള വിവരങ്ങളിൽ മാറ്റമില്ല.';

  @override
  String get generalDetailsSaveFailed =>
      'അംഗത്തിന്റെ വിവരങ്ങൾ സേവ് ചെയ്യാനായില്ല. നിലവിലുള്ള വിവരങ്ങളിൽ മാറ്റമില്ല.';

  @override
  String get appLocked => 'കുടുംബവിവരങ്ങൾ സംരക്ഷിച്ചിരിക്കുന്നു';

  @override
  String get unlockReason => 'കുടുംബവിവരങ്ങൾ ഉപയോഗിക്കാൻ സ്ഥിരീകരിക്കുക.';

  @override
  String get unlockApp => 'തുറക്കുക';

  @override
  String get authenticating => 'സ്ഥിരീകരിക്കുന്നു…';

  @override
  String get authenticationNotCompleted =>
      'സ്ഥിരീകരണം പൂർത്തിയായില്ല. ആപ്പ് ലോക്കിലാണ്.';

  @override
  String get deviceAuthenticationUnavailable =>
      'ഈ ആപ്പ് ഉപയോഗിക്കാൻ ഉപകരണത്തിൽ ബയോമെട്രിക്സോ ഉപകരണ പാസ്‌കോഡോ സജ്ജീകരിക്കുക.';

  @override
  String get authenticationFailed =>
      'സ്ഥിരീകരിക്കാനായില്ല. ആപ്പ് ലോക്കിലാണ്; വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get hasOwnWell => 'സ്വന്തമായി കിണറുണ്ടോ';

  @override
  String get houseType => 'വീടിന്റെ തരം';

  @override
  String get headFullName => 'പൂർണ്ണ പേര്';

  @override
  String get dateOfBirth => 'ജനനത്തീയതി';

  @override
  String get gender => 'ലിംഗം';

  @override
  String get personPhone => 'വ്യക്തിഗത ഫോൺ (ഐച്ഛികം)';

  @override
  String get selectOption => 'ഒരു ഓപ്ഷൻ തിരഞ്ഞെടുക്കുക';

  @override
  String get selectDate => 'തീയതി തിരഞ്ഞെടുക്കുക';

  @override
  String get requiredField => 'ഈ ഫീൽഡ് ആവശ്യമാണ്.';

  @override
  String get futureDateError => 'ജനനത്തീയതി ഭാവിയിലാകരുത്.';

  @override
  String get save => 'കുടുംബം സേവ് ചെയ്യുക';

  @override
  String get saving => 'സേവ് ചെയ്യുന്നു…';

  @override
  String get cancel => 'റദ്ദാക്കുക';

  @override
  String get yes => 'ഉണ്ട്';

  @override
  String get no => 'ഇല്ല';

  @override
  String get draftStatus => 'പൂർത്തിയാകാത്തത്';

  @override
  String get completeStatus => 'പൂർത്തിയായി';

  @override
  String get noHouseholds => 'കുടുംബങ്ങൾ ഇതുവരെ രജിസ്റ്റർ ചെയ്തിട്ടില്ല.';

  @override
  String get addFirstHousehold => 'ആദ്യ കുടുംബം രജിസ്റ്റർ ചെയ്യുക';

  @override
  String get registrationFailed =>
      'കുടുംബം സേവ് ചെയ്യാനായില്ല. നിലവിലുള്ള വിവരങ്ങൾ മാറ്റമില്ലാതെ സൂക്ഷിച്ചിട്ടുണ്ട്.';

  @override
  String get possibleDuplicatesTitle => 'സമാനമായ കുടുംബങ്ങൾ';

  @override
  String get possibleDuplicatesMessage =>
      'ഈ പേരും വീട്ടുനമ്പറും അല്ലെങ്കിൽ ഫോണും ഉള്ള കുടുംബം ഇതിനകം ഉണ്ടാകാം. തുടരുന്നതിന് മുമ്പ് പരിശോധിക്കുക.';

  @override
  String get continueRegistration => 'എന്നിരുന്നാലും തുടരുക';

  @override
  String get reviewMatches => 'പരിശോധിക്കുക';

  @override
  String get householdSaved => 'കുടുംബം രജിസ്റ്റർ ചെയ്തു.';

  @override
  String houseNumberSummary(Object houseNumber) {
    return 'വീട്ടുനമ്പർ: $houseNumber';
  }

  @override
  String get rationYellow => 'മഞ്ഞ';

  @override
  String get rationPink => 'പിങ്ക്';

  @override
  String get rationBlue => 'നീല';

  @override
  String get rationWhite => 'വെള്ള';

  @override
  String get other => 'മറ്റുള്ളവ';

  @override
  String get unknown => 'അറിയില്ല';

  @override
  String get houseTiledRoof => 'ഓട് മേഞ്ഞത്';

  @override
  String get houseConcreteTerrace => 'കോൺക്രീറ്റ് / ടെറസ്';

  @override
  String get houseSheetRoof => 'ഷീറ്റ് മേഞ്ഞത്';

  @override
  String get genderFemale => 'സ്ത്രീ';

  @override
  String get genderMale => 'പുരുഷൻ';

  @override
  String get genderPreferNotToSay => 'പറയാൻ താൽപര്യമില്ല';

  @override
  String get addressRequired => 'വിലാസം നൽകുക.';

  @override
  String get headRoleDescription =>
      'ഈ വ്യക്തിയെ കുടുംബനാഥനായി / നാഥയായി സേവ് ചെയ്യും.';

  @override
  String get requiredFieldShort => 'ആവശ്യമാണ്';

  @override
  String get databaseUnavailable =>
      'പ്രാദേശിക ഡാറ്റാബേസ് തുറക്കാനായില്ല. നിലവിലുള്ള വിവരങ്ങൾ മാറ്റമില്ലാതെ സൂക്ഷിച്ചിട്ടുണ്ട്. ആപ്പ് വീണ്ടും ഇൻസ്റ്റാൾ ചെയ്യുന്നതിന് മുമ്പ് അഡ്മിനിസ്ട്രേറ്ററെ ബന്ധപ്പെടുക.';

  @override
  String get householdListLoadFailed =>
      'കുടുംബവിവരങ്ങൾ ലഭ്യമാക്കാനായില്ല. നിലവിലുള്ള വിവരങ്ങളിൽ മാറ്റമുണ്ടായിട്ടില്ല.';

  @override
  String get householdProfileTitle => 'കുടുംബ വിവരങ്ങൾ';

  @override
  String get familyMembers => 'കുടുംബാംഗങ്ങൾ';

  @override
  String get addMemberAction => 'അംഗത്തെ ചേർക്കുക';

  @override
  String get addMemberTitle => 'കുടുംബാംഗത്തെ ചേർക്കുക';

  @override
  String get editMemberTitle => 'കുടുംബാംഗത്തിന്റെ വിവരങ്ങൾ തിരുത്തുക';

  @override
  String get memberName => 'പൂർണ്ണ പേര്';

  @override
  String get relationshipToHead => 'കുടുംബനാഥനുമായുള്ള ബന്ധം';

  @override
  String get selectRelationship => 'ബന്ധം തിരഞ്ഞെടുക്കുക';

  @override
  String get relationshipHead => 'കുടുംബനാഥൻ / നാഥ';

  @override
  String get relationshipSpouse => 'ഭാര്യ / ഭർത്താവ്';

  @override
  String get relationshipSon => 'മകൻ';

  @override
  String get relationshipDaughter => 'മകൾ';

  @override
  String get relationshipParent => 'മാതാപിതാവ്';

  @override
  String get relationshipSibling => 'സഹോദരൻ / സഹോദരി';

  @override
  String get relationshipGrandparent => 'മുത്തശ്ശൻ / മുത്തശ്ശി';

  @override
  String get relationshipInLaw => 'വിവാഹബന്ധത്തിലുള്ള ബന്ധു';

  @override
  String get relationshipOther => 'മറ്റുള്ളവർ';

  @override
  String get memberPhoneInvalid => 'സാധുവായ ഫോൺ നമ്പർ നൽകുക.';

  @override
  String get saveMember => 'അംഗത്തെ സേവ് ചെയ്യുക';

  @override
  String get memberAdded => 'അംഗത്തെ ചേർത്തു.';

  @override
  String get memberUpdated => 'അംഗത്തിന്റെ വിവരങ്ങൾ പുതുക്കി.';

  @override
  String get memberSaveFailed =>
      'അംഗത്തിന്റെ വിവരങ്ങൾ സേവ് ചെയ്യാനായില്ല. നിലവിലുള്ള വിവരങ്ങൾ മാറ്റമില്ലാതെ സൂക്ഷിച്ചിട്ടുണ്ട്.';

  @override
  String get removeMemberAction => 'അംഗത്തെ നീക്കുക';

  @override
  String get removeMemberTitle => 'ഈ അംഗത്തെ നീക്കണോ?';

  @override
  String get removeMemberMessage =>
      'ഈ അംഗത്തെ ആർക്കൈവ് ചെയ്ത് സജീവ കുടുംബത്തിൽ നിന്ന് മറയ്ക്കും. പിന്നീട് പുനഃസ്ഥാപിക്കാം.';

  @override
  String get confirmRemoveMember => 'അംഗത്തെ നീക്കുക';

  @override
  String get memberRemoved => 'സജീവ കുടുംബത്തിൽ നിന്ന് അംഗത്തെ നീക്കി.';

  @override
  String get archivedMembers => 'ആർക്കൈവ് ചെയ്ത അംഗങ്ങൾ';

  @override
  String get showArchivedMembers => 'ആർക്കൈവ് ചെയ്ത അംഗങ്ങളെ കാണിക്കുക';

  @override
  String get restoreMemberAction => 'അംഗത്തെ പുനഃസ്ഥാപിക്കുക';

  @override
  String get memberRestored => 'അംഗത്തെ പുനഃസ്ഥാപിച്ചു.';

  @override
  String get memberActionFailed => 'അംഗത്തിന്റെ നടപടി പൂർത്തിയാക്കാനായില്ല.';

  @override
  String get houseNumberLabel => 'വീട്ടുനമ്പർ';

  @override
  String get houseTypeLabel => 'വീടിന്റെ തരം';

  @override
  String get wellOwnership => 'സ്വന്തം കിണർ';

  @override
  String get searchPeopleTitle => 'ആളുകളെ തിരയുക';

  @override
  String get searchPeopleHint => 'പേര്, വീട്, നമ്പർ, അല്ലെങ്കിൽ ഫോൺ';

  @override
  String get ageRange => 'പ്രായപരിധി';

  @override
  String get minimumAge => 'കുറഞ്ഞ പ്രായം';

  @override
  String get maximumAge => 'കൂടിയ പ്രായം';

  @override
  String get rationCardTypes => 'റേഷൻ കാർഡ് തരങ്ങൾ';

  @override
  String get pregnancyStatus => 'ഗർഭാവസ്ഥ';

  @override
  String get currentlyPregnant => 'ഇപ്പോൾ ഗർഭിണികൾ';

  @override
  String get householdFilter => 'കുടുംബം';

  @override
  String get allHouseholds => 'എല്ലാ കുടുംബങ്ങളും';

  @override
  String get applyFilters => 'ഫിൽട്ടർ ചെയ്യുക';

  @override
  String get resetFilters => 'മായ്ക്കുക';

  @override
  String get noSearchResults => 'പൊരുത്തപ്പെടുന്ന ആളുകളെ കണ്ടെത്തിയില്ല.';

  @override
  String searchAge(Object age) {
    return 'പ്രായം $age';
  }

  @override
  String get matchingPeople => 'പൊരുത്തപ്പെട്ടവർ';

  @override
  String get invalidAge => 'പൂജ്യമോ അതിലധികമോ ഉള്ള പൂർണ്ണസംഖ്യ നൽകുക.';

  @override
  String get invalidAgeRange =>
      'കുറഞ്ഞ പ്രായം കൂടിയ പ്രായത്തേക്കാൾ കൂടുതലാകരുത്.';

  @override
  String get memberSearchFailed =>
      'ആളുകളെ തിരയാനായില്ല. നിലവിലുള്ള വിവരങ്ങളിൽ മാറ്റമുണ്ടായിട്ടില്ല.';

  @override
  String get backupTitle => 'ബാക്കപ്പ്, പുനഃസ്ഥാപിക്കൽ';

  @override
  String get backupPrivacyNotice =>
      'ബാക്കപ്പിൽ എല്ലാ കുടുംബ, അംഗ, ആരോഗ്യ, പ്രത്യുത്പാദന വിവരങ്ങളും ഉൾപ്പെടുന്നു. നിങ്ങൾ സൃഷ്ടിക്കുന്ന പാസ്‌ഫ്രെയ്‌സ് ഉപയോഗിച്ച് ഇത് എൻക്രിപ്റ്റ് ചെയ്യും. പാസ്‌ഫ്രെയ്‌സ് സുരക്ഷിതമായി സൂക്ഷിക്കുക; ആപ്പിൽ ഇത് സൂക്ഷിക്കില്ല.';

  @override
  String get backupCreateAction => 'എൻക്രിപ്റ്റ് ചെയ്ത ബാക്കപ്പ് സൃഷ്ടിക്കുക';

  @override
  String get backupRestoreAction => 'ബാക്കപ്പ് പുനഃസ്ഥാപിക്കുക';

  @override
  String get backupCreateTitle => 'ബാക്കപ്പ് സുരക്ഷിതമാക്കുക';

  @override
  String get backupPassphraseTitle => 'ബാക്കപ്പ് പാസ്‌ഫ്രെയ്‌സ് നൽകുക';

  @override
  String get backupPassphraseHint =>
      'കുറഞ്ഞത് 12 അക്ഷരങ്ങൾ ഉപയോഗിക്കുക. പാസ്‌ഫ്രെയ്‌സ് നഷ്ടപ്പെട്ടാൽ വീണ്ടെടുക്കാനാകില്ല.';

  @override
  String get backupPassphraseLabel => 'പാസ്‌ഫ്രെയ്‌സ്';

  @override
  String get backupPassphraseConfirm => 'പാസ്‌ഫ്രെയ്‌സ് സ്ഥിരീകരിക്കുക';

  @override
  String get backupPassphraseInvalid =>
      '12 മുതൽ 1024 അക്ഷരങ്ങൾ വരെയുള്ള പാസ്‌ഫ്രെയ്‌സ് നൽകുക.';

  @override
  String get backupPassphraseMismatch =>
      'പാസ്‌ഫ്രെയ്‌സുകൾ തമ്മിൽ പൊരുത്തപ്പെടുന്നില്ല.';

  @override
  String get backupShareMessage => 'എൻക്രിപ്റ്റ് ചെയ്ത കുടുംബവിവര ബാക്കപ്പ്';

  @override
  String get backupOperationFailed =>
      'ബാക്കപ്പ് നടപടി പരാജയപ്പെട്ടു. നിലവിലുള്ള പ്രാദേശിക വിവരങ്ങളിൽ മാറ്റമുണ്ടായിട്ടില്ല.';

  @override
  String get backupFileReadFailed =>
      'തിരഞ്ഞെടുത്ത ബാക്കപ്പ് ഫയൽ വായിക്കാനായില്ല.';

  @override
  String get backupFileInvalid =>
      'ബാക്കപ്പ് ഫയൽ അസാധുവാണ് അല്ലെങ്കിൽ ഈ ആപ്പ് പതിപ്പുമായി പൊരുത്തപ്പെടുന്നില്ല.';

  @override
  String get backupAuthenticationFailed =>
      'പാസ്‌ഫ്രെയ്‌സ് തെറ്റാണ് അല്ലെങ്കിൽ ബാക്കപ്പ് ഫയലിൽ മാറ്റം വരുത്തിയിട്ടുണ്ട്.';

  @override
  String get backupRestorePreviewTitle => 'ബാക്കപ്പിന്റെ വിവരങ്ങൾ പരിശോധിക്കുക';

  @override
  String backupRestorePreview(
    int households,
    int members,
    int householdConflicts,
    int memberConflicts,
  ) {
    return 'ബാക്കപ്പിൽ $households കുടുംബങ്ങളും $members അംഗങ്ങളുമുണ്ട്. നിലവിലുള്ള ഐഡി വൈരുദ്ധ്യങ്ങൾ: $householdConflicts കുടുംബങ്ങൾ, $memberConflicts അംഗങ്ങൾ. ലയിപ്പിക്കുമ്പോൾ വൈരുദ്ധ്യമുള്ള പ്രാദേശിക വിവരങ്ങൾ നിലനിർത്തും; പകരംവയ്ക്കൽ നിലവിലെ എല്ലാ പ്രാദേശിക വിവരങ്ങളും ഇല്ലാതാക്കും.';
  }

  @override
  String get backupMergeAction => 'ലയിപ്പിക്കുക';

  @override
  String get backupReplaceAction =>
      'എല്ലാ പ്രാദേശിക വിവരങ്ങളും മാറ്റിസ്ഥാപിക്കുക';

  @override
  String get backupReplaceConfirmTitle =>
      'എല്ലാ പ്രാദേശിക വിവരങ്ങളും മാറ്റിസ്ഥാപിക്കണോ?';

  @override
  String get backupReplaceConfirmMessage =>
      'തിരഞ്ഞെടുത്ത ബാക്കപ്പ് ഉപയോഗിച്ച് നിലവിലെ എല്ലാ കുടുംബ-അംഗ വിവരങ്ങളും മാറ്റിസ്ഥാപിക്കും. ഇത് പഴയപടിയാക്കാനാകില്ല.';

  @override
  String backupRestoreComplete(int imported, int skipped) {
    return 'പുനഃസ്ഥാപിക്കൽ പൂർത്തിയായി. $imported വിവരങ്ങൾ ഇറക്കുമതി ചെയ്തു; $skipped ഒഴിവാക്കി.';
  }

  @override
  String get continueAction => 'തുടരുക';

  @override
  String get csvExportTitle =>
      'തിരഞ്ഞെടുത്ത വിവരങ്ങൾ CSV ആയി കയറ്റുമതി ചെയ്യുക';

  @override
  String get csvPrivacyNotice =>
      'സജീവമായ കുടുംബങ്ങളുടെയും അംഗങ്ങളുടെയും വിവരങ്ങളാണ് കയറ്റുമതിയിൽ ഉൾപ്പെടുക. ആധാർ, ആരോഗ്യ, വിവാഹ, ഗർഭാവസ്ഥ, കുട്ടി, കുടുംബാസൂത്രണ വിവരങ്ങൾ തുടക്കത്തിൽ ഒഴിവാക്കിയിരിക്കും. CSV പങ്കിട്ടുകഴിഞ്ഞാൽ എൻക്രിപ്റ്റ് ചെയ്തതായിരിക്കില്ല. കയറ്റുമതിക്ക് മുമ്പ് തിരഞ്ഞെടുത്ത വിവരങ്ങൾ പരിശോധിക്കുക.';

  @override
  String get csvExportAction => 'തിരഞ്ഞെടുത്ത വിവരങ്ങൾ കയറ്റുമതി ചെയ്യുക';

  @override
  String get csvShareMessage => 'കുടുംബവിവര CSV കയറ്റുമതി';

  @override
  String get csvSelectHouseholdsTitle => 'കുടുംബങ്ങൾ തിരഞ്ഞെടുക്കുക';

  @override
  String get csvSelectHouseholdsHint =>
      'കയറ്റുമതിയിൽ ഉൾപ്പെടുത്താൻ എല്ലാ സജീവ കുടുംബങ്ങളെയോ തിരഞ്ഞെടുത്ത ചില കുടുംബങ്ങളെയോ തിരഞ്ഞെടുക്കുക.';

  @override
  String get csvSelectAll => 'എല്ലാ സജീവ കുടുംബങ്ങളും തിരഞ്ഞെടുക്കുക';

  @override
  String get csvNoHouseholds => 'കയറ്റുമതി ചെയ്യാൻ സജീവ കുടുംബങ്ങളില്ല.';

  @override
  String get csvSensitiveConfirmTitle =>
      'സെൻസിറ്റീവ് വിവരങ്ങൾ കയറ്റുമതി ചെയ്യണോ?';

  @override
  String get csvSensitiveConfirmMessage =>
      'സെൻസിറ്റീവ് ആധാർ, ആരോഗ്യം, വിവാഹം, ഗർഭാവസ്ഥ, കുട്ടി, കുടുംബാസൂത്രണ വിവരങ്ങൾ നിങ്ങൾ തിരഞ്ഞെടുത്തു. CSV എൻക്രിപ്റ്റ് ചെയ്തതല്ല; പങ്കിട്ടതിന് ശേഷം മറ്റ് ആപ്പുകൾക്ക് ലഭ്യമായേക്കാം. നിങ്ങൾക്ക് അനുമതിയുണ്ടെന്നും ഈ വിവരങ്ങൾ ആവശ്യമാണെന്നും ഉറപ്പുണ്ടെങ്കിൽ മാത്രം തുടരുക.';

  @override
  String get csvSensitiveConfirmAction =>
      'സെൻസിറ്റീവ് വിവരങ്ങൾ കയറ്റുമതി ചെയ്യുക';

  @override
  String get csvExportMatchesTitle => 'പൊരുത്തപ്പെട്ടവരെ കയറ്റുമതി ചെയ്യുക';
}
