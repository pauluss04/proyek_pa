import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:herbal/pages/subhome_admin/apotek_admin.dart';
import 'package:herbal/pages/subhome_admin/home_admin.dart';
import 'package:herbal/pages/subhome_admin/medicine_admin.dart';
import 'package:herbal/pages/subhome_admin/myprofile_admin.dart';
import 'package:herbal/pages/subhome_admin/newspaper_list.dart';
import 'package:herbal/pages/subhome_admin/radio_admin.dart';

class HomeAdminPage extends StatefulWidget {
  const HomeAdminPage({Key? key}) : super(key: key);

  @override
  HomeAdminPageState createState() => HomeAdminPageState();
}

class HomeAdminPageState extends State<HomeAdminPage> {
  final List<Widget> _widgetList = [
    const BerandaAdmin(),
    const MyProfileAdmin(),
  ];
  int _index = 0;
  double windowHeight = 0;
  double windowWidth = 0;
  @override
  Widget build(BuildContext context) {
    windowHeight = MediaQuery.of(context).size.height - 25;
    windowWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        bottomNavigationBar: BottomNavyBar(
          containerHeight: 60,
          iconSize: 30,
          mainAxisAlignment: MainAxisAlignment.center,
          backgroundColor: Color(0xFF2C3246),
          selectedIndex: _index,
          showElevation: true,
          itemCornerRadius: 24,
          curve: Curves.easeIn,
          onItemSelected: (index) => setState(() => _index = index),
          items: <BottomNavyBarItem>[
            BottomNavyBarItem(
              icon: Icon(Icons.home),
              title: Text('Beranda', style: GoogleFonts.nunito(fontSize: 18)),
              activeColor: Colors.white,
              textAlign: TextAlign.center,
            ),
            BottomNavyBarItem(
              icon: Icon(Icons.settings),
              title: Text(
                'Setelan',
                style: GoogleFonts.nunito(fontSize: 18),
              ),
              activeColor: Colors.white,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        body: DoubleBackToCloseApp(
          snackBar: SnackBar(
              duration: const Duration(seconds: 1),
              width: windowWidth * 0.7,
              behavior: SnackBarBehavior.floating,
              elevation: 6.0,
              content: const Text(
                'Tekan sekali lagi untuk keluar',
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              )),
          child: _widgetList[_index],
        ));
  }
}
