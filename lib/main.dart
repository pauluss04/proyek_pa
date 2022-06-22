import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:herbal/pages/home.dart';
import 'package:herbal/pages/home_public.dart';
import 'package:herbal/widgets/splash.dart';
import 'package:path_provider/path_provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages//auth/authlogin.dart';

Future<void> main() async {
//   Directory tempDir = await getTemporaryDirectory();
// String tempPath = tempDir.path;

// Directory appDocDir = await getApplicationDocumentsDirectory();
// String appDocPath = appDocDir.path;
  // String isRoleAdmin = 'users';
  // await dotenv.load();
  // await Firebase.initializeApp();
  // final prefs = await SharedPreferences.getInstance();
  // if (prefs.getString('role') != null) {
  //   isRoleAdmin = prefs.getString('role')!;
  // }

  // SystemChrome.setPreferredOrientations([
  //   DeviceOrientation.portraitUp,
  // ]);
  runApp(MyApp());
  // runApp(const MyApp());

  
}
class MyApp extends StatelessWidget {
  const MyApp({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) => ResponsiveWrapper.builder(
       child,
          maxWidth: 1200,
          minWidth: 480,
          defaultScale: true,
          breakpoints: [
            const ResponsiveBreakpoint.resize(480, name: MOBILE),
            const ResponsiveBreakpoint.autoScale(800, name: TABLET),
            const ResponsiveBreakpoint.resize(1000, name: DESKTOP),
          ], 
      ),
      debugShowCheckedModeBanner: false,
      home: SplashScreen() ,
    );
  }
}