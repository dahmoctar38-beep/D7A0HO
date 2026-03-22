class UserPreferences {
  final bool isDiabetic;
  final bool isHypertensive;
  final List<String> allergens;
  final bool veganMode;

  const UserPreferences({
    this.isDiabetic = false,
    this.isHypertensive = false,
    this.allergens = const [],
    this.veganMode = false,
  });

  UserPreferences copyWith({
    bool? isDiabetic,
    bool? isHypertensive,
    List<String>? allergens,
    bool? veganMode,
  }) =>
      UserPreferences(
        isDiabetic: isDiabetic ?? this.isDiabetic,
        isHypertensive: isHypertensive ?? this.isHypertensive,
        allergens: allergens ?? this.allergens,
        veganMode: veganMode ?? this.veganMode,
      );
}
