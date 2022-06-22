import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_twitch_player/flutter_twitch_player.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:herbal/shared/shared.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/link.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

class HomeListPublic extends StatefulWidget {
  const HomeListPublic({Key? key}) : super(key: key);

  @override
  HomeListPublicState createState() => HomeListPublicState();
}

class HomeListPublicState extends State<HomeListPublic> {
  double windowHeight = 0;
  double windowWidth = 0;
  bool isLoading = false;
  String token = "";
  Future<void>? _launched;

  TwitchController twitchController = TwitchController();
  final List<String> imgList = [
    'https://drive.google.com/uc?export=view&id=1YoYckxtziivFi1Eep5y2d_oN7V-VwsgX',
    'https://drive.google.com/uc?export=view&id=1nga-bWrdoREt0YnXsw-6Y5dMqyYI9O6S',
    'https://drive.google.com/uc?export=view&id=1RKRPsKkBHzbTbv1v_WXkVbAYu-CymAfW',
    'https://drive.google.com/uc?export=view&id=1FHIov-1nW-FF1aJ1ulkxrKj4BhKVx0AL',
    'https://drive.google.com/uc?export=view&id=1IhTEA1o_0XPwiejD_D8kyyhEfJonpPfb',
    'https://drive.google.com/uc?export=view&id=1U_r699YuRp4eqaciPIfW06MSUcHgz4er',
    'https://drive.google.com/uc?export=view&id=1gi2RzcxtYj0GF4GLyq2bcQ4kLF3ymdYH',
  ];

  @override
  void initState() {
    initiateData();

    super.initState();
  }

  Future<void> _launchInWebViewOrVC(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        universalLinksOnly: true,
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  initiateData() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token').toString();
  }

  alertError(String err, int error) {
    setState(() {
      isLoading = false;
    });
    AwesomeDialog(
            context: context,
            dialogType: error == 0 ? DialogType.WARNING : DialogType.ERROR,
            animType: AnimType.SCALE,
            headerAnimationLoop: false,
            title: 'Kesalahan',
            desc: err,
            btnOkOnPress: () {},
            btnOkIcon: Icons.cancel,
            btnOkColor: Colors.red)
        .show();
  }

  @override
  Widget build(BuildContext context) {
    windowHeight = MediaQuery.of(context).size.height - 25;
    const String igUrl = 'https://www.instagram.com/bsk.radionetwork/';
    const String fbUrl = 'https://www.facebook.com/bskgroupsamarinda/';
    const String webUrl = 'https://bskmedia.co.id/';
    const String youtubeUrl =
        'https://www.youtube.com/channel/UCp-_MIm95m3U-dE_lXl5ekw';
    const String twitcheUrl = 'https://www.twitch.tv/bskmedia';
    windowWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF2C3246),
          title: Text(
            "Beranda",
            style: GoogleFonts.nunito(fontSize:25),
          ),
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
            child: SafeArea(
                bottom: false,
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 30,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: TwitchPlayerIFrame(
                          controller: twitchController,
                          channel: "bskmedia",
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Text(
                        "Penyiar Kami",
                        style: GoogleFonts.nunito(fontSize: 25),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 5),
                        width: 400,
                        height: 400,
                        child: Swiper(
                          loop: true,
                          // pagination: SwiperPagination(),
                          itemCount: imgList.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Container(
                              height: 300,
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image(
                                    image: NetworkImage(imgList[index]),
                                    fit: BoxFit.cover,
                                  )),
                            );
                          },
                          viewportFraction: 0.8,
                          scale: 0.9,
                          autoplay: true,
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Text(
                        "Kunjungi kami Di",
                        style: GoogleFonts.nunito(fontSize: 25),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 2.0, // gap between adjacent chips
                        runSpacing: 2.0, // gap between lines
                        children: [
                          IconButton(
                            icon: FaIcon(
                              FontAwesomeIcons.instagram,
                              color: Colors.red,
                              size: 50,
                            ),
                            iconSize: 50,
                            onPressed: () => setState(() {
                              _launched = _launchInWebViewOrVC(igUrl);
                            }),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          IconButton(
                            icon: FaIcon(
                              FontAwesomeIcons.facebook,
                              color: Colors.blue,
                              size: 50,
                            ),
                            iconSize: 50,
                            onPressed: () => setState(() {
                              _launched = _launchInWebViewOrVC(fbUrl);
                            }),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          IconButton(
                            icon: FaIcon(
                              FontAwesomeIcons.youtube,
                              color: Colors.red,
                              size: 50,
                            ),
                            iconSize: 50,
                            onPressed: () => setState(() {
                              _launched = _launchInWebViewOrVC(youtubeUrl);
                            }),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.web,
                              size: 50,
                            ),
                            iconSize: 50,
                            onPressed: () => setState(() {
                              _launched = _launchInWebViewOrVC(webUrl);
                            }),
                          ),
                          SizedBox(
                            height: 50,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ))));
  }
}
