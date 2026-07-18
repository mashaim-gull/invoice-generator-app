// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InvoiceModelAdapter extends TypeAdapter<InvoiceModel> {
  @override
  final int typeId = 0;

  @override
  InvoiceModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InvoiceModel(
      id: fields[0] as String,
      invoiceNumber: fields[1] as String,
      invoiceDate: fields[2] as DateTime,
      dueDate: fields[3] as DateTime,
      company: fields[4] as CompanyModel,
      customer: fields[5] as CustomerModel,
      items: (fields[6] as List).cast<ItemModel>(),
      subtotal: fields[7] as double,
      taxPercentage: fields[8] as double,
      taxAmount: fields[9] as double,
      totalDiscount: fields[10] as double,
      grandTotal: fields[11] as double,
      notes: fields[12] as String,
      paymentInstructions: fields[13] as String,
      invoiceStatus: fields[14] as InvoiceStatus,
      createdAt: fields[15] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, InvoiceModel obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.invoiceNumber)
      ..writeByte(2)
      ..write(obj.invoiceDate)
      ..writeByte(3)
      ..write(obj.dueDate)
      ..writeByte(4)
      ..write(obj.company)
      ..writeByte(5)
      ..write(obj.customer)
      ..writeByte(6)
      ..write(obj.items)
      ..writeByte(7)
      ..write(obj.subtotal)
      ..writeByte(8)
      ..write(obj.taxPercentage)
      ..writeByte(9)
      ..write(obj.taxAmount)
      ..writeByte(10)
      ..write(obj.totalDiscount)
      ..writeByte(11)
      ..write(obj.grandTotal)
      ..writeByte(12)
      ..write(obj.notes)
      ..writeByte(13)
      ..write(obj.paymentInstructions)
      ..writeByte(14)
      ..write(obj.invoiceStatus)
      ..writeByte(15)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvoiceModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class InvoiceStatusAdapter extends TypeAdapter<InvoiceStatus> {
  @override
  final int typeId = 5;

  @override
  InvoiceStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return InvoiceStatus.paid;
      case 1:
        return InvoiceStatus.unpaid;
      case 2:
        return InvoiceStatus.overdue;
      default:
        return InvoiceStatus.paid;
    }
  }

  @override
  void write(BinaryWriter writer, InvoiceStatus obj) {
    switch (obj) {
      case InvoiceStatus.paid:
        writer.writeByte(0);
        break;
      case InvoiceStatus.unpaid:
        writer.writeByte(1);
        break;
      case InvoiceStatus.overdue:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvoiceStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

