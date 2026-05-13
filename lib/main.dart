import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// Условный импорт sqflite_common_ffi для Desktop.
import 'package:sqflite_common_ffi/sqflite_ffi.dart'
    if (dart.library.html) 'services/_sqflite_stub.dart';

import 'l10n/app_localizations.dart';
import 'providers/auth_provider.dart';
import 'providers/library_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/weather_provider.dart';
import 'screens/adaptive_shell.dart';
import 'screens/library_detail_screen.dart';
import 'screens/login_screen.dart';
import 'utils/platform_utils.dart';

void main() {
  // Глобальная обработка ошибок Flutter.
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError: ${details.exception}');
  };

  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация sqflite для Desktop (Linux/Windows/macOS).
  if (!kIsWeb && (PlatformUtils.isLinux ||
      PlatformUtils.isWindows ||
      PlatformUtils.isMacOS)) {
    try {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    } catch (e) {
      debugPrint('sqflite ffi init error: $e');
    }
  }

  runApp(const MinskLibrariesApp());
}

class MinskLibrariesApp extends StatelessWidget {
  const MinskLibrariesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()..load()),
        ChangeNotifierProvider(create: (_) => AuthProvider()..bootstrap()),
        ChangeNotifierProvider(
            create: (_) => LibraryProvider()..loadLibraries()),
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
      ],
      child: const _AppRoot(),
    );
  }
}

class _AppRoot extends StatefulWidget {
  const _AppRoot();

  @override
  State<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<_AppRoot> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = GoRouter(
      initialLocation: '/',
      refreshListenable: context.read<AuthProvider>(),
      redirect: (ctx, state) {
        final auth = ctx.read<AuthProvider>();
        final loggingIn = state.matchedLocation == '/login';
        if (!auth.isLoggedIn && !loggingIn) return '/login';
        if (auth.isLoggedIn && loggingIn) return '/';
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (ctx, state) => LoginScreen(
            onLoginSuccess: () => ctx.go('/'),
          ),
        ),
        GoRoute(
          path: '/',
          builder: (ctx, state) => const AdaptiveShell(),
          routes: [
            GoRoute(
              path: 'library/:id',
              builder: (ctx, state) {
                final id =
                    int.tryParse(state.pathParameters['id'] ?? '') ?? -1;
                final lib = ctx
                    .read<LibraryProvider>()
                    .libraries
                    .where((l) => l.id == id)
                    .firstOrNull;
                if (lib == null) {
                  return Scaffold(
                    appBar: AppBar(),
                    body: const Center(child: Text('Not found')),
                  );
                }
                return LibraryDetailScreen(library: lib);
              },
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    final lightScheme = ColorScheme.fromSeed(
      seedColor: Colors.indigo,
      brightness: Brightness.light,
    );
    final darkScheme = ColorScheme.fromSeed(
      seedColor: Colors.indigo,
      brightness: Brightness.dark,
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Minsk Libraries',
      themeMode: theme.themeMode,
      theme: ThemeData(
        colorScheme: lightScheme,
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: lightScheme.surface,
          foregroundColor: lightScheme.onSurface,
          elevation: 0,
          scrolledUnderElevation: 1,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: darkScheme,
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: darkScheme.surface,
          foregroundColor: darkScheme.onSurface,
          elevation: 0,
          scrolledUnderElevation: 1,
        ),
      ),
      locale: theme.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: _router,
    );
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
