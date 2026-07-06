import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/models/event_model.dart';
import '../../../shared/services/event_change_notifier.dart';

class TrainingsPage extends StatefulWidget {
  const TrainingsPage({super.key});

  @override
  State<TrainingsPage> createState() => _TrainingsPageState();
}

class _TrainingsPageState extends State<TrainingsPage> {
  List<EventModel> _trainings = [];
  bool _isLoading = true;
  bool _showFutureOnly = false;

  @override
  void initState() {
    super.initState();
    _loadTrainings();

    // Listen for event changes from other pages
    EventChangeNotifier().addListener(_onEventChanged);
  }

  @override
  void dispose() {
    EventChangeNotifier().removeListener(_onEventChanged);
    super.dispose();
  }

  void _onEventChanged() {
    _loadTrainings();
  }

  Future<void> _loadTrainings() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await Supabase.instance.client
          .from('events')
          .select()
          .eq('user_id', userId)
          .eq('event_type', 'training')
          .order('start_date', ascending: false)
          .timeout(const Duration(seconds: 10));

      final trainings = (response as List).map((e) => EventModel.fromJson(e)).where((e) => e.deletedAt == null).toList();

      if (mounted) {
        setState(() {
          _trainings = trainings;
          _isLoading = false;
        });
      }
    } catch (e) {
      // Error loading trainings
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.error}: $e')),
        );
      }
    }
  }

  List<EventModel> get _filteredTrainings {
    if (_showFutureOnly) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      return _trainings.where((t) {
        final eventStart = DateTime(t.startDate.year, t.startDate.month, t.startDate.day);
        return eventStart.isAfter(today);
      }).toList();
    }
    return _trainings;
  }

  Color _getEventColor(String eventType) {
    return Colors.blue;
  }

  Future<void> _confirmDelete(EventModel event) async {
    final l10n = AppLocalizations.of(context)!;
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
      _loadTrainings();
    }
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
                : _filteredTrainings.isEmpty
                    ? Center(child: Text(l10n.noData))
                    : RefreshIndicator(
                        onRefresh: _loadTrainings,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredTrainings.length,
                          itemBuilder: (context, index) {
                            final training = _filteredTrainings[index];
                            return Dismissible(
                              key: Key(training.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 16),
                                color: Colors.red,
                                child: const Icon(Icons.delete, color: Colors.white),
                              ),
                              confirmDismiss: (_) async {
                                _confirmDelete(training);
                                return false;
                              },
                              child: Card(
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: _getEventColor(training.eventType),
                                    child: const Icon(Icons.school, color: Colors.white),
                                  ),
                                  title: Text(training.title),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${DateFormat('dd.MM.yyyy').format(training.startDate)} - ${DateFormat('dd.MM.yyyy').format(training.endDate)}',
                                      ),
                                      if (training.description.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          training.description,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ],
                                  ),
                                  onTap: () async {
                                    await context.push('/events/edit', extra: {'event': training});
                                    _loadTrainings();
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
          await context.push('/events/add', extra: {'date': null, 'eventType': 'training'});
          _loadTrainings();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
