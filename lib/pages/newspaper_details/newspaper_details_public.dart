// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:favorite_button/favorite_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:herbal/api/api_services.dart';
import 'package:herbal/pages/auth/authlogin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:url_launcher/url_launcher.dart';

class NewspaperDetailsPublic extends StatefulWidget {
  const NewspaperDetailsPublic({Key? key}) : super(key: key);

  @override
  NewspaperDetailsPublicState createState() => NewspaperDetailsPublicState();
}

class NewspaperDetailsPublicState extends State<NewspaperDetailsPublic> {
  double windowHeight = 0;
  double windowWidth = 0;
  var dataNews = [];
  bool isLoading = true;
  String token = "";
  var datePublish = "";
  @override
  void initState() {
    initializeDateFormatting('id');
    initiateData();
    super.initState();
  }

  initiateData() async {
    setState(() {
      isLoading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token').toString();
    String tempDataIdCart = prefs.getString('dataBerita')!;
    dataNews = json.decode(tempDataIdCart);
    datePublish = getCustomFormattedDateTime(
        dataNews[0]['created_at'], 'EEE, dd MMMM yyyy hh:mm a');
    setState(() {
      isLoading = false;
    });
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
    await ApiServices().addLikeNews(token, id.toString()).then((json) {
      if (json != null) {
        if (json['status'] == 'success') {
          initiateData();
          print("berhasil1");
          setState(() {});
        } else {
          print("error7");
          alertError(json.toString(), 1);
        }
      }
    }).catchError((e) {
      print("error6");
      alertError(e.toString(), 1);
    });
  }

  removeLikeItem(id) async {
    await ApiServices().removeLikeNews(token, id.toString()).then((json) {
      if (json != null) {
        if (json['status'] == 'success') {
          initiateData();
          print("berhasil2");
          setState(() {});
        } else {
          print("error9");
          alertError(json.toString(), 1);
        }
      }
    }).catchError((e) {
      print("error8");
      alertError(e.toString(), 1);
    });
  }

  alertError(String err, int error) {
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

  getCustomFormattedDateTime(String givenDateTime, String dateFormat) {
    final DateTime docDateTime = DateTime.parse(givenDateTime).toLocal();
    return DateFormat(dateFormat, 'id').format(docDateTime);
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
  Widget build(BuildContext context) {
    windowHeight = MediaQuery.of(context).size.height - 25;
    windowWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF2C3246),
          title: Text("Detail Berita", style: GoogleFonts.nunito(fontSize: 25)),
          actions: [
            for (int indext = 0; indext < dataNews.length; indext++)
              FavoriteButton(
                iconSize: 50,
                isFavorite: false,
                valueChanged: (value){
                  value = likeManagement(
                      dataNews[indext]['id'], dataNews[indext]['has_like']);
                  print('Is Favorite : $value');
              },),
              // LikeButton(
              //   onTap: onLikeButtonTapped,
              //   likeBuilder: (isLiked) {
              //     return Icon(
              //       Icons.home,
              //       color: isLiked ? Colors.red : Colors.grey,
              //     );
              //   },
              // ),
            // IconButton(
            //   iconSize: 30,
            //   icon: Icon(
            //     dataNews[indext]['has_like']
            //         ? Icons.favorite
            //         : Icons.favorite_border,
            //     color: dataNews[indext]['has_like'] ? Colors.red : Colors.white,
            //   ),
            //   onPressed: () {
            //     setState(() {
            //       // print(likeManagement(dataNews[i]['id'],
            //       //     dataNews[i]['has_like']));
            //       likeManagement(
            //           dataNews[indext]['id'], dataNews[indext]['has_like']);
            //     });
            //   },
            // ),
            IconButton(
              iconSize: 30,
              icon: const Icon(Icons.share),
              onPressed: () {
                // share();
                setState(() async {
                  await FlutterShare.share(
                      title: dataNews[0]['title'],
                      text: dataNews[0]['description'] +
                          "\n \n Untuk lebih lengkapnya bisa download aplikasi BSK Media di link ",
                      linkUrl: 'https://flutter.dev/',
                      chooserTitle: 'aaaaaa');
                });
              },
            ),
          ],
        ),
        body: SafeArea(
            child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Stack(
            children: [
              Image.network(
                  !isLoading
                      ? dataNews[0]['image']['path'].toString()
                      : 'https://t4.ftcdn.net/jpg/00/89/55/15/360_F_89551596_LdHAZRwz3i4EM4J0NHNHy2hEUYDfXc0j.jpg',
                  fit: BoxFit.contain,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.4),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 275.0, 0, 0),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Material(
                    shadowColor: Colors.black,
                    borderRadius: BorderRadius.circular(35),
                    child: Scrollbar(
                        child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                          child: Text(!isLoading ? dataNews[0]['title'] : '',
                              style: GoogleFonts.nunito(
                                  fontSize: 26, fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: EdgeInsets.all(5),
                          child: Text(!isLoading ? datePublish : '',
                              style: GoogleFonts.nunito(
                                  fontSize: 21, fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: EdgeInsets.all(5),
                          child: Text(!isLoading ? dataNews[0]['author'] : '',
                              style: GoogleFonts.nunito(
                                  fontSize: 21, fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(
                              !isLoading ? dataNews[0]['description'] : '',
                              style: GoogleFonts.nunito(fontSize: 20)),
                        ),
                        Padding(
                          padding: EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Text("Source",
                                  style: GoogleFonts.nunito(fontSize: 18)),
                              TextButton(
                                onPressed: () {
                                  _launchInWebViewOrVC(
                                      dataNews[0]['link'].toString());
                                },
                                child: Text(
                                    !isLoading ? dataNews[0]['source'] : '',
                                    style: GoogleFonts.nunito(fontSize: 18)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )),
                  ),
                ),
              ),
            ],
          ),
        )));
  }
}
