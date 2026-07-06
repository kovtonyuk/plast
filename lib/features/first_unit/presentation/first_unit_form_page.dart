import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/models/first_unit_model.dart';

class FirstUnitFormPage extends StatefulWidget {
  final FirstUnitModel? unitToEdit;

  const FirstUnitFormPage({super.key, this.unitToEdit});

  @override
  State<FirstUnitFormPage> createState() => _FirstUnitFormPageState();
}

class _FirstUnitFormPageState extends State<FirstUnitFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _aboutFirstStepsController = TextEditingController();
  final _aboutFirstImpressionsController = TextEditingController();

  DateTime? _firstStepsDate;
  DateTime? _scarfTyingDate;
  bool _isSaving = false;

  bool get _isEditing => widget.unitToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameController.text = widget.unitToEdit!.name;
      _aboutFirstStepsController.text = widget.unitToEdit!.aboutFirstSteps;
      _aboutFirstImpressionsController.text = widget.unitToEdit!.aboutFirstImpressions;
      _firstStepsDate = widget.unitToEdit!.firstStepsDate;
      _scarfTyingDate = widget.unitToEdit!.scarfTyingDate;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _aboutFirstStepsController.dispose();
    _aboutFirstImpressionsController.dispose();
    super.dispose();
  }

  Future<void> _selectFirstStepsDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _firstStepsDate ?? DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _firstStepsDate = picked);
    }
  }

  Future<void> _selectScarfTyingDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _scarfTyingDate ?? DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _scarfTyingDate = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final data = {
        'user_id': userId,
        'name': _nameController.text.trim(),
        'first_steps_date': _firstStepsDate?.toIso8601String(),
        'scarf_tying_date': _scarfTyingDate?.toIso8601String(),
        'about_first_steps': _aboutFirstStepsController.text.trim(),
        'about_first_impressions': _aboutFirstImpressionsController.text.trim(),
      };

      if (_isEditing) {
        await Supabase.instance.client
            .from('first_units')
            .update(data)
            .eq('id', widget.unitToEdit!.id);
      } else {
        data['created_at'] = DateTime.now().toIso8601String();
        await Supabase.instance.client.from('first_units').insert(data);
      }

      if (mounted) context.pop();
    } catch (e) {
      // Error saving first unit
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.error}: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _goToMembers() {
    if (_isEditing) {
      context.push('/first-unit/${widget.unitToEdit!.id}/members', extra: widget.unitToEdit!.name);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Спочатку збережіть гурток')),
      );
    }
  }

  void _goToRules() {
    if (_isEditing) {
      context.push('/first-unit/${widget.unitToEdit!.id}/rules', extra: widget.unitToEdit!.name);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Спочатку збережіть гурток')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editFirstUnit : l10n.addFirstUnit),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: '${l10n.name} *',
                prefixIcon: const Icon(Icons.badge),
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
              onTap: _selectFirstStepsDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: l10n.firstStepsDate,
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: const OutlineInputBorder(),
                ),
                child: Text(
                  _firstStepsDate != null
                      ? DateFormat('dd.MM.yyyy').format(_firstStepsDate!)
                      : '—',
                ),
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _selectScarfTyingDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: l10n.scarfTyingDate,
                  prefixIcon: const Icon(Icons.workspaces),
                  border: const OutlineInputBorder(),
                ),
                child: Text(
                  _scarfTyingDate != null
                      ? DateFormat('dd.MM.yyyy').format(_scarfTyingDate!)
                      : '—',
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _aboutFirstStepsController,
              decoration: InputDecoration(
                labelText: l10n.aboutFirstSteps,
                prefixIcon: const Icon(Icons.description),
                border: const OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _aboutFirstImpressionsController,
              decoration: InputDecoration(
                labelText: l10n.aboutFirstImpressions,
                prefixIcon: const Icon(Icons.emoji_emotions),
                border: const OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 24),
            const Divider(thickness: 2),
            const SizedBox(height: 16),

            // Members section - as a button to navigate to separate page
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: const Icon(Icons.people, color: Colors.white),
                ),
                title: Text(l10n.members),
                subtitle: _isEditing ? Text('${l10n.edit} / ${l10n.add}') : null,
                trailing: const Icon(Icons.chevron_right),
                onTap: _goToMembers,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  child: const Icon(Icons.rule, color: Colors.white),
                ),
                title: Text(l10n.rules),
                subtitle: _isEditing ? Text('${l10n.edit} / ${l10n.add}') : null,
                trailing: const Icon(Icons.chevron_right),
                onTap: _goToRules,
              ),
            ),

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }
}
