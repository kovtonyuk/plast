import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/models/goal_model.dart';

class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key});

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  List<GoalModel> _goals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;

    if (userId == null) {
      return;
    }

    try {
      final response = await Supabase.instance.client
          .from('goals')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final goals = (response as List).map((e) => GoalModel.fromJson(e)).toList();

      if (mounted) {
        setState(() {
          _goals = goals;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<bool> _confirmDelete(GoalModel goal, AppLocalizations l10n) async {
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
      try {
        // Use RPC to bypass RLS issue with UPDATE + WITH CHECK
        await Supabase.instance.client.rpc('soft_delete_goal', params: {'goal_id': goal.id});
        _loadGoals();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${AppLocalizations.of(context)!.error}: $e')),
          );
        }
      }
    }
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _goals.isEmpty
              ? Center(child: Text(l10n.noData))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _goals.length,
                  itemBuilder: (context, index) {
                    final goal = _goals[index];
                    final progress = goal.stepsCompleted.isEmpty
                        ? 0.0
                        : goal.completedStepsCount / goal.stepsCompleted.length;

                    return Dismissible(
                      key: Key(goal.id),
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
                      confirmDismiss: (_) => _confirmDelete(goal, l10n),
                      child: Card(
                        child: InkWell(
                          onTap: () async {
                            await context.push('/goals/edit', extra: goal);
                            _loadGoals();
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        goal.title,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${l10n.goalTargetDate}: ${DateFormat('dd.MM.yyyy').format(goal.targetDate)}',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                if (goal.steps.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  LinearProgressIndicator(value: progress, backgroundColor: Colors.grey[300]),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${goal.completedStepsCount}/${goal.stepsCompleted.length}',
                                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push('/goals/add');
          _loadGoals();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
