// ignore_for_file: unused_import, unused_field, avoid_unnecessary_containers, prefer_const_constructors

import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:herbal/api/api_services.dart';
import 'package:herbal/pages/auth/authlogin.dart';
import 'package:herbal/pages/newspaper_details/newspaper_details_public.dart';
import 'package:herbal/shared/shared.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsPaperListPublic extends StatefulWidget {
  const NewsPaperListPublic({Key? key}) : super(key: key);

  @override
  NewsPaperListPublicState createState() => NewsPaperListPublicState();
}

class NewsPaperListPublicState extends State<NewsPaperListPublic> {
  TextEditingController find = TextEditingController();
  double windowHeight = 0;
  double windowWidth = 0;
  String token = '';
  bool isLoading = true;
  var tempData = [];
  var generalData = [];
  Future<void>? _launched;

  var optCategory = [
    {'name': 'All Category', 'val': ''},
    {'name': 'Olahraga', 'val': 'sport'},
    {'name': 'Kesehatan', 'val': 'health'},
    {'name': 'Sosial dan Budaya', 'val': 'social'}
  ];
  String category = "";
  @override
  void initState() {
    super.initState();
    initiateData();
  }

  Future <void> initiateData() async {
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

  getItem() async {
    setState(() {
      isLoading = true;
    });
    await ApiServices().getNewsUser(token, category).then((json) {
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
      print(e.toString());
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
        await removeLikeNews(id);
      } else {
        await addLikeNews(id);
      }
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AuthLoginPage()),
      ).then((value) => initiateData());
    }
  }

  addLikeNews(id) async {
    await ApiServices().addLikeNews(token, id.toString()).then((json) {
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

  removeLikeNews(id) async {
    await ApiServices().removeLikeNews(token, id.toString()).then((json) {
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

  detailBerita(var dataIdCart) async {
    final prefs = await SharedPreferences.getInstance();
    var sendData = [dataIdCart];
    prefs.setString('dataBerita', jsonEncode(sendData));
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const NewspaperDetailsPublic()));
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
        title: Text(
          "Berita",
          style: GoogleFonts.nunito(fontSize:25),
        ),
      ),
      body: DoubleBackToCloseApp(
          snackBar: SnackBar(
              duration: const Duration(seconds: 1),
              width: windowWidth * 0.7,
              behavior: SnackBarBehavior.floating,
              elevation: 6.0,
              content: Text(
                'Tekan sekali lagi untuk keluar',
                style: GoogleFonts.nunito(fontSize: 30),
                textAlign: TextAlign.center,
              )),
          child: RefreshIndicator(
            onRefresh: initiateData,
            child: SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: DropdownButtonFormField<String>(
          
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Color(0xFF2C3246)),
                                  borderRadius: BorderRadius.circular(10))),
                          isExpanded: false,
                          items:
                              optCategory.map<DropdownMenuItem<String>>((items) {
                            return DropdownMenuItem(
                                value: items['val'].toString(),
                                child: Text(
                                  items['name'].toString(),
                                  style: GoogleFonts.nunito(fontSize: 20),
                                ));
                          }).toList(),
                          value: category,
                          onChanged: (val) => setState(() {
                            category = val.toString();
                            initiateData();
                          }),
                          onSaved: (val) => setState(() {
                            category = val.toString();
                          }),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      for (int index = 0; index < tempData.length; index++)
                        Container(
                          margin: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(20.0)),
                          ),
                          child: InkWell(
                              splashColor: Colors.white,
                              highlightColor: Colors.blue.withOpacity(0.5),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(20.0)),
                              onTap: () => detailBerita(tempData[index]),
                              child: Container(
                                margin: EdgeInsets.all(12.0),
                                padding: EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12.0),
                                    // ignore: prefer_const_literals_to_create_immutables
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 3.0,
                                      ),
                                    ]),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.fromLTRB(12, 0, 12, 0),
                                      height: 200.0,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12.0),
                                        image: DecorationImage(
                                            image: NetworkImage(
                                              tempData.isNotEmpty
                                                  ? tempData[index]['image']
                                                          ['path']
                                                      .toString()
                                                  : 'https://t4.ftcdn.net/jpg/00/89/55/15/360_F_89551596_LdHAZRwz3i4EM4J0NHNHy2hEUYDfXc0j.jpg',
                                                  
                                            ),
                                            fit: BoxFit.cover),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 8.0,
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(6.0),
                                      decoration: BoxDecoration(
                                        color: Color(0xFF2C3246),
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                      child: Text(
                                        !isLoading
                                            ? tempData[index]['author'].toString()
                                            : '',
                                        textAlign: TextAlign.left,
                                        style: GoogleFonts.nunito(
                                          color: Colors.white,
                                          fontSize: 18.0,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 8.0,
                                    ),
                                    Container(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                              child: Container(
                                            child: Text(
                                              !isLoading
                                                  ? tempData[index]['title']
                                                      .toString()
                                                  : '',
                                              softWrap: false,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.nunito(
                                                fontSize: 25.0,
                                              ),
                                            ),
                                          )),
                                          // Container(
                                          //   alignment: Alignment.centerRight,
                                          //   child: IconButton(
                                          //     iconSize: 35,
                                          //     onPressed: () {
                                          //       likeManagement(
                                          //           tempData[index]['id'],
                                          //           tempData[index]['has_like']);
                                          //     },
                                          //     icon: Icon(
                                          //       tempData[index]['has_like']
                                          //           ? Icons.favorite
                                          //           : Icons.favorite_outline,
                                          //       color: tempData[index]['has_like']
                                          //           ? Colors.red
                                          //           : Color(0xFF2C3246),
                                          //     ),
                                          //   ),
                                          // ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              )),
                        )
                    ],
                  )),
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
