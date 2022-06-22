import 'dart:async';
import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:favorite_button/favorite_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_radio_player/flutter_radio_player.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:herbal/api/api_services.dart';
import 'package:herbal/pages/auth/authlogin.dart';
import 'package:radio_player/radio_player.dart';
// ignore: import_of_legacy_library_into_null_safe
// import 'package:flutter_radio/flutter_radio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class RadioDetailsPublic extends StatefulWidget {
  const RadioDetailsPublic({Key? key}) : super(key: key);

  @override
  RadioDetailsPublicState createState() => RadioDetailsPublicState();
}

class RadioDetailsPublicState extends State<RadioDetailsPublic> {
  double windowHeight = 0;
  double windowWidth = 0;
  var pathUrl = [];
  String token = "";
  bool isLoading = true;
  Future<void>? _launched;
  bool isPlaying = false;
  RadioPlayer _radioPlayer = RadioPlayer();
  int idx = 0;

  @override
  void initState() {
    super.initState();
    initiateData();
  }

  @override
  void dispose() async {
    super.dispose();
  }

  Future<void> _launchInWebViewOrVC(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        universalLinksOnly: true,
      );
    }
  }

  checkTokenisExist() async {
    if (token != "") {
      return true;
    } else {
      return false;
    }
  }

  likeManagement(id, value) async {
    if (await checkTokenisExist()) {
      if (value == true) {
        await removeLikeItem(id);
      } else {
        await addLikeItem(id);
      }
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AuthLoginPage()),
      );
    }
  }

  addLikeItem(id) async {
    await ApiServices().addLikeItem(token, id.toString()).then((json) {
      if (json != null) {
        if (json['status'] == 'success') {
          initiateData();
          setState(() {});
        } else {
          alertError(json.toString(), 1);
          print(alertError(json.toString(), 1));
        }
      }
    }).catchError((e) {
      alertError(e.toString(), 1);
    });
  }

  removeLikeItem(id) async {
    await ApiServices().removeLikeItem(token, id.toString()).then((json) {
      if (json != null) {
        if (json['status'] == 'success') {
          initiateData();
          setState(() {});
        } else {
          alertError(json.toString(), 1);
        }
      }
    }).catchError((e) {
      alertError(e.toString(), 1);
    });
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

  initiateData() async {
    setState(() {
      isLoading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    
    token = prefs.getString('token').toString();
    if (prefs.getString('streamingRadio') != "") {
      pathUrl.add(jsonDecode(prefs.getString('streamingRadio')!));
    }

    _radioPlayer.stateStream.listen((value) {
      setState(() {
        isPlaying = value;
      });
      print(pathUrl[0]['link_stream']);
      print(pathUrl[0]['name']);
    });
    print(pathUrl);
    setState(() {
      isLoading = false;
    });
  }

  // Future<void> initRadioService() async {
  //   try {
  //     await _flutterRadioPlayer.init(
  //       "",
  //       "",
  //       pathUrl[0]['channel'],
  //       "false",
  //     );
  //   } on PlatformException {
  //     print("Exception occurred while trying to register the services.");
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    const String igUrl = 'https://www.instagram.com/bsk.radionetwork/';
    const String fbUrl = 'https://www.facebook.com/bskgroupsamarinda/';
    const String webUrl = 'https://bskmedia.co.id/';
    const String youtubeUrl =
        'https://www.youtube.com/channel/UCp-_MIm95m3U-dE_lXl5ekw';
    const String twitcheUrl = 'https://www.twitch.tv/bskmedia';
    windowHeight = MediaQuery.of(context).size.height;
    windowWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Color(0xFF2C3246),
            title: Text("Play Radio", style: GoogleFonts.nunito(fontSize: 25))),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: windowHeight * 0.04,
              ),
              Expanded(
                  flex: 1,
                  child: Align(
                      alignment: Alignment.center,
                      child: Image.network(
                        !isLoading
                            ? pathUrl[0]['image']['name'] == "default.jpg"
                                ? "'https://t4.ftcdn.net/jpg/00/89/55/15/360_F_89551596_LdHAZRwz3i4EM4J0NHNHy2hEUYDfXc0j.jpg'"
                                : pathUrl[0]['image']['path'].toString()
                            : 'https://t4.ftcdn.net/jpg/00/89/55/15/360_F_89551596_LdHAZRwz3i4EM4J0NHNHy2hEUYDfXc0j.jpg',
                        width: windowWidth * 0.8,
                        height: windowWidth * 0.8,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.network(
                            'https://t4.ftcdn.net/jpg/00/89/55/15/360_F_89551596_LdHAZRwz3i4EM4J0NHNHy2hEUYDfXc0j.jpg',
                            width: 50,
                            height: 50,
                          );
                        },
                      ))),
              SizedBox(
                height: windowHeight * 0.04,
              ),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(!isLoading ? pathUrl[0]['name'] : '',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.nunito(
                              color: Colors.black54, fontSize: 25)),
                      SizedBox(
                        height: windowHeight * 0.01,
                      ),
                      Text(
                          !isLoading
                              ? pathUrl[0]['channel']
                              : 'saluran radio (109.0 fm)',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.nunito(
                              color: Colors.black54, fontSize: 25)),
                      SizedBox(
                        height: windowHeight * 0.01,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            iconSize: 40,
                            icon: const Icon(Icons.share),
                            onPressed: () {
                              // share();
                              setState(() async {
                                await FlutterShare.share(
                                    title: pathUrl[0]['name'],
                                    text: pathUrl[0]['channel'] +
                                        "\n \n Untuk lebih lengkapnya bisa download apilikasi BSK Media di link ",
                                    linkUrl: 'https://flutter.dev/',
                                    chooserTitle: 'aaaaaa');
                              });
                            },
                          ),
                          SizedBox(
                            width: windowWidth * 0.05,
                          ),
                          IconButton(
                            iconSize: 60,
                            onPressed: () {
                              print(pathUrl.length);
                              isPlaying
                                  ? _radioPlayer.pause()
                                  : _radioPlayer.play();
                            },
                            icon: Icon(
                              isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                            ),
                          ),
                          SizedBox(
                            width: windowWidth * 0.05,
                          ),
                          FavoriteButton(
                            iconSize: 60,
                            isFavorite: false,
                            valueChanged: (value) {
                              value = likeManagement(
                                  pathUrl[0]['id'], pathUrl[0]['has_like']);
                              print('Is Favorite : $value');
                            },
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        ));
  }
}
