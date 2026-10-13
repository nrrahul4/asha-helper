enum HouseholdRecordStatus {
  draft('draft'),
  complete('complete');

  const HouseholdRecordStatus(this.code);

  final String code;

  static HouseholdRecordStatus fromCode(String code) =>
      values.firstWhere((value) => value.code == code);
}

enum RationCardType {
  bpl('bpl'),
  apl('apl'),
  aay('aay'),
  yellow('yellow'),
  pink('pink'),
  blue('blue'),
  white('white'),
  other('other'),
  unknown('unknown');

  const RationCardType(this.code);

  final String code;

  static const selectableValues = <RationCardType>[bpl, apl, aay];

  bool get requiresReview => !selectableValues.contains(this);

  static RationCardType fromCode(String code) =>
      values.firstWhere((value) => value.code == code);
}

enum HouseType {
  tiledRoof('tiled_roof'),
  concreteTerrace('concrete_terrace'),
  sheetRoof('sheet_roof'),
  other('other'),
  unknown('unknown');

  const HouseType(this.code);

  final String code;

  static HouseType fromCode(String code) =>
      values.firstWhere((value) => value.code == code);
}

enum Gender {
  female('female'),
  male('male'),
  other('other'),
  preferNotToSay('prefer_not_to_say'),
  unknown('unknown');

  const Gender(this.code);

  final String code;

  static Gender fromCode(String code) =>
      values.firstWhere((value) => value.code == code);
}

enum RelationshipToHead {
  head('head'),
  spouse('spouse'),
  son('son'),
  daughter('daughter'),
  parent('parent'),
  sibling('sibling'),
  grandparent('grandparent'),
  inLaw('in_law'),
  other('other');

  const RelationshipToHead(this.code);

  final String code;

  static RelationshipToHead fromCode(String code) =>
      values.firstWhere((value) => value.code == code);
}

enum BloodGroup {
  aPositive('a_pos'),
  aNegative('a_neg'),
  bPositive('b_pos'),
  bNegative('b_neg'),
  abPositive('ab_pos'),
  abNegative('ab_neg'),
  oPositive('o_pos'),
  oNegative('o_neg'),
  unknown('unknown');

  const BloodGroup(this.code);

  final String code;

  static BloodGroup fromCode(String code) =>
      values.firstWhere((value) => value.code == code);
}
