import '../models/invoice_model.dart';

/// Produces the next unused sequential number for the active settings prefix.
class InvoiceNumberService {
  const InvoiceNumberService();

  String nextNumber({required String prefix, required Iterable<InvoiceModel> invoices}) {
    final expression = RegExp('^${RegExp.escape(prefix)}(\\d+)\$');
    var highest = 0;
    for (final invoice in invoices) {
      final match = expression.firstMatch(invoice.invoiceNumber);
      final value = match == null ? null : int.tryParse(match.group(1)!);
      if (value != null && value > highest) highest = value;
    }
    return prefix + (highest + 1).toString().padLeft(3, '0');
  }
}
