import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/widgets/date_picker_tile.dart';
import '../../../core/widgets/time_picker_tile.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/models/event_model.dart';
import '../../../shared/services/event_change_notifier.dart';
import '../../../shared/services/notification_service.dart';

class AddEventPage extends StatefulWidget {
  final DateTime? initialDate;
  final String? initialEventType;
  final EventModel? eventToEdit;

  const AddEventPage({
    super.key,
    this.initialDate,
    this.initialEventType,
    this.eventToEdit,
  });

  @override
  State<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _stepsController = TextEditingController();
  late DateTime _startDate;
  late TimeOfDay _startTime;
  DateTime _endDate = DateTime.now();
  late TimeOfDay _endTime;
  String _eventType = 'event';
  int? _remindBeforeMinutes;
  bool _isLoading = false;

  bool get _isEditing => widget.eventToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _titleController.text = widget.eventToEdit!.title;
      _descriptionController.text = widget.eventToEdit!.description;
      _stepsController.text = widget.eventToEdit!.steps ?? '';
      _startDate = widget.eventToEdit!.startDate;
      _startTime = TimeOfDay.fromDateTime(widget.eventToEdit!.startDate);
      _endDate = widget.eventToEdit!.endDate;
      _endTime = TimeOfDay.fromDateTime(widget.eventToEdit!.endDate);
      _eventType = widget.eventToEdit!.eventType;
      _remindBeforeMinutes = widget.eventToEdit!.remindBeforeMinutes;
    } else {
      final now = DateTime.now();
      _startDate = widget.initialDate ?? now;
      _startTime = const TimeOfDay(hour: 10, minute: 0);
      _endDate = _startDate;
      _endTime = const TimeOfDay(hour: 11, minute: 0);
      _eventType = widget.initialEventType ?? 'event';
      _remindBeforeMinutes = 60; // Default: 1 hour before
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _stepsController.dispose();
    super.dispose();
  }

  DateTime _combineDateAndTime(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _isLoading = true;
    });

    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final startDateTime = _combineDateAndTime(_startDate, _startTime);
      final endDateTime = _combineDateAndTime(_endDate, _endTime);

      final data = {
        'user_id': userId,
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'event_type': _eventType,
        'start_date': startDateTime.toIso8601String(),
        'end_date': endDateTime.toIso8601String(),
        'steps': widget.eventToEdit?.eventType == 'goal' ? _stepsController.text.trim() : null,
        'remind_before_minutes': _remindBeforeMinutes,
      };

      String eventId;

      if (_isEditing) {
        await Supabase.instance.client
            .from('events')
            .update(data)
            .eq('id', widget.eventToEdit!.id);
        eventId = widget.eventToEdit!.id;

        // Cancel old notification
        await NotificationService().cancelEventNotification(widget.eventToEdit!.id);
      } else {
        final result = await Supabase.instance.client.from('events').insert(data).select().single();
        eventId = result['id'] as String;
      }

      // Schedule notification if reminder is set
      if (_remindBeforeMinutes != null) {
        final event = EventModel(
          id: eventId,
          userId: userId,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          eventType: _eventType,
          startDate: startDateTime,
          endDate: endDateTime,
          createdAt: DateTime.now(),
          steps: null,
          remindBeforeMinutes: _remindBeforeMinutes,
        );
        await NotificationService().scheduleEventNotification(event, l10n);
      }

      // Notify all pages that events changed
      EventChangeNotifier().notifyEventChanged();

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.error}: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getAddEventTitle(AppLocalizations l10n) {
    switch (_eventType) {
      case 'training':
        return '${l10n.add} ${l10n.training}';
      case 'camp':
        return '${l10n.add} ${l10n.camp}';
      default:
        return l10n.addEvent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.edit : _getAddEventTitle(l10n)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: l10n.eventTitle,
                prefixIcon: const Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.required;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: l10n.eventDescription,
                prefixIcon: const Icon(Icons.description),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _eventType,
              decoration: InputDecoration(
                labelText: l10n.eventType,
                prefixIcon: const Icon(Icons.category),
              ),
              items: [
                DropdownMenuItem(value: 'training', child: Text(l10n.training)),
                DropdownMenuItem(value: 'camp', child: Text(l10n.camp)),
                DropdownMenuItem(value: 'event', child: Text(l10n.event)),
              ],
              onChanged: _isEditing
                  ? null
                  : (value) {
                      setState(() {
                        _eventType = value!;
                      });
                    },
            ),
            const SizedBox(height: 16),
            DatePickerTile(
              label: l10n.startDate,
              date: _startDate,
              onTap: () => _selectDate(context, true),
            ),
            const SizedBox(height: 8),
            TimePickerTile(
              label: l10n.startTime,
              time: _startTime,
              onTap: () => _selectTime(context, true),
            ),
            const SizedBox(height: 16),
            DatePickerTile(
              label: l10n.endDate,
              date: _endDate,
              onTap: () => _selectDate(context, false),
            ),
            const SizedBox(height: 8),
            TimePickerTile(
              label: l10n.endTime,
              time: _endTime,
              onTap: () => _selectTime(context, false),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int?>(
              value: _remindBeforeMinutes,
              decoration: InputDecoration(
                labelText: l10n.reminder,
                prefixIcon: const Icon(Icons.notifications),
              ),
              items: [
                DropdownMenuItem<int?>(
                  value: null,
                  child: Text(l10n.noReminder),
                ),
                ...NotificationService.reminderOptions(l10n).map(
                  (option) => DropdownMenuItem<int?>(
                    value: option.value,
                    child: Text(option.label),
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _remindBeforeMinutes = value;
                });
              },
            ),
            if (_isEditing && widget.eventToEdit?.eventType == 'goal') ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _stepsController,
                decoration: InputDecoration(
                  labelText: l10n.stepsGoal,
                  prefixIcon: const Icon(Icons.checklist),
                ),
                maxLines: 5,
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveEvent,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.save),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
