import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/models/event_model.dart';
import '../../../shared/services/event_change_notifier.dart';

class CampsPage extends StatefulWidget {
  const CampsPage({super.key});

  @override
  State<CampsPage> createState() => _CampsPageState();
}

class _CampsPageState extends State<CampsPage> {
  List<EventModel> _camps = [];
  bool _isLoading = true;
  bool _showFutureOnly = false;

  @override
  void initState() {
    super.initState();
    _loadCamps();

    // Listen for event changes from other pages
    EventChangeNotifier().addListener(_onEventChanged);
  }

  @override
  void dispose() {
    EventChangeNotifier().removeListener(_onEventChanged);
    super.dispose();
  }

  void _onEventChanged() {
    _loadCamps();
  }

  Future<void> _loadCamps() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    setState(() => _isLoading = true);

    final response = await Supabase.instance.client
        .from('events')
        .select()
        .eq('user_id', userId)
        .eq('event_type', 'camp')
        .order('start_date', ascending: false);

    final camps = (response as List).map((e) => EventModel.fromJson(e)).where((e) => e.deletedAt == null).toList();

    setState(() {
      _camps = camps;
      _isLoading = false;
    });
  }

  List<EventModel> get _filteredCamps {
    if (_showFutureOnly) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      return _camps.where((c) {
        final eventStart = DateTime(c.startDate.year, c.startDate.month, c.startDate.day);
        return eventStart.isAfter(today);
      }).toList();
    }
    return _camps;
  }

  Color _getEventColor(String eventType) {
    return Colors.green;
  }

  Future<bool> _confirmDelete(EventModel camp, AppLocalizations l10n) async {
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
          .eq('id', camp.id);
      EventChangeNotifier().notifyEventChanged();
      _loadCamps();
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
                : _filteredCamps.isEmpty
                    ? Center(child: Text(l10n.noData))
                    : RefreshIndicator(
                        onRefresh: _loadCamps,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredCamps.length,
                          itemBuilder: (context, index) {
                            final camp = _filteredCamps[index];
                            return Dismissible(
                              key: Key(camp.id),
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
                              confirmDismiss: (_) => _confirmDelete(camp, l10n),
                              child: Card(
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: _getEventColor(camp.eventType),
                                    child: const Icon(
                                      Icons.park,
                                      color: Colors.white,
                                    ),
                                  ),
                                  title: Text(camp.title),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${DateFormat('dd.MM.yyyy').format(camp.startDate)} - ${DateFormat('dd.MM.yyyy').format(camp.endDate)}',
                                      ),
                                      if (camp.description.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          camp.description,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ],
                                  ),
                                  onTap: () async {
                                    await context.push('/events/edit', extra: {'event': camp});
                                    _loadCamps();
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
          await context.push('/events/add', extra: {'date': null, 'eventType': 'camp'});
          _loadCamps();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
