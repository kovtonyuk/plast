import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/models/plast_activity_model.dart';

class PlastActivityFormPage extends StatefulWidget {
  final PlastActivityModel? activityToEdit;

  const PlastActivityFormPage({super.key, this.activityToEdit});

  @override
  State<PlastActivityFormPage> createState() => _PlastActivityFormPageState();
}

class _PlastActivityFormPageState extends State<PlastActivityFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _projectNameController = TextEditingController();
  final _positionController = TextEditingController();
  final _areaController = TextEditingController();

  DateTime? _date;
  bool _isSaving = false;

  bool get _isEditing => widget.activityToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _projectNameController.text = widget.activityToEdit!.projectName;
      _positionController.text = widget.activityToEdit!.position;
      _areaController.text = widget.activityToEdit!.area;
      _date = widget.activityToEdit!.date;
    }
  }

  @override
  void dispose() {
    _projectNameController.dispose();
    _positionController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final data = {
        'user_id': userId,
        'project_name': _projectNameController.text.trim(),
        'position': _positionController.text.trim(),
        'date': _date?.toIso8601String(),
        'area': _areaController.text.trim(),
      };

      if (_isEditing) {
        await Supabase.instance.client
            .from('plast_activities')
            .update(data)
            .eq('id', widget.activityToEdit!.id);
      } else {
        data['created_at'] = DateTime.now().toIso8601String();
        await Supabase.instance.client.from('plast_activities').insert(data);
      }

      if (mounted) context.pop();
    } catch (e) {
      // Error saving plast activity
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
        title: Text(_isEditing ? l10n.editPlastActivity : l10n.addPlastActivity),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _projectNameController,
              decoration: InputDecoration(
                labelText: '${l10n.projectName} *',
                prefixIcon: const Icon(Icons.title),
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
            TextFormField(
              controller: _positionController,
              decoration: InputDecoration(
                labelText: '${l10n.position} *',
                prefixIcon: const Icon(Icons.work),
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
            TextFormField(
              controller: _areaController,
              decoration: InputDecoration(
                labelText: l10n.area,
                prefixIcon: const Icon(Icons.location_on),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _selectDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: l10n.date,
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: const OutlineInputBorder(),
                ),
                child: Text(
                  _date != null
                      ? DateFormat('dd.MM.yyyy').format(_date!)
                      : '—',
                ),
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
