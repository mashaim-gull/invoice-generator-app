import 'package:hive_flutter/hive_flutter.dart';
import '../models/invoice_model.dart';
import '../models/customer_model.dart';
import '../models/company_model.dart';
import '../models/item_model.dart';
import '../models/settings_model.dart';

class HiveDatabase {
  static const String invoiceBoxName = 'invoiceBox';
  static const String customerBoxName = 'customerBox';
  static const String companyBoxName = 'companyBox';
  static const String settingsBoxName = 'settingsBox';

  static Future<void> init() async {
    // Register Adapters
    Hive.registerAdapter(InvoiceModelAdapter());
    Hive.registerAdapter(InvoiceStatusAdapter());
    Hive.registerAdapter(CustomerModelAdapter());
    Hive.registerAdapter(CompanyModelAdapter());
    Hive.registerAdapter(ItemModelAdapter());
    Hive.registerAdapter(SettingsModelAdapter());

    // Open Boxes
    await Hive.openBox<InvoiceModel>(invoiceBoxName);
    await Hive.openBox<CustomerModel>(customerBoxName);
    await Hive.openBox<CompanyModel>(companyBoxName);
    await Hive.openBox<SettingsModel>(settingsBoxName);
  }
}

