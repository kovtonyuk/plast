import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/models/goal_model.dart';
import '../../../shared/services/notification_service.dart';

class GoalFormPage extends StatefulWidget {
  final GoalModel? goalToEdit;

  const GoalFormPage({super.key, this.goalToEdit});

  @override
  State<GoalFormPage> createState() => _GoalFormPageState();
}

class _GoalFormPageState extends State<GoalFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _stepController = TextEditingController();

  late DateTime _targetDate;
  List<String> _steps = [];
  List<bool> _stepsCompleted = [];
  bool _isLoading = false;
  bool _isSaving = false;

  bool get _isEditing => widget.goalToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _titleController.text = widget.goalToEdit!.title;
      _targetDate = widget.goalToEdit!.targetDate;
      _steps = List.from(widget.goalToEdit!.steps);
      _stepsCompleted = List.from(widget.goalToEdit!.stepsCompleted);
    } else {
      _targetDate = DateTime.now().add(const Duration(days: 30));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _stepController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _targetDate = picked);
    }
  }

  void _addStep() {
    if (_stepController.text.trim().isEmpty) return;
    setState(() {
      _steps.add(_stepController.text.trim());
      _stepsCompleted.add(false);
      _stepController.clear();
    });
  }

  void _removeStep(int index) {
    setState(() {
      _steps.removeAt(index);
      _stepsCompleted.removeAt(index);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_steps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.goalStepsRequired)),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final stepsCompletedStr = _stepsCompleted.map((e) => e ? '1' : '0').join('|||');
      final data = {
        'user_id': userId,
        'title': _titleController.text.trim(),
        'target_date': _targetDate.toIso8601String(),
        'steps': _steps.join('|||'),
        'steps_completed': stepsCompletedStr,
      };

      if (_isEditing) {
        final result = await Supabase.instance.client
            .from('goals')
            .update(data)
            .eq('id', widget.goalToEdit!.id)
            .select();

        // Cancel old notification and schedule new one
        await NotificationService().cancelGoalNotification(widget.goalToEdit!.id);
        final updatedGoal = GoalModel(
          id: widget.goalToEdit!.id,
          userId: userId,
          title: _titleController.text.trim(),
          targetDate: _targetDate,
          steps: _steps,
          stepsCompleted: _stepsCompleted,
          createdAt: widget.goalToEdit!.createdAt,
        );
        await NotificationService().scheduleGoalNotification(updatedGoal);
      } else {
        data['created_at'] = DateTime.now().toIso8601String();
        final insertResult = await Supabase.instance.client.from('goals').insert(data).select();
        final goalId = (insertResult as List).first['id'] as String;

        // Schedule notification
        final newGoal = GoalModel(
          id: goalId,
          userId: userId,
          title: _titleController.text.trim(),
          targetDate: _targetDate,
          steps: _steps,
          stepsCompleted: _stepsCompleted,
          createdAt: DateTime.now(),
        );
        await NotificationService().scheduleGoalNotification(newGoal);
      }

      if (mounted) context.pop();
    } catch (e, stack) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.error}: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.edit : l10n.addGoal),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: l10n.goalTitle,
                prefixIcon: const Icon(Icons.flag),
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.required;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _selectDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: l10n.goalTargetDate,
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: const OutlineInputBorder(),
                ),
                child: Text(DateFormat('dd.MM.yyyy').format(_targetDate)),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.goalSteps,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _stepController,
                    decoration: InputDecoration(
                      labelText: l10n.goalStepHint,
                      border: const OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addStep(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _addStep,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._steps.asMap().entries.map((entry) {
              final index = entry.key;
              final step = entry.value;
              return Card(
                child: CheckboxListTile(
                  value: _stepsCompleted[index],
                  onChanged: (value) {
                    setState(() => _stepsCompleted[index] = value ?? false);
                  },
                  title: Text(step),
                  secondary: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeStep(index),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              );
            }),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }
}
