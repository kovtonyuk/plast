import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/models/first_unit_member_model.dart';
import '../../../shared/models/kurin_member_model.dart';

class KurinMembersPage extends StatefulWidget {
  final String kurinId;
  final String kurinName;

  const KurinMembersPage({
    super.key,
    required this.kurinId,
    required this.kurinName,
  });

  @override
  State<KurinMembersPage> createState() => _KurinMembersPageState();
}

class _KurinMembersPageState extends State<KurinMembersPage> {
  List<KurinMemberModel> _members = [];
  bool _isLoading = true;
  bool _isSaving = false;

  // Form state. The page is a single-screen form when adding/editing,
  // mirroring the UX of first_unit_members_page.
  bool _isAddingMember = false;
  bool _isEditingMember = false;
  KurinMemberModel? _editingMember;
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
    try {
      final response = await Supabase.instance.client
          .from('kurin_members')
          .select()
          .eq('kurin_id', widget.kurinId);

      final members = (response as List)
          .map((e) => KurinMemberModel.fromJson(e))
          .toList();

      if (mounted) {
        setState(() {
          _members = members;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
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

  void _startEditingMember(KurinMemberModel member) {
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
    final l10n = AppLocalizations.of(context)!;
    if (_firstNameController.text.trim().isEmpty ||
        _lastNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.required)),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final data = {
        'kurin_id': widget.kurinId,
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'date_of_birth': _dateOfBirth?.toIso8601String(),
        'address': _addressController.text.trim(),
        'phone': _phoneController.text.trim(),
        'member_type': _memberType?.name,
      };

      if (_isEditingMember) {
        await Supabase.instance.client
            .from('kurin_members')
            .update(data)
            .eq('id', _editingMember!.id);
      } else {
        await Supabase.instance.client.from('kurin_members').insert(data);
      }

      await _loadMembers();

      if (mounted) {
        setState(() {
          _isAddingMember = false;
          _isEditingMember = false;
          _editingMember = null;
        });
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

  Future<bool> _confirmDeleteMember(
    KurinMemberModel member,
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
          .from('kurin_members')
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
        title: Text('${l10n.kurinMembers} - ${widget.kurinName}'),
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
                          _isEditingMember
                              ? l10n.editKurinMember
                              : l10n.addKurinMember,
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
              ...(_members.map((m) => _buildMemberCard(m, l10n))),
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

  Widget _buildMemberCard(KurinMemberModel member, AppLocalizations l10n) {
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
        confirmDismiss: (_) => _confirmDeleteMember(member, l10n),
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
