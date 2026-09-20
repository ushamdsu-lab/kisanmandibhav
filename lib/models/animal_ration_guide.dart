class AnimalRationCalculation {
  final double dryFodderKg; // सूखा चारा (भूसा/कड़बी)
  final double greenFodderKg; // हरा चारा (बरसीम/मक्का/नेपियर)
  final double concentrateKg; // संतुलित दाना / खली
  final double mineralMixtureGrams; // मिनरल मिक्चर (खनिज लवण)
  final double saltGrams; // साधारण नमक
  final double dailyWaterLiters; // अनुमानित पीने का पानी

  const AnimalRationCalculation({
    required this.dryFodderKg,
    required this.greenFodderKg,
    required this.concentrateKg,
    required this.mineralMixtureGrams,
    required this.saltGrams,
    required this.dailyWaterLiters,
  });

  /// Scientific ICAR / NDRI feeding standards
  /// [isBuffalo]: true for buffalo (needs higher concentrate/fat), false for cow
  /// [dailyMilkLiters]: current milk yield per day
  /// [bodyWeightKg]: estimated body weight (~350kg to 500kg)
  /// [isPregnant]: whether animal is in advanced pregnancy (+1.5kg feed)
  factory AnimalRationCalculation.calculate({
    required bool isBuffalo,
    required double dailyMilkLiters,
    double bodyWeightKg = 400,
    bool isPregnant = false,
  }) {
    // Maintenance concentrate: 1.25 kg for cow, 1.5 kg for buffalo
    double concentrate = isBuffalo ? 1.5 : 1.25;

    // Production concentrate:
    // Cow: 1 kg concentrate for every 2.5 to 3.0 Liters milk
    // Buffalo: 1 kg concentrate for every 2.0 to 2.5 Liters milk (due to higher fat)
    if (isBuffalo) {
      concentrate += (dailyMilkLiters / 2.0);
    } else {
      concentrate += (dailyMilkLiters / 2.5);
    }

    if (isPregnant) {
      concentrate += 1.25; // Extra pregnancy allowance
    }

    // Dry fodder: 4 to 6 kg for cow, 6 to 8 kg for buffalo
    double dryFodder = isBuffalo ? 7.0 : 5.0;

    // Green fodder: 15 to 25 kg
    double greenFodder = isBuffalo ? 22.0 : 18.0;

    // Mineral mixture: 50g base + 5g per 2L milk
    double mineral = 50.0 + (dailyMilkLiters * 2.5).clamp(0, 50);

    // Common salt: 40-50 grams
    double salt = 45.0;

    // Daily water: 50 to 80 Liters (Milk requires 4x water)
    double water = (bodyWeightKg * 0.1) + (dailyMilkLiters * 4.0);

    return AnimalRationCalculation(
      dryFodderKg: double.parse(dryFodder.toStringAsFixed(1)),
      greenFodderKg: double.parse(greenFodder.toStringAsFixed(1)),
      concentrateKg: double.parse(concentrate.toStringAsFixed(1)),
      mineralMixtureGrams: double.parse(mineral.toStringAsFixed(0)),
      saltGrams: salt,
      dailyWaterLiters: double.parse(water.toStringAsFixed(0)),
    );
  }
}
