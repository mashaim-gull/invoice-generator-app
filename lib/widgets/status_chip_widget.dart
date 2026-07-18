import 'package:flutter/material.dart';
import '../models/invoice_model.dart';

/// Colored chip that reflects the invoice payment status.
class StatusChipWidget extends StatelessWidget {
  final InvoiceStatus status;

  const StatusChipWidget({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _bgColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _bgColor.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: _bgColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            _label,
            style: TextStyle(
              color: _bgColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Color get _bgColor {
    switch (status) {
      case InvoiceStatus.paid:
        return const Color(0xFF2E7D32); // Green 800
      case InvoiceStatus.unpaid:
        return const Color(0xFFE65100); // Orange 900
      case InvoiceStatus.overdue:
        return const Color(0xFFC62828); // Red 800
    }
  }

  String get _label {
    switch (status) {
      case InvoiceStatus.paid:
        return 'PAID';
      case InvoiceStatus.unpaid:
        return 'UNPAID';
      case InvoiceStatus.overdue:
        return 'OVERDUE';
    }
  }
}

