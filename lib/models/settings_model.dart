import 'package:hive/hive.dart';

part 'settings_model.g.dart';

@HiveType(typeId: 4)
class SettingsModel extends HiveObject {
  @HiveField(0)
  String currency;

  @HiveField(1)
  String invoicePrefix;

  @HiveField(2)
  double defaultTaxPercentage;

  @HiveField(3)
  bool darkModeEnabled;

  SettingsModel({
    required this.currency,
    required this.invoicePrefix,
    required this.defaultTaxPercentage,
    required this.darkModeEnabled,
  });
}

