import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/models/link_courier_model.dart';

class LinkCourierFormPage extends StatefulWidget {
  final LinkCourierModel? unitToEdit;

  const LinkCourierFormPage({super.key, this.unitToEdit});

  @override
  State<LinkCourierFormPage> createState() => _LinkCourierFormPageState();
}

class _LinkCourierFormPageState extends State<LinkCourierFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _aboutFirstStepsController = TextEditingController();
  final _aboutFirstImpressionsController = TextEditingController();
  final _howToBeLinkController = TextEditingController();

  DateTime? _firstStepsDate;
  bool _isSaving = false;

  bool get _isEditing => widget.unitToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameController.text = widget.unitToEdit!.name;
      _aboutFirstStepsController.text = widget.unitToEdit!.aboutFirstSteps;
      _aboutFirstImpressionsController.text =
          widget.unitToEdit!.aboutFirstImpressions;
      _howToBeLinkController.text = widget.unitToEdit!.howToBeLink;
      _firstStepsDate = widget.unitToEdit!.firstStepsDate;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _aboutFirstStepsController.dispose();
    _aboutFirstImpressionsController.dispose();
    _howToBeLinkController.dispose();
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final data = {
        'user_id': userId,
        'name': _nameController.text.trim(),
        'first_steps_date': _firstStepsDate?.toIso8601String(),
        'about_first_steps': _aboutFirstStepsController.text.trim(),
        'about_first_impressions': _aboutFirstImpressionsController.text.trim(),
        'how_to_be_link': _howToBeLinkController.text.trim(),
      };

      if (_isEditing) {
        await Supabase.instance.client
            .from('link_couriers')
            .update(data)
            .eq('id', widget.unitToEdit!.id);
      } else {
        data['created_at'] = DateTime.now().toIso8601String();
        await Supabase.instance.client.from('link_couriers').insert(data);
      }

      if (mounted) context.pop();
    } catch (e) {
      // Error saving link courier
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
        title: Text(_isEditing ? l10n.editLinkCourier : l10n.addLinkCourier),
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
            const SizedBox(height: 16),
            TextFormField(
              controller: _howToBeLinkController,
              decoration: InputDecoration(
                labelText: l10n.howToBeLink,
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
