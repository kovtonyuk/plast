import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/widgets/date_picker_tile.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/models/meetup_info_model.dart';

class MeetupInfoPage extends StatefulWidget {
  const MeetupInfoPage({super.key});

  @override
  State<MeetupInfoPage> createState() => _MeetupInfoPageState();
}

class _MeetupInfoPageState extends State<MeetupInfoPage> {
  bool _isLoading = true;
  bool _isSaving = false;
  List<MeetupInfoModel> _meetups = [];

  // Form state. The page is a single-screen form when adding/editing,
  // mirroring the UX of camp_info_page and training_info_page.
  bool _isAddingMeetup = false;
  MeetupInfoModel? _editingMeetup;
  final _themeController = TextEditingController();
  final _attendeesController = TextEditingController();
  final _commentController = TextEditingController();
  DateTime? _date;

  @override
  void initState() {
    super.initState();
    _loadMeetups();
  }

  @override
  void dispose() {
    _themeController.dispose();
    _attendeesController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadMeetups() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await Supabase.instance.client
          .from('meetup_info')
          .select()
          .eq('user_id', userId)
          .order('date', ascending: false);

      final list = (response as List)
          .map((e) => MeetupInfoModel.fromJson(e))
          .toList();

      if (mounted) {
        setState(() {
          _meetups = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _startAddingMeetup() {
    setState(() {
      _isAddingMeetup = true;
      _editingMeetup = null;
      _themeController.clear();
      _attendeesController.clear();
      _commentController.clear();
      _date = null;
    });
  }

  void _startEditingMeetup(MeetupInfoModel meetup) {
    setState(() {
      _isAddingMeetup = false;
      _editingMeetup = meetup;
      _themeController.text = meetup.theme;
      _attendeesController.text = meetup.attendees;
      _commentController.text = meetup.comment;
      _date = meetup.date;
    });
  }

  void _cancelEditing() {
    setState(() {
      _isAddingMeetup = false;
      _editingMeetup = null;
      _themeController.clear();
      _attendeesController.clear();
      _commentController.clear();
      _date = null;
    });
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _saveMeetup() async {
    final l10n = AppLocalizations.of(context)!;
    if (_themeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.required)),
      );
      return;
    }
    if (_date == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.required)),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final data = {
        'theme': _themeController.text.trim(),
        'date': _date!.toIso8601String().split('T').first,
        'attendees': _attendeesController.text.trim(),
        'comment': _commentController.text.trim(),
      };

      if (_editingMeetup != null) {
        await Supabase.instance.client
            .from('meetup_info')
            .update(data)
            .eq('id', _editingMeetup!.id);
      } else {
        data['user_id'] = userId;
        await Supabase.instance.client.from('meetup_info').insert(data);
      }

      if (mounted) {
        setState(() {
          _isAddingMeetup = false;
          _editingMeetup = null;
          _themeController.clear();
          _attendeesController.clear();
          _commentController.clear();
          _date = null;
        });
        _loadMeetups();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.profileSaved)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.error}: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<bool> _confirmDelete(
    MeetupInfoModel meetup,
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
          .from('meetup_info')
          .delete()
          .eq('id', meetup.id);
      _loadMeetups();
    }
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.meetupInfo),
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
        title: Text(l10n.meetupInfo),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isAddingMeetup || _editingMeetup != null
          ? _buildForm(l10n)
          : _buildList(l10n),
      floatingActionButton: _isAddingMeetup || _editingMeetup != null
          ? null
          : FloatingActionButton(
              onPressed: _startAddingMeetup,
              child: const Icon(Icons.add),
            ),
    );
  }

  Widget _buildForm(AppLocalizations l10n) {
    final isEditing = _editingMeetup != null;
    final title = isEditing ? l10n.editMeetup : l10n.addMeetup;

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
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _themeController,
          decoration: InputDecoration(
            labelText: l10n.meetupTheme,
            prefixIcon: const Icon(Icons.title),
          ),
        ),
        const SizedBox(height: 16),
        DatePickerTile(
          label: l10n.meetupDate,
          date: _date,
          onTap: _selectDate,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _attendeesController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: l10n.meetupAttendees,
            prefixIcon: const Icon(Icons.group),
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _commentController,
          maxLines: 4,
          decoration: InputDecoration(
            labelText: l10n.meetupComment,
            prefixIcon: const Icon(Icons.comment),
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _isSaving ? null : _saveMeetup,
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
    if (_meetups.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.groups, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(l10n.noData, style: TextStyle(color: Colors.grey[600], fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _meetups.length,
      itemBuilder: (context, index) {
        return _buildMeetupCard(_meetups[index], l10n);
      },
    );
  }

  Widget _buildMeetupCard(MeetupInfoModel meetup, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: Key(meetup.id),
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
        confirmDismiss: (_) => _confirmDelete(meetup, l10n),
        child: Card(
          child: InkWell(
            onTap: () => _startEditingMeetup(meetup),
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
                          meetup.theme,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          DateFormat('dd.MM.yyyy').format(meetup.date),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (meetup.attendees.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.group, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            meetup.attendees,
                            style: TextStyle(color: Colors.grey[600]),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (meetup.comment.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.comment, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            meetup.comment,
                            style: TextStyle(color: Colors.grey[600]),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
