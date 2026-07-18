import 'package:hive/hive.dart';

part 'company_model.g.dart';

@HiveType(typeId: 2)
class CompanyModel extends HiveObject {
  @HiveField(0)
  String companyName;

  @HiveField(1)
  String address;

  @HiveField(2)
  String email;

  @HiveField(3)
  String phone;

  @HiveField(4)
  String logoPath;

  CompanyModel({
    required this.companyName,
    required this.address,
    required this.email,
    required this.phone,
    required this.logoPath,
  });
}

