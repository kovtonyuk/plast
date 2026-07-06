import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimePickerTile extends StatelessWidget {
  final String label;
  final TimeOfDay? time;
  final VoidCallback? onTap;
  final bool isEnabled;

  const TimePickerTile({
    super.key,
    required this.label,
    required this.time,
    this.onTap,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Opacity(
      opacity: isEnabled ? 1.0 : 0.6,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outline,
            width: 1,
          ),
        ),
        child: ListTile(
          leading: Icon(Icons.access_time, color: colorScheme.primary),
          title: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          subtitle: Text(
            time != null ? time!.format(context) : '—',
            style: const TextStyle(fontSize: 16),
          ),
          trailing: Icon(Icons.access_time, color: colorScheme.primary),
          enabled: isEnabled,
          onTap: onTap,
        ),
      ),
    );
  }
}

class DateTimePickerTile extends StatelessWidget {
  final String label;
  final DateTime? dateTime;
  final VoidCallback? onTap;
  final bool isEnabled;
  final bool showDate;
  final bool showTime;

  const DateTimePickerTile({
    super.key,
    required this.label,
    required this.dateTime,
    this.onTap,
    this.isEnabled = true,
    this.showDate = true,
    this.showTime = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    String formattedValue = '—';
    if (dateTime != null) {
      final parts = <String>[];
      if (showDate) {
        parts.add(DateFormat('dd.MM.yyyy').format(dateTime!));
      }
      if (showTime) {
        parts.add(DateFormat('HH:mm').format(dateTime!));
      }
      formattedValue = parts.join(' ');
    }

    return Opacity(
      opacity: isEnabled ? 1.0 : 0.6,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outline,
            width: 1,
          ),
        ),
        child: ListTile(
          leading: Icon(Icons.calendar_today, color: isEnabled ? colorScheme.primary : null),
          title: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isEnabled ? colorScheme.onSurfaceVariant : colorScheme.outline,
            ),
          ),
          subtitle: Text(
            formattedValue,
            style: TextStyle(
              fontSize: 16,
              color: isEnabled ? null : colorScheme.outline,
            ),
          ),
          trailing: Icon(
            Icons.calendar_today,
            color: isEnabled ? colorScheme.primary : colorScheme.outline,
          ),
          enabled: isEnabled,
          onTap: onTap,
        ),
      ),
    );
  }
}
