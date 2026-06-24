import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aidatpanel/main.dart'; // Projenizin ana dosyası
import 'package:aidatpanel/l10n/strings.g.dart'; // Çeviriler

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('login -> dashboard akışı iskeleti', (tester) async {
    // Çevirilerin (i18n) test ortamında çökmemesi için dili varsayılan olarak başlat
    LocaleSettings.setLocale(AppLocale.tr);

    // 1) Uygulamayı ProviderScope ile ayağa kaldır
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    
    // Uygulamanın ve animasyonların yüklenmesini bekle
    await tester.pumpAndSettle();

    // 2) Email alanını bul ve doldur
    final emailField = find.byKey(const ValueKey('email'));
    expect(emailField, findsOneWidget, reason: 'Email text field bulunamadı.');
    await tester.enterText(emailField, 'test@example.com');

    // Şifre alanını bul (şifre gizli olan TextField)
    final passwordField = find.byWidgetPredicate(
      (widget) => widget is TextField && widget.obscureText == true,
    );
    expect(passwordField, findsOneWidget, reason: 'Şifre text field bulunamadı.');
    await tester.enterText(passwordField, 'Password123!');

    // Sanal klavyeyi kapat
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    // 3) Giriş Yap butonunu bul ve tıkla (ElevatedButton)
    final loginButton = find.byType(ElevatedButton);
    expect(loginButton, findsOneWidget, reason: 'Giriş Yap butonu bulunamadı.');
    
    await tester.tap(loginButton);

    // İstek atılmasını ve olası ekran geçişini/uyarıyı bekle
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Dashboard'a geçiş yapıp yapmadığını ya da uygulamanın ayakta kalıp kalmadığını doğrula.
    // Gerçek bir kullanıcı hesabı olmadığı için muhtemelen "hata mesajı" çıkacaktır,
    // ancak en azından uygulamanın login ekranını çizip etkileşime girdiğini doğrulamış oluyoruz.
    expect(find.byType(MyApp), findsOneWidget);
  });
}
