import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'database/hive_database.dart';
import 'services/settings_service.dart';
import 'services/invoice_service.dart';
import 'screens/splash_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/invoice_list_screen.dart';
import 'screens/create_invoice_screen.dart';
import 'screens/invoice_details_screen.dart';
import 'screens/edit_invoice_screen.dart';
import 'models/invoice_model.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive and open all boxes
  await Hive.initFlutter();
  await HiveDatabase.init();

  // Initialize services that require Hive access
  final settingsService = SettingsService();
  await settingsService.init();

  final invoiceService = InvoiceService();
  await invoiceService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsService>.value(value: settingsService),
        ChangeNotifierProvider<InvoiceService>.value(value: invoiceService),
      ],
      child: const InvoiceGeneratorApp(),
    ),
  );
}

class InvoiceGeneratorApp extends StatelessWidget {
  const InvoiceGeneratorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsService>(
      builder: (context, settings, _) {
        return MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          // ── Theme management ──────────────────────────────────────────────
          themeMode:
              settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          theme: _buildLightTheme(),
          darkTheme: _buildDarkTheme(),
          // ── Navigation ────────────────────────────────────────────────────
          initialRoute: '/',
          onGenerateRoute: _onGenerateRoute,
        );
      },
    );
  }

  // ── Route generator ─────────────────────────────────────────────────────────
  Route<dynamic>? _onGenerateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case '/':
        return MaterialPageRoute(
            builder: (_) => const SplashScreen());
      case '/dashboard':
        return MaterialPageRoute(
            builder: (_) => const DashboardScreen());
      case '/settings':
        return MaterialPageRoute(
            builder: (_) => const SettingsScreen());
      case '/invoices':
        return MaterialPageRoute(
            builder: (_) => const InvoiceListScreen());
      case '/invoice/create':
        return MaterialPageRoute(
            builder: (_) => const CreateInvoiceScreen());
      case '/invoice/detail':
        final id = routeSettings.arguments as String?;
        return MaterialPageRoute(
            builder: (_) => InvoiceDetailsScreen(invoiceId: id));
      case '/invoice/edit':
        final invoice = routeSettings.arguments;
        if (invoice is! InvoiceModel) return null;
        return MaterialPageRoute(builder: (_) => EditInvoiceScreen(invoice: invoice));
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Not Found')),
            body: const Center(child: Text('Page not found')),
          ),
        );
    }
  }

  // ── Light theme ──────────────────────────────────────────────────────────────
  ThemeData _buildLightTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppConstants.primarySeed,
      brightness: Brightness.light,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side:
              BorderSide(color: colorScheme.outline.withValues(alpha: 0.15)),
        ),
      ),
    );
  }

  // ── Dark theme ───────────────────────────────────────────────────────────────
  ThemeData _buildDarkTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppConstants.primarySeed,
      brightness: Brightness.dark,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side:
              BorderSide(color: colorScheme.outline.withValues(alpha: 0.15)),
        ),
      ),
    );
  }
}

