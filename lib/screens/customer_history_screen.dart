import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/invoice_service.dart';
import '../services/settings_service.dart';
import '../widgets/empty_state_widget.dart';
import '../models/invoice_model.dart';
import '../utils/constants.dart';

class CustomerHistoryScreen extends StatelessWidget {
  const CustomerHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final invoiceService = context.watch<InvoiceService>();
    final currency = context.watch<SettingsService>().currency;
    final currencySymbol = AppConstants.currencySymbols[currency] ?? currency;
    final numberFmt = NumberFormat('#,##0.00', 'en_US');

    // Group invoices by customer name
    final Map<String, _CustomerStats> customerStats = {};
    for (var invoice in invoiceService.invoices) {
      final name = invoice.customer.name.trim().isEmpty ? 'Unnamed Customer' : invoice.customer.name.trim();
      if (!customerStats.containsKey(name)) {
        customerStats[name] = _CustomerStats(name: name);
      }
      customerStats[name]!.addInvoice(invoice);
    }

    final sortedCustomers = customerStats.values.toList()
      ..sort((a, b) => b.totalSpent.compareTo(a.totalSpent));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer History'),
      ),
      body: sortedCustomers.isEmpty
          ? const EmptyStateWidget(
              icon: Icons.people_outline,
              title: 'No customers found',
              message: 'Create invoices to see customer history here.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: sortedCustomers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final c = sortedCustomers[index];
                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                c.name,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Text(
                              '$currencySymbol${numberFmt.format(c.totalSpent)}',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Total Invoices: ${c.invoiceCount}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Recent: ${c.recentInvoiceCount} in the last 30 days',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _CustomerStats {
  final String name;
  int invoiceCount = 0;
  double totalSpent = 0;
  int recentInvoiceCount = 0;

  _CustomerStats({required this.name});

  void addInvoice(InvoiceModel invoice) {
    invoiceCount++;
    totalSpent += invoice.grandTotal;
    final now = DateTime.now();
    if (invoice.invoiceDate.isAfter(now.subtract(const Duration(days: 30)))) {
      recentInvoiceCount++;
    }
  }
}
