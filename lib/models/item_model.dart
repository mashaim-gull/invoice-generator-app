import 'package:hive/hive.dart';

part 'item_model.g.dart';

@HiveType(typeId: 3)
class ItemModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String itemName;

  @HiveField(2)
  int quantity;

  @HiveField(3)
  double unitPrice;

  @HiveField(4)
  double discount;

  @HiveField(5)
  double totalPrice;

  ItemModel({
    required this.id,
    required this.itemName,
    required this.quantity,
    required this.unitPrice,
    required this.discount,
    required this.totalPrice,
  });
}

