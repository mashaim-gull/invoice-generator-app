import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import '../models/invoice_model.dart';
import '../pdf/pdf_generator.dart';
import '../services/settings_service.dart';
import 'package:flutter/foundation.dart';

class PdfPreviewScreen extends StatelessWidget {
  final InvoiceModel invoice;

  const PdfPreviewScreen({super.key, required this.invoice});

  Future<void> _downloadPdf(BuildContext context, Uint8List pdfData) async {
    try {
      if (Platform.isAndroid) {
        // Request storage permission on older Android versions
        if (await Permission.storage.request().isGranted || await Permission.manageExternalStorage.request().isGranted) {
          // Continue
        }
      }

      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else if (Platform.isWindows) {
        directory = await getDownloadsDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory != null) {
        final sanitizedName = invoice.invoiceNumber.replaceAll(RegExp(r'[^a-zA-Z0-9\-]'), '_');
        final file = File('${directory.path}/$sanitizedName.pdf');
        await file.writeAsBytes(pdfData);
        
        if (context.mounted) {
          Fluttertoast.showToast(msg: 'Invoice $sanitizedName.pdf downloaded successfully.');
        }
      } else {
        if (context.mounted) {
          Fluttertoast.showToast(msg: 'Failed to find download directory.');
        }
      }
    } catch (e) {
      if (context.mounted) {
        Fluttertoast.showToast(msg: 'Failed to download PDF: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsService = context.read<SettingsService>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Preview ${invoice.invoiceNumber}'),
      ),
      body: PdfPreview(
        build: (format) => PdfGenerator.generateInvoice(invoice, settingsService.company, settingsService.settings),
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
        onPrintError: (context, error) {
          Fluttertoast.showToast(msg: 'Error printing: $error');
        },
        actions: [
          PdfPreviewAction(
            icon: const Icon(Icons.download),
            onPressed: (context, build, pageFormat) async {
              final pdfData = await build(pageFormat);
              if (context.mounted) {
                await _downloadPdf(context, pdfData);
              }
            },
          ),
        ],
      ),
    );
  }
}
