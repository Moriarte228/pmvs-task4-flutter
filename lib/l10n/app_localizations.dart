import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_be.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('be'),
    Locale('en'),
    Locale('ru')
  ];

  String get appTitle;
  String get allLibraries;
  String get noLibraries;
  String get settings;
  String get language;
  String get about;
  String get aboutDescription;
  String get address;
  String get workingHours;
  String get phone;
  String get website;
  String get selectDistrict;
  String get weather;
  String get weatherError;
  String get loading;
  String get humidity;
  String get wind;
  String get login;
  String get logout;
  String get email;
  String get password;
  String get loginButton;
  String get loginError;
  String get emailRequired;
  String get passwordRequired;
  String get passwordTooShort;
  String get emailInvalid;
  String get loginHint;
  String get welcome;
  String get home;
  String get map;
  String get list;
  String get favorites;
  String get districts;
  String get totalLibraries;
  String get lastUpdate;
  String get theme;
  String get themeSystem;
  String get themeLight;
  String get themeDark;
  String get clearCache;
  String get clearCacheConfirm;
  String get cacheCleared;
  String get version;
  String get appVersion;
  String get addLibrary;
  String get deleteLibrary;
  String get deleteConfirm;
  String get deleted;
  String get added;
  String get cancel;
  String get delete;
  String get add;
  String get save;
  String get name;
  String get district;
  String get selectDistrictHint;
  String get latitude;
  String get longitude;
  String get fieldRequired;
  String get offlineMode;
  String get noInternet;
  String get yes;
  String get no;
  String get ok;
  String get back;
  String get search;
  String get searchHint;
  String get noResults;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['be', 'en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  switch (locale.languageCode) {
    case 'be':
      return AppLocalizationsBe();
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale".');
}
