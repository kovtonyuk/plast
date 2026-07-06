import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/models/first_unit_member_model.dart';
import '../../../shared/services/notification_service.dart';

class FirstUnitMembersPage extends StatefulWidget {
  final String firstUnitId;
  final String firstUnitName;

  const FirstUnitMembersPage({
    super.key,
    required this.firstUnitId,
    required this.firstUnitName,
  });

  @override
  State<FirstUnitMembersPage> createState() => _FirstUnitMembersPageState();
}

class _FirstUnitMembersPageState extends State<FirstUnitMembersPage> {
  List<FirstUnitMemberModel> _members = [];
  bool _isLoading = true;
  bool _isSaving = false;
  final _notificationService = NotificationService();

  // Form state
  bool _isAddingMember = false;
  bool _isEditingMember = false;
  FirstUnitMemberModel? _editingMember;
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  DateTime? _dateOfBirth;
  MemberType? _memberType;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadMembers() async {
    final response = await Supabase.instance.client
        .from('first_unit_members')
        .select()
        .eq('first_unit_id', widget.firstUnitId);

    final members = (response as List)
        .map((e) => FirstUnitMemberModel.fromJson(e))
        .toList();

    if (mounted) {
      setState(() {
        _members = members;
        _isLoading = false;
      });
    }
  }

  void _startAddingMember() {
    setState(() {
      _isAddingMember = true;
      _isEditingMember = false;
      _editingMember = null;
      _firstNameController.clear();
      _lastNameController.clear();
      _addressController.clear();
      _phoneController.clear();
      _dateOfBirth = null;
      _memberType = null;
    });
  }

  void _startEditingMember(FirstUnitMemberModel member) {
    setState(() {
      _isAddingMember = true;
      _isEditingMember = true;
      _editingMember = member;
      _firstNameController.text = member.firstName;
      _lastNameController.text = member.lastName;
      _addressController.text = member.address;
      _phoneController.text = member.phone;
      _dateOfBirth = member.dateOfBirth;
      _memberType = member.memberType;
    });
  }

  void _cancelMemberForm() {
    setState(() {
      _isAddingMember = false;
      _isEditingMember = false;
      _editingMember = null;
    });
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _dateOfBirth = picked);
    }
  }

  Future<void> _saveMember() async {
    if (_firstNameController.text.trim().isEmpty ||
        _lastNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppLocalizations.of(context)!.required}')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final data = {
        'first_unit_id': widget.firstUnitId,
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'date_of_birth': _dateOfBirth?.toIso8601String(),
        'address': _addressController.text.trim(),
        'phone': _phoneController.text.trim(),
        'member_type': _memberType?.name,
      };

      if (_isEditingMember) {
        await Supabase.instance.client
            .from('first_unit_members')
            .update(data)
            .eq('id', _editingMember!.id);

        await _notificationService.cancelBirthdayNotificationsFull(
          _editingMember!.id,
        );
      } else {
        await Supabase.instance.client.from('first_unit_members').insert(data);
      }

      await _loadMembers();

      if (_dateOfBirth != null) {
        final savedMembers = await Supabase.instance.client
            .from('first_unit_members')
            .select()
            .eq('first_name', _firstNameController.text.trim())
            .eq('last_name', _lastNameController.text.trim())
            .eq('first_unit_id', widget.firstUnitId);

        if (savedMembers.isNotEmpty) {
          final newMember = FirstUnitMemberModel.fromJson(savedMembers.first);
          await _notificationService.scheduleBirthdayNotificationFull(
            newMember,
          );
        }
      }

      if (mounted) {
        setState(() {
          _isAddingMember = false;
          _isEditingMember = false;
          _editingMember = null;
        });
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

  Future<bool> _confirmDeleteMember(FirstUnitMemberModel member) async {
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
            child: Text(
              AppLocalizations.of(context)!.delete,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _notificationService.cancelBirthdayNotificationsFull(member.id);
      await Supabase.instance.client
          .from('first_unit_members')
          .delete()
          .eq('id', member.id);
      _loadMembers();
    }
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.members} - ${widget.firstUnitName}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_isAddingMember) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _isEditingMember ? l10n.editMember : l10n.addMember,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: _cancelMemberForm,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _firstNameController,
                            decoration: InputDecoration(
                              labelText: '${l10n.memberFirstName} *',
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _lastNameController,
                            decoration: InputDecoration(
                              labelText: '${l10n.memberLastName} *',
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: _selectDate,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: l10n.memberDateOfBirth,
                          prefixIcon: const Icon(Icons.cake),
                          border: const OutlineInputBorder(),
                        ),
                        child: Text(
                          _dateOfBirth != null
                              ? DateFormat('dd.MM.yyyy').format(_dateOfBirth!)
                              : '—',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: l10n.memberAddress,
                        prefixIcon: const Icon(Icons.location_on),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: l10n.memberPhone,
                        prefixIcon: const Icon(Icons.phone),
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<MemberType>(
                      initialValue: _memberType,
                      decoration: InputDecoration(
                        labelText: l10n.memberType,
                        prefixIcon: const Icon(Icons.badge),
                        border: const OutlineInputBorder(),
                      ),
                      items: MemberType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(_getMemberTypeLabel(type, l10n)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _memberType = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveMember,
                        child: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
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

          if (!_isAddingMember) ...[
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_members.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    l10n.noData,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              )
            else
              ...(_members.map((member) => _buildMemberCard(member, l10n))),
          ],
        ],
      ),
      floatingActionButton: _isAddingMember
          ? null
          : FloatingActionButton(
              onPressed: _startAddingMember,
              child: const Icon(Icons.add),
            ),
    );
  }

  Widget _buildMemberCard(FirstUnitMemberModel member, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Dismissible(
        key: Key(member.id),
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
        confirmDismiss: (_) => _confirmDeleteMember(member),
        child: Card(
          child: ListTile(
            onTap: () => _startEditingMember(member),
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.person, color: Colors.white),
            ),
            title: Text('${member.firstName} ${member.lastName}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (member.memberType != null)
                  Text(_getMemberTypeLabel(member.memberType!, l10n)),
                if (member.dateOfBirth != null)
                  Text(
                    '${l10n.dateOfBirth}: ${DateFormat('dd.MM.yyyy').format(member.dateOfBirth!)}',
                  ),
                if (member.address.isNotEmpty)
                  Text('${l10n.memberAddress}: ${member.address}'),
                if (member.phone.isNotEmpty)
                  Text('${l10n.memberPhone}: ${member.phone}'),
              ],
            ),
            isThreeLine: member.memberType != null ||
                (member.dateOfBirth != null && member.address.isNotEmpty),
          ),
        ),
      ),
    );
  }

  String _getMemberTypeLabel(MemberType type, AppLocalizations l10n) {
    switch (type) {
      case MemberType.novak:
        return l10n.memberTypeNovak;
      case MemberType.ptasha:
        return l10n.memberTypePtasha;
      case MemberType.yunak:
        return l10n.memberTypeYunak;
      case MemberType.pidvykhovnyk:
        return l10n.memberTypePidvykhovnyk;
      case MemberType.vykhovnyk:
        return l10n.memberTypeVykhovnyk;
    }
  }
}
