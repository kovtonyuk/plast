import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_urls.dart';
import '../../../l10n/app_localizations.dart';

class UsefulInfoPage extends StatelessWidget {
  const UsefulInfoPage({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.usefulInfo),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/calendar'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Сайт Пласту
          _buildLinkCard(
            context: context,
            icon: Icons.language,
            title: AppLocalizations.of(context)!.site_plast_title,
            subtitle: AppLocalizations.of(context)!.site_plast,
            url: AppUrls.plastSite,
          ),
          const SizedBox(height: 12),

          // Правильник впорядку
          _buildLinkCard(
            context: context,
            icon: Icons.description,
            title: AppLocalizations.of(context)!.pravilnik_vporiadu,
            subtitle: AppLocalizations.of(context)!.pdf,
            url: AppUrls.pravylnykVporiadku,
          ),
          const SizedBox(height: 12),

          // Правильник однострою (частина 1)
          _buildLinkCard(
            context: context,
            icon: Icons.description,
            title: AppLocalizations.of(context)!.pravilnuk_odnostrii_part_one,
            subtitle: AppLocalizations.of(context)!.pdf,
            url: AppUrls.pravylnykOdnostroiuPart1,
          ),
          const SizedBox(height: 12),

          // Правильник однострою (частина 2)
          _buildLinkCard(
            context: context,
            icon: Icons.description,
            title: AppLocalizations.of(context)!.pravilnuk_odnostrii_part_two,
            subtitle: AppLocalizations.of(context)!.pdf,
            url: AppUrls.pravylnykOdnostroiuPart2,
          ),
          const SizedBox(height: 24),

          // Основні заходи
          Text(
            AppLocalizations.of(context)!.osnovni_zahodu,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),

          // Осінь
          _buildSeasonSection(
            context: context,
            season: AppLocalizations.of(context)!.autumn,
            color: Colors.orange,
            events: [
              AppLocalizations.of(context)!.open_plast_year,
              AppLocalizations.of(context)!.autumn_raid,
              AppLocalizations.of(context)!.pov_vatra,
              AppLocalizations.of(context)!.november_chun,
            ],
          ),
          const SizedBox(height: 16),

          // Зима
          _buildSeasonSection(
            context: context,
            season: AppLocalizations.of(context)!.winter,
            color: Colors.blue,
            events: [
              AppLocalizations.of(context)!.andr_vechornici,
              AppLocalizations.of(context)!.vvm,
              AppLocalizations.of(context)!.vertepu,
              AppLocalizations.of(context)!.bi_pi,
            ],
          ),
          const SizedBox(height: 16),

          // Весна
          _buildSeasonSection(
            context: context,
            season: AppLocalizations.of(context)!.spring,
            color: Colors.green,
            events: [
              AppLocalizations.of(context)!.shevchenkiada,
              AppLocalizations.of(context)!.dppp,
              AppLocalizations.of(context)!.spring_raid,
              AppLocalizations.of(context)!.stegkamu_hero,
              AppLocalizations.of(context)!.gaivku,
              AppLocalizations.of(context)!.st_yuri,
            ],
          ),
          const SizedBox(height: 16),

          // Літо
          _buildSeasonSection(
            context: context,
            season: AppLocalizations.of(context)!.summer,
            color: Colors.amber,
            events: [
              AppLocalizations.of(context)!.camps,
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildLinkCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required String url,
  }) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.open_in_new),
        onTap: () => _launchUrl(url),
      ),
    );
  }

  Widget _buildSeasonSection({
    required BuildContext context,
    required String season,
    required Color color,
    required List<String> events,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  season,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...events.map((event) => Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                  Expanded(child: Text(event)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}
