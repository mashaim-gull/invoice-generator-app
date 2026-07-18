import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../services/settings_service.dart';
import '../utils/constants.dart';
import '../widgets/custom_textfield.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  // Company controllers
  late TextEditingController _companyNameCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;

  bool _isSaving = false;
  bool _isPickingImage = false;

  @override
  void initState() {
    super.initState();
    final service = context.read<SettingsService>();
    _companyNameCtrl =
        TextEditingController(text: service.company.companyName);
    _addressCtrl = TextEditingController(text: service.company.address);
    _emailCtrl = TextEditingController(text: service.company.email);
    _phoneCtrl = TextEditingController(text: service.company.phone);
  }

  @override
  void dispose() {
    _companyNameCtrl.dispose();
    _addressCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    setState(() => _isPickingImage = true);
    try {
      final picker = ImagePicker();
      final pickedFile =
          await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (pickedFile != null && mounted) {
        await context.read<SettingsService>().saveLogoPath(pickedFile.path);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Logo updated successfully')),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isPickingImage = false);
    }
  }

  Future<void> _saveCompany() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      await context.read<SettingsService>().saveCompany(
            companyName: _companyNameCtrl.text.trim(),
            address: _addressCtrl.text.trim(),
            email: _emailCtrl.text.trim(),
            phone: _phoneCtrl.text.trim(),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Company details saved')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          TextButton.icon(
            onPressed: _isSaving ? null : _saveCompany,
            icon: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: const Text('Save'),
          ),
        ],
      ),
      body: Consumer<SettingsService>(
        builder: (context, settings, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Company Logo ──────────────────────────────────────────
                  _SectionCard(
                    title: 'Company Logo',
                    icon: Icons.image_outlined,
                    child: Center(
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: _isPickingImage ? null : _pickLogo,
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline
                                            .withValues(alpha: 0.3),
                                        width: 2),
                                    image: settings.company.logoPath.isNotEmpty
                                        ? DecorationImage(
                                            image: FileImage(
                                                File(settings.company.logoPath)),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child:
                                      settings.company.logoPath.isEmpty
                                          ? Icon(
                                              Icons.business,
                                              size: 50,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withValues(alpha: 0.5),
                                            )
                                          : null,
                                ),
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.edit,
                                      size: 14, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: _isPickingImage ? null : _pickLogo,
                            icon: _isPickingImage
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2))
                                : const Icon(Icons.upload_outlined),
                            label: Text(settings.company.logoPath.isEmpty
                                ? 'Upload Logo'
                                : 'Change Logo'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Company Details ───────────────────────────────────────
                  _SectionCard(
                    title: 'Company Details',
                    icon: Icons.business_outlined,
                    child: Column(
                      children: [
                        CustomTextField(
                          label: 'Company Name',
                          controller: _companyNameCtrl,
                          prefixIcon: Icons.business,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Company name is required'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          label: 'Address',
                          controller: _addressCtrl,
                          prefixIcon: Icons.location_on_outlined,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          label: 'Email',
                          controller: _emailCtrl,
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return null;
                            if (!v.contains('@')) {
                              return 'Enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          label: 'Phone Number',
                          controller: _phoneCtrl,
                          prefixIcon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Invoice Settings ──────────────────────────────────────
                  _SectionCard(
                    title: 'Invoice Settings',
                    icon: Icons.receipt_long_outlined,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Invoice Prefix
                        Text(
                          'Invoice Prefix',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.6)),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: AppConstants.prefixOptions.map((prefix) {
                            final isSelected =
                                settings.invoicePrefix == prefix;
                            return ChoiceChip(
                              label: Text(prefix),
                              selected: isSelected,
                              onSelected: (_) =>
                                  settings.setInvoicePrefix(prefix),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),

                        // Default Tax
                        Text(
                          'Default Tax (%)',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.6)),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              AppConstants.taxOptions.map((tax) {
                            final isSelected =
                                settings.defaultTax == tax;
                            return ChoiceChip(
                              label: Text('${tax.toStringAsFixed(0)}%'),
                              selected: isSelected,
                              onSelected: (_) =>
                                  settings.setDefaultTax(tax),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Currency ──────────────────────────────────────────────
                  _SectionCard(
                    title: 'Currency',
                    icon: Icons.attach_money_outlined,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Currency',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.6)),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              AppConstants.currencies.map((currency) {
                            final isSelected =
                                settings.currency == currency;
                            final symbol =
                                AppConstants.currencySymbols[currency] ??
                                    currency;
                            return ChoiceChip(
                              avatar: Text(symbol,
                                  style: const TextStyle(fontSize: 12)),
                              label: Text(currency),
                              selected: isSelected,
                              onSelected: (_) =>
                                  settings.setCurrency(currency),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Theme ─────────────────────────────────────────────────
                  _SectionCard(
                    title: 'Appearance',
                    icon: Icons.palette_outlined,
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      secondary: Icon(
                        settings.isDarkMode
                            ? Icons.dark_mode_outlined
                            : Icons.light_mode_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      title: const Text('Dark Mode'),
                      subtitle: Text(
                          settings.isDarkMode ? 'Dark theme active' : 'Light theme active'),
                      value: settings.isDarkMode,
                      onChanged: (v) => settings.setDarkMode(v),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Save button ───────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _isSaving ? null : _saveCompany,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.save_outlined),
                      label: const Text('Save Company Details'),
                      style: FilledButton.styleFrom(
                          padding:
                              const EdgeInsets.symmetric(vertical: 16)),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Reusable settings section card
// ────────────────────────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            child,
          ],
        ),
      ),
    );
  }
}

