import 'package:hive/hive.dart';

part 'customer_model.g.dart';

@HiveType(typeId: 1)
class CustomerModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String address;

  @HiveField(3)
  String email;

  @HiveField(4)
  String phone;

  @HiveField(5)
  bool? isFavorite;

  CustomerModel({
    required this.id,
    required this.name,
    required this.address,
    required this.email,
    required this.phone,
    this.isFavorite = false,
  });
}

