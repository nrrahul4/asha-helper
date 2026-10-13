class PregnancyDetailsInput {
  const PregnancyDetailsInput({
    this.abaId = '',
    this.lastMensesDate,
    this.consultingHospital = '',
    this.previousPregnancyCount,
    this.lastLiveBirthDate,
  });

  final String abaId;
  final DateTime? lastMensesDate;
  final String consultingHospital;
  final int? previousPregnancyCount;
  final DateTime? lastLiveBirthDate;
}
