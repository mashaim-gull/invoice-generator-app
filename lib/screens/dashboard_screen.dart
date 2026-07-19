import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/invoice_service.dart';
import '../services/settings_service.dart';
import '../models/invoice_model.dart';
import '../utils/constants.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/status_chip_widget.dart';
import 'customer_history_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer2<InvoiceService, SettingsService>(
        builder: (context, invoiceService, settingsService, _) {
          final currencySymbol =
              AppConstants.currencySymbols[settingsService.currency] ?? '\$';
          final numberFmt =
              NumberFormat('#,##0.00', 'en_US');

          return CustomScrollView(
            slivers: [
              // ── Hero App Bar ──────────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 140,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.primaryContainer,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back! 👋',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.85),
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              settingsService.company.companyName.isNotEmpty
                                  ? settingsService.company.companyName
                                  : AppConstants.appName,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  title: const Text(
                    'Dashboard',
                    style: TextStyle(color: Colors.white),
                  ),
                  titlePadding:
                      const EdgeInsets.only(left: 20, bottom: 16),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.settings_outlined,
                        color: Colors.white),
                    onPressed: () =>
                        Navigator.of(context).pushNamed('/settings'),
                  ),
                ],
              ),

              // ── Body ──────────────────────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // ── Stats grid ──────────────────────────────────────────
                    _SectionTitle(title: 'Overview'),
                    const SizedBox(height: 12),
                    _StatsGrid(
                      invoiceService: invoiceService,
                      currencySymbol: currencySymbol,
                      numberFmt: numberFmt,
                    ),
                    const SizedBox(height: 24),

                    // ── Quick actions ────────────────────────────────────────
                    _SectionTitle(title: 'Quick Actions'),
                    const SizedBox(height: 12),
                    _QuickActions(),
                    const SizedBox(height: 24),

                    // ── Recent Invoices ──────────────────────────────────────
                    _SectionTitle(
                      title: 'Recent Invoices',
                      trailing: invoiceService.totalCount > 0
                          ? TextButton(
                              onPressed: () => Navigator.of(context)
                                  .pushNamed('/invoices'),
                              child: const Text('View All'),
                            )
                          : null,
                    ),
                    const SizedBox(height: 12),
                    _RecentInvoicesList(
                      invoices: invoiceService.recentInvoices,
                      currencySymbol: currencySymbol,
                      numberFmt: numberFmt,
                    ),
                    const SizedBox(height: 24),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pushNamed('/invoice/create'),
        icon: const Icon(Icons.add),
        label: const Text('New Invoice'),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Section title row
// ────────────────────────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const _SectionTitle({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Statistics grid (2-column responsive)
// ────────────────────────────────────────────────────────────────────────────
class _StatsGrid extends StatelessWidget {
  final InvoiceService invoiceService;
  final String currencySymbol;
  final NumberFormat numberFmt;

  const _StatsGrid({
    required this.invoiceService,
    required this.currencySymbol,
    required this.numberFmt,
  });

