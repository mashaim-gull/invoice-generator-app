# Invoice Generator App

## Project Overview
The Invoice Generator App is a modern, responsive, and robust Flutter application designed to simplify the invoicing process for businesses and freelancers. It allows users to create, manage, and share professional invoices with ease. All data is stored locally on the device using Hive, ensuring fast performance and offline availability.

## Features
- **Invoice Creation**: Auto-generation of invoice numbers, flexible date selection, and line-item calculations.
- **Invoice Management**: Search, filter, duplicate, and delete invoices effortlessly.
- **PDF Generation**: Generate professional, Material Design inspired PDF invoices.
- **Export & Share**: Download PDFs locally or share them via device share sheet (WhatsApp, Email, etc.).
- **Dashboard**: Track overall revenue, outstanding amounts, and overdue invoices.
- **Settings**: Customize company details, logo, currency, default tax, and toggle Dark Mode.
- **Offline First**: All data is securely stored on the device using Hive.


## Folder Structure
```
lib/
├── database/      # Hive database setup and adapters
├── models/        # Data models (Invoice, Company, Customer, Items)
├── pdf/           # PDF Generation logic using pdf package
├── screens/       # UI Screens (Dashboard, List, Create, Details, Settings, etc.)
├── services/      # Business logic (InvoiceService, SettingsService)
├── utils/         # Constants, helpers, theme configuration
├── widgets/       # Reusable UI components
└── main.dart      # Application entry point
```

## Technologies Used
- **Flutter** & **Dart**: Core framework and language.
- **Hive**: Lightweight and fast key-value local database.
- **Provider**: State management.
- **Material Design 3**: Modern, adaptable UI design system.

## Packages Used
- `hive` & `hive_flutter`: Local data storage.
- `provider`: App state management.
- `pdf`: To generate the PDF documents.
- `printing`: For previewing, printing, and sharing PDFs.
- `share_plus`: To share invoices to other apps.
- `path_provider`: To access the local file system for downloads.
- `permission_handler`: Managing storage permissions.
- `intl`: For date and currency formatting.
- `image_picker`: For selecting the company logo.
- `uuid`: Generating unique identifiers.
- `fluttertoast`: Displaying minimal feedback messages.

## Setup Instructions
1. Clone the repository: `git clone [repository-url]`
2. Navigate to the project directory: `cd invoice_generator_app`
3. Fetch dependencies: `flutter pub get`
4. Run code generation (for Hive adapters): `flutter pub run build_runner build --delete-conflicting-outputs`

## Installation Guide
To run the app on a connected device or emulator:
```bash
flutter run
```

## Build APK Instructions
To generate a release APK suitable for distribution:
```bash
flutter clean
flutter pub get
flutter build apk --release
```
The generated APK will be located at `build/app/outputs/flutter-apk/app-release.apk`.


## Future Improvements
- Cloud Syncing and Backup (Firebase / Supabase).
- Multi-currency support per invoice.
- Invoice templates customization.
- Import/Export data in CSV format.
