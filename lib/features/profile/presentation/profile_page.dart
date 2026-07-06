import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/date_picker_tile.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/models/profile_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final _firstNameFocusNode = FocusNode();
  final _lastNameFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();
  final _imagePicker = ImagePicker();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _heardAboutPlastController = TextEditingController();
  final _whoNamedController = TextEditingController();
  final _stanychnyPhoneController = TextEditingController();
  final _zamistnykPhoneController = TextEditingController();
  final _referentUspUpsPhoneController = TextEditingController();
  final _referentUppUpnUpuPhoneController = TextEditingController();
  final _skarbnykPhoneController = TextEditingController();

  DateTime? _dateOfBirth;
  DateTime? _dateOfNaming;
  DateTime? _dateJoinedPlast;
  DateTime? _dateOath;
  String? _avatarUrl;
  bool _isLoading = false;
  bool _isEditing = false;
  bool _profileExistsInDb = false;
  bool _showFirstNameError = false;
  bool _showLastNameError = false;
  bool _showPhoneError = false;
  bool _showDateOfBirthError = false;
  ProfileModel? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();

    // Clear errors when user types
    _firstNameController.addListener(_clearFirstNameError);
    _lastNameController.addListener(_clearLastNameError);
    _phoneController.addListener(_clearPhoneError);
  }

  void _clearFirstNameError() {
    if (_showFirstNameError && _firstNameController.text.trim().isNotEmpty) {
      setState(() => _showFirstNameError = false);
    }
  }

  void _clearLastNameError() {
    if (_showLastNameError && _lastNameController.text.trim().isNotEmpty) {
      setState(() => _showLastNameError = false);
    }
  }

  void _clearPhoneError() {
    if (_showPhoneError && _phoneController.text.trim().isNotEmpty) {
      setState(() => _showPhoneError = false);
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 500,
      maxHeight: 500,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() => _isLoading = true);

      try {
        final userId = Supabase.instance.client.auth.currentUser!.id;
        final fileName = '$userId/avatar.jpg';

        // Upload to Supabase Storage
        await Supabase.instance.client.storage
            .from('avatars')
            .upload(fileName, File(pickedFile.path));

        // Get public URL
        final url = Supabase.instance.client.storage
            .from('avatars')
            .getPublicUrl(fileName);

        setState(() => _avatarUrl = url);
      } catch (e) {
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${l10n.uploadError}: $e')),
          );
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _firstNameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    _phoneFocusNode.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _nicknameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _heardAboutPlastController.dispose();
    _whoNamedController.dispose();
    _stanychnyPhoneController.dispose();
    _zamistnykPhoneController.dispose();
    _referentUspUpsPhoneController.dispose();
    _referentUppUpnUpuPhoneController.dispose();
    _skarbnykPhoneController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final response = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response != null && mounted) {
        setState(() {
          _profile = ProfileModel.fromJson(response);
          _firstNameController.text = _profile!.firstName;
          _lastNameController.text = _profile!.lastName;
          _nicknameController.text = _profile!.nickname ?? '';
          _phoneController.text = AppConstants.stripPhonePrefix(_profile!.phone);
          _locationController.text = _profile!.location;
          _dateOfBirth = _profile!.dateOfBirth;
          _dateOfNaming = _profile!.dateOfNaming;
          _dateJoinedPlast = _profile!.dateJoinedPlast;
          _dateOath = _profile!.dateOath;
          _avatarUrl = _profile!.avatarUrl;
          _heardAboutPlastController.text = _profile!.heardAboutPlast ?? '';
          _whoNamedController.text = _profile!.whoNamed ?? '';
          _stanychnyPhoneController.text = AppConstants.stripPhonePrefix(_profile!.stanychnyPhone);
          _zamistnykPhoneController.text = AppConstants.stripPhonePrefix(_profile!.zamistnykStanychnogoPhone);
          _referentUspUpsPhoneController.text = AppConstants.stripPhonePrefix(_profile!.referentUspUpsPhone);
          _referentUppUpnUpuPhoneController.text = AppConstants.stripPhonePrefix(_profile!.referentUppUpnUpuPhone);
          _skarbnykPhoneController.text = AppConstants.stripPhonePrefix(_profile!.skarbnykPhone);
          _profileExistsInDb = true;
        });
      } else if (mounted) {
        setState(() {
          _profileExistsInDb = false;
          _isEditing = true;
        });
      }
    } catch (e) {
      // Error loading profile
      if (mounted) {
        setState(() {
          _profileExistsInDb = false;
          _isEditing = true;
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    final l10n = AppLocalizations.of(context)!;
    // Check required fields
    final bool firstNameEmpty = _firstNameController.text.trim().isEmpty;
    final bool lastNameEmpty = _lastNameController.text.trim().isEmpty;
    final bool phoneEmpty = _phoneController.text.trim().isEmpty;
    final bool dobEmpty = _dateOfBirth == null;

    // Validate phone format (digits only, 9 digits)
    final String phoneValue = _phoneController.text.trim();
    final bool phoneInvalid = !phoneEmpty && !RegExp(r'^[0-9]{9}$').hasMatch(phoneValue);

    final bool hasError = firstNameEmpty || lastNameEmpty || phoneEmpty || dobEmpty || phoneInvalid;

    // Calculate scroll position
    double firstErrorOffset = 0;
    if (lastNameEmpty) {
      firstErrorOffset = 250;
    } else if (firstNameEmpty) {
      firstErrorOffset = 330;
    } else if (phoneEmpty || phoneInvalid) {
      firstErrorOffset = 500;
    } else if (dobEmpty) {
      firstErrorOffset = 600;
    }

    if (hasError) {
      setState(() {
        _showLastNameError = lastNameEmpty;
        _showFirstNameError = firstNameEmpty;
        _showPhoneError = phoneEmpty || phoneInvalid;
        _showDateOfBirthError = dobEmpty;
      });

      // Scroll to first error
      _scrollController.animateTo(
        firstErrorOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

      // Focus on first empty field
      if (lastNameEmpty) {
        _lastNameFocusNode.requestFocus();
      } else if (firstNameEmpty) {
        _firstNameFocusNode.requestFocus();
      } else if (phoneEmpty || phoneInvalid) {
        _phoneFocusNode.requestFocus();
      }

      String errorMsg = l10n.fillRequiredFields;
      if (phoneInvalid) {
        errorMsg = l10n.phoneInvalid;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final data = {
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'nickname': _nicknameController.text.trim().isEmpty ? null : _nicknameController.text.trim(),
        'avatar_url': _avatarUrl,
        'phone': AppConstants.ensurePhonePrefix(_phoneController.text.trim()),
        'location': _locationController.text.trim(),
        'date_of_birth': _dateOfBirth?.toIso8601String(),
        'date_of_naming': _dateOfNaming?.toIso8601String(),
        'date_joined_plast': _dateJoinedPlast?.toIso8601String(),
        'date_oath': _dateOath?.toIso8601String(),
        'heard_about_plast': _heardAboutPlastController.text.trim().isEmpty ? null : _heardAboutPlastController.text.trim(),
        'who_named': _whoNamedController.text.trim().isEmpty ? null : _whoNamedController.text.trim(),
        'stanychny_phone': _stanychnyPhoneController.text.trim().isEmpty ? null : AppConstants.ensurePhonePrefix(_stanychnyPhoneController.text.trim()),
        'zamistnyk_stanychnogo_phone': _zamistnykPhoneController.text.trim().isEmpty ? null : AppConstants.ensurePhonePrefix(_zamistnykPhoneController.text.trim()),
        'referent_usp_ups_phone': _referentUspUpsPhoneController.text.trim().isEmpty ? null : AppConstants.ensurePhonePrefix(_referentUspUpsPhoneController.text.trim()),
        'referent_upp_upn_upu_phone': _referentUppUpnUpuPhoneController.text.trim().isEmpty ? null : AppConstants.ensurePhonePrefix(_referentUppUpnUpuPhoneController.text.trim()),
        'skarbnyk_phone': _skarbnykPhoneController.text.trim().isEmpty ? null : AppConstants.ensurePhonePrefix(_skarbnykPhoneController.text.trim()),
      };

      if (_profileExistsInDb) {
        await Supabase.instance.client
            .from('profiles')
            .update(data)
            .eq('id', userId);
      } else {
        data['id'] = userId;
        data['created_at'] = DateTime.now().toIso8601String();
        await Supabase.instance.client.from('profiles').insert(data);
        setState(() {
          _profileExistsInDb = true;
        });
      }

      await _loadProfile();
      if (mounted) {
        setState(() {
          _isEditing = false;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.profileSaved),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Error saving profile
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.error}: $e')),
        );
      }
    }
  }

  Future<void> _selectDate(int dateType) async {
    DateTime? currentDate;
    switch (dateType) {
      case 1:
        currentDate = _dateOfBirth;
        break;
      case 2:
        currentDate = _dateOfNaming;
        break;
      case 3:
        currentDate = _dateJoinedPlast;
        break;
      case 4:
        currentDate = _dateOath;
        break;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: currentDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        switch (dateType) {
          case 1:
            _dateOfBirth = picked;
            if (_showDateOfBirthError) _showDateOfBirthError = false;
            break;
          case 2:
            _dateOfNaming = picked;
            break;
          case 3:
            _dateJoinedPlast = picked;
            break;
          case 4:
            _dateOath = picked;
            break;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(_profile != null
            ? '${_profile!.firstName} ${_profile!.lastName}'
            : l10n.profile),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/calendar'),
        ),
        actions: [
          if (!_isEditing && _profileExistsInDb)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ), 
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: _profile == null && !_isEditing && !_profileExistsInDb
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  // Avatar with user info
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          backgroundImage: _avatarUrl != null
                              ? NetworkImage(_avatarUrl!)
                              : null,
                          child: _avatarUrl == null
                              ? Text(
                                  _firstNameController.text.isNotEmpty
                                      ? '${_firstNameController.text[0]}${_lastNameController.text.isNotEmpty ? _lastNameController.text[0] : ''}'
                                          .toUpperCase()
                                      : '?',
                                  style: const TextStyle(fontSize: 36, color: Colors.white),
                                )
                              : null,
                        ),
                        if (_isEditing)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.secondary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_profileExistsInDb && !_isEditing)
                    Center(
                      child: Column(
                        children: [
                          if (_profile?.email != null) ...[
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _profile!.email!,
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  _profile!.emailVerified == 1 ? Icons.verified : Icons.warning,
                                  size: 18,
                                  color: _profile!.emailVerified == 1 ? Colors.green : Colors.orange,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                          ],
                          Text(
                            '@${_nicknameController.text.isNotEmpty ? _nicknameController.text : l10n.noNickname}',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${l10n.profileId}: ${_profile?.id.substring(0, 8)}...',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey,
                                ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Required fields header
                  Text(
                    l10n.mainInfo,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),

                  // Last Name
                  TextFormField(
                    controller: _lastNameController,
                    focusNode: _lastNameFocusNode,
                    decoration: InputDecoration(
                      labelText: '${l10n.lastName} *',
                      prefixIcon: const Icon(Icons.person),
                      errorText: _showLastNameError ? l10n.required : null,
                      border: _showLastNameError
                          ? OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red))
                          : null,
                    ),
                    enabled: _isEditing,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),

                  // First Name
                  TextFormField(
                    controller: _firstNameController,
                    focusNode: _firstNameFocusNode,
                    decoration: InputDecoration(
                      labelText: '${l10n.firstName} *',
                      prefixIcon: const Icon(Icons.person_outline),
                      errorText: _showFirstNameError ? l10n.required : null,
                      border: _showFirstNameError
                          ? OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red))
                          : null,
                    ),
                    enabled: _isEditing,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),

                  // Nickname
                  TextFormField(
                    controller: _nicknameController,
                    decoration: InputDecoration(
                      labelText: l10n.nickname,
                      prefixIcon: const Icon(Icons.alternate_email),
                    ),
                    enabled: _isEditing,
                  ),
                  const SizedBox(height: 16),

                  // Phone
                  TextFormField(
                    controller: _phoneController,
                    focusNode: _phoneFocusNode,
                    decoration: InputDecoration(
                      labelText: '${l10n.phone} *',
                      prefixIcon: const Icon(Icons.phone),
                      prefixText: AppConstants.phonePrefix,
                      errorText: _showPhoneError ? l10n.required : null,
                      border: _showPhoneError
                          ? OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red))
                          : null,
                    ),
                    keyboardType: TextInputType.phone,
                    enabled: _isEditing,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),

                  // Location
                  TextFormField(
                    controller: _locationController,
                    decoration: InputDecoration(
                      labelText: '${l10n.location} *',
                      prefixIcon: const Icon(Icons.location_on),
                    ),
                    enabled: _isEditing,
                    validator: (v) =>
                        v?.trim().isEmpty == true ? l10n.required : null,
                  ),
                  const SizedBox(height: 16),

                  // Date of Birth
                  DatePickerTile(
                    label: l10n.dateOfBirth,
                    date: _dateOfBirth,
                    isRequired: true,
                    isError: _showDateOfBirthError,
                    isEnabled: _isEditing,
                    icon: Icons.cake,
                    onTap: _isEditing ? () => _selectDate(1) : null,
                  ),
                  const SizedBox(height: 16),

                  // Heard about Plast
                  TextFormField(
                    controller: _heardAboutPlastController,
                    decoration: InputDecoration(
                      labelText: l10n.heardAboutPlast,
                      prefixIcon: const Icon(Icons.history_edu),
                    ),
                    maxLines: 2,
                    enabled: _isEditing,
                  ),
                  const SizedBox(height: 24),

                  // Plast info header
                  Text(
                    l10n.plastInfo,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),

                  // Date Joined Plast
                  DatePickerTile(
                    label: l10n.dateJoinedPlast,
                    date: _dateJoinedPlast,
                    isEnabled: _isEditing,
                    icon: Icons.groups,
                    onTap: _isEditing ? () => _selectDate(3) : null,
                  ),
                  const SizedBox(height: 16),

                  // Date of Naming
                  DatePickerTile(
                    label: l10n.dateOfNaming,
                    date: _dateOfNaming,
                    isEnabled: _isEditing,
                    icon: Icons.calendar_today,
                    onTap: _isEditing ? () => _selectDate(2) : null,
                  ),
                  const SizedBox(height: 16),

                  // Who Named
                  TextFormField(
                    controller: _whoNamedController,
                    decoration: InputDecoration(
                      labelText: l10n.whoNamed,
                      prefixIcon: const Icon(Icons.person_pin),
                    ),
                    enabled: _isEditing,
                  ),
                  const SizedBox(height: 16),

                  // Date Oath
                  DatePickerTile(
                    label: l10n.dateOath,
                    date: _dateOath,
                    isEnabled: _isEditing,
                    icon: Icons.flag,
                    onTap: _isEditing ? () => _selectDate(4) : null,
                  ),
                  const SizedBox(height: 24),

                  // Contacts header
                  Text(
                    l10n.contacts,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),

                  // Станичний
                  TextFormField(
                    controller: _stanychnyPhoneController,
                    decoration: InputDecoration(
                      labelText: '${l10n.stanychny} (${l10n.phone})',
                      prefixIcon: const Icon(Icons.supervisor_account),
                      prefixText: AppConstants.phonePrefix,
                    ),
                    keyboardType: TextInputType.phone,
                    enabled: _isEditing,
                  ),
                  const SizedBox(height: 16),

                  // Заступник станичного
                  TextFormField(
                    controller: _zamistnykPhoneController,
                    decoration: InputDecoration(
                      labelText: '${l10n.zamistnykStanychnogo} (${l10n.phone})',
                      prefixIcon: const Icon(Icons.supervisor_account),
                      prefixText: AppConstants.phonePrefix,
                    ),
                    keyboardType: TextInputType.phone,
                    enabled: _isEditing,
                  ),
                  const SizedBox(height: 16),

                  // Референт УСП/УПС
                  TextFormField(
                    controller: _referentUspUpsPhoneController,
                    decoration: InputDecoration(
                      labelText: '${l10n.referentUspUps} (${l10n.phone})',
                      prefixIcon: const Icon(Icons.badge),
                      prefixText: AppConstants.phonePrefix,
                    ),
                    keyboardType: TextInputType.phone,
                    enabled: _isEditing,
                  ),
                  const SizedBox(height: 16),

                  // Референт УПП/УПН/УПЮ
                  TextFormField(
                    controller: _referentUppUpnUpuPhoneController,
                    decoration: InputDecoration(
                      labelText: '${l10n.referentUppUpnUpu} (${l10n.phone})',
                      prefixIcon: const Icon(Icons.badge),
                      prefixText: AppConstants.phonePrefix,
                    ),
                    keyboardType: TextInputType.phone,
                    enabled: _isEditing,
                  ),
                  const SizedBox(height: 16),

                  // Скарбник
                  TextFormField(
                    controller: _skarbnykPhoneController,
                    decoration: InputDecoration(
                      labelText: '${l10n.skarbnyk} (${l10n.phone})',
                      prefixIcon: const Icon(Icons.account_balance_wallet),
                      prefixText: AppConstants.phonePrefix,
                    ),
                    keyboardType: TextInputType.phone,
                    enabled: _isEditing,
                  ),
                  const SizedBox(height: 32),

                  // Save buttons
                  if (_isEditing) ...[
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              _loadProfile();
                              setState(() => _isEditing = false);
                            },
                            child: Text(l10n.cancel),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveProfile,
                            child: _isLoading
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
                  ],
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }
}
