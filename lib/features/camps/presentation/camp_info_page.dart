import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/widgets/date_picker_tile.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/models/camp_model.dart';

class CampInfoPage extends StatefulWidget {
  const CampInfoPage({super.key});

  @override
  State<CampInfoPage> createState() => _CampInfoPageState();
}

class _CampInfoPageState extends State<CampInfoPage> {
  bool _isLoading = true;
  bool _isSaving = false;
  List<CampModel> _camps = [];

  bool _isAddingCamp = false;
  CampModel? _editingCamp;
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _resultCommentController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  CampUlad _selectedUlad = CampUlad.upj;
  CampLevel _selectedLevel = CampLevel.stanych;
  CampRole _selectedRole = CampRole.uchasnyk;
  CampResultType _selectedResultType = CampResultType.stupin;

  @override
  void initState() {
    super.initState();
    _loadCamps();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _resultCommentController.dispose();
    super.dispose();
  }

  Future<void> _loadCamps() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await Supabase.instance.client
          .from('camps')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final camps = (response as List).map((e) => CampModel.fromJson(e)).toList();

      if (mounted) {
        setState(() {
          _camps = camps;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _startAddingCamp() {
    setState(() {
      _isAddingCamp = true;
      _editingCamp = null;
      _nameController.clear();
      _locationController.clear();
      _resultCommentController.clear();
      _startDate = null;
      _endDate = null;
      _selectedUlad = CampUlad.upj;
      _selectedLevel = CampLevel.stanych;
      _selectedRole = CampRole.uchasnyk;
      _selectedResultType = CampResultType.stupin;
    });
  }

  void _startEditingCamp(CampModel camp) {
    setState(() {
      _isAddingCamp = false;
      _editingCamp = camp;
      _nameController.text = camp.name;
      _locationController.text = camp.location;
      _resultCommentController.text = camp.resultComment;
      _startDate = camp.startDate;
      _endDate = camp.endDate;
      _selectedUlad = camp.ulad;
      _selectedLevel = camp.level;
      _selectedRole = camp.role;
      _selectedResultType = camp.resultType;
    });
  }

  void _cancelEditing() {
    setState(() {
      _isAddingCamp = false;
      _editingCamp = null;
      _nameController.clear();
      _locationController.clear();
      _resultCommentController.clear();
      _startDate = null;
      _endDate = null;
      _selectedUlad = CampUlad.upj;
      _selectedLevel = CampLevel.stanych;
      _selectedRole = CampRole.uchasnyk;
      _selectedResultType = CampResultType.stupin;
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

  Future<void> _saveCamp() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.required)),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final data = {
        'name': _nameController.text.trim(),
        'ulad': _selectedUlad.name,
        'level': _selectedLevel.name,
        'start_date': _startDate?.toIso8601String().split('T').first,
        'end_date': _endDate?.toIso8601String().split('T').first,
        'location': _locationController.text.trim(),
        'role': _selectedRole.name,
        'result_type': _selectedResultType.name,
        'result_comment': _resultCommentController.text.trim(),
      };

      if (_editingCamp != null) {
        await Supabase.instance.client
            .from('camps')
            .update(data)
            .eq('id', _editingCamp!.id);
      } else {
        data['user_id'] = userId;
        await Supabase.instance.client.from('camps').insert(data);
      }

      if (mounted) {
        setState(() {
          _isAddingCamp = false;
          _editingCamp = null;
          _nameController.clear();
          _locationController.clear();
          _resultCommentController.clear();
          _startDate = null;
          _endDate = null;
          _selectedUlad = CampUlad.upj;
          _selectedLevel = CampLevel.stanych;
          _selectedRole = CampRole.uchasnyk;
          _selectedResultType = CampResultType.stupin;
        });
        _loadCamps();
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

  Future<bool> _confirmDelete(CampModel camp, AppLocalizations l10n) async {
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
          .from('camps')
          .delete()
          .eq('id', camp.id);
      _loadCamps();
    }
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.campInfo),
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
        title: Text(l10n.campInfo),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isAddingCamp || _editingCamp != null
          ? _buildForm(l10n)
          : _buildList(l10n),
      floatingActionButton: _isAddingCamp || _editingCamp != null
          ? null
          : FloatingActionButton(
              onPressed: _startAddingCamp,
              child: const Icon(Icons.add),
            ),
    );
  }

  Widget _buildForm(AppLocalizations l10n) {
    final isEditing = _editingCamp != null;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: _cancelEditing,
            ),
            Text(
              isEditing ? l10n.edit : l10n.add,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: l10n.eventTitle,
            prefixIcon: const Icon(Icons.title),
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<CampUlad>(
          value: _selectedUlad,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.ulad,
            prefixIcon: Icon(Icons.groups),
          ),
          items: CampUlad.values.map((u) {
            return DropdownMenuItem(value: u, child: Text(CampModel.uladToString(u)));
          }).toList(),
          onChanged: (v) => setState(() => _selectedUlad = v!),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<CampLevel>(
          value: _selectedLevel,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.level,
            prefixIcon: Icon(Icons.layers),
          ),
          items: CampLevel.values.map((l) {
            return DropdownMenuItem(value: l, child: Text(CampModel.levelToString(l)));
          }).toList(),
          onChanged: (v) => setState(() => _selectedLevel = v!),
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
          controller: _locationController,
          decoration: InputDecoration(
            labelText: l10n.location,
            prefixIcon: const Icon(Icons.location_on),
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<CampRole>(
          value: _selectedRole,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.role,
            prefixIcon: Icon(Icons.badge),
          ),
          items: CampRole.values.map((r) {
            return DropdownMenuItem(value: r, child: Text(CampModel.roleToString(r)));
          }).toList(),
          onChanged: (v) => setState(() => _selectedRole = v!),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<CampResultType>(
          value: _selectedResultType,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.result,
            prefixIcon: Icon(Icons.emoji_events),
          ),
          items: CampResultType.values.map((t) {
            return DropdownMenuItem(value: t, child: Text(CampModel.resultTypeToString(t)));
          }).toList(),
          onChanged: (v) => setState(() => _selectedResultType = v!),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _resultCommentController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.comments,
            prefixIcon: Icon(Icons.comment),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _isSaving ? null : _saveCamp,
          child: _isSaving
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(l10n.save),
        ),
      ],
    );
  }

  Widget _buildList(AppLocalizations l10n) {
    if (_camps.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cabin, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(l10n.noData, style: TextStyle(color: Colors.grey[600], fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _camps.length,
      itemBuilder: (context, index) {
        final camp = _camps[index];
        return _buildCampCard(camp, l10n);
      },
    );
  }

  Widget _buildCampCard(CampModel camp, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: Key(camp.id),
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
        confirmDismiss: (_) => _confirmDelete(camp, l10n),
        child: Card(
          child: InkWell(
            onTap: () => _startEditingCamp(camp),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          camp.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          CampModel.uladToString(camp.ulad),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.layers, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        CampModel.levelToString(camp.level),
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.badge, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        CampModel.roleToString(camp.role),
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  if (camp.startDate != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          camp.endDate != null
                              ? '${DateFormat('dd.MM.yyyy').format(camp.startDate!)} - ${DateFormat('dd.MM.yyyy').format(camp.endDate!)}'
                              : DateFormat('dd.MM.yyyy').format(camp.startDate!),
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                  if (camp.location.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            camp.location,
                            style: TextStyle(color: Colors.grey[600]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.emoji_events, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${CampModel.resultTypeToString(camp.resultType)}${camp.resultComment.isNotEmpty ? ' - ${camp.resultComment}' : ''}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
