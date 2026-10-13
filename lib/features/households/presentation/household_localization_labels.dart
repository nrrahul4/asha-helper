import '../../../data/models/database_codes.dart';
import '../../../l10n/generated/app_localizations.dart';

String rationCardLabel(AppLocalizations strings, RationCardType value) =>
    switch (value) {
      RationCardType.bpl => strings.rationBpl,
      RationCardType.apl => strings.rationApl,
      RationCardType.aay => strings.rationAay,
      RationCardType.yellow => strings.rationYellow,
      RationCardType.pink => strings.rationPink,
      RationCardType.blue => strings.rationBlue,
      RationCardType.white => strings.rationWhite,
      RationCardType.other => strings.other,
      RationCardType.unknown => strings.unknown,
    };

String houseTypeLabel(AppLocalizations strings, HouseType value) =>
    switch (value) {
      HouseType.tiledRoof => strings.houseTiledRoof,
      HouseType.concreteTerrace => strings.houseConcreteTerrace,
      HouseType.sheetRoof => strings.houseSheetRoof,
      HouseType.other => strings.other,
      HouseType.unknown => strings.unknown,
    };

String genderLabel(AppLocalizations strings, Gender value) => switch (value) {
  Gender.female => strings.genderFemale,
  Gender.male => strings.genderMale,
  Gender.other => strings.other,
  Gender.preferNotToSay => strings.genderPreferNotToSay,
  Gender.unknown => strings.unknown,
};

String relationshipLabel(AppLocalizations strings, RelationshipToHead value) =>
    switch (value) {
      RelationshipToHead.head => strings.relationshipHead,
      RelationshipToHead.spouse => strings.relationshipSpouse,
      RelationshipToHead.son => strings.relationshipSon,
      RelationshipToHead.daughter => strings.relationshipDaughter,
      RelationshipToHead.parent => strings.relationshipParent,
      RelationshipToHead.sibling => strings.relationshipSibling,
      RelationshipToHead.grandparent => strings.relationshipGrandparent,
      RelationshipToHead.inLaw => strings.relationshipInLaw,
      RelationshipToHead.other => strings.relationshipOther,
    };

String householdStatusLabel(
  AppLocalizations strings,
  HouseholdRecordStatus status,
) => switch (status) {
  HouseholdRecordStatus.draft => strings.draftStatus,
  HouseholdRecordStatus.complete => strings.completeStatus,
};