  @override
  Widget build(BuildContext context) {
    final cards = [
      _CardData(
        title: 'Total Invoices',
        value: '${invoiceService.totalCount}',
        icon: Icons.receipt_long_outlined,
        startColor: const Color(0xFF1565C0),
        endColor: const Color(0xFF1976D2),
        subtitle: 'All time',
      ),
      _CardData(
        title: 'Total Revenue',
        value:
            '$currencySymbol${numberFmt.format(invoiceService.totalRevenue)}',
        icon: Icons.account_balance_wallet_outlined,
        startColor: const Color(0xFF2E7D32),
        endColor: const Color(0xFF388E3C),
        subtitle: 'From paid invoices',
      ),
      _CardData(
        title: 'Paid',
        value: '${invoiceService.paidCount}',
        icon: Icons.check_circle_outline,
        startColor: const Color(0xFF00796B),
        endColor: const Color(0xFF00897B),
        subtitle: 'Invoices paid',
      ),
      _CardData(
        title: 'Unpaid',
        value: '${invoiceService.unpaidCount}',
        icon: Icons.pending_actions_outlined,
        startColor: const Color(0xFFE65100),
        endColor: const Color(0xFFF57C00),
        subtitle: 'Awaiting payment',
      ),
      _CardData(
        title: 'Overdue',
        value: '${invoiceService.overdueCount}',
        icon: Icons.warning_amber_outlined,
        startColor: const Color(0xFFC62828),
        endColor: const Color(0xFFD32F2F),
        subtitle: 'Past due date',
      ),
      _CardData(
        title: 'Monthly Income',
        value: '$currencySymbol${numberFmt.format(invoiceService.currentMonthRevenue)}',
        icon: Icons.calendar_today_outlined,
        startColor: const Color(0xFF6A1B9A),
        endColor: const Color(0xFF8E24AA),
        subtitle: 'This month',
      ),
      _CardData(
        title: 'Monthly Invoices',
        value: '${invoiceService.currentMonthInvoicesCount}',
        icon: Icons.assignment_outlined,
        startColor: const Color(0xFF0277BD),
        endColor: const Color(0xFF039BE5),
        subtitle: 'Created this month',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
        final itemHeight = constraints.maxWidth > 600 ? 130.0 : 120.0;
        final itemWidth = constraints.maxWidth / crossAxisCount;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: itemWidth / itemHeight,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: cards.length,
          itemBuilder: (context, index) {
            final c = cards[index];
            return DashboardCard(
              title: c.title,
              value: c.value,
              icon: c.icon,
              startColor: c.startColor,
              endColor: c.endColor,
              subtitle: c.subtitle,
            );
          },
        );
      },
    );
  }
}

class _CardData {
  final String title, value, subtitle;
  final IconData icon;
  final Color startColor, endColor;
  const _CardData({
    required this.title,
    required this.value,
    required this.icon,
    required this.startColor,
    required this.endColor,
    required this.subtitle,
  });
}

// ────────────────────────────────────────────────────────────────────────────
// Quick action buttons row
// ────────────────────────────────────────────────────────────────────────────
class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: _ActionChip(
            icon: Icons.add_circle_outline,
            label: 'New Invoice',
            color: colorScheme.primary,
            onTap: () => Navigator.of(context).pushNamed('/invoice/create'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionChip(
            icon: Icons.list_alt_outlined,
            label: 'All Invoices',
            color: colorScheme.secondary,
            onTap: () => Navigator.of(context).pushNamed('/invoices'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionChip(
            icon: Icons.settings_outlined,
            label: 'Settings',
            color: colorScheme.tertiary,
            onTap: () => Navigator.of(context).pushNamed('/settings'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionChip(
            icon: Icons.people_outline,
            label: 'Customers',
            color: Colors.teal,
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CustomerHistoryScreen())),
          ),
        ),
      ],
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Recent invoices list
// ────────────────────────────────────────────────────────────────────────────
class _RecentInvoicesList extends StatelessWidget {
  final List<InvoiceModel> invoices;
  final String currencySymbol;
  final NumberFormat numberFmt;

  const _RecentInvoicesList({
    required this.invoices,
    required this.currencySymbol,
    required this.numberFmt,
  });

  @override
  Widget build(BuildContext context) {
    if (invoices.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.receipt_long_outlined,
        title: 'No Invoices Yet',
        message:
            'Create your first invoice to see it here. Tap the + button to get started.',
        action: FilledButton.icon(
          onPressed: () => Navigator.of(context).pushNamed('/invoice/create'),
          icon: const Icon(Icons.add),
          label: const Text('Create Invoice'),
        ),
      );
    }

    return Column(
      children: invoices
          .map((inv) => _InvoiceListTile(
                invoice: inv,
                currencySymbol: currencySymbol,
                numberFmt: numberFmt,
              ))
          .toList(),
    );
  }
}

class _InvoiceListTile extends StatelessWidget {
  final InvoiceModel invoice;
  final String currencySymbol;
  final NumberFormat numberFmt;

  const _InvoiceListTile({
    required this.invoice,
    required this.currencySymbol,
    required this.numberFmt,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.of(context)
            .pushNamed('/invoice/detail', arguments: invoice.id),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Invoice number badge
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.receipt_outlined,
                    color: colorScheme.primary, size: 22),
              ),
              const SizedBox(width: 12),

              // Invoice details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invoice.invoiceNumber,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      invoice.customer.name,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),

              // Amount + status
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$currencySymbol${numberFmt.format(invoice.grandTotal)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  StatusChipWidget(status: invoice.invoiceStatus),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

