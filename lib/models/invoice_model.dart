import 'package:hive/hive.dart';
import 'customer_model.dart';
import 'company_model.dart';
import 'item_model.dart';

part 'invoice_model.g.dart';

@HiveType(typeId: 5)
enum InvoiceStatus {
  @HiveField(0)
  paid,
  @HiveField(1)
  unpaid,
  @HiveField(2)
  overdue,
}

@HiveType(typeId: 0)
class InvoiceModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String invoiceNumber;

  @HiveField(2)
  DateTime invoiceDate;

  @HiveField(3)
  DateTime dueDate;

  @HiveField(4)
  CompanyModel company;

  @HiveField(5)
  CustomerModel customer;

  @HiveField(6)
  List<ItemModel> items;

  @HiveField(7)
  double subtotal;

  @HiveField(8)
  double taxPercentage;

  @HiveField(9)
  double taxAmount;

  @HiveField(10)
  double totalDiscount;

  @HiveField(11)
  double grandTotal;

  @HiveField(12)
  String notes;

  @HiveField(13)
  String paymentInstructions;

  @HiveField(14)
  InvoiceStatus invoiceStatus;

  @HiveField(15)
  DateTime createdAt;

  InvoiceModel({
    required this.id,
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.dueDate,
    required this.company,
    required this.customer,
    required this.items,
    required this.subtotal,
    required this.taxPercentage,
    required this.taxAmount,
    required this.totalDiscount,
    required this.grandTotal,
    required this.notes,
    required this.paymentInstructions,
    required this.invoiceStatus,
    required this.createdAt,
  });
}

