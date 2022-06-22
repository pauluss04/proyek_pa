// ignore_for_file: unused_import, unnecessary_null_comparison, avoid_print

import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:herbal/api/api_services.dart';
import 'package:herbal/pages/address_list/list_address.dart';
import 'package:herbal/pages/auth/authlogin.dart';
import 'package:herbal/pages/detail_myprofile/detail_myprofile_public.dart';
import 'package:herbal/pages/home_public.dart';
import 'package:herbal/pages/list_cart/list_cart.dart';
import 'package:herbal/pages/list_favorite/list_favorite.dart';
import 'package:herbal/pages/list_transaction/list_transaction.dart';
import 'package:herbal/pages/subhome_public/homelistpublic.dart';
import 'package:herbal/shared/shared.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class MyProfilePublic extends StatefulWidget {
  const MyProfilePublic({Key? key}) : super(key: key);

  @override
  MyProfilePublicState createState() => MyProfilePublicState();
}

class MyProfilePublicState extends State<MyProfilePublic> {
  double windowHeight = 0;
  double windowWidth = 0;
  String token = '';
  bool cropProses = false;
  var tempData = [];
  bool isLoading = true;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  void initState() {
    super.initState();
    initiateData();
  }

  initiateData() async {
    setState(() {
      isLoading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('token') != null) {
      token = prefs.getString('token').toString();
    }
    tempData = [];
    if (token != "") {
      await getItem();
    }
    setState(() {
      isLoading = false;
    });
  }

  getItem() async {
    await ApiServices().getProfileUser(token).then((json) {
      if (json != null) {
        if (json['status'] == 'success') {
          setState(() {
            tempData.add(json['data']);
          });
        }
      }
    }).catchError((e) {
      alertError(e.toString(), 1);
    });
  }

  logoutProses() async {
    bool isSignedGoogle = await _googleSignIn.isSignedIn();
    await ApiServices().logoutLogin(token).then((json) async {
      if (json != null) {
        var jsonConvert = jsonDecode(json);
        if (jsonConvert['status'] == 'success') {
          SharedPreferences preferences = await SharedPreferences.getInstance();
          await preferences.clear();
          print(isSignedGoogle);
          if (isSignedGoogle == true) {
            print('login google true');
            await _handleSignOut();
            Navigator.of(context)
                .pushReplacement(MaterialPageRoute(builder: (_) {
              return const AuthLoginPage();
            }));
          } else {
            Navigator.of(context)
                .pushReplacement(MaterialPageRoute(builder: (_) {
              return const HomePublicPage();
            }));
          }
        } else {
          alertError(json.toString(), 1);
        }
      }
    }).catchError((e) {
      alertError(e.toString(), 1);
    });
  }

  Future<void> _handleSignOut() => _googleSignIn.disconnect();
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

  @override
  Widget build(BuildContext context) {
    windowHeight = MediaQuery.of(context).size.height - 25;
    windowWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Color(0xFF2C3246),
          title: Text(
            "Setelan",
            style: GoogleFonts.nunito(fontSize: 25),
          ),
        ),
        body: SafeArea(
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
                          for (var i = 0; i < 6; i++)
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
              : token != ""
                  ? SingleChildScrollView(
                      child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //profile user
                              Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 20),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: Image.network(
                                          !isLoading
                                              ? tempData[0]['image']['name'] ==
                                                      "default.jpg"
                                                  ? "'https://t4.ftcdn.net/jpg/00/89/55/15/360_F_89551596_LdHAZRwz3i4EM4J0NHNHy2hEUYDfXc0j.jpg'"
                                                  : tempData[0]['image']['path']
                                                      .toString()
                                              : 'https://t4.ftcdn.net/jpg/00/89/55/15/360_F_89551596_LdHAZRwz3i4EM4J0NHNHy2hEUYDfXc0j.jpg',
                                          width: 120,
                                          height: 120,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Image.network(
                                              'https://t4.ftcdn.net/jpg/00/89/55/15/360_F_89551596_LdHAZRwz3i4EM4J0NHNHy2hEUYDfXc0j.jpg',
                                              width: 120,
                                              height: 120,
                                            );
                                          },
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 5),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              !isLoading
                                                  ? tempData[0]['name']
                                                  : 'Nama Pengguna',
                                              style: GoogleFonts.nunito(
                                                  color: Colors.black87,
                                                  fontSize: 23),
                                            ),
                                            SizedBox(
                                              height: windowHeight * 0.01,
                                            ),
                                            Text(
                                              !isLoading
                                                  ? tempData[0]['no_telephone']
                                                      .toString()
                                                  : 'Nomor telepon',
                                              style: GoogleFonts.nunito(
                                                  color: Colors.black87,
                                                  fontSize: 18),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  )),
                              //Ubah Profil
                              Container(
                                padding: EdgeInsets.only(left: 10),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Pengaturan Akun",
                                        textAlign: TextAlign.start,
                                        style: GoogleFonts.nunito(
                                            color: Colors.black87,
                                            fontSize: 23),
                                      ),
                                      SizedBox(
                                        height: windowHeight * 0.02,
                                      ),
                                      Row(children: [
                                        Icon(
                                          Icons.account_circle_rounded,
                                          size: windowWidth * 0.08,
                                          color: Colors.black87,
                                        ),
                                        SizedBox(
                                          width: windowWidth * 0.02,
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: TextButton(
                                            onPressed: () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const MyDetailProfilePublic()),
                                            ).then((value) => initiateData()),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                  "Ubah Profil",
                                                  style: GoogleFonts.nunito(
                                                      color: Colors.black87,
                                                      fontSize: 23),
                                                ),
                                                SizedBox(
                                                  height: 2,
                                                ),
                                                Text(
                                                  "Mengubah data diri pengguna",
                                                  style: GoogleFonts.nunito(
                                                      color: Colors.black87,
                                                      fontSize: 18),
                                                ),
                                              ],
                                            ),
                                            style: ButtonStyle(
                                              alignment: Alignment
                                                  .centerLeft, // <-- had to set alignment
                                              padding: MaterialStateProperty
                                                  .all<EdgeInsetsGeometry>(
                                                const EdgeInsets.all(
                                                    0), // <-- had to set padding to 0
                                              ),
                                            ),
                                          ),
                                        )
                                      ]),
                                    ]),
                              ),
                              SizedBox(
                                height: windowHeight * 0.01,
                              ),
                              //Daftar Alamat
                              Container(
                                padding: EdgeInsets.only(left: 10),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.location_pin,
                                      size: windowWidth * 0.08,
                                      color: Colors.black87,
                                    ),
                                    SizedBox(
                                      width: windowWidth * 0.02,
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: TextButton(
                                        onPressed: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const ListAddress()),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              "Daftar Alamat",
                                              style: GoogleFonts.nunito(
                                                  color: Colors.black87,
                                                  fontSize: 23),
                                            ),
                                            SizedBox(
                                              height: 2,
                                            ),
                                            Text(
                                              "Atur alamat pengiriman belanjaan",
                                              style: GoogleFonts.nunito(
                                                  color: Colors.black87,
                                                  fontSize: 18),
                                            ),
                                          ],
                                        ),
                                        style: ButtonStyle(
                                          alignment: Alignment
                                              .centerLeft, // <-- had to set alignment
                                          padding: MaterialStateProperty.all<
                                              EdgeInsetsGeometry>(
                                            const EdgeInsets.all(
                                                0), // <-- had to set padding to 0
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: windowHeight * 0.02,
                              ),

                              SizedBox(
                                height: windowHeight * 0.02,
                              ),
                              //Daftar Kenginan
                              Container(
                                padding: EdgeInsets.only(left: 10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Aktifitas Saya",
                                        textAlign: TextAlign.start,
                                        style: GoogleFonts.nunito(
                                            color: Colors.black87,
                                            fontSize: 23,
                                            fontWeight: FontWeight.normal)),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.favorite,
                                          size: windowWidth * 0.08,
                                          color: Colors.black87,
                                        ),
                                        SizedBox(
                                          width: windowWidth * 0.02,
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: TextButton(
                                            onPressed: () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const ListFavorite()),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                  "Daftar Keinginan",
                                                  style: GoogleFonts.nunito(
                                                      color: Colors.black87,
                                                      fontSize: 23),
                                                ),
                                                SizedBox(
                                                  height: 2,
                                                ),
                                                Text(
                                                  "Menampilkan daftar keinginan",
                                                  style: GoogleFonts.nunito(
                                                      color: Colors.black87,
                                                      fontSize: 18),
                                                ),
                                              ],
                                            ),
                                            style: ButtonStyle(
                                              alignment: Alignment
                                                  .centerLeft, // <-- had to set alignment
                                              padding: MaterialStateProperty
                                                  .all<EdgeInsetsGeometry>(
                                                const EdgeInsets.all(
                                                    0), // <-- had to set padding to 0
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              //Daftar Transaksi
                              Container(
                                padding: EdgeInsets.only(left: 10),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.assignment_outlined,
                                      size: windowWidth * 0.08,
                                      color: Colors.black87,
                                    ),
                                    SizedBox(
                                      width: windowWidth * 0.02,
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: TextButton(
                                        onPressed: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const TransactionList()),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              "Daftar Transaksi",
                                              style: GoogleFonts.nunito(
                                                  color: Colors.black87,
                                                  fontSize: 23),
                                            ),
                                            SizedBox(
                                              height: 2,
                                            ),
                                            Text(
                                              "Menampilkan daftar transaksi pengguna",
                                              style: GoogleFonts.nunito(
                                                  color: Colors.black87,
                                                  fontSize: 18),
                                            ),
                                          ],
                                        ),
                                        style: ButtonStyle(
                                          alignment: Alignment
                                              .centerLeft, // <-- had to set alignment
                                          padding: MaterialStateProperty.all<
                                              EdgeInsetsGeometry>(
                                            const EdgeInsets.all(
                                                0), // <-- had to set padding to 0
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: windowWidth * 0.01,
                              ),
                              //Daftar Keranjang
                              Container(
                                padding: EdgeInsets.only(left: 10),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.shop,
                                      size: windowWidth * 0.08,
                                      color: Colors.black87,
                                    ),
                                    SizedBox(
                                      width: windowWidth * 0.02,
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: TextButton(
                                        onPressed: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const ListCart()),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              "Daftar Keranjang",
                                              style: GoogleFonts.nunito(
                                                  color: Colors.black87,
                                                  fontSize: 23),
                                            ),
                                            SizedBox(
                                              height: 2,
                                            ),
                                            Text(
                                              "Menampilkan daftar keranjang pengguna",
                                              style: GoogleFonts.nunito(
                                                  color: Colors.black87,
                                                  fontSize: 18),
                                            ),
                                          ],
                                        ),
                                        style: ButtonStyle(
                                          alignment: Alignment
                                              .centerLeft, // <-- had to set alignment
                                          padding: MaterialStateProperty.all<
                                              EdgeInsetsGeometry>(
                                            const EdgeInsets.all(
                                                0), // <-- had to set padding to 0
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 50),

                              Align(
                                alignment: Alignment.center,
                                child: Container(
                                  margin: const EdgeInsets.all(16),
                                  decoration: const BoxDecoration(
                                      shape: BoxShape.circle),
                                  child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          onPrimary: defaultColor,
                                          primary: Color(0xFF2C3246),
                                          shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(20.0)))),
                                      onPressed: () => logoutProses(),
                                      child: Container(
                                        constraints: const BoxConstraints(
                                            maxWidth: 150.0, minHeight: 50.0),
                                        alignment: Alignment.center,
                                        child: Text(
                                          "Keluar",
                                          style: GoogleFonts.nunito(
                                              color: Colors.white,
                                              fontSize: 20),
                                        ),
                                      )),
                                ),
                              )
                            ],
                          )),
                    )
                  : Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 20),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SvgPicture.network(
                              "https://drive.google.com/uc?export=view&id=1HVluhHFQpc2SNS3UnXphFa75AVV2wO7f",
                              height: 150,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Align(
                                alignment: Alignment.center,
                                child: Container(
                                  margin: const EdgeInsets.all(16),
                                  decoration: const BoxDecoration(
                                      shape: BoxShape.circle),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      primary: Color(0xFF2C3246),
                                      onPrimary: defaultColor,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(80.0)),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const AuthLoginPage()),
                                      ).then((value) => initiateData());
                                    },
                                    child: Container(
                                      constraints: const BoxConstraints(
                                          maxWidth: 150.0, minHeight: 50.0),
                                      alignment: Alignment.center,
                                      child: Text(
                                        "Masuk",
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.nunito(
                                            color: Colors.white, fontSize: 20),
                                      ),
                                    ),
                                  ),
                                )),
                          ])),
        ));
  }
}
