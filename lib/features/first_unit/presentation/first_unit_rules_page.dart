import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/models/first_unit_rule_model.dart';

class FirstUnitRulesPage extends StatefulWidget {
  final String firstUnitId;
  final String firstUnitName;

  const FirstUnitRulesPage({
    super.key,
    required this.firstUnitId,
    required this.firstUnitName,
  });

  @override
  State<FirstUnitRulesPage> createState() => _FirstUnitRulesPageState();
}

class _FirstUnitRulesPageState extends State<FirstUnitRulesPage> {
  List<FirstUnitRuleModel> _rules = [];
  bool _isLoading = true;
  bool _isSaving = false;

  // Form state
  bool _isAddingRule = false;
  bool _isEditingRule = false;
  FirstUnitRuleModel? _editingRule;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRules();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadRules() async {
    final response = await Supabase.instance.client
        .from('first_unit_rules')
        .select()
        .eq('first_unit_id', widget.firstUnitId)
        .order('order_index');

    final rules = (response as List)
        .map((e) => FirstUnitRuleModel.fromJson(e))
        .toList();

    if (mounted) {
      setState(() {
        _rules = rules;
        _isLoading = false;
      });
    }
  }

  void _startAddingRule() {
    setState(() {
      _isAddingRule = true;
      _isEditingRule = false;
      _editingRule = null;
      _titleController.clear();
      _descriptionController.clear();
    });
  }

  void _startEditingRule(FirstUnitRuleModel rule) {
    setState(() {
      _isAddingRule = true;
      _isEditingRule = true;
      _editingRule = rule;
      _titleController.text = rule.title;
      _descriptionController.text = rule.description;
    });
  }

  void _cancelRuleForm() {
    setState(() {
      _isAddingRule = false;
      _isEditingRule = false;
      _editingRule = null;
    });
  }

  Future<void> _saveRule() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.required)),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final data = {
        'first_unit_id': widget.firstUnitId,
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'order_index': _editingRule?.orderIndex ?? _rules.length,
      };

      if (_isEditingRule) {
        await Supabase.instance.client
            .from('first_unit_rules')
            .update(data)
            .eq('id', _editingRule!.id);
      } else {
        await Supabase.instance.client.from('first_unit_rules').insert(data);
      }

      await _loadRules();

      if (mounted) {
        setState(() {
          _isAddingRule = false;
          _isEditingRule = false;
          _editingRule = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.profileSaved)),
        );
      }
    } catch (e) {
      // Error saving rule
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.error}: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<bool> _confirmDeleteRule(FirstUnitRuleModel rule) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.delete),
        content: Text(AppLocalizations.of(context)!.confirmDelete),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context)!.delete,
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await Supabase.instance.client
          .from('first_unit_rules')
          .delete()
          .eq('id', rule.id);
      _loadRules();
    }
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.rules} - ${widget.firstUnitName}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_isAddingRule) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _isEditingRule ? l10n.editRule : l10n.addRule,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: _cancelRuleForm,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: '${l10n.ruleTitle} *',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: l10n.ruleDescription,
                        border: const OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveRule,
                        child: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(l10n.save),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_rules.isEmpty && !_isAddingRule)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  l10n.noData,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            )
          else if (!_isAddingRule)
            ...(_rules.map((rule) => _buildRuleCard(rule))),
        ],
      ),
      floatingActionButton: _isAddingRule
          ? null
          : FloatingActionButton(
              onPressed: _startAddingRule,
              child: const Icon(Icons.add),
            ),
    );
  }

  Widget _buildRuleCard(FirstUnitRuleModel rule) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Dismissible(
        key: Key(rule.id),
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
        confirmDismiss: (_) => _confirmDeleteRule(rule),
        child: Card(
          child: ListTile(
            onTap: () => _startEditingRule(rule),
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                '${rule.orderIndex + 1}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(rule.title),
            subtitle: rule.description.isNotEmpty
                ? Text(
                    rule.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
