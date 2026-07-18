import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';
import '../models/settings_model.dart';
import '../models/company_model.dart';
import '../utils/constants.dart';

/// SettingsService manages all application settings (company info, preferences)
/// using Hive for local persistence and ChangeNotifier for Provider integration.
class SettingsService extends ChangeNotifier {
  late Box<SettingsModel> _settingsBox;
  late Box<CompanyModel> _companyBox;

  SettingsModel? _settings;
  CompanyModel? _company;

  SettingsModel get settings => _settings ?? _defaultSettings;
  CompanyModel get company => _company ?? _defaultCompany;

  bool get isDarkMode => settings.darkModeEnabled;
  String get currency => settings.currency;
  String get invoicePrefix => settings.invoicePrefix;
  double get defaultTax => settings.defaultTaxPercentage;

  // ── Defaults ────────────────────────────────────────────────────────────────
  SettingsModel get _defaultSettings => SettingsModel(
        currency: AppConstants.defaultCurrency,
        invoicePrefix: AppConstants.defaultInvoicePrefix,
        defaultTaxPercentage: AppConstants.defaultTaxPercentage,
        darkModeEnabled: false,
      );

  CompanyModel get _defaultCompany => CompanyModel(
        companyName: '',
        address: '',
        email: '',
        phone: '',
        logoPath: '',
      );

  // ── Initialization ──────────────────────────────────────────────────────────
  Future<void> init() async {
    _settingsBox = Hive.box<SettingsModel>(AppConstants.settingsBoxName);
    _companyBox = Hive.box<CompanyModel>(AppConstants.companyBoxName);

    _settings = _settingsBox.get(AppConstants.settingsKey);
    _company = _companyBox.get(AppConstants.companyKey);
  }

  // ── Theme ───────────────────────────────────────────────────────────────────
  Future<void> setDarkMode(bool value) async {
    final updated = SettingsModel(
      currency: settings.currency,
      invoicePrefix: settings.invoicePrefix,
      defaultTaxPercentage: settings.defaultTaxPercentage,
      darkModeEnabled: value,
    );
    await _settingsBox.put(AppConstants.settingsKey, updated);
    _settings = updated;
    notifyListeners();
  }

  // ── Currency ─────────────────────────────────────────────────────────────────
  Future<void> setCurrency(String value) async {
    final updated = SettingsModel(
      currency: value,
      invoicePrefix: settings.invoicePrefix,
      defaultTaxPercentage: settings.defaultTaxPercentage,
      darkModeEnabled: settings.darkModeEnabled,
    );
    await _settingsBox.put(AppConstants.settingsKey, updated);
    _settings = updated;
    notifyListeners();
  }

  // ── Invoice Prefix ───────────────────────────────────────────────────────────
  Future<void> setInvoicePrefix(String value) async {
    final updated = SettingsModel(
      currency: settings.currency,
      invoicePrefix: value,
      defaultTaxPercentage: settings.defaultTaxPercentage,
      darkModeEnabled: settings.darkModeEnabled,
    );
    await _settingsBox.put(AppConstants.settingsKey, updated);
    _settings = updated;
    notifyListeners();
  }

  // ── Default Tax ──────────────────────────────────────────────────────────────
  Future<void> setDefaultTax(double value) async {
    final updated = SettingsModel(
      currency: settings.currency,
      invoicePrefix: settings.invoicePrefix,
      defaultTaxPercentage: value,
      darkModeEnabled: settings.darkModeEnabled,
    );
    await _settingsBox.put(AppConstants.settingsKey, updated);
    _settings = updated;
    notifyListeners();
  }

  // ── Company Info ─────────────────────────────────────────────────────────────
  Future<void> saveCompany({
    required String companyName,
    required String address,
    required String email,
    required String phone,
    String? logoPath,
  }) async {
    final updated = CompanyModel(
      companyName: companyName,
      address: address,
      email: email,
      phone: phone,
      logoPath: logoPath ?? company.logoPath,
    );
    await _companyBox.put(AppConstants.companyKey, updated);
    _company = updated;
    notifyListeners();
  }

  // ── Logo ─────────────────────────────────────────────────────────────────────
  Future<void> saveLogoPath(String path) async {
    final updated = CompanyModel(
      companyName: company.companyName,
      address: company.address,
      email: company.email,
      phone: company.phone,
      logoPath: path,
    );
    await _companyBox.put(AppConstants.companyKey, updated);
    _company = updated;
    notifyListeners();
  }
}

