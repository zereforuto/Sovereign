/// Supported weight measurement units in Sovereign.
enum WeightUnit {
  kg,
  lb;

  static WeightUnit fromString(String? val) {
    return val?.toLowerCase() == 'lb' ? WeightUnit.lb : WeightUnit.kg;
  }
}
