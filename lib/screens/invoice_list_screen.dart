import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../models/invoice_model.dart';
import '../services/invoice_service.dart';
import '../services/settings_service.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/status_chip_widget.dart';
import 'edit_invoice_screen.dart';

class InvoiceListScreen extends StatelessWidget {
  const InvoiceListScreen({super.key});

  Future<void> _delete(BuildContext context, InvoiceModel invoice) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete invoice?'),
        content: Text('Are you sure you want to delete ${invoice.invoiceNumber}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<InvoiceService>().deleteInvoice(invoice.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final invoiceService = context.watch<InvoiceService>();
    final currency = context.watch<SettingsService>().currency;
    final invoicePrefix = context.read<SettingsService>().invoicePrefix;
    final invoices = invoiceService.filteredInvoices;
    final totalInvoices = invoiceService.totalCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Invoices'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Export as CSV',
            onPressed: () async {
              final path = await invoiceService.exportInvoicesToCsv();
              if (path != null) {
                Fluttertoast.showToast(msg: 'Exported successfully to: $path');
              } else {
                Fluttertoast.showToast(msg: 'Failed to export CSV. Check permissions.');
              }
            },
          ),
        ],
        bottom: totalInvoices == 0
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(120),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search by number or customer...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: invoiceService.searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    invoiceService.setSearchQuery('');
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (value) => invoiceService.setSearchQuery(value),
                        controller: TextEditingController(text: invoiceService.searchQuery)..selection = TextSelection.collapsed(offset: invoiceService.searchQuery.length),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          if (invoiceService.statusFilter != null)
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ActionChip(
                                label: const Text('Clear Filters'),
                                avatar: const Icon(Icons.clear, size: 16),
                                onPressed: () => invoiceService.clearFilters(),
                              ),
                            ),
                          _buildFilterChip(context, invoiceService, 'All', null),
                          const SizedBox(width: 8),
                          _buildFilterChip(context, invoiceService, 'Paid', InvoiceStatus.paid),
                          const SizedBox(width: 8),
                          _buildFilterChip(context, invoiceService, 'Unpaid', InvoiceStatus.unpaid),
                          const SizedBox(width: 8),
                          _buildFilterChip(context, invoiceService, 'Overdue', InvoiceStatus.overdue),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/invoice/create'),
        icon: const Icon(Icons.add),
        label: const Text('New invoice'),
      ),
      body: totalInvoices == 0
          ? const EmptyStateWidget(icon: Icons.receipt_long_outlined, title: 'No invoices yet', message: 'Create your first invoice to get started.')
          : invoices.isEmpty
              ? const EmptyStateWidget(icon: Icons.search_off, title: 'No results found', message: 'Try adjusting your search or filters.')
              : LayoutBuilder(
                  builder: (_, constraints) => ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: constraints.maxWidth > 700 ? 48 : 16, vertical: 16),
                    itemCount: invoices.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final invoice = invoices[index];
                      return Card(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => Navigator.pushNamed(context, '/invoice/detail', arguments: invoice.id),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [Expanded(child: Text(invoice.invoiceNumber, style: Theme.of(context).textTheme.titleMedium)), StatusChipWidget(status: invoice.invoiceStatus)]),
                                const SizedBox(height: 6),
                                Text(invoice.customer.name.isEmpty ? 'Unnamed customer' : invoice.customer.name),
                                const SizedBox(height: 12),
                                Wrap(spacing: 18, runSpacing: 6, children: [Text('Total: $currency ${invoice.grandTotal.toStringAsFixed(2)}'), Text('Issued: ${DateFormat.yMMMd().format(invoice.invoiceDate)}'), Text('Due: ${DateFormat.yMMMd().format(invoice.dueDate)}')]),
                                const SizedBox(height: 6),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: PopupMenuButton<String>(
                                    onSelected: (action) async {
                                      switch (action) {
                                        case 'view':
                                          Navigator.pushNamed(context, '/invoice/detail', arguments: invoice.id);
                                        case 'edit':
                                          Navigator.push(context, MaterialPageRoute(builder: (_) => EditInvoiceScreen(invoice: invoice)));
                                        case 'delete':
                                          await _delete(context, invoice);
                                        case 'duplicate':
                                          await invoiceService.duplicateInvoice(invoice, prefix: invoicePrefix, newId: const Uuid().v4());
                                      }
                                    },
                                    itemBuilder: (_) => const [
                                      PopupMenuItem(value: 'view', child: Text('View invoice')),
                                      PopupMenuItem(value: 'edit', child: Text('Edit invoice')),
                                      PopupMenuItem(value: 'duplicate', child: Text('Duplicate invoice')),
                                      PopupMenuItem(value: 'delete', child: Text('Delete invoice')),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildFilterChip(BuildContext context, InvoiceService invoiceService, String label, InvoiceStatus? status) {
    final isSelected = invoiceService.statusFilter == status;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => invoiceService.setStatusFilter(status),
    );
  }
}
