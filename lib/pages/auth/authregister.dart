import 'dart:convert';
import 'dart:ui';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:herbal/api/api_services.dart';
import 'package:herbal/shared/shared.dart';
import 'package:herbal/widgets/loading.dart';

class AuthRegisterPage extends StatefulWidget {
  const AuthRegisterPage({Key? key}) : super(key: key);

  @override
  AuthRegisterState createState() => AuthRegisterState();
}

class AuthRegisterState extends State<AuthRegisterPage> {
  double windowHeight = 0;
  double windowWidth = 0;
  bool hidePassword = true;
  bool hideConfirmPassword = true;
  TextEditingController username = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController noTelp = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();
  TextEditingController address = TextEditingController();
  bool isLoading = false;
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

  registerProsses() async {
    if (username.text != "" &&
        email.text != "" &&
        noTelp.text != "" &&
        password.text != "" &&
        confirmPassword.text != "" &&
        address.text != "") {
      setState(() {
        noTelp.text = noTelp.text.replaceFirst('0', '');
      });
      setState(() {
        isLoading = true;
      });
      await ApiServices()
          .registerPublicUser(username.text, email.text, password.text,
              confirmPassword.text, noTelp.text, address.text)
          .then((json) {
        if (json != null) {
          var jsonConvert = jsonDecode(json);
          if (jsonConvert['status'] == "success") {
            setState(() {
              isLoading = false;
            });
            Navigator.pop(context);
          }
        }
      }).catchError((e) {
        alertError(e.toString(), 1);
      });
    } else {
      alertError('Data harus di isi semua!', 0);
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    windowHeight = MediaQuery.of(context).size.height - 25;
    windowWidth = MediaQuery.of(context).size.width;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          textTheme: GoogleFonts.latoTextTheme(Theme.of(context).textTheme)),
      home: Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
              child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: double.infinity,
                child: Stack(children: <Widget>[
                  // ignore: sized_box_for_whitespace
                  Positioned(
                    top: 200,
                    left: -100,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: const BoxDecoration(
                        color: Color(0x304599ff),
                        borderRadius: BorderRadius.all(
                          Radius.circular(150),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: -10,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: const BoxDecoration(
                        color: Color(0x30cc33ff),
                        borderRadius: BorderRadius.all(
                          Radius.circular(100),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 80,
                        sigmaY: 80,
                      ),
                      child: Container(),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(children: <Widget>[
                        const SizedBox(
                          height: 70,
                        ),
                        const SizedBox(
                          height: 50,
                        ),
                        Container(
                          child: Image.asset(
                            'assets/images/bsk.png',
                            height: 80,
                          ),
                        ),
                        const SizedBox(
                          height: 70,
                        ),
                        Padding(
                            padding: const EdgeInsets.only(
                                left: 25, right: 25, top: 20, bottom: 5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Nama Pengguna',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.nunito(fontSize: 22),
                                ),
                                TextField(
                                  controller: username,
                                  style: GoogleFonts.nunito(fontSize: 18),
                                  keyboardType: TextInputType.text,
                                  textCapitalization: TextCapitalization.words,
                                  decoration: const InputDecoration(
                                      // hintText: 'Nama Pengguna,
                                      ),
                                ),
                              ],
                            )),
                        Padding(
                            padding: const EdgeInsets.only(
                                left: 25, right: 25, top: 20, bottom: 5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Alamat',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.nunito(fontSize: 22),
                                ),
                                TextField(
                                  controller: address,
                                  style: GoogleFonts.nunito(fontSize: 18),
                                  keyboardType: TextInputType.text,
                                  textCapitalization: TextCapitalization.words,
                                  decoration: const InputDecoration(
                                      // hintText: 'Nama Pengguna,
                                      ),
                                ),
                              ],
                            )),
                        Padding(
                            padding: const EdgeInsets.only(
                                left: 25, right: 25, top: 5, bottom: 5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Email',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.nunito(fontSize: 22),
                                ),
                                TextField(
                                  controller: email,
                                  style: GoogleFonts.nunito(fontSize: 18),
                                  keyboardType: TextInputType.emailAddress,
                                  textCapitalization: TextCapitalization.words,
                                  decoration: const InputDecoration(
                                      // hintText: 'Email',

                                      ),
                                ),
                              ],
                            )),
                        Padding(
                            padding: const EdgeInsets.only(
                                left: 25, right: 25, top: 5, bottom: 5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Nomor Telepon',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.nunito(fontSize: 22),
                                ),
                                TextField(
                                  controller: noTelp,
                                  style: GoogleFonts.nunito(fontSize: 18),
                                  keyboardType: TextInputType.number,
                                  textCapitalization: TextCapitalization.words,
                                  decoration: const InputDecoration(
                                      // hintText: 'Nomor Telepon',

                                      ),
                                ),
                              ],
                            )),
                        Padding(
                            padding: const EdgeInsets.only(
                                left: 25, right: 25, top: 5, bottom: 5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Password',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.nunito(fontSize: 22),
                                ),
                                TextField(
                                  controller: password,
                                  style: GoogleFonts.nunito(fontSize: 18),
                                  keyboardType: TextInputType.text,
                                  textCapitalization: TextCapitalization.words,
                                  obscureText: hidePassword,
                                  enableSuggestions: false,
                                  autocorrect: false,
                                  decoration: InputDecoration(
                                    // hintText: 'Password',
                                    suffixIcon: IconButton(
                                      icon: Icon(!hidePassword
                                          ? Icons.visibility
                                          : Icons.visibility_off),
                                      onPressed: () {
                                        setState(() {});
                                        hidePassword = !hidePassword;
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            )),
                        Padding(
                            padding: const EdgeInsets.only(
                                left: 25, right: 25, top: 5, bottom: 5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Konfirmasi Password',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.nunito(fontSize: 22),
                                ),
                                TextField(
                                  controller: confirmPassword,
                                  style: GoogleFonts.nunito(fontSize: 18),
                                  keyboardType: TextInputType.text,
                                  textCapitalization: TextCapitalization.words,
                                  obscureText: hideConfirmPassword,
                                  enableSuggestions: false,
                                  autocorrect: false,
                                  decoration: InputDecoration(
                                    // hintText: 'Konfirmasi Password',
                                    suffixIcon: IconButton(
                                      icon: Icon(!hideConfirmPassword
                                          ? Icons.visibility
                                          : Icons.visibility_off),
                                      onPressed: () {
                                        setState(() {});
                                        hideConfirmPassword =
                                            !hideConfirmPassword;
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            )),
                        Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              margin: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                  color: Colors.green, shape: BoxShape.circle),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: Color(0xFF2C3246),
                                  onPrimary: defaultColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(80.0)),
                                ),
                                onPressed: () {
                                  registerProsses();
                                },
                                child: Container(
                                  constraints: const BoxConstraints(
                                      maxWidth: 250.0, minHeight: 50.0),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    "Daftar",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20),
                                  ),
                                ),
                              ),
                            )),
                      ]),
                    ),
                  ),
                  Loading(isLoading)
                ]),
              ),
            ],
          ))),
    );
  }
}
