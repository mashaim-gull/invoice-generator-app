import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/company_model.dart';
import '../models/customer_model.dart';
import '../models/invoice_model.dart';
import '../models/item_model.dart';
import '../services/invoice_service.dart';
import '../services/settings_service.dart';

class CreateInvoiceScreen extends StatefulWidget {
  final InvoiceModel? invoice;
  const CreateInvoiceScreen({super.key, this.invoice});
  @override State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  final _form = GlobalKey<FormState>();
  final _uuid = const Uuid();
  late final Map<String, TextEditingController> _c;
  late DateTime _date, _due;
  late double _tax;
  late InvoiceStatus _status;
  final List<_ItemDraft> _items = [];
  String? _number;

  @override void initState() {
    super.initState();
    final i = widget.invoice; final co = i?.company; final cu = i?.customer;
    _c = {'companyName': TextEditingController(text: co?.companyName ?? ''), 'companyAddress': TextEditingController(text: co?.address ?? ''), 'companyEmail': TextEditingController(text: co?.email ?? ''), 'companyPhone': TextEditingController(text: co?.phone ?? ''), 'customerName': TextEditingController(text: cu?.name ?? ''), 'customerAddress': TextEditingController(text: cu?.address ?? ''), 'customerEmail': TextEditingController(text: cu?.email ?? ''), 'customerPhone': TextEditingController(text: cu?.phone ?? ''), 'notes': TextEditingController(text: i?.notes ?? ''), 'payment': TextEditingController(text: i?.paymentInstructions ?? '')};
    _date = i?.invoiceDate ?? DateTime.now(); _due = i?.dueDate ?? DateTime.now().add(const Duration(days: 14)); _tax = i?.taxPercentage ?? 0; _status = i?.invoiceStatus ?? InvoiceStatus.unpaid; _number = i?.invoiceNumber;
    if (i == null) {_items.add(_ItemDraft());} else {_items.addAll(i.items.map(_ItemDraft.fromModel));}
  }
  @override void didChangeDependencies() { super.didChangeDependencies(); if (widget.invoice == null && _number == null) { final s = context.read<SettingsService>(); _number = context.read<InvoiceService>().nextInvoiceNumber(s.invoicePrefix); _tax = s.defaultTax; final co = s.company; _c['companyName']!.text = co.companyName; _c['companyAddress']!.text = co.address; _c['companyEmail']!.text = co.email; _c['companyPhone']!.text = co.phone; } }
  @override void dispose() { for (final v in _c.values) {v.dispose();} for (final i in _items) {i.dispose();} super.dispose(); }

