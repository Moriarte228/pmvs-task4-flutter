import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_localizations.dart';
import '../utils/platform_utils.dart';
import 'home_screen.dart';
import 'map_screen.dart';
import 'library_list_screen.dart';
import 'settings_screen.dart';

/// Корневой адаптивный экран.
///
/// На мобильных устройствах — нижняя навигация (BottomNavigationBar).
/// На Desktop/Web — боковой NavigationRail с поддержкой клавиатурных
/// сокращений (Ctrl+1..4) и hover-эффектов.
class AdaptiveShell extends StatefulWidget {
  const AdaptiveShell({super.key});

  @override
  State<AdaptiveShell> createState() => _AdaptiveShellState();
}

class _AdaptiveShellState extends State<AdaptiveShell> {
  int _index = 0;

  late final List<Widget> _pages = const [
    HomeScreen(),
    MapScreen(),
    LibraryListScreen(),
    SettingsScreen(),
  ];

  void _onSelected(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final width = MediaQuery.sizeOf(context).width;

    // Адаптивный выбор навигации.
    // < 600px — BottomNavigationBar (мобильные)
    // 600-1200px — NavigationRail (планшет/маленький десктоп)
    // > 1200px — расширенный NavigationRail с подписями
    final useRail = width >= 600 || PlatformUtils.isDesktop;
    final extended = width >= 1200;

    final destinations = [
      _Dest(icon: Icons.home_outlined, selectedIcon: Icons.home, label: l10n.home),
      _Dest(icon: Icons.map_outlined, selectedIcon: Icons.map, label: l10n.map),
      _Dest(icon: Icons.list_alt_outlined, selectedIcon: Icons.list, label: l10n.list),
      _Dest(icon: Icons.settings_outlined, selectedIcon: Icons.settings, label: l10n.settings),
    ];

    final body = IndexedStack(index: _index, children: _pages);

    // Глобальные клавиатурные сокращения для Desktop/Web.
    final shortcuts = <ShortcutActivator, Intent>{
      const SingleActivator(LogicalKeyboardKey.digit1, control: true):
          const _SelectTabIntent(0),
      const SingleActivator(LogicalKeyboardKey.digit2, control: true):
          const _SelectTabIntent(1),
      const SingleActivator(LogicalKeyboardKey.digit3, control: true):
          const _SelectTabIntent(2),
      const SingleActivator(LogicalKeyboardKey.digit4, control: true):
          const _SelectTabIntent(3),
    };

    final actions = <Type, Action<Intent>>{
      _SelectTabIntent:
          CallbackAction<_SelectTabIntent>(onInvoke: (intent) {
        _onSelected(intent.index);
        return null;
      }),
    };

    return Shortcuts(
      shortcuts: shortcuts,
      child: Actions(
        actions: actions,
        child: Focus(
          autofocus: true,
          child: Scaffold(
            body: useRail
                ? Row(
                    children: [
                      NavigationRail(
                        extended: extended,
                        selectedIndex: _index,
                        onDestinationSelected: _onSelected,
                        labelType: extended
                            ? NavigationRailLabelType.none
                            : NavigationRailLabelType.all,
                        destinations: destinations
                            .map((d) => NavigationRailDestination(
                                  icon: Icon(d.icon),
                                  selectedIcon: Icon(d.selectedIcon),
                                  label: Text(d.label),
                                ))
                            .toList(),
                      ),
                      const VerticalDivider(width: 1),
                      Expanded(child: body),
                    ],
                  )
                : body,
            bottomNavigationBar: useRail
                ? null
                : NavigationBar(
                    selectedIndex: _index,
                    onDestinationSelected: _onSelected,
                    destinations: destinations
                        .map((d) => NavigationDestination(
                              icon: Icon(d.icon),
                              selectedIcon: Icon(d.selectedIcon),
                              label: d.label,
                            ))
                        .toList(),
                  ),
            // Drawer для дополнительной навигации на маленьких экранах.
            drawer: useRail
                ? null
                : Drawer(
                    child: ListView(
                      children: [
                        DrawerHeader(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Icon(Icons.local_library,
                                  color: Colors.white, size: 36),
                              const SizedBox(height: 8),
                              Text(
                                l10n.appTitle,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ...destinations.asMap().entries.map((e) {
                          final i = e.key;
                          final d = e.value;
                          return ListTile(
                            leading: Icon(_index == i ? d.selectedIcon : d.icon),
                            title: Text(d.label),
                            selected: _index == i,
                            onTap: () {
                              Navigator.pop(context);
                              _onSelected(i);
                            },
                          );
                        }),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _Dest {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  _Dest({required this.icon, required this.selectedIcon, required this.label});
}

class _SelectTabIntent extends Intent {
  final int index;
  const _SelectTabIntent(this.index);
}
