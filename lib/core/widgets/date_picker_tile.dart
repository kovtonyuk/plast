import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePickerTile extends StatelessWidget {
  final String label;
  final DateTime? date;
  final bool isRequired;
  final bool isError;
  final bool isEnabled;
  final VoidCallback? onTap;
  final IconData icon;

  const DatePickerTile({
    super.key,
    required this.label,
    required this.date,
    this.isRequired = false,
    this.isError = false,
    this.isEnabled = true,
    this.onTap,
    this.icon = Icons.calendar_today,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color borderColor = colorScheme.outline;
    if (isError) borderColor = Colors.red;

    return Opacity(
      opacity: isEnabled ? 1.0 : 0.6,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor,
            width: isError ? 2 : 1,
          ),
        ),
        child: ListTile(
          leading: Icon(icon, color: isError ? Colors.red : null),
          title: Text(
            isRequired ? '$label *' : label,
            style: TextStyle(
              fontSize: 12,
              color: isError ? Colors.red : colorScheme.onSurfaceVariant,
            ),
          ),
          subtitle: Text(
            date != null ? DateFormat('dd.MM.yyyy').format(date!) : '—',
            style: TextStyle(
              fontSize: 16,
              color: isError ? Colors.red : null,
            ),
          ),
          trailing: isError
              ? const Icon(Icons.error, color: Colors.red)
              : Icon(icon, color: colorScheme.primary),
          enabled: isEnabled,
          onTap: onTap,
        ),
      ),
    );
  }
}