  double get _subtotal => _items.fold(0, (a, b) => a + b.quantity * b.price);
  double get _discount => _items.fold(0, (a, b) => a + b.discount);
  double get _taxAmount => (_subtotal - _discount) * _tax / 100;
  double get _total => _subtotal + _taxAmount - _discount;
  String? _email(String? v) => v == null || v.isEmpty || RegExp(r'^[^@$s]+@[^@$s]+$.[^@$s]+$$').hasMatch(v) ? null : 'Enter a valid email';
  String? _phone(String? v) => v == null || v.isEmpty || RegExp(r'^[0-9+() -]{7,}$$').hasMatch(v) ? null : 'Enter a valid phone number';
  Future<void> _pick(bool due) async { final d = await showDatePicker(context: context, initialDate: due ? _due : _date, firstDate: DateTime(2000), lastDate: DateTime(2100)); if (d != null) setState(() {if(due){_due=d;}else{_date=d;}}); }
  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    if (_due.isBefore(_date) || _items.isEmpty) {ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add at least one item and use a valid due date.'))); return;}
    final old = widget.invoice; final settings = context.read<SettingsService>();
    final effectiveStatus = _status != InvoiceStatus.paid && _due.isBefore(DateTime.now()) ? InvoiceStatus.overdue : _status;
    final model = InvoiceModel(id: old?.id ?? _uuid.v4(), invoiceNumber: _number!, invoiceDate: _date, dueDate: _due, company: CompanyModel(companyName: _c['companyName']!.text.trim(), address: _c['companyAddress']!.text.trim(), email: _c['companyEmail']!.text.trim(), phone: _c['companyPhone']!.text.trim(), logoPath: old?.company.logoPath ?? settings.company.logoPath), customer: CustomerModel(id: old?.customer.id ?? _uuid.v4(), name: _c['customerName']!.text.trim(), address: _c['customerAddress']!.text.trim(), email: _c['customerEmail']!.text.trim(), phone: _c['customerPhone']!.text.trim()), items: _items.map((x) => x.model(_uuid.v4())).toList(), subtotal: _subtotal, taxPercentage: _tax, taxAmount: _taxAmount, totalDiscount: _discount, grandTotal: _total, notes: _c['notes']!.text.trim(), paymentInstructions: _c['payment']!.text.trim(), invoiceStatus: effectiveStatus, createdAt: old?.createdAt ?? DateTime.now());
    final service = context.read<InvoiceService>(); if(old == null) {await service.addInvoice(model);} else {await service.updateInvoice(model);} if(mounted) Navigator.pop(context);
  }
  @override Widget build(BuildContext context) { final currency = context.watch<SettingsService>().currency; return Scaffold(appBar: AppBar(title: Text(widget.invoice == null ? 'Create Invoice' : 'Edit Invoice')), body: LayoutBuilder(builder: (_, box) => Form(key: _form, child: ListView(padding: EdgeInsets.symmetric(horizontal: box.maxWidth > 720 ? 48 : 16, vertical: 20), children: [
    _section('Invoice information', [ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.tag), title: const Text('Invoice number'), subtitle: Text(_number ?? 'Generating...')), Wrap(spacing: 12, children: [_dateButton('Invoice date', _date, () => _pick(false)), _dateButton('Due date', _due, () => _pick(true))])]),
    _section('Company information', [_field('companyName','Company name'),_field('companyAddress','Company address',lines:2),_field('companyEmail','Company email',validator:_email),_field('companyPhone','Company phone',validator:_phone)]),
    _section('Customer information', [_field('customerName','Customer name',validator:(v)=>v == null || v.trim().isEmpty ? 'Customer name is required' : null),_field('customerAddress','Customer address',lines:2),_field('customerEmail','Customer email',validator:_email),_field('customerPhone','Customer phone',validator:_phone)]),
    _section('Products & services', [..._items.asMap().entries.map((e)=>_item(e.key,e.value)), OutlinedButton.icon(onPressed:()=>setState(()=>_items.add(_ItemDraft())),icon:const Icon(Icons.add),label:const Text('Add item'))]),
    _section('Financial summary', [DropdownButtonFormField<double>(initialValue:_tax,decoration:const InputDecoration(labelText:'Tax percentage',border:OutlineInputBorder()),items:[0,5,10,15,17].map((x)=>DropdownMenuItem(value:x.toDouble(),child:Text('$x%'))).toList(),onChanged:(x)=>setState(()=>_tax=x??0)),const SizedBox(height:12),_sum('Subtotal',_subtotal,currency),_sum('Tax',_taxAmount,currency),_sum('Discount',-_discount,currency),const Divider(),_sum('Grand total',_total,currency,bold:true)]),
    _section('Additional information', [_field('notes','Notes',lines:3),_field('payment','Payment instructions',lines:3)]),
    if(widget.invoice != null) _section('Status',[DropdownButtonFormField<InvoiceStatus>(initialValue:_status,decoration:const InputDecoration(border:OutlineInputBorder()),items:InvoiceStatus.values.map((x)=>DropdownMenuItem(value:x,child:Text(x.name.toUpperCase()))).toList(),onChanged:(x)=>setState(()=>_status=x!))]),
    FilledButton.icon(onPressed:_save,icon:const Icon(Icons.save),label:Text(widget.invoice == null ? 'Save invoice' : 'Update invoice'))])))); }
  Widget _section(String t,List<Widget> kids)=>Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(t,style:const TextStyle(fontSize:18,fontWeight:FontWeight.w600)),const SizedBox(height:14),...kids])));
  Widget _field(String key,String label,{int lines=1,String? Function(String?)? validator})=>Padding(padding:const EdgeInsets.only(bottom:12),child:TextFormField(controller:_c[key],maxLines:lines,validator:validator,keyboardType:label.contains('email')?TextInputType.emailAddress:label.contains('phone')?TextInputType.phone:TextInputType.text,decoration:InputDecoration(labelText:label,border:const OutlineInputBorder())));
  Widget _dateButton(String label,DateTime date,VoidCallback tap)=>SizedBox(width:220,child:OutlinedButton.icon(onPressed:tap,icon:const Icon(Icons.calendar_today),label:Text('$label\n${DateFormat.yMMMd().format(date)}'),style:OutlinedButton.styleFrom(alignment:Alignment.centerLeft,padding:const EdgeInsets.all(14))));
  Widget _sum(String l,double x,String currency,{bool bold=false})=>Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[Text(l,style:bold?const TextStyle(fontWeight:FontWeight.bold):null),Text('$currency ${x.toStringAsFixed(2)}',style:bold?const TextStyle(fontWeight:FontWeight.bold):null)]);
  Widget _item(int n,_ItemDraft x)=>Card(color:Theme.of(context).colorScheme.surfaceContainerHighest,child:Padding(padding:const EdgeInsets.all(12),child:Column(children:[Row(children:[Text('Item ${n+1}',style:const TextStyle(fontWeight:FontWeight.w600)),const Spacer(),if(_items.length>1)IconButton(onPressed:()=>setState((){x.dispose();_items.removeAt(n);}),icon:const Icon(Icons.delete_outline))]),TextFormField(controller:x.name,validator:(v)=>v == null || v.trim().isEmpty ? 'Product name is required' : null,decoration:const InputDecoration(labelText:'Product or service name',border:OutlineInputBorder())),const SizedBox(height:8),Wrap(spacing:8,runSpacing:8,children:[_num(x.qty,'Quantity',(v)=>(int.tryParse(v??'')??0)>0?null:'Must be > 0'),_num(x.unit,'Unit price',(v)=>(double.tryParse(v??'')??0)>0?null:'Must be > 0'),_num(x.off,'Discount',null)]),const SizedBox(height:8),Align(alignment:Alignment.centerRight,child:Text('Item total: ${x.total.toStringAsFixed(2)}'))])));
  Widget _num(TextEditingController c,String l,String? Function(String?)? valid)=>SizedBox(width:155,child:TextFormField(controller:c,validator:valid,onChanged:(_)=>setState((){}),keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:InputDecoration(labelText:l,border:const OutlineInputBorder())));
}
class _ItemDraft { final name=TextEditingController(),qty=TextEditingController(text:'1'),unit=TextEditingController(text:'0'),off=TextEditingController(text:'0'); _ItemDraft(); _ItemDraft.fromModel(ItemModel i){name.text=i.itemName;qty.text=i.quantity.toString();unit.text=i.unitPrice.toString();off.text=i.discount.toString();} int get quantity=>int.tryParse(qty.text)??0; double get price=>double.tryParse(unit.text)??0; double get discount=>double.tryParse(off.text)??0; double get total=>quantity*price-discount; ItemModel model(String id)=>ItemModel(id:id,itemName:name.text.trim(),quantity:quantity,unitPrice:price,discount:discount,totalPrice:total); void dispose(){name.dispose();qty.dispose();unit.dispose();off.dispose();} }
