// ignore_for_file: avoid_print, unnecessary_new

import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:herbal/api/api_services.dart';
import 'package:herbal/pages/auth/authlogin.dart';
import 'package:herbal/pages/list_cart/list_cart.dart';
import 'package:herbal/pages/medicine_details/medicine_details.dart';
import 'package:herbal/shared/shared.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class MedicinePage extends StatefulWidget {
  const MedicinePage({Key? key}) : super(key: key);

  @override
  MedicinePageState createState() => MedicinePageState();
}

class MedicinePageState extends State<MedicinePage> {
  TextEditingController find = TextEditingController();
  double windowHeight = 0;
  double windowWidth = 0;
  String token = "";
  var tempData = [];
  var generalData = [];
  int cartPending = 0;
  var list_unit = [];

  Future<void>? _launched;

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
    await getCart();
    await getItem();
    await getGeneralItem();
    await getUnits();
  }

  @override
  void dispose() {
    super.dispose();
  }

  getUnits() async {
    await ApiServices().getUnits(token).then((json) {
      if (json != null) {
        print(json);
        setState(() {
          list_unit = json;
        });
      }
    }).catchError((e) {
      alertError(e.toString(), 1);
    });
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
    await ApiServices().getItemsPublic(token, "", find.text).then((json) {
      if (json != null) {
        if (json['status'] == 'success') {
          setState(() {
            tempData = json['data']['data'];
          });
          print(tempData);
        } else {
          alertError(json.toString(), 1);
        }
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
    await ApiServices().addLikeItem(token, id.toString()).then((json) {
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
    await ApiServices().removeLikeItem(token, id.toString()).then((json) {
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

  getCart() async {
    if (await checkTokenisExist()) {
      final prefs = await SharedPreferences.getInstance();
      await ApiServices().getCart(token).then((json) {
        print("json");
        print(json);
        if (json != null) {
          if (json['status'] == 'success' && json['data']['data'].length > 0) {
            if (json['data']['data'][0]['data'].length > 0) {
              var tempSendCart = [];
              for (var i = 0; i < json['data']['data'][0]['data'].length; i++) {
                tempSendCart.add({
                  'id': json['data']['data'][0]['data'][i]['id'],
                  'volume': json['data']['data'][0]['data'][i]['volume'],
                  'price': json['data']['data'][0]['data'][i]['price']
                });
              }
              setState(() {
                cartPending = json['data']['data'][0]['data'].length;
              });
              prefs.setString('dataCart', jsonEncode(tempSendCart));
            } else {
              prefs.setString('dataCart', "");
              cartPending = 0;
            }
          }
        }
      }).catchError((e) {
        print('object');
        alertError(e.toString(), 1);
      });
    } else {
      cartPending = 0;
    }
  }

  alertError(String err, int error) {
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

  setIDCart(var dataIdCart) async {
    final prefs = await SharedPreferences.getInstance();
    var sendData = [await dataIdCart];
    await prefs.setString('idItemCart', jsonEncode(sendData));
    Navigator.push(context,
            MaterialPageRoute(builder: (context) => const MedicineDetails()))
        .then((value) => initiateData());
    // if (await checkTokenisExist()) {

    // } else {
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(builder: (context) => const AuthLoginPage()),
    //   ).then((value) => initiateData());
    // }
  }

  listCart() async {
    if (await checkTokenisExist()) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ListCart()),
      ).then((value) => initiateData());
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AuthLoginPage()),
      );
    }
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
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 1,
              child: Text("Obat Herbal", style: GoogleFonts.nunito(fontSize: 25)),
            ),
            Stack(children: [
              IconButton(
                  iconSize: 40,
                  onPressed: () {
                    listCart();
                  },
                  icon: const Icon(
                    Icons.shopping_cart,
                    size: 30,
                  )),
              new Positioned(
                  right: 1,
                  top: 3,
                  child: cartPending > 0
                      ? Container(
                          width: windowWidth * 0.07,
                          height: windowWidth * 0.05,
                          decoration: const BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0)),
                            color: Colors.red,
                          ),
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              cartPending.toString(),
                              style: GoogleFonts.nunito(
                                  color: Colors.white, fontSize: 15),
                            ),
                          ),
                        )
                      : Text(''))
            ])
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: initiateData,
        child: Container(
            margin: const EdgeInsets.all(20),
            child: ListView(children: [
              TextField(
                onEditingComplete: () => getItem(),
                controller: find,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    labelText: "Cari Obat"),
              ),
              SizedBox(
                height: 10,
              ),
              Align(
                alignment: Alignment.center,
                child: Wrap(
                  children: [
                    for (var i = 0; i < tempData.length; i++)
                      Container(
                        margin: const EdgeInsets.all(7),
                        width: windowWidth * 0.4,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            onPrimary: defaultColor,
                            onSurface: Colors.white,
                            primary: Colors.white,
                            shape:  RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)
                            ),
                          ),
                          onPressed: () {
                            setIDCart(tempData[i]);
                          },
                          child: Align(
                            alignment: Alignment.center,
                            child: Stack(
                              children: <Widget>[
                                // Positioned(
                                //   top: 0.0,
                                //   right: -10.0,
                                //   width: 50,
                                //   child: IconButton(
                                //     onPressed: () {
                                //       likeManagement(
                                //           tempData[i]['detail'][0]['id'],
                                //           tempData[i]['detail'][0]['has_like']);
                                //     },
                                //     icon: Icon(
                                //       tempData[i]['detail'][0]['has_like']
                                //           ? Icons.favorite
                                //           : Icons.favorite_outline,
                                //       color: tempData[i]['detail'][0]
                                //               ['has_like']
                                //           ? Colors.red
                                //           : Colors.blue,
                                //     ),
                                //     color: Colors.blue,
                                //   ),
                                // ),
                                Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Center(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: windowWidth * 0.01,
                                          height: windowHeight * 0.01,
                                        ),
                                        Align(
                                            alignment: Alignment.center,
                                            child: Image.network(
                                              tempData[i]['image']['path']
                                                  .toString(),
                                              width: 100,
                                              height: 100,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Image.network(
                                                  'https://t4.ftcdn.net/jpg/00/89/55/15/360_F_89551596_LdHAZRwz3i4EM4J0NHNHy2hEUYDfXc0j.jpg',
                                                  width: 90,
                                                );
                                              },
                                            )),
                                        SizedBox(
                                          width: windowWidth * 0.01,
                                          height: windowHeight * 0.01,
                                        ),
                                        Center(
                                          child: Text(
                                            tempData[i]['name'].toString(),
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.nunito(
                                              fontSize: 20,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: windowWidth * 0.01,
                                          height: windowHeight * 0.01,
                                        ),
                                        // Row(
                                        //   children: [
                                        //     Expanded(
                                        //       flex: 3,
                                        //       child: Text(
                                        //         "Rp. " +
                                        //             tempData[i]['detail'][0]
                                        //                     ['price']
                                        //                 .toString(),
                                        //         style: const TextStyle(
                                        //           color: Colors.black,
                                        //         ),
                                        //       ),
                                        //     ),
                                        //     Expanded(
                                        //         flex: 1,
                                        //         child: IconButton(
                                        //           highlightColor: Colors.black,
                                        //           onPressed: () {
                                        //             Navigator.push(
                                        //                 context,
                                        //                 MaterialPageRoute(
                                        //                     builder: (context) =>
                                        //                         const MedicineDetails()));
                                        //           },
                                        //           icon: const Icon(
                                        //             Icons.add_circle,
                                        //             size: 30,
                                        //             color: Colors.blueAccent,
                                        //           ),
                                        //         ))
                                        //   ],
                                        // ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                  ],
                ),
              )
            ])),
      ),
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
