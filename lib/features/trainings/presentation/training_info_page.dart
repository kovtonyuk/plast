import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/widgets/date_picker_tile.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/models/training_entry_model.dart';

class TrainingInfoPage extends StatefulWidget {
  const TrainingInfoPage({super.key});

  @override
  State<TrainingInfoPage> createState() => _TrainingInfoPageState();
}

class _TrainingInfoPageState extends State<TrainingInfoPage> {
  bool _isLoading = true;
  bool _isSaving = false;
  List<TrainingEntryModel> _entries = [];

  // Expanded state for accordions
  final Map<String, bool> _expanded = {};

  // Form fields for adding/editing entry
  bool _isAddingEntry = false;
  TrainingEntryModel? _editingEntry;
  String? _selectedType;
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final _commandantController = TextEditingController();
  final _commentsController = TextEditingController();
  final _roleController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  // Categories for sections
  static const _uppTypes = ['vvp', 'vppt'];
  static const _upnTypes = ['rov', 'rovMace', 'rovNest', 'rovLeaders'];
  static const _upyTypes = ['kvv', 'kvz', 'kvpt', 'kvpv', 'lsh'];
  static const _otherTypes = ['kvdch'];

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _commandantController.dispose();
    _commentsController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  Future<void> _loadEntries() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final response = await Supabase.instance.client
        .from('training_entries')
        .select()
        .eq('user_id', userId)
        .order('start_date', ascending: false);

    final entries = (response as List)
        .map((e) => TrainingEntryModel.fromJson(e))
        .toList();

