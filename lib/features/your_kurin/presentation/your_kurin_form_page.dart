import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/models/your_kurin_model.dart';

class YourKurinFormPage extends StatefulWidget {
  final YourKurinModel? unitToEdit;

  const YourKurinFormPage({super.key, this.unitToEdit});

  @override
  State<YourKurinFormPage> createState() => _YourKurinFormPageState();
}

class _YourKurinFormPageState extends State<YourKurinFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _whyThisKurinController = TextEditingController();
  final _aboutThoughtsController = TextEditingController();

  DateTime? _firstMeetingDate;
  DateTime? _supporterDate;
  DateTime? _dcKurinDate;
  bool _isSaving = false;

  bool get _isEditing => widget.unitToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameController.text = widget.unitToEdit!.name;
      _whyThisKurinController.text = widget.unitToEdit!.whyThisKurin;
      _aboutThoughtsController.text = widget.unitToEdit!.aboutThoughts;
      _firstMeetingDate = widget.unitToEdit!.firstMeetingDate;
      _supporterDate = widget.unitToEdit!.supporterDate;
      _dcKurinDate = widget.unitToEdit!.dcKurinDate;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _whyThisKurinController.dispose();
    _aboutThoughtsController.dispose();
    super.dispose();
  }

  Future<void> _selectFirstMeetingDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _firstMeetingDate ?? DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _firstMeetingDate = picked);
    }
  }

  Future<void> _selectSupporterDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _supporterDate ?? DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _supporterDate = picked);
    }
  }

  Future<void> _selectDcKurinDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dcKurinDate ?? DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _dcKurinDate = picked);
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
        'first_meeting_date': _firstMeetingDate?.toIso8601String(),
        'supporter_date': _supporterDate?.toIso8601String(),
        'dc_kurin_date': _dcKurinDate?.toIso8601String(),
        'why_this_kurin': _whyThisKurinController.text.trim(),
        'about_thoughts': _aboutThoughtsController.text.trim(),
      };

      if (_isEditing) {
        await Supabase.instance.client
            .from('your_kurin')
            .update(data)
            .eq('id', widget.unitToEdit!.id);
      } else {
        data['created_at'] = DateTime.now().toIso8601String();
        await Supabase.instance.client.from('your_kurin').insert(data);
      }

      if (mounted) context.pop();
    } catch (e) {
      // Error saving your kurin
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('${AppLocalizations.of(context)!.error}: $e')),
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
        title: Text(_isEditing ? l10n.editYourKurin : l10n.addYourKurin),
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
              onTap: _selectFirstMeetingDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: l10n.firstMeetingDate,
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: const OutlineInputBorder(),
                ),
                child: Text(
                  _firstMeetingDate != null
                      ? DateFormat('dd.MM.yyyy').format(_firstMeetingDate!)
                      : '—',
                ),
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _selectSupporterDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: l10n.supporterDate,
                  prefixIcon: const Icon(Icons.how_to_reg),
                  border: const OutlineInputBorder(),
                ),
                child: Text(
                  _supporterDate != null
                      ? DateFormat('dd.MM.yyyy').format(_supporterDate!)
                      : '—',
                ),
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _selectDcKurinDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: l10n.dcKurinDate,
                  prefixIcon: const Icon(Icons.stars),
                  border: const OutlineInputBorder(),
                ),
                child: Text(
                  _dcKurinDate != null
                      ? DateFormat('dd.MM.yyyy').format(_dcKurinDate!)
                      : '—',
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _whyThisKurinController,
              decoration: InputDecoration(
                labelText: l10n.whyThisKurin,
                prefixIcon: const Icon(Icons.question_mark),
                border: const OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _aboutThoughtsController,
              decoration: InputDecoration(
                labelText: l10n.aboutYourThoughts,
                prefixIcon: const Icon(Icons.psychology),
                border: const OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
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
