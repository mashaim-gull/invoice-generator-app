import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:invoice_generator_app/services/settings_service.dart';
import 'package:invoice_generator_app/services/invoice_service.dart';
import 'package:invoice_generator_app/screens/dashboard_screen.dart';

/// Tests that core screens render without errors using mocked providers.
void main() {
  testWidgets('DashboardScreen renders without errors', (tester) async {
    // Arrange: provide real (uninitialized) services – no Hive required
    // because we just want to verify that widget trees build cleanly.
    final settingsService = SettingsService();
    final invoiceService = InvoiceService();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SettingsService>.value(
              value: settingsService),
          ChangeNotifierProvider<InvoiceService>.value(
              value: invoiceService),
        ],
        child: const MaterialApp(
          home: DashboardScreen(),
        ),
      ),
    );

    // Assert: the dashboard overview label is present
    expect(find.text('Overview'), findsOneWidget);
  });
}
