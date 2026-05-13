import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:minsk_libraries/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('Integration tests', () {
    testWidgets('Старт без сессии открывает экран логина', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // На экране логина есть поля email и пароля.
      expect(find.byType(TextFormField), findsAtLeastNWidgets(2));
      expect(find.byIcon(Icons.email_outlined), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    });

    testWidgets('Логин с валидным email/паролем → главный экран',
        (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).at(1);

      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'password123');
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.login));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // После логина должна появиться навигация (Bottom или Rail).
      final hasBottomNav = find.byType(NavigationBar).evaluate().isNotEmpty;
      final hasRail = find.byType(NavigationRail).evaluate().isNotEmpty;
      expect(hasBottomNav || hasRail, isTrue,
          reason: 'после входа отображается навигация');
    });

    testWidgets('Невалидный email показывает ошибку валидации',
        (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).at(1);

      await tester.enterText(emailField, 'not-an-email');
      await tester.enterText(passwordField, '123'); // слишком короткий
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.login));
      await tester.pumpAndSettle();

      // Сообщение об ошибке валидации появилось.
      expect(find.textContaining(RegExp(r'email|Email|пароль|Пароль')),
          findsWidgets);
    });
  });
}
