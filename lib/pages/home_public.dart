import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:herbal/pages/subhome_public/medicine.dart';
import 'package:herbal/pages/subhome_public/homelistpublic.dart';
import 'package:herbal/pages/subhome_public/newspaperlist_public.dart';
import 'package:herbal/pages/subhome_public/radio_public.dart';
import 'package:herbal/pages/subhome_public/myprofile_public.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';

class HomePublicPage extends StatefulWidget {
  const HomePublicPage({Key? key}) : super(key: key);

  @override
  HomePublicPageState createState() => HomePublicPageState();
}

class HomePublicPageState extends State<HomePublicPage> {
  final List<Widget> _widgetList = [
    const HomeListPublic(),
    const NewsPaperListPublic(),
    const MedicinePage(),
    const RadioListPublic(),
    const MyProfilePublic(),
  ];
  int _index = 0;
  double windowHeight = 0;
  double windowWidth = 0;
  @override
  Widget build(BuildContext context) {
    windowHeight = MediaQuery.of(context).size.height - 25;
    windowWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        bottomNavigationBar: 
        BottomNavyBar(
          key: Key('navBarUser'),
          containerHeight: 60,
          iconSize: 30,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          backgroundColor: Color(0xFF2C3246),
          selectedIndex: _index,
          showElevation: true,
          itemCornerRadius: 24,
          curve: Curves.easeIn,
          onItemSelected: (index) => setState(() => _index = index),
          items: <BottomNavyBarItem>[
            BottomNavyBarItem(
              icon: const Icon(Icons.home, key: Key("home")),
              title: Text('Beranda', style: GoogleFonts.nunito(fontSize: 18)),
              activeColor: Colors.white,
              textAlign: TextAlign.center,
            ),
            BottomNavyBarItem(
              icon: const Icon(Icons.my_library_books, key: Key("beritaUser"),),
              title: Text('Berita', style: GoogleFonts.nunito(fontSize: 18)),
              activeColor: Colors.white,
              textAlign: TextAlign.center,
            ),
            BottomNavyBarItem(
              icon: Icon(Icons.shopping_cart),
              title: Text('Obat Herbal', style: GoogleFonts.nunito(fontSize: 18)),
              activeColor: Colors.white,
              textAlign: TextAlign.center,
            ),
            BottomNavyBarItem(
              icon: Icon(Icons.radio),
              title: Text('Radio', style: GoogleFonts.nunito(fontSize: 18)),
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
