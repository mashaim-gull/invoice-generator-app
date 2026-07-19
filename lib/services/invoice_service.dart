import 'dart:io';
import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import '../models/invoice_model.dart';
import '../utils/constants.dart';
import 'invoice_number_service.dart';

/// InvoiceService manages all invoice data operations using Hive storage
/// and exposes invoice lists / stats via ChangeNotifier for Provider.
class InvoiceService extends ChangeNotifier {
  late Box<InvoiceModel> _invoiceBox;

  List<InvoiceModel> _invoices = [];

  List<InvoiceModel> get invoices => List.unmodifiable(_invoices);

  // ── Stats ────────────────────────────────────────────────────────────────────
  int get totalCount => _invoices.length;

  int get paidCount =>
      _invoices.where((i) => i.invoiceStatus == InvoiceStatus.paid).length;

  int get unpaidCount =>
      _invoices.where((i) => i.invoiceStatus == InvoiceStatus.unpaid).length;

  int get overdueCount =>
      _invoices.where((i) => i.invoiceStatus == InvoiceStatus.overdue).length;

  double get totalRevenue => _invoices
      .where((i) => i.invoiceStatus == InvoiceStatus.paid)
      .fold(0.0, (sum, i) => sum + i.grandTotal);

  List<InvoiceModel> get recentInvoices {
    final sorted = [..._invoices]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(5).toList();
  }

  // ── Initialization ──────────────────────────────────────────────────────────
  Future<void> init() async {
    _invoiceBox = Hive.box<InvoiceModel>(AppConstants.invoiceBoxName);
    _loadInvoices();
  }

  void _loadInvoices() {
    _invoices = _invoiceBox.values.toList();
    _updateOverdueStatuses();
    notifyListeners();
  }

  /// Automatically marks unpaid invoices as overdue if past due date.
  void _updateOverdueStatuses() {
    final now = DateTime.now();
    for (int i = 0; i < _invoices.length; i++) {
      final inv = _invoices[i];
      if (inv.invoiceStatus == InvoiceStatus.unpaid &&
          inv.dueDate.isBefore(now)) {
        final updated = InvoiceModel(
          id: inv.id,
          invoiceNumber: inv.invoiceNumber,
          invoiceDate: inv.invoiceDate,
          dueDate: inv.dueDate,
          company: inv.company,
          customer: inv.customer,
          items: inv.items,
          subtotal: inv.subtotal,
          taxPercentage: inv.taxPercentage,
          taxAmount: inv.taxAmount,
          totalDiscount: inv.totalDiscount,
          grandTotal: inv.grandTotal,
          notes: inv.notes,
          paymentInstructions: inv.paymentInstructions,
          invoiceStatus: InvoiceStatus.overdue,
          createdAt: inv.createdAt,
        );
        _invoiceBox.put(updated.id, updated);
        _invoices[i] = updated;
      }
    }
  }

  // ── CRUD ─────────────────────────────────────────────────────────────────────
  Future<void> addInvoice(InvoiceModel invoice) async {
    await _invoiceBox.put(invoice.id, invoice);
    _loadInvoices();
  }

  Future<void> updateInvoice(InvoiceModel invoice) async {
    await _invoiceBox.put(invoice.id, invoice);
    _loadInvoices();
  }

  Future<void> deleteInvoice(String id) async {
    await _invoiceBox.delete(id);
    _loadInvoices();
  }

  InvoiceModel? getInvoiceById(String id) {
    return _invoiceBox.get(id);
  }

  String nextInvoiceNumber(String prefix) => const InvoiceNumberService()
      .nextNumber(prefix: prefix, invoices: _invoices);

  Future<InvoiceModel> duplicateInvoice(
    InvoiceModel source, {
    required String prefix,
    required String newId,
  }) async {
    final copy = InvoiceModel(
      id: newId,
      invoiceNumber: nextInvoiceNumber(prefix),
      invoiceDate: DateTime.now(),
      dueDate: source.dueDate,
      company: source.company,
      customer: source.customer,
      items: source.items,
      subtotal: source.subtotal,
      taxPercentage: source.taxPercentage,
      taxAmount: source.taxAmount,
      totalDiscount: source.totalDiscount,
      grandTotal: source.grandTotal,
      notes: source.notes,
      paymentInstructions: source.paymentInstructions,
      invoiceStatus: InvoiceStatus.unpaid,
      createdAt: DateTime.now(),
    );
    await addInvoice(copy);
    return copy;
  }

  // ── Search & Filtering ───────────────────────────────────────────────────────
  String _searchQuery = '';
  InvoiceStatus? _statusFilter;

  String get searchQuery => _searchQuery;
  InvoiceStatus? get statusFilter => _statusFilter;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setStatusFilter(InvoiceStatus? status) {
    _statusFilter = status;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _statusFilter = null;
    notifyListeners();
  }

  List<InvoiceModel> get filteredInvoices {
    var result = [..._invoices];

    // 1. Status Filter
    if (_statusFilter != null) {
      result = result.where((i) => i.invoiceStatus == _statusFilter).toList();
    }

    // 2. Search Query (Invoice Number or Customer Name)
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      result = result.where((i) {
        final matchNumber = i.invoiceNumber.toLowerCase().contains(q);
        final matchName = i.customer.name.toLowerCase().contains(q);
        return matchNumber || matchName;
      }).toList();
    }

    // Default Sort (Created At Descending)
    result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return result;
  }

  // ── Monthly Income Summary ───────────────────────────────────────────────────
  double get currentMonthRevenue {
    final now = DateTime.now();
    return _invoices
        .where((i) => i.invoiceStatus == InvoiceStatus.paid && i.invoiceDate.year == now.year && i.invoiceDate.month == now.month)
        .fold(0.0, (sum, i) => sum + i.grandTotal);
  }

  int get currentMonthInvoicesCount {
    final now = DateTime.now();
    return _invoices.where((i) => i.invoiceDate.year == now.year && i.invoiceDate.month == now.month).length;
  }

  // ── CSV Export ───────────────────────────────────────────────────────────────
  Future<String?> exportInvoicesToCsv() async {
    try {
      if (Platform.isAndroid) {
        if (!await Permission.storage.request().isGranted && !await Permission.manageExternalStorage.request().isGranted) {
          return null;
        }
      }

      List<List<dynamic>> rows = [
        ['Invoice Number', 'Customer Name', 'Invoice Date', 'Status', 'Total Amount']
      ];

      for (var invoice in _invoices) {
        rows.add([
          invoice.invoiceNumber,
          invoice.customer.name,
          DateFormat('yyyy-MM-dd').format(invoice.invoiceDate),
          invoice.invoiceStatus.name.toUpperCase(),
          invoice.grandTotal.toStringAsFixed(2),
        ]);
      }

      String csvData = const ListToCsvConverter().convert(rows);

      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) directory = await getExternalStorageDirectory();
      } else if (Platform.isWindows) {
        directory = await getDownloadsDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory != null) {
        final file = File('${directory.path}/invoices_export_${DateTime.now().millisecondsSinceEpoch}.csv');
        await file.writeAsString(csvData);
        return file.path;
      }
    } catch (e) {
      debugPrint('Export CSV error: $e');
    }
    return null;
  }
}

