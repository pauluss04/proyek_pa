import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:herbal/pages/home_public.dart';
import 'package:herbal/pages/subhome_public/homelistpublic.dart';
import 'package:herbal/pages/subhome_public/newspaperlist_public.dart';
import 'package:herbal/widgets/splash.dart';
import 'package:integration_test/integration_test.dart';

import 'package:herbal/main.dart' as app;

void main (){
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Tap Bottom Berita', (tester) async{
      app.main();
      // await tester.pumpAndSettle();
      
      await tester.pumpWidget(const SplashScreen(), Duration(seconds: 5));
      await tester.pumpWidget(const HomePublicPage(),Duration(seconds: 5));
      // await tester.ensureVisible(find.byKey(Key('navBarUser')));
      final finder = find.byKey(Key('beritaUser'));
      await tester.tap(finder);
      expect(finder, findsOneWidget);
      print('clicked on first');
      await tester.pumpWidget(const NewsPaperListPublic());
    });
}
