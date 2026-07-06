import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/models/event_model.dart';
import '../../../shared/services/event_change_notifier.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<EventModel>> _events = {};
  List<EventModel> _selectedEvents = [];
  final _userId = Supabase.instance.client.auth.currentUser?.id;

  // Filter states
  final Set<String> _selectedFilters = {'training', 'camp', 'event'};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadEvents();

    // Listen for event changes from other pages
    EventChangeNotifier().addListener(_onEventChanged);
  }

  @override
  void dispose() {
    EventChangeNotifier().removeListener(_onEventChanged);
    super.dispose();
  }

  void _onEventChanged() {
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    if (_userId == null) return;

    final response = await Supabase.instance.client
        .from('events')
        .select()
        .eq('user_id', _userId);

    final events = (response as List)
        .map((e) => EventModel.fromJson(e))
        .where((e) => e.deletedAt == null)
        .toList();

    final Map<DateTime, List<EventModel>> eventMap = {};
    for (var event in events) {
      final date = DateTime(event.startDate.year, event.startDate.month, event.startDate.day);
      if (eventMap[date] == null) {
        eventMap[date] = [];
      }
      eventMap[date]!.add(event);
    }

    setState(() {
      _events = eventMap;
      _updateSelectedEvents();
    });
  }

  void _updateSelectedEvents() {
    final dayKey = _selectedDay != null
        ? DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day)
        : null;

    List<EventModel> eventsForDay = [];
    if (dayKey != null) {
      eventsForDay = _events[dayKey] ?? [];
    }

    // Apply filters
    _selectedEvents = eventsForDay
        .where((e) => _selectedFilters.contains(e.eventType))
        .toList();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _updateSelectedEvents();
    });
  }

  void _toggleFilter(String eventType) {
    setState(() {
      if (_selectedFilters.contains(eventType)) {
        if (_selectedFilters.length > 1) {
          _selectedFilters.remove(eventType);
        }
      } else {
        _selectedFilters.add(eventType);
      }
      _updateSelectedEvents();
    });
  }

  Color _getEventColor(String eventType) {
    switch (eventType) {
      case 'training':
        return Colors.blue;
      case 'camp':
        return Colors.green;
      case 'event':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getEventTypeLabel(String eventType, AppLocalizations l10n) {
    switch (eventType) {
      case 'training':
        return l10n.training;
      case 'camp':
        return l10n.camp;
      case 'event':
        return l10n.event;
      default:
        return eventType;
    }
  }

  String _getMonthName(int month, AppLocalizations l10n) {
    switch (month) {
      case 1: return l10n.january;
      case 2: return l10n.february;
      case 3: return l10n.march;
      case 4: return l10n.april;
      case 5: return l10n.may;
      case 6: return l10n.june;
      case 7: return l10n.july;
      case 8: return l10n.august;
      case 9: return l10n.september;
      case 10: return l10n.october;
      case 11: return l10n.november;
      case 12: return l10n.december;
      default: return '';
    }
  }

  String _getDayName(DateTime day, AppLocalizations l10n) {
    switch (day.weekday) {
      case DateTime.monday: return l10n.mon;
      case DateTime.tuesday: return l10n.tue;
      case DateTime.wednesday: return l10n.wed;
      case DateTime.thursday: return l10n.thu;
      case DateTime.friday: return l10n.fri;
      case DateTime.saturday: return l10n.sat;
      case DateTime.sunday: return l10n.sun;
      default: return '';
    }
  }

  Future<bool> _confirmDelete(EventModel event, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.delete),
        content: Text(l10n.confirmDelete),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await Supabase.instance.client
          .from('events')
          .update({'deleted_at': DateTime.now().toIso8601String()})
          .eq('id', event.id);
      EventChangeNotifier().notifyEventChanged();
      _loadEvents();
    }
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Column(
        children: [
          TableCalendar<EventModel>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: CalendarFormat.month,
            availableCalendarFormats: const {
              CalendarFormat.month: '',
            },
            eventLoader: (day) {
              final eventsForDay = _events[DateTime(day.year, day.month, day.day)] ?? [];
              return eventsForDay.where((e) => _selectedFilters.contains(e.eventType)).toList();
            },
            onDaySelected: _onDaySelected,
            calendarStyle: CalendarStyle(
              markerDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isEmpty) return null;
                return Positioned(
                  bottom: 1,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: events.take(3).map((event) {
                      return Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(
                          color: _getEventColor(event.eventType),
                          shape: BoxShape.circle,
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
            headerStyle: HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
              titleTextFormatter: (date, locale) => '${_getMonthName(date.month, l10n)} ${date.year}',
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
              weekendStyle: TextStyle(color: Theme.of(context).colorScheme.error),
              dowTextFormatter: (day, locale) => _getDayName(day, l10n),
            ),
          ),
          const SizedBox(height: 8),
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _FilterChip(
                  label: l10n.training,
                  color: Colors.blue,
                  isSelected: _selectedFilters.contains('training'),
                  onTap: () => _toggleFilter('training'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: l10n.camp,
                  color: Colors.green,
                  isSelected: _selectedFilters.contains('camp'),
                  onTap: () => _toggleFilter('camp'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: l10n.event,
                  color: Colors.orange,
                  isSelected: _selectedFilters.contains('event'),
                  onTap: () => _toggleFilter('event'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _selectedEvents.isEmpty
                ? Center(
                    child: Text(l10n.noData),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _selectedEvents.length,
                    itemBuilder: (context, index) {
                      final event = _selectedEvents[index];
                      return Dismissible(
                        key: Key(event.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (_) => _confirmDelete(event, l10n),
                        child: Card(
                          child: ListTile(
                            leading: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: _getEventColor(event.eventType),
                                shape: BoxShape.circle,
                              ),
                            ),
                            title: Text(event.title),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${DateFormat('dd.MM.yyyy').format(event.startDate)} - ${DateFormat('dd.MM.yyyy').format(event.endDate)}',
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _getEventColor(event.eventType).withAlpha(51),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    _getEventTypeLabel(event.eventType, l10n),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _getEventColor(event.eventType),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if (event.description.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(event.description),
                                ],
                              ],
                            ),
                            isThreeLine: true,
                            onTap: () async {
                              await context.push('/events/edit', extra: {'event': event});
                              _loadEvents();
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push('/events/add', extra: {'date': _selectedDay, 'eventType': 'event'});
          _loadEvents();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withAlpha(51) : Colors.transparent,
          border: Border.all(color: isSelected ? color : Colors.grey),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
