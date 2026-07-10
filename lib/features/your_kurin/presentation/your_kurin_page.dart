import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/models/your_kurin_model.dart';

class YourKurinPage extends StatefulWidget {
  const YourKurinPage({super.key});

  @override
  State<YourKurinPage> createState() => _YourKurinPageState();
}

class _YourKurinPageState extends State<YourKurinPage> {
  List<YourKurinModel> _units = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUnits();
  }

  Future<void> _loadUnits() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    setState(() => _isLoading = true);

    final response = await Supabase.instance.client
        .from('your_kurin')
        .select()
        .eq('user_id', userId)
        .order('first_meeting_date', ascending: false);

    final units = (response as List)
        .map((e) => YourKurinModel.fromJson(e))
        .toList();

    if (mounted) {
      setState(() {
        _units = units;
        _isLoading = false;
      });
    }
  }

  Future<bool> _confirmDelete(
    YourKurinModel unit,
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
          .from('your_kurin')
          .delete()
          .eq('id', unit.id);
      _loadUnits();
    }
    return confirmed ?? false;
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            key: const Key('drawer_header'),
            decoration: const BoxDecoration(color: Color(0xFF368683)),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Image(
                    key: Key('drawer_logo'),
                    image: AssetImage(AppConstants.logoAssetPath),
                    fit: BoxFit.contain,
                    height: 84,
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: Text(AppLocalizations.of(context)!.calendar),
            onTap: () {
              Navigator.pop(context);
              context.go('/calendar');
            },
          ),
          ListTile(
            leading: const Icon(Icons.school),
            title: Text(AppLocalizations.of(context)!.trainings),
            onTap: () {
              Navigator.pop(context);
              context.go('/trainings');
            },
          ),
          ListTile(
            leading: const Icon(Icons.park),
            title: Text(AppLocalizations.of(context)!.camps),
            onTap: () {
              Navigator.pop(context);
              context.go('/camps');
            },
          ),
          ListTile(
            leading: const Icon(Icons.event),
            title: Text(AppLocalizations.of(context)!.events),
            onTap: () {
              Navigator.pop(context);
              context.go('/events');
            },
          ),
          ListTile(
            leading: const Icon(Icons.flag),
            title: Text(AppLocalizations.of(context)!.goals),
            onTap: () {
              Navigator.pop(context);
              context.go('/goals');
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.admin_panel_settings),
            title: Text(AppLocalizations.of(context)!.adminActivities),
            onTap: () {
              Navigator.pop(context);
              context.push('/admin-activities');
            },
          ),
          ListTile(
            leading: Icon(Icons.volunteer_activism),
            title: Text(AppLocalizations.of(context)!.plastActivities),
            onTap: () {
              Navigator.pop(context);
              context.push('/plast-activities');
            },
          ),
          ListTile(
            leading: Icon(Icons.child_care),
            title: Text(AppLocalizations.of(context)!.firstUnit),
            onTap: () {
              Navigator.pop(context);
              context.push('/first-unit');
            },
          ),
          ListTile(
            leading: Icon(Icons.connect_without_contact),
            title: Text(AppLocalizations.of(context)!.linkCourier),
            onTap: () {
              Navigator.pop(context);
              context.push('/link-courier');
            },
          ),
          ListTile(
            leading: Icon(Icons.groups),
            title: Text(AppLocalizations.of(context)!.yourKurin),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(AppLocalizations.of(context)!.profile),
            onTap: () {
              Navigator.pop(context);
              context.push('/profile');
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(AppLocalizations.of(context)!.usefulInfo),
            onTap: () {
              Navigator.pop(context);
              context.push('/useful-info');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(AppLocalizations.of(context)!.settings),
            onTap: () {
              Navigator.pop(context);
              context.push('/settings');
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(l10n.yourKurin),
      ),
      drawer: _buildDrawer(context),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _units.isEmpty
          ? Center(child: Text(l10n.noData))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _units.length,
              itemBuilder: (context, index) {
                final unit = _units[index];
                return Dismissible(
                  key: Key(unit.id),
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
                  confirmDismiss: (_) => _confirmDelete(unit, l10n),
                  child: Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: const Icon(Icons.groups, color: Colors.white),
                      ),
                      title: Text(unit.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (unit.firstMeetingDate != null)
                            Text(
                              '${l10n.firstMeetingDate}: ${DateFormat('dd.MM.yyyy').format(unit.firstMeetingDate!)}',
                            ),
                          if (unit.supporterDate != null)
                            Text(
                              '${l10n.supporterDate}: ${DateFormat('dd.MM.yyyy').format(unit.supporterDate!)}',
                            ),
                          if (unit.dcKurinDate != null)
                            Text(
                              '${l10n.dcKurinDate}: ${DateFormat('dd.MM.yyyy').format(unit.dcKurinDate!)}',
                            ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.people_outline),
                        tooltip: l10n.kurinMembers,
                        onPressed: () => context.push(
                          '/your-kurin/${unit.id}/members',
                          extra: unit.name,
                        ),
                      ),
                      onTap: () async {
                        await context.push('/your-kurin/edit', extra: unit);
                        _loadUnits();
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push('/your-kurin/add');
          _loadUnits();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
