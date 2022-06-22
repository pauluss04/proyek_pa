// ignore_for_file: unused_import, unused_field, prefer_const_constructors, avoid_unnecessary_containers

import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:herbal/api/api_services.dart';
import 'package:herbal/pages/auth/authlogin.dart';
import 'package:herbal/pages/radio_details/radio_details_pubic.dart';
import 'package:herbal/shared/shared.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class RadioListPublic extends StatefulWidget {
  const RadioListPublic({Key? key}) : super(key: key);

  @override
  RadioListPublicState createState() => RadioListPublicState();
}

class RadioListPublicState extends State<RadioListPublic> {
  double windowHeight = 0;
  double windowWidth = 0;
  String token = '';

  var tempData = [];
  bool isLoading = true;
  var generalData = [];
  Future<void>? _launched;

  @override
  void initState() {
    super.initState();
    initiateData();
  }

  Future<void> initiateData() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('token') != null) {
      token = prefs.getString('token').toString();
    }
    await getItem();
    await getGeneralItem();
  }

  getGeneralItem() async {
    await ApiServices().getGeneralData().then((json) {
      if (json != null) {
        setState(() {
          generalData.add(json);
        });
      }
    }).catchError((e) {
      alertError(e.toString(), 1);
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
    await ApiServices().addLikeRadio(token, id.toString()).then((json) {
      if (json != null) {
        if (json['status'] == 'success') {
          initiateData();
        } else {
          alertError(json.toString(), 1);
        }
      }
    }).catchError((e) {
      alertError(e.toString(), 1);
    });
  }

  removeLikeItem(id) async {
    await ApiServices().removeLikeRadio(token, id.toString()).then((json) {
      if (json != null) {
        if (json['status'] == 'success') {
          initiateData();
        } else {
          alertError(json.toString(), 1);
        }
      }
    }).catchError((e) {
      alertError(e.toString(), 1);
    });
  }

  getItem() async {
    setState(() {
      isLoading = true;
    });
    await ApiServices().getRadioUser(token).then((json) {
      if (json != null) {
        if (json['status'] == 'success') {
          setState(() {
            tempData = json['data']['data'];
          });
        } else {
          alertError(json.toString(), 1);
        }
      }
    }).catchError((e) {
      alertError(e.toString(), 1);
    });
    setState(() {
      isLoading = false;
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
            title: 'Error',
            desc: err,
            btnOkOnPress: () {},
            btnOkIcon: Icons.cancel,
            btnOkColor: Colors.red)
        .show();
  }

  streamingRadio(index) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('streamingRadio', jsonEncode(tempData[index]));

    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const RadioDetailsPublic()));
  }

  Future<void> _launchInWebViewOrVC(String text, String no) async {
    String url = "https://wa.me/" + no + "&?text=" + text;
    if (await canLaunch(url)) {
      await launch(
        url,
        universalLinksOnly: true,
      );
    }
  }

  whatsappUrl() {
    setState(() {
      isLoading = false;
    });
    AwesomeDialog(
      context: context,
      dialogType: DialogType.NO_HEADER,
      animType: AnimType.SCALE,
      headerAnimationLoop: false,
      body: Padding(
        padding: EdgeInsets.all(18),
        child: Column(
          // ignore: prefer_const_literals_to_create_immutables
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  _launched = _launchInWebViewOrVC(
                      "Permisi, Saya ingin menanyakan tentang Obat Herbal",
                      "+6281223235544");
                });
              },
              child: ListTile(
                leading: Icon(Icons.phone),
                title: Text('Bio 7 , Alpha Propolis', style: GoogleFonts.nunito(fontSize : 22)),
                subtitle: Text('081223235544',style: GoogleFonts.nunito(fontSize : 18)),
              ),
            ),
            InkWell(
              onTap: () {
                setState(() {
                  _launched = _launchInWebViewOrVC(
                      "Permisi, Saya ingin menanyakan tentang Obat Herbal",
                      "+6282256789933");
                });
              },
              child: ListTile(
                leading: Icon(Icons.phone),
                title: Text('Nano Energizer, Dr SDISNI, VITMAN, Alpha King', style: GoogleFonts.nunito(fontSize : 22)),
                subtitle: Text('082256789933',style: GoogleFonts.nunito(fontSize : 18)),
              ),
            ),
            InkWell(
              onTap: () {
                setState(() {
                  _launched = _launchInWebViewOrVC(
                      "Permisi, Saya ingin menanyakan tentang Obat Herbal",
                      "+6281254683728");
                });
              },
              child: ListTile(
                leading: Icon(Icons.phone),
                title: Text('MKing', style: GoogleFonts.nunito(fontSize : 22)),
                subtitle: Text('081254683728',style: GoogleFonts.nunito(fontSize : 18)),
              ),
            ),
            InkWell(
              onTap: () {
                setState(() {
                  _launched = _launchInWebViewOrVC(
                      "Permisi, Saya ingin menanyakan tentang Obat Herbal",
                      "+6281344756669");
                });
              },
              child: ListTile(
                leading: Icon(Icons.phone),
                title: Text(
                    'King Pandanus, Herbal King Temu Putih, Herbal King Kunyit',style: GoogleFonts.nunito(fontSize : 22)),
                subtitle: Text('081344756669',style: GoogleFonts.nunito(fontSize : 18)),
              ),
            ),
            InkWell(
              onTap: () {
                setState(() {
                  _launched = _launchInWebViewOrVC(
                      "Permisi, Saya ingin menanyakan tentang Seputar BSK Media",
                      "+6285247297798");
                });
              },
              child: ListTile(
                leading: Icon(Icons.phone),
                title: Text('Customer Service Bsk Media',style: GoogleFonts.nunito(fontSize : 22)),
                subtitle: Text('085247297798',style: GoogleFonts.nunito(fontSize : 18)),
              ),
            )
          ],
        ),
      ),
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    windowHeight = MediaQuery.of(context).size.height - 25;
    windowWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF2C3246),
        title: Text("Radio", style: GoogleFonts.nunito(fontSize: 25)),
      ),
      body: DoubleBackToCloseApp(
          snackBar: SnackBar(
              duration: const Duration(seconds: 1),
              width: windowWidth * 0.7,
              behavior: SnackBarBehavior.floating,
              elevation: 6.0,
              content: Text(
                'Tekan sekali lagi untuk keluar',
                style: GoogleFonts.nunito(fontSize: 14),
                textAlign: TextAlign.center,
              )),
          child: RefreshIndicator(
            onRefresh: initiateData,
            child: SafeArea(
              bottom: false,
              child: isLoading
                  ? Shimmer.fromColors(
                      baseColor: Colors.black12,
                      highlightColor: Colors.black26,
                      enabled: isLoading,
                      // ignore: sized_box_for_whitespace
                      child: Container(
                        height: windowHeight,
                        width: double.infinity,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              for (var i = 0; i < 5; i++)
                                Container(
                                  margin: const EdgeInsets.all(10),
                                  height: 70,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                            ]),
                      ))
                  : Stack(children: <Widget>[
                      RefreshIndicator(
                        onRefresh: initiateData,
                        child: GridView(
                          shrinkWrap: true,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16),
                          children: [
                            for (int index = 0;
                                index < tempData.length;
                                index++)
                              Center(
                                child: Container(
                                  margin: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.shade200,
                                        spreadRadius: 3,
                                        blurRadius: 10,
                                        offset: Offset(0, 3),
                                      )
                                    ],
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20.0)),
                                    color: Colors.white,
                                  ),
                                  child: InkWell(
                                    splashColor: Colors.yellow,
                                    highlightColor:
                                        Colors.blue.withOpacity(0.5),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(20.0)),
                                    onTap: () => streamingRadio(index),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 25, horizontal: 5),
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Image.network(
                                              tempData[index]['image']['path']
                                                  .toString(),
                                              width: 100,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Image.network(
                                                  'https://t4.ftcdn.net/jpg/00/89/55/15/360_F_89551596_LdHAZRwz3i4EM4J0NHNHy2hEUYDfXc0j.jpg',
                                                  width: 100,
                                                );
                                              },
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 20),
                                                child: Text(
                                                  tempData[index]['name']
                                                      .toString(),
                                                  maxLines: 1,
                                                  textAlign: TextAlign.center,
                                                  style: GoogleFonts.nunito(
                                                      fontSize: 20),
                                                ),
                                              ),
                                            ),
                                            // Expanded(
                                            //   child: IconButton(
                                            //     onPressed: () {
                                            //       likeManagement(
                                            //           tempData[index]['id'],
                                            //           tempData[index]['has_like']);
                                            //     },
                                            //     icon: Icon(
                                            //       tempData[index]['has_like']
                                            //           ? Icons.favorite
                                            //           : Icons.favorite_border,
                                            //       color: tempData[index]['has_like']
                                            //           ? Colors.red
                                            //           : Color(0xFF2C3246),
                                            //     ),
                                            //     color: Color(0xFF2C3246),
                                            //   ),
                                            // )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                          ],
                        ),
                      )
                    ]),
            ),
          )),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.transparent,
        child: Image.network(
          "https://drive.google.com/uc?export=view&id=1XTUl-P77mdrQdEsG6-rdarojcxwQQ7h3",
          height: 50,
        ),
        onPressed: () => setState(() {
          _launched = whatsappUrl();
        }),
      ),
    );
  }
}
