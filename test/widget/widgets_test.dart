import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:minsk_libraries/l10n/app_localizations.dart';
import 'package:minsk_libraries/widgets/info_card.dart';

void main() {
  Widget wrap(Widget child, {Locale locale = const Locale('ru')}) {
    return MaterialApp(
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );
  }

  group('Widget tests', () {
    testWidgets('InfoCard отображает title, value и иконку',
        (tester) async {
      await tester.pumpWidget(wrap(
        const InfoCard(
          icon: Icons.local_library,
          title: 'Библиотек',
          value: '42',
          color: Colors.indigo,
        ),
      ));

      expect(find.text('Библиотек'), findsOneWidget);
      expect(find.text('42'), findsOneWidget);
      expect(find.byIcon(Icons.local_library), findsOneWidget);
    });

    testWidgets('InfoCard вызывает onTap при нажатии', (tester) async {
      var tapped = 0;
      await tester.pumpWidget(wrap(
        InfoCard(
          icon: Icons.map,
          title: 'Районы',
          value: '9',
          color: Colors.green,
          onTap: () => tapped++,
        ),
      ));

      await tester.tap(find.byType(InfoCard));
      await tester.pump();
      expect(tapped, 1);
    });

    testWidgets('AppLocalizations переключаются между ru и en',
        (tester) async {
      await tester.pumpWidget(wrap(
        Builder(builder: (ctx) {
          return Text(AppLocalizations.of(ctx)!.appTitle);
        }),
        locale: const Locale('ru'),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Библиотеки Минска'), findsOneWidget);

      await tester.pumpWidget(wrap(
        Builder(builder: (ctx) {
          return Text(AppLocalizations.of(ctx)!.appTitle);
        }),
        locale: const Locale('en'),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Minsk Libraries'), findsOneWidget);
    });
  });
}
