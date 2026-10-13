import '../../../data/models/database_codes.dart';

class MemberGeneralDetailsInput {
  const MemberGeneralDetailsInput({
    this.aadhaarNumber = '',
    this.educationLevel = '',
    this.jobTitle = '',
    this.isCurrentlyWorkingAbroad,
    this.bloodGroup,
  });

  final String aadhaarNumber;
  final String educationLevel;
  final String jobTitle;
  final bool? isCurrentlyWorkingAbroad;
  final BloodGroup? bloodGroup;
}
