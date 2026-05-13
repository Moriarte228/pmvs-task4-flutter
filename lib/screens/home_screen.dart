import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/district.dart';
import '../providers/library_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/platform_utils.dart';
import '../widgets/info_card.dart';
import 'library_list_screen.dart';

/// Главный экран — карточки со сводкой и быстрым доступом.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final libProv = context.watch<LibraryProvider>();
    final auth = context.watch<AuthProvider>();
    final districts = District.getDistricts();

    // Адаптивное число колонок.
    final width = context.widthPct(1);
    final crossAxisCount = width < 600 ? 1 : (width < 1000 ? 2 : 3);

    return RefreshIndicator(
      onRefresh: () => libProv.loadLibraries(),
      child: ListView(
        padding: EdgeInsets.symmetric(
          horizontal: width < 600 ? 12 : 24,
          vertical: 16,
        ),
        children: [
          // Приветствие
          if (auth.email != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                '${l10n.welcome}, ${auth.email}',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),

          // Баннер офлайн-режима.
          if (libProv.isOffline)
            Card(
              color: Colors.orange.shade100,
              child: ListTile(
                leading: const Icon(Icons.wifi_off, color: Colors.orange),
                title: Text(l10n.offlineMode),
                subtitle: libProv.lastUpdate != null
                    ? Text(
                        '${l10n.lastUpdate}: ${_fmtDate(libProv.lastUpdate!)}')
                    : null,
              ),
            ),

          const SizedBox(height: 8),

          // Сводные карточки.
          GridView.count(
            crossAxisCount: crossAxisCount,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              InfoCard(
                icon: Icons.local_library,
                title: l10n.totalLibraries,
                value: libProv.libraries.length.toString(),
                color: Colors.indigo,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const LibraryListScreen()),
                ),
              ),
              InfoCard(
                icon: Icons.map,
                title: l10n.districts,
                value: districts.length.toString(),
                color: Colors.green,
              ),
              InfoCard(
                icon: Icons.update,
                title: l10n.lastUpdate,
                value: libProv.lastUpdate != null
                    ? _fmtDate(libProv.lastUpdate!)
                    : '—',
                color: Colors.orange,
              ),
            ],
          ),

          const SizedBox(height: 16),
          Text(
            l10n.districts,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Список районов как карточки.
          ...districts.map((d) {
            final count =
                libProv.libraries.where((l) => l.district == d.id).length;
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                title: Text(d.getName(locale)),
                subtitle: Text('${l10n.totalLibraries}: $count'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  context.read<LibraryProvider>().selectDistrict(d);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LibraryListScreen(),
                    ),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  String _fmtDate(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(dt.day)}.${two(dt.month)}.${dt.year} ${two(dt.hour)}:${two(dt.minute)}';
  }
}


