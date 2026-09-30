enum RadioBandType {
  uzunDalga('UZUN DALGA', 'LW (Long Wave)', 'kHz', 140.0, 290.0, 1.0),
  ortaDalga('ORTA DALGA', 'MW / AM (Medium Wave)', 'kHz', 520.0, 1620.0, 5.0),
  kisaDalga('KISA DALGA', 'SW (Short Wave)', 'MHz', 5.8, 18.2, 0.05),
  fm('FM DALGASI', 'UKW / FM (Ultralight)', 'MHz', 87.5, 108.0, 0.1);

  final String turkishTitle;
  final String internationalTitle;
  final String unit;
  final double minFrequency;
  final double maxFrequency;
  final double step;

  const RadioBandType(
    this.turkishTitle,
    this.internationalTitle,
    this.unit,
    this.minFrequency,
    this.maxFrequency,
    this.step,
  );
}
