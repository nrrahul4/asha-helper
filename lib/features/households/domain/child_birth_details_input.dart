import '../../../data/models/child_birth_details.dart';

class ChildBirthDetailsInput {
  const ChildBirthDetailsInput({
    this.birthWeightKg,
    this.birthTime,
    this.deliveryType,
    this.specialCareRequired,
    this.specialCareDetails,
    this.requiresSpecialCareAnswer = false,
  });

  final double? birthWeightKg;
  final String? birthTime;
  final ChildDeliveryType? deliveryType;
  final bool? specialCareRequired;
  final String? specialCareDetails;
  final bool requiresSpecialCareAnswer;
}
