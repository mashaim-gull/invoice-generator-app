import 'package:flutter/material.dart';
import 'dart:io' as dart_io;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/invoice_service.dart';
import '../services/settings_service.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/status_chip_widget.dart';
import 'edit_invoice_screen.dart';
import 'pdf_preview_screen.dart';

class InvoiceDetailsScreen extends StatelessWidget {
  final String? invoiceId;
  const InvoiceDetailsScreen({super.key,this.invoiceId});
  @override Widget build(BuildContext context) {
    final invoice=invoiceId==null?null:context.watch<InvoiceService>().getInvoiceById(invoiceId!);
    if(invoice==null)return const Scaffold(body:EmptyStateWidget(icon:Icons.error_outline,title:'Invoice not found',message:'This invoice may have been deleted.'));
    final currency=context.watch<SettingsService>().currency;
    return Scaffold(
      appBar:AppBar(
        title:Text(invoice.invoiceNumber),
        actions:[
          IconButton(onPressed:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>PdfPreviewScreen(invoice:invoice))),icon:const Icon(Icons.picture_as_pdf),tooltip:'Preview PDF'),
          IconButton(onPressed:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>EditInvoiceScreen(invoice:invoice))),icon:const Icon(Icons.edit),tooltip:'Edit invoice')
        ]
      ),
      body:LayoutBuilder(builder:(_,box)=>ListView(padding:EdgeInsets.symmetric(horizontal:box.maxWidth>760?56:16,vertical:20),children:[
        _card('Invoice information',[Text('Invoice date: ${DateFormat.yMMMd().format(invoice.invoiceDate)}'),Text('Due date: ${DateFormat.yMMMd().format(invoice.dueDate)}'),const SizedBox(height:10),StatusChipWidget(status:invoice.invoiceStatus)]),
        _card('Company information',[_info(invoice.company.companyName,invoice.company.address,invoice.company.email,invoice.company.phone, invoice.company.logoPath)]),
        _card('Customer information',[_info(invoice.customer.name,invoice.customer.address,invoice.customer.email,invoice.customer.phone)]),
        _card('Products & services',[SingleChildScrollView(scrollDirection:Axis.horizontal,child:DataTable(columns:const [DataColumn(label:Text('Item')),DataColumn(label:Text('Qty'),numeric:true),DataColumn(label:Text('Unit price'),numeric:true),DataColumn(label:Text('Discount'),numeric:true),DataColumn(label:Text('Total'),numeric:true)],rows:invoice.items.map((x)=>DataRow(cells:[DataCell(Text(x.itemName)),DataCell(Text('${x.quantity}')),DataCell(Text(x.unitPrice.toStringAsFixed(2))),DataCell(Text(x.discount.toStringAsFixed(2))),DataCell(Text(x.totalPrice.toStringAsFixed(2)))])).toList()))]),
        _card('Financial summary',[_row('Subtotal',invoice.subtotal,currency),_row('Tax (${invoice.taxPercentage.toStringAsFixed(0)}%)',invoice.taxAmount,currency),_row('Discount',-invoice.totalDiscount,currency),const Divider(),_row('Grand total',invoice.grandTotal,currency,bold:true)]),
        if(invoice.notes.isNotEmpty||invoice.paymentInstructions.isNotEmpty)_card('Additional information',[if(invoice.notes.isNotEmpty)Text('Notes\n${invoice.notes}'),if(invoice.notes.isNotEmpty&&invoice.paymentInstructions.isNotEmpty)const SizedBox(height:12),if(invoice.paymentInstructions.isNotEmpty)Text('Payment instructions\n${invoice.paymentInstructions}')])
      ]))
    );
  }
  Widget _card(String title,List<Widget> children)=>Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:const TextStyle(fontSize:18,fontWeight:FontWeight.w600)),const SizedBox(height:12),...children])));
  Widget _info(String title,String address,String email,String phone,[String logoPath=''])=>Row(crossAxisAlignment:CrossAxisAlignment.start,children:[if(logoPath.isNotEmpty)Padding(padding:const EdgeInsets.only(right:12),child:Container(width:60,height:60,decoration:BoxDecoration(shape:BoxShape.circle,image:DecorationImage(image:FileImage(dart_io.File(logoPath)),fit:BoxFit.cover)))),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:const TextStyle(fontWeight:FontWeight.w600)),if(address.isNotEmpty)Text(address),if(email.isNotEmpty)Text(email),if(phone.isNotEmpty)Text(phone)]))]);
  Widget _row(String label,double value,String currency,{bool bold=false})=>Padding(padding:const EdgeInsets.symmetric(vertical:3),child:Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[Text(label,style:bold?const TextStyle(fontWeight:FontWeight.bold):null),Text('$currency ${value.toStringAsFixed(2)}',style:bold?const TextStyle(fontWeight:FontWeight.bold):null)]));
}
