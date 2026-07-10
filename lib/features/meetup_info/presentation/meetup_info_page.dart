import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/widgets/date_picker_tile.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/models/first_unit_member_model.dart';
import '../../../shared/models/kurin_member_model.dart';
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
  final _commentController = TextEditingController();
  DateTime? _date;

  // Selected attendees (id -> display name). Mixed from
  // first_unit_members and kurin_members; only ids are persisted.
  final Map<String, String> _selectedAttendees = {};

  // User's first_unit.id and your_kurin.id (looked up once on form open).
  String? _firstUnitId;
  String? _kurinId;

  @override
  void initState() {
    super.initState();
    _loadMeetups();
  }

  @override
  void dispose() {
    _themeController.dispose();
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

  // Resolves attendee display names for a list of meetups.
  // Single batched query per source — avoids N+1 calls.
  Future<Map<String, String>> _loadAttendeeNames(
    List<MeetupInfoModel> meetups,
  ) async {
    final ids = <String>{};
    for (final m in meetups) {
      ids.addAll(m.attendeeIds);
    }
    if (ids.isEmpty) return const {};

    final result = <String, String>{};

    // Try first_unit_members first.
    final fu = await Supabase.instance.client
        .from('first_unit_members')
        .select('id, first_name, last_name')
        .inFilter('id', ids.toList());
    final foundFu = <String>{};
    for (final row in (fu as List)) {
      final id = row['id'] as String;
      foundFu.add(id);
      result[id] = '${row['first_name']} ${row['last_name']}'.trim();
    }

    // Anything not in first_unit_members — look in kurin_members.
    final missing = ids.difference(foundFu).toList();
    if (missing.isNotEmpty) {
      final km = await Supabase.instance.client
          .from('kurin_members')
          .select('id, first_name, last_name')
          .inFilter('id', missing);
      for (final row in (km as List)) {
        final id = row['id'] as String;
        result[id] = '${row['first_name']} ${row['last_name']}'.trim();
      }
    }

    return result;
  }

  void _startAddingMeetup() {
    setState(() {
      _isAddingMeetup = true;
      _editingMeetup = null;
      _themeController.clear();
      _commentController.clear();
      _date = null;
      _selectedAttendees.clear();
      _firstUnitId = null;
      _kurinId = null;
    });
    _resolveUserUnits();
  }

  void _startEditingMeetup(MeetupInfoModel meetup) async {
    setState(() {
      _isAddingMeetup = false;
      _editingMeetup = meetup;
      _themeController.text = meetup.theme;
      _commentController.text = meetup.comment;
      _date = meetup.date;
      _selectedAttendees.clear();
      _firstUnitId = null;
      _kurinId = null;
    });
    _resolveUserUnits();
    final names = await _loadAttendeeNames([meetup]);
    if (!mounted) return;
    setState(() {
      for (final id in meetup.attendeeIds) {
        _selectedAttendees[id] = names[id] ?? id.substring(0, 8);
      }
    });
  }

  // Look up the user's first_unit and your_kurin rows so we know where
  // to pull attendees from. A user typically has at most one of each.
  Future<void> _resolveUserUnits() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    try {
      final fu = await Supabase.instance.client
          .from('first_units')
          .select('id')
          .eq('user_id', userId)
          .limit(1);
      final km = await Supabase.instance.client
          .from('your_kurin')
          .select('id')
          .eq('user_id', userId)
          .limit(1);
      if (!mounted) return;
      setState(() {
        _firstUnitId = (fu as List).isNotEmpty
            ? fu.first['id'] as String
            : null;
        _kurinId = (km as List).isNotEmpty ? km.first['id'] as String : null;
      });
    } catch (_) {
      // If the table isn't there or user has no unit — just leave ids null
      // and hide the corresponding picker button.
    }
  }

  void _cancelEditing() {
    setState(() {
      _isAddingMeetup = false;
      _editingMeetup = null;
      _themeController.clear();
      _commentController.clear();
      _date = null;
      _selectedAttendees.clear();
      _firstUnitId = null;
      _kurinId = null;
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
        'attendees': '',
        'attendee_ids': _selectedAttendees.keys.toList(),
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
          _commentController.clear();
          _date = null;
          _selectedAttendees.clear();
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
        _buildAttendeesSection(l10n),
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

  Widget _buildAttendeesSection(AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.group, size: 20),
                const SizedBox(width: 8),
                Text(
                  l10n.meetupAttendees,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Add buttons — only show sources that exist for the user.
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (_firstUnitId != null)
                  OutlinedButton.icon(
                    onPressed: () => _pickFromFirstUnit(l10n),
                    icon: const Icon(Icons.school, size: 18),
                    label: Text(l10n.meetupSelectFromFirstUnit),
                  ),
                if (_kurinId != null)
                  OutlinedButton.icon(
                    onPressed: () => _pickFromKurin(l10n),
                    icon: const Icon(Icons.groups, size: 18),
                    label: Text(l10n.meetupSelectFromKurin),
                  ),
              ],
            ),
            if (_firstUnitId == null && _kurinId == null) ...[
              const SizedBox(height: 8),
              Text(
                l10n.meetupNoAttendeesAvailable,
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ],
            const Divider(height: 24),
            Text(
              l10n.meetupSelectedAttendees,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            if (_selectedAttendees.isEmpty)
              Text(
                l10n.meetupAttendeesEmpty,
                style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
              )
            else
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _selectedAttendees.entries.map((e) {
                  return InputChip(
                    label: Text(e.value),
                    onDeleted: () {
                      setState(() => _selectedAttendees.remove(e.key));
                    },
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFromFirstUnit(AppLocalizations l10n) async {
    if (_firstUnitId == null) return;
    final response = await Supabase.instance.client
        .from('first_unit_members')
        .select('id, first_name, last_name, member_type')
        .eq('first_unit_id', _firstUnitId!);
    final members = (response as List)
        .map((e) => FirstUnitMemberModel.fromJson(e))
        .toList();
    if (!mounted) return;
    final picked = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _AttendeePickerSheet(
        title: l10n.meetupSelectFromFirstUnit,
        members: members,
        alreadySelected: _selectedAttendees.keys.toSet(),
      ),
    );
    if (picked != null) {
      setState(() {
        for (final id in picked) {
          final m = members.firstWhere((e) => e.id == id);
          _selectedAttendees[id] = '${m.firstName} ${m.lastName}'.trim();
        }
      });
    }
  }

  Future<void> _pickFromKurin(AppLocalizations l10n) async {
    if (_kurinId == null) return;
    final response = await Supabase.instance.client
        .from('kurin_members')
        .select('id, first_name, last_name, member_type')
        .eq('kurin_id', _kurinId!);
    final members = (response as List)
        .map((e) => KurinMemberModel.fromJson(e))
        .toList();
    if (!mounted) return;
    final picked = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _AttendeePickerSheet(
        title: l10n.meetupSelectFromKurin,
        members: members,
        alreadySelected: _selectedAttendees.keys.toSet(),
      ),
    );
    if (picked != null) {
      setState(() {
        for (final id in picked) {
          final m = members.firstWhere((e) => e.id == id);
          _selectedAttendees[id] = '${m.firstName} ${m.lastName}'.trim();
        }
      });
    }
  }

  Widget _buildList(AppLocalizations l10n) {
    return FutureBuilder<Map<String, String>>(
      // Resolve display names for all meetups at once. Re-runs when the
      // list of meetups changes (e.g. after insert/delete).
      future: _loadAttendeeNames(_meetups),
      builder: (context, snapshot) {
        final names = snapshot.data ?? const <String, String>{};
        if (_meetups.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.groups, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  l10n.noData,
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _meetups.length,
          itemBuilder: (context, index) {
            return _buildMeetupCard(_meetups[index], names, l10n);
          },
        );
      },
    );
  }

  Widget _buildMeetupCard(
    MeetupInfoModel meetup,
    Map<String, String> names,
    AppLocalizations l10n,
  ) {
    // Show up to 3 attendee names, then "+N" for the rest. Avoids a
    // huge text block when many members are selected.
    final attendeeNames = meetup.attendeeIds
        .map((id) => names[id] ?? id.substring(0, 8))
        .toList();
    final shown = attendeeNames.take(3).toList();
    final extra = attendeeNames.length - shown.length;

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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          DateFormat('dd.MM.yyyy').format(meetup.date),
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (attendeeNames.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.group, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            extra > 0
                                ? '${shown.join(', ')} +$extra'
                                : shown.join(', '),
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

/// Bottom sheet for selecting attendees. Already-selected members are
/// hidden from the list (per requirement) and "Select all" only picks
/// the visible ones. Returns the picked ids (in the order tapped).
class _AttendeePickerSheet extends StatefulWidget {
  final String title;
  final List<dynamic> members; // FirstUnitMemberModel | KurinMemberModel
  final Set<String> alreadySelected;

  const _AttendeePickerSheet({
    required this.title,
    required this.members,
    required this.alreadySelected,
  });

  @override
  State<_AttendeePickerSheet> createState() => _AttendeePickerSheetState();
}

class _AttendeePickerSheetState extends State<_AttendeePickerSheet> {
  final Set<String> _picked = {};

  String _displayName(dynamic m) =>
      '${m.firstName} ${m.lastName}'.trim();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Filter out members that are already selected — per requirement
    // "якщо він вже був вибраний, то щоб зникав вже з вибору".
    final available = widget.members
        .where((m) => !widget.alreadySelected.contains(m.id))
        .toList();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (available.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          if (_picked.length == available.length) {
                            _picked.clear();
                          } else {
                            _picked
                              ..clear()
                              ..addAll(available.map((m) => m.id as String));
                          }
                        });
                      },
                      child: Text(
                        _picked.length == available.length
                            ? l10n.cancel
                            : l10n.add,
                      ),
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: available.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        l10n.meetupAttendeesEmpty,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: available.length,
                      itemBuilder: (context, i) {
                        final m = available[i];
                        final id = m.id as String;
                        final isPicked = _picked.contains(id);
                        return CheckboxListTile(
                          value: isPicked,
                          onChanged: (v) {
                            setState(() {
                              if (v == true) {
                                _picked.add(id);
                              } else {
                                _picked.remove(id);
                              }
                            });
                          },
                          title: Text(_displayName(m)),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, null),
                      child: Text(l10n.cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _picked.isEmpty
                          ? null
                          : () => Navigator.pop(context, _picked.toList()),
                      child: Text(
                        l10n.save,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
