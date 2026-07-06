import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/models/event_model.dart';
import '../../../shared/services/event_change_notifier.dart';

class EventsListPage extends StatefulWidget {
  const EventsListPage({super.key});

  @override
  State<EventsListPage> createState() => _EventsListPageState();
}

class _EventsListPageState extends State<EventsListPage> {
  List<EventModel> _events = [];
  bool _isLoading = true;
  bool _showFutureOnly = false;

  @override
  void initState() {
    super.initState();
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
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    setState(() => _isLoading = true);

    final response = await Supabase.instance.client
        .from('events')
        .select()
        .eq('user_id', userId)
        .eq('event_type', 'event')
        .order('start_date', ascending: false);

    final events = (response as List).map((e) => EventModel.fromJson(e)).where((e) => e.deletedAt == null).toList();

    setState(() {
      _events = events;
      _isLoading = false;
    });
  }

  List<EventModel> get _filteredEvents {
    if (_showFutureOnly) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      return _events.where((e) {
        final eventStart = DateTime(e.startDate.year, e.startDate.month, e.startDate.day);
        return eventStart.isAfter(today);
      }).toList();
    }
    return _events;
  }

  Color _getEventColor(EventModel event) {
    return Colors.orange;
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(l10n.upcoming),
                const Spacer(),
                Switch(
                  value: _showFutureOnly,
                  onChanged: (v) => setState(() => _showFutureOnly = v),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredEvents.isEmpty
                    ? Center(child: Text(l10n.noData))
                    : RefreshIndicator(
                        onRefresh: _loadEvents,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredEvents.length,
                          itemBuilder: (context, index) {
                            final event = _filteredEvents[index];
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
                                  leading: CircleAvatar(
                                    backgroundColor: _getEventColor(event),
                                    child: const Icon(Icons.event, color: Colors.white),
                                  ),
                                  title: Text(event.title),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${DateFormat('dd.MM.yyyy').format(event.startDate)} - ${DateFormat('dd.MM.yyyy').format(event.endDate)}',
                                      ),
                                      if (event.description.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          event.description,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ],
                                  ),
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push('/events/add', extra: {'date': null, 'eventType': 'event'});
          _loadEvents();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
