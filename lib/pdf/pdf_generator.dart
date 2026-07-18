import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../models/invoice_model.dart';
import '../models/company_model.dart';
import '../models/settings_model.dart';
import '../models/item_model.dart';
import 'dart:io';

class PdfGenerator {
  static Future<Uint8List> generateInvoice(
      InvoiceModel invoice, CompanyModel company, SettingsModel settings) async {
    final pdf = pw.Document();

    pw.MemoryImage? logoImage;
    if (company.logoPath.isNotEmpty) {
      try {
        final file = File(company.logoPath);
        if (file.existsSync()) {
          logoImage = pw.MemoryImage(file.readAsBytesSync());
        }
      } catch (e) {
        // Ignored
      }
    }

    final currency = settings.currency;
    final primaryColor = PdfColors.blueGrey800;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // ── Header ─────────────────────────────────────────────────────────────
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      if (logoImage != null)
                        pw.Container(
                          height: 60,
                          margin: const pw.EdgeInsets.only(bottom: 10),
                          child: pw.Image(logoImage),
                        ),
                      pw.Text(company.companyName, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: primaryColor)),
                      pw.SizedBox(height: 4),
                      if (company.address.isNotEmpty) pw.Text(company.address, style: const pw.TextStyle(fontSize: 10)),
                      if (company.email.isNotEmpty) pw.Text(company.email, style: const pw.TextStyle(fontSize: 10)),
                      if (company.phone.isNotEmpty) pw.Text(company.phone, style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('INVOICE', style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold, color: primaryColor)),
                    pw.SizedBox(height: 10),
                    _buildTextRow('Invoice Number:', invoice.invoiceNumber),
                    _buildTextRow('Date:', DateFormat.yMMMd().format(invoice.invoiceDate)),
                    _buildTextRow('Due Date:', DateFormat.yMMMd().format(invoice.dueDate)),
                    _buildTextRow('Status:', invoice.invoiceStatus.name.toUpperCase()),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 30),

            // ── Customer Info ──────────────────────────────────────────────────────
            pw.Text('BILL TO', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: primaryColor)),
            pw.Divider(color: PdfColors.grey300),
            pw.SizedBox(height: 5),
            pw.Text(invoice.customer.name, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            if (invoice.customer.address.isNotEmpty) pw.Text(invoice.customer.address, style: const pw.TextStyle(fontSize: 10)),
            if (invoice.customer.email.isNotEmpty) pw.Text(invoice.customer.email, style: const pw.TextStyle(fontSize: 10)),
            if (invoice.customer.phone.isNotEmpty) pw.Text(invoice.customer.phone, style: const pw.TextStyle(fontSize: 10)),
            pw.SizedBox(height: 30),

            // ── Products Table ─────────────────────────────────────────────────────
            _buildProductsTable(invoice.items, currency),
            pw.SizedBox(height: 20),

            // ── Financial Summary ──────────────────────────────────────────────────
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Expanded(flex: 5, child: pw.SizedBox()),
                pw.Expanded(
                  flex: 4,
                  child: pw.Column(
                    children: [
                      _buildSummaryRow('Subtotal', invoice.subtotal, currency),
                      _buildSummaryRow('Tax (${invoice.taxPercentage.toStringAsFixed(0)}%)', invoice.taxAmount, currency),
                      _buildSummaryRow('Discount', -invoice.totalDiscount, currency),
                      pw.Divider(color: PdfColors.grey300),
                      _buildSummaryRow('Grand Total', invoice.grandTotal, currency, isBold: true, fontSize: 16),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 40),

            // ── Additional Info ────────────────────────────────────────────────────
            if (invoice.notes.isNotEmpty) ...[
              pw.Text('Notes:', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: primaryColor)),
              pw.SizedBox(height: 4),
              pw.Text(invoice.notes, style: const pw.TextStyle(fontSize: 10)),
              pw.SizedBox(height: 15),
            ],
            if (invoice.paymentInstructions.isNotEmpty) ...[
              pw.Text('Payment Instructions:', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: primaryColor)),
              pw.SizedBox(height: 4),
              pw.Text(invoice.paymentInstructions, style: const pw.TextStyle(fontSize: 10)),
            ],
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildTextRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisSize: pw.MainAxisSize.min,
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
          pw.SizedBox(width: 10),
          pw.Text(value, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  static pw.Widget _buildProductsTable(List<ItemModel> items, String currency) {
    return pw.TableHelper.fromTextArray(
      headers: ['Item', 'Qty', 'Unit Price', 'Discount', 'Total'],
      data: items.map((item) {
        return [
          item.itemName,
          item.quantity.toString(),
          '$currency ${item.unitPrice.toStringAsFixed(2)}',
          '$currency ${item.discount.toStringAsFixed(2)}',
          '$currency ${item.totalPrice.toStringAsFixed(2)}',
        ];
      }).toList(),
      border: null,
      headerStyle: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
      cellStyle: const pw.TextStyle(fontSize: 10),
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerRight,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerRight,
        4: pw.Alignment.centerRight,
      },
      rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200))),
      cellPadding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 4),
    );
  }

  static pw.Widget _buildSummaryRow(String label, double value, String currency, {bool isBold = false, double fontSize = 10}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: fontSize, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
          pw.Text('$currency ${value.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: fontSize, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
        ],
      ),
    );
  }
}
