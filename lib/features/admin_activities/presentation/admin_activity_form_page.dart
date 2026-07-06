import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/models/admin_activity_model.dart';

class AdminActivityFormPage extends StatefulWidget {
  final AdminActivityModel? activityToEdit;

  const AdminActivityFormPage({super.key, this.activityToEdit});

  @override
  State<AdminActivityFormPage> createState() => _AdminActivityFormPageState();
}

class _AdminActivityFormPageState extends State<AdminActivityFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _positionController = TextEditingController();
  final _stanytsiaController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  bool _isSaving = false;

  bool get _isEditing => widget.activityToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _positionController.text = widget.activityToEdit!.position;
      _stanytsiaController.text = widget.activityToEdit!.stanytsia;
      _startDate = widget.activityToEdit!.startDate;
      _endDate = widget.activityToEdit!.endDate;
    }
  }

  @override
  void dispose() {
    _positionController.dispose();
    _stanytsiaController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(1990),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final data = {
        'user_id': userId,
        'position': _positionController.text.trim(),
        'start_date': _startDate?.toIso8601String(),
        'end_date': _endDate?.toIso8601String(),
        'stanytsia': _stanytsiaController.text.trim(),
      };

      if (_isEditing) {
        await Supabase.instance.client
            .from('admin_activities')
            .update(data)
            .eq('id', widget.activityToEdit!.id);
      } else {
        data['created_at'] = DateTime.now().toIso8601String();
        await Supabase.instance.client.from('admin_activities').insert(data);
      }

      if (mounted) context.pop();
    } catch (e) {
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
        title: Text(_isEditing ? l10n.editAdminActivity : l10n.addAdminActivity),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
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
              controller: _stanytsiaController,
              decoration: InputDecoration(
                labelText: l10n.location,
                prefixIcon: const Icon(Icons.location_on),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _selectStartDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: l10n.startDate,
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: const OutlineInputBorder(),
                ),
                child: Text(
                  _startDate != null
                      ? DateFormat('dd.MM.yyyy').format(_startDate!)
                      : '—',
                ),
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _selectEndDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: l10n.endDate,
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: const OutlineInputBorder(),
                ),
                child: Text(
                  _endDate != null
                      ? DateFormat('dd.MM.yyyy').format(_endDate!)
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
