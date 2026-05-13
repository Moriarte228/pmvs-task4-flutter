import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../providers/library_provider.dart';
import '../providers/theme_provider.dart';
import '../services/notification_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = context.watch<ThemeProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        children: [
          // Тема
          _SectionHeader(title: l10n.theme),
          RadioListTile<ThemeMode>(
            title: Text(l10n.themeSystem),
            value: ThemeMode.system,
            groupValue: theme.themeMode,
            onChanged: (v) => v == null ? null : theme.setThemeMode(v),
            secondary: const Icon(Icons.brightness_auto),
          ),
          RadioListTile<ThemeMode>(
            title: Text(l10n.themeLight),
            value: ThemeMode.light,
            groupValue: theme.themeMode,
            onChanged: (v) => v == null ? null : theme.setThemeMode(v),
            secondary: const Icon(Icons.light_mode),
          ),
          RadioListTile<ThemeMode>(
            title: Text(l10n.themeDark),
            value: ThemeMode.dark,
            groupValue: theme.themeMode,
            onChanged: (v) => v == null ? null : theme.setThemeMode(v),
            secondary: const Icon(Icons.dark_mode),
          ),
          const Divider(),

          // Язык
          _SectionHeader(title: l10n.language),
          RadioListTile<Locale?>(
            title: const Text('Система / System'),
            value: null,
            groupValue: theme.locale,
            onChanged: (v) => theme.setLocale(v),
          ),
          RadioListTile<Locale?>(
            title: const Text('Русский'),
            value: const Locale('ru'),
            groupValue: theme.locale,
            onChanged: (v) => theme.setLocale(v),
          ),
          RadioListTile<Locale?>(
            title: const Text('English'),
            value: const Locale('en'),
            groupValue: theme.locale,
            onChanged: (v) => theme.setLocale(v),
          ),
          RadioListTile<Locale?>(
            title: const Text('Беларуская'),
            value: const Locale('be'),
            groupValue: theme.locale,
            onChanged: (v) => theme.setLocale(v),
          ),
          const Divider(),

          // Очистка кеша
          ListTile(
            leading: const Icon(Icons.cleaning_services_outlined),
            title: Text(l10n.clearCache),
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(l10n.clearCache),
                  content: Text(l10n.clearCacheConfirm),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text(l10n.cancel),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text(l10n.ok),
                    ),
                  ],
                ),
              );
              if (confirmed == true && context.mounted) {
                await context.read<LibraryProvider>().clearCache();
                if (context.mounted) {
                  NotificationService.instance
                      .success(context, l10n.cacheCleared);
                }
              }
            },
          ),
          const Divider(),

          // О приложении
          _SectionHeader(title: l10n.about),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.aboutDescription),
            subtitle: Text('${l10n.version}: ${l10n.appVersion}'),
          ),
          const Divider(),

          // Выход
          if (auth.isLoggedIn)
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red.shade400),
              title: Text(
                l10n.logout,
                style: TextStyle(color: Colors.red.shade400),
              ),
              subtitle: auth.email != null ? Text(auth.email!) : null,
              onTap: () async {
                await context.read<AuthProvider>().logout();
              },
            ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
