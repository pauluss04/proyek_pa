import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:herbal/main.dart' as app;

void main (){
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  test("testingBerita", (){
    testWidgets('Tap Bottom Berita', (tester)async{
      app.main();

      await tester.pumpAndSettle();

      expect(find.text("Berita"), findsOneWidget);
      
      final Finder berita = find.byKey(Key("Berita"));

      await tester.tap(berita);

      await tester.pumpAndSettle();

      // expect(find.widgetWithText(Scaffold(), text), matcher)
      expect(find.text("Berita"), findsOneWidget);
    });
  });
}