    setState(() {
      _entries = entries;
      _isLoading = false;
    });
  }

  List<TrainingEntryModel> _getEntriesForType(String type) {
    return _entries.where((e) => e.trainingType == type).toList();
  }

  List<TrainingEntryModel> _getCustomEntries() {
    return _entries.where((e) => e.trainingType.startsWith('custom_')).toList();
  }

  void _startAddingEntry({TrainingEntryModel? entry, bool isCustom = false}) {
    setState(() {
      _isAddingEntry = true;
      _editingEntry = entry;
      _selectedType = isCustom ? 'custom_' : null;
      if (entry != null) {
        // Editing existing entry - for built-in types, name is not editable
        _nameController.text = entry.trainingType.startsWith('custom_')
            ? entry.trainingType.substring(7)
            : '';
        _numberController.text = entry.number;
        _commandantController.text = entry.commandant;
        _commentsController.text = entry.comments;
        _roleController.text = entry.trainingType.startsWith('custom_')
            ? entry.role
            : '';
        _startDate = entry.startDate;
        _endDate = entry.endDate;
      } else {
        _nameController.clear();
        _numberController.clear();
        _commandantController.clear();
        _commentsController.clear();
        _roleController.clear();
        _startDate = null;
        _endDate = null;
      }
    });
  }

  void _cancelAddingEntry() {
    setState(() {
      _isAddingEntry = false;
      _selectedType = null;
      _startDate = null;
      _endDate = null;
    });
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  Future<void> _saveEntry() async {
    final isEditing = _editingEntry != null;
    final showNameField = isEditing
        ? _editingEntry!.trainingType.startsWith('custom_')
        : (_selectedType?.startsWith('custom_') ?? false);

    if (!isEditing && showNameField && _nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.required)),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final data = {
        'number': _numberController.text.trim(),
        'start_date': _startDate?.toIso8601String(),
        'end_date': _endDate?.toIso8601String(),
        'commandant': _commandantController.text.trim(),
        'comments': _commentsController.text.trim(),
        'role': _roleController.text.trim(),
      };

      if (_editingEntry != null) {
        // Update existing entry
        await Supabase.instance.client
            .from('training_entries')
            .update(data)
            .eq('id', _editingEntry!.id);
      } else {
        // Insert new entry
        final customTypeName = 'custom_${_nameController.text.trim()}';
        data['user_id'] = userId;
        data['training_type'] = customTypeName;
        await Supabase.instance.client.from('training_entries').insert(data);
      }

      if (mounted) {
        setState(() {
          _isAddingEntry = false;
          _editingEntry = null;
        });
        _loadEntries();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.profileSaved)),
        );
      }
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

  String _getTrainingLabel(String type, AppLocalizations l10n) {
    switch (type) {
      case 'kvdch':
        return l10n.toolKVDCH;
      case 'vvp':
        return l10n.toolVVP;
      case 'vppt':
        return l10n.toolVPPT;
      case 'rov':
        return l10n.toolROV;
      case 'rovMace':
        return l10n.toolROVMace;
      case 'rovNest':
        return l10n.toolROVNesting;
      case 'rovLeaders':
        return l10n.toolROVConductors;
      case 'kvv':
        return l10n.toolKVV;
      case 'kvz':
        return l10n.toolKVZ;
      case 'kvpt':
        return l10n.toolKVPT;
      case 'kvpv':
        return l10n.toolKVPV;
      case 'lsh':
        return l10n.toolLSH;
      default:
        if (type.startsWith('custom_')) {
          return type.substring(7);
        }
        return type;
    }
  }

  String _getAbbreviation(String type, AppLocalizations l10n) {
    switch (type) {
      case '':
        return AppLocalizations.of(context)!.autumn;
      case 'kvdch':
        return 'КВДЧ';
      case 'vvp':
        return 'ВВП';
      case 'vppt':
        return 'ВППТ';
      case 'rov':
        return 'РОВ';
      case 'rovMace':
        return 'РОВ булавних';
      case 'rovNest':
        return 'РОВ гніздових';
      case 'rovLeaders':
        return 'РОВ провідника таборів';
      case 'kvv':
        return 'КВВ';
      case 'kvz':
        return 'КВЗ';
      case 'kvpt':
        return 'КВПТ';
      case 'kvpv':
        return 'КВПВ';
      case 'lsh':
        return 'ЛШ';
      default:
        if (type.startsWith('custom_')) {
          return type.substring(7);
        }
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.trainingInfo),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.trainingInfo),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isAddingEntry ? _buildAddForm(l10n) : _buildList(l10n),
      floatingActionButton: _isAddingEntry
          ? null
          : FloatingActionButton(
              onPressed: () => _startAddingEntry(isCustom: true),
              child: const Icon(Icons.add),
            ),
    );
  }

  Widget _buildAddForm(AppLocalizations l10n) {
    final isEditing = _editingEntry != null;
    // Only show name field for custom types
    final showNameField = isEditing
        ? _editingEntry!.trainingType.startsWith('custom_')
        : (_selectedType?.startsWith('custom_') ?? false);
    // Only show role field for custom types
    final showRoleField = isEditing
        ? _editingEntry!.trainingType.startsWith('custom_')
        : (_selectedType?.startsWith('custom_') ?? false);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: _cancelAddingEntry,
            ),
            Text(
              isEditing ? l10n.edit : l10n.add,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        if (showNameField) ...[
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: l10n.eventTitle,
              prefixIcon: const Icon(Icons.title),
            ),
            validator: (value) {
              if (!isEditing && (value == null || value.trim().isEmpty)) {
                return l10n.required;
              }
              return null;
            },
          ),
        ],
        const SizedBox(height: 16),
        TextFormField(
          controller: _numberController,
          decoration: InputDecoration(
            labelText: l10n.kvdchNumber,
            prefixIcon: const Icon(Icons.numbers),
          ),
        ),
        const SizedBox(height: 16),
        DatePickerTile(
          label: l10n.startDate,
          date: _startDate,
          onTap: _selectStartDate,
        ),
        const SizedBox(height: 16),
        DatePickerTile(
          label: l10n.endDate,
          date: _endDate,
          onTap: _selectEndDate,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _commandantController,
          decoration: InputDecoration(
            labelText: l10n.commandant,
            prefixIcon: const Icon(Icons.person),
          ),
        ),
        if (showRoleField) ...[
          const SizedBox(height: 16),
          TextFormField(
            controller: _roleController,
            decoration: const InputDecoration(
              labelText: 'В ролі кого',
              prefixIcon: Icon(Icons.badge),
            ),
          ),
        ],
        const SizedBox(height: 16),
        TextFormField(
          controller: _commentsController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: l10n.comments,
            prefixIcon: const Icon(Icons.comment),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _isSaving ? null : _saveEntry,
          child: _isSaving
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.save),
        ),
      ],
    );
  }

  Widget _buildList(AppLocalizations l10n) {
    return Form(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // КВДЧ
          _buildAccordion(
            key: 'kvdch',
            title: l10n.toolKVDCH,
            children: _getEntriesForType('kvdch'),
            l10n: l10n,
          ),
          const SizedBox(height: 8),

          // УПП Section Header
          _buildSectionHeader(
            '${l10n.categoryUPP} - ${l10n.categoryUPPDesc}',
            l10n,
          ),
          const SizedBox(height: 4),
          _buildAccordion(
            key: 'vvp',
            title: l10n.toolVVP,
            children: _getEntriesForType('vvp'),
            l10n: l10n,
          ),
          const SizedBox(height: 4),
          _buildAccordion(
            key: 'vppt',
            title: l10n.toolVPPT,
            children: _getEntriesForType('vppt'),
            l10n: l10n,
          ),
          const SizedBox(height: 8),

          // УПН Section Header
          _buildSectionHeader(
            '${l10n.categoryUPN} - ${l10n.categoryUPNDesc}',
            l10n,
          ),
          const SizedBox(height: 4),
          _buildAccordion(
            key: 'rov',
            title: l10n.toolROV,
            children: _getEntriesForType('rov'),
            l10n: l10n,
          ),
          const SizedBox(height: 4),
          _buildAccordion(
            key: 'rovMace',
            title: l10n.toolROVMace,
            children: _getEntriesForType('rovMace'),
            l10n: l10n,
          ),
          const SizedBox(height: 4),
          _buildAccordion(
            key: 'rovNest',
            title: l10n.toolROVNesting,
            children: _getEntriesForType('rovNest'),
            l10n: l10n,
          ),
          const SizedBox(height: 4),
          _buildAccordion(
            key: 'rovLeaders',
            title: l10n.toolROVConductors,
            children: _getEntriesForType('rovLeaders'),
            l10n: l10n,
          ),
          const SizedBox(height: 8),

          // УПЮ Section Header
          _buildSectionHeader(
            '${l10n.categoryUPY} - ${l10n.categoryUPYDesc}',
            l10n,
          ),
          const SizedBox(height: 4),
          _buildAccordion(
            key: 'kvv',
            title: l10n.toolKVV,
            children: _getEntriesForType('kvv'),
            l10n: l10n,
          ),
          const SizedBox(height: 4),
          _buildAccordion(
            key: 'kvz',
            title: l10n.toolKVZ,
            children: _getEntriesForType('kvz'),
            l10n: l10n,
          ),
          const SizedBox(height: 4),
          _buildAccordion(
            key: 'kvpt',
            title: l10n.toolKVPT,
            children: _getEntriesForType('kvpt'),
            l10n: l10n,
          ),
          const SizedBox(height: 4),
          _buildAccordion(
            key: 'kvpv',
            title: l10n.toolKVPV,
            children: _getEntriesForType('kvpv'),
            l10n: l10n,
          ),
          const SizedBox(height: 4),
          _buildAccordion(
            key: 'lsh',
            title: l10n.toolLSH,
            children: _getEntriesForType('lsh'),
            l10n: l10n,
          ),
          const SizedBox(height: 8),

          // Custom entries
          if (_getCustomEntries().isNotEmpty) ...[
            const Divider(thickness: 2),
            _buildSectionHeader(l10n.training, l10n),
            const SizedBox(height: 4),
            ..._getCustomEntries().map((entry) => _buildEntryCard(entry, l10n)),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildAccordion({
    required String key,
    required String title,
    required List<TrainingEntryModel> children,
    required AppLocalizations l10n,
  }) {
    final isExpanded = _expanded[key] ?? false;
    final abbr = _getAbbreviation(key, l10n);
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        abbr,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(title),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        child: const Icon(Icons.info_outline, size: 18),
                      ),
                    ],
                  ),
                ),
                if (children.isEmpty)
                  IconButton(
                    icon: Icon(
                      Icons.add,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: () {
                      setState(() {
                        _expanded[key] = true;
                        _editingEntry = null;
                        _isAddingEntry = true;
                        _selectedType = key;
                        _nameController.clear();
                        _numberController.clear();
                        _commandantController.clear();
                        _commentsController.clear();
                        _roleController.clear();
                        _startDate = null;
                        _endDate = null;
                      });
                    },
                  ),
              ],
            ),
            trailing: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
            onTap: () => setState(() {
              if (isExpanded) {
                _expanded[key] = false;
              } else {
                for (final k in _expanded.keys) {
                  _expanded[k] = false;
                }
                _expanded[key] = true;
              }
            }),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: children.isEmpty
                  ? Text(l10n.noData, style: TextStyle(color: Colors.grey[600]))
                  : Column(
                      children: children
                          .map((e) => _buildEntryCard(e, l10n))
                          .toList(),
                    ),
            ),
        ],
      ),
    );
  }

  Widget _buildEntryCard(TrainingEntryModel entry, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Dismissible(
        key: Key(entry.id),
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
        confirmDismiss: (_) => _confirmDelete(entry, l10n),
        child: Card(
          child: ListTile(
            onTap: () => _startAddingEntry(entry: entry),
            title: Text(_getTrainingLabel(entry.trainingType, l10n)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (entry.number.isNotEmpty) Text(entry.number),
                if (entry.trainingType.startsWith('custom_') &&
                    entry.role.isNotEmpty)
                  Text('В ролі: ${entry.role}'),
                if (entry.startDate != null)
                  Text(
                    entry.endDate != null
                        ? '${DateFormat('dd.MM.yyyy').format(entry.startDate!)} - ${DateFormat('dd.MM.yyyy').format(entry.endDate!)}'
                        : DateFormat('dd.MM.yyyy').format(entry.startDate!),
                  ),
                if (entry.commandant.isNotEmpty)
                  Text('${l10n.commandant}: ${entry.commandant}'),
                if (entry.comments.isNotEmpty)
                  Text(
                    entry.comments,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
            isThreeLine: true,
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(
    TrainingEntryModel entry,
    AppLocalizations l10n,
  ) async {
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
          .from('training_entries')
          .delete()
          .eq('id', entry.id);
      _loadEntries();
    }
    return confirmed ?? false;
  }
}
