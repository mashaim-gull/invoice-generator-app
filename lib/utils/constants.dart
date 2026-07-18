import 'package:flutter/material.dart';

class AppConstants {
  // ── Hive box names ─────────────────────────────────────────────────────────
  static const String invoiceBoxName = 'invoiceBox';
  static const String customerBoxName = 'customerBox';
  static const String companyBoxName = 'companyBox';
  static const String settingsBoxName = 'settingsBox';

  // ── Hive settings keys ──────────────────────────────────────────────────────
  static const String settingsKey = 'app_settings';
  static const String companyKey = 'company_info';

  // ── Default settings ────────────────────────────────────────────────────────
  static const String defaultCurrency = 'USD';
  static const String defaultInvoicePrefix = 'INV-';
  static const double defaultTaxPercentage = 10.0;

  // ── Currency options ────────────────────────────────────────────────────────
  static const List<String> currencies = ['PKR', 'USD', 'EUR', 'GBP'];

  static const Map<String, String> currencySymbols = {
    'PKR': '₨',
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
  };

  // ── Invoice prefix options ──────────────────────────────────────────────────
  static const List<String> prefixOptions = [
    'INV-',
    'SALE-',
    'BILL-',
    'RCPT-',
    'ABC-',
  ];

  // ── Tax percentage options ──────────────────────────────────────────────────
  static const List<double> taxOptions = [0, 5, 10, 15, 17];

  // ── App name ────────────────────────────────────────────────────────────────
  static const String appName = 'Invoice Generator';

  // ── App color scheme seed ───────────────────────────────────────────────────
  static const Color primarySeed = Color(0xFF1565C0); // Deep blue
}

