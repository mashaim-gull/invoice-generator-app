import 'package:flutter/material.dart';
import '../models/invoice_model.dart';
import 'create_invoice_screen.dart';
class EditInvoiceScreen extends StatelessWidget { final InvoiceModel invoice; const EditInvoiceScreen({super.key,required this.invoice}); @override Widget build(BuildContext context)=>CreateInvoiceScreen(invoice:invoice); }
