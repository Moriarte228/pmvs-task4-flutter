# Minsk Libraries

Кроссплатформенное Flutter-приложение «Библиотеки Минска» с единой кодовой базой
для **Android, iOS, Linux (Desktop) и Web**. Реализовано в рамках задания 4
лабораторной работы 8.

## Возможности

- 🔐 **Авторизация** по email/паролю с сохранением сессии (SharedPreferences)
- 🏠 **Главный экран** в виде карточек со сводкой и быстрым доступом
- 🗺️ **Интерактивная карта** районов Минска (OpenStreetMap)
- 📋 **Список библиотек** с поиском, добавлением и удалением (swipe-to-delete)
- 🔍 **Детальный просмотр** с картой и контактами
- 🌓 **Тёмная/светлая/системная** тема (с сохранением выбора)
- 🌐 **3 языка**: русский, английский, беларуская
- 📡 **Офлайн-режим** — кеширование последних данных
- 🔔 **Уведомления**: Toast на Android/iOS, SnackBar на Linux/Web
- ⚙️ **Настройки**: тема, язык, очистка кеша, версия

## Стек

| Категория | Технология |
|---|---|
| Framework | Flutter 3.24+, Dart 3.5+ |
| State | Provider 6.x |
| Навигация | GoRouter 14.x |
| Карта | flutter_map + OpenStreetMap |
| БД | SQLite (sqflite + sqflite_common_ffi для Desktop) |
| Локальное хранение | SharedPreferences |
| Сеть | http |
| Уведомления | fluttertoast + SnackBar |

## Адаптивная вёрстка

| Платформа | Навигация |
|---|---|
| Android / iOS (< 600px) | `NavigationBar` (BottomNav) + `Drawer` + жесты свайпа |
| Linux / Desktop (600–1200px) | `NavigationRail` (collapsed) |
| Web / Desktop (> 1200px) | `NavigationRail` (extended) |

Используется `MediaQuery.sizeOf`, расширения `BuildContext` (`widthPct`,
`screenType`), условная компиляция через `kIsWeb` и `Platform.isXxx`.

**Клавиатурные сокращения** (Desktop/Web): `Ctrl+1..4` — переключение вкладок.

Все экраны корректно рендерятся в диапазоне от 360px до 2560px.

## Структура проекта

```
lib/
  l10n/                  ARB-файлы + сгенерированные локализации (ru/en/be)
  models/                LibraryModel, District
  providers/             AuthProvider, LibraryProvider, ThemeProvider, WeatherProvider
  services/              DatabaseService, AuthService, CacheService,
                         NotificationService, WeatherService
  screens/               LoginScreen, AdaptiveShell, HomeScreen, MapScreen,
                         LibraryListScreen, LibraryDetailScreen,
                         AddLibraryScreen, SettingsScreen
  widgets/               InfoCard, WeatherCard
  utils/                 PlatformUtils, Breakpoints, ResponsiveContext
  main.dart              GoRouter, MultiProvider, темы
test/
  unit/                  Тесты моделей
  widget/                Тесты виджетов
integration_test/        End-to-end тесты
.github/workflows/       CI для всех платформ
```

## Запуск

```bash
flutter pub get
flutter run                  # на подключённом устройстве/эмуляторе
flutter run -d linux         # Linux desktop
flutter run -d chrome        # Web
```

Логин: любой валидный email и пароль от 6 символов (подсказка показана на
экране входа).

## Тесты

```bash
flutter test                                       # unit + widget
flutter test integration_test/app_test.dart       # integration
```

В проекте: 3 unit-теста, 3 widget-теста, 3 integration-теста.

## CI/CD

GitHub Actions (`.github/workflows/build.yml`) собирает все платформы из
единой кодовой базы:

- `analyze-and-test` — `flutter analyze` + `flutter test` + coverage
- `build-android` — APK
- `build-ios` — `--no-codesign`
- `build-linux` — `flutter build linux`
- `build-web` — `flutter build web`

Все артефакты публикуются через `actions/upload-artifact@v4`.

## Локализация

Поддерживаются `ru`, `en`, `be`. Строки в `lib/l10n/intl_*.arb`,
переключение — в настройках или через системные настройки устройства.

## Обработка ошибок

Все сетевые и БД-операции обёрнуты в `try/catch` с выводом в консоль через
`debugPrint`. Глобальный обработчик `FlutterError.onError` в `main.dart`.
Ошибки валидации формы логина показываются пользователю через `NotificationService`.

## Анимации

- Fade + slide на экране логина
- Fade-in карты на главном
- Hero-like переход к детальному экрану (fade + slide)
- Анимированный `Dismissible` для удаления свайпом
