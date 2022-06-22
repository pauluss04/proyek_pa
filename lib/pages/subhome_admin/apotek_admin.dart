// ignore_for_file: unused_field

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:herbal/api/api_services.dart';
import 'package:herbal/shared/shared.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class ApotekAdminList extends StatefulWidget {
  const ApotekAdminList({Key? key}) : super(key: key);

  @override
  ApotekAdminListState createState() => ApotekAdminListState();
}

class ApotekAdminListState extends State<ApotekAdminList> {
  TextEditingController name = TextEditingController();
  TextEditingController city = TextEditingController();
  TextEditingController linkAddress = TextEditingController();
  TextEditingController linkAddress1 = TextEditingController();
  late File imageFile;
  late Uint8List imageTemp;
  late String baseImage;
  final ImagePicker _picker = ImagePicker();
  List<dynamic> tempPop = [];
  double windowHeight = 0;
  double windowWidth = 0;
  int id = 0;
  int idUpdate = 0;
  bool cropProses = false;
  String token = '';
  var tempData = [];
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    initiateData();
  }

  initiateData() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token').toString();
    await getItem();
  }

  getItem() async {
    setState(() {
      isLoading = true;
    });
    await ApiServices().getApotekAdmin(token).then((json) {
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

  createItem() async {
    setState(() {
      isLoading = true;
    });
    await ApiServices()
        .addApotek(token, name.text, city.text, linkAddress.text)
        .then((json) {
      if (json != null) {
        if (json['status'] == 'success') {
          getItem();
        }
      }
    }).catchError((e) {
      alertError(e.toString(), 1);
    });
    setState(() {
      isLoading = false;
    });
  }

  updateItem(index) async {
    setState(() {
      isLoading = true;
    });
    await ApiServices()
        .updateApotek(
            token, idUpdate.toString(), name.text, city.text, linkAddress.text)
        .then((json) {
      if (json != null) {
        if (json['status'] == 'success') {
          getItem();
        }
      }
    }).catchError((e) {
      alertError(e.toString(), 1);
    });
    setState(() {
      isLoading = false;
    });
  }

  deleteItem(index) async {
    setState(() {
      isLoading = true;
    });
    await ApiServices().deleteApotek(token, idUpdate.toString()).then((json) {
      if (json != null) {
        if (json['status'] == 'success') {
          getItem();
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
            title: 'Kesalahan',
            desc: err,
            btnOkOnPress: () {},
            btnOkIcon: Icons.cancel,
            btnOkColor: Colors.red)
        .show();
  }

  deleteAlert(int index) {
    AwesomeDialog(
            context: context,
            dialogType: DialogType.WARNING,
            animType: AnimType.SCALE,
            headerAnimationLoop: false,
            title: 'Peringatan',
            desc: "Anda yakin ingin menghapus data?",
            btnOkOnPress: () {
              deleteItem(index);
            },
            btnOkIcon: Icons.check,
            btnOkColor: Colors.red,
            btnOkText: "Betul",
            btnCancelText: "Batal",
            buttonsTextStyle: GoogleFonts.nunito(),
            btnCancelColor: Color(0xFF2C3246),
            btnCancelIcon: Icons.cancel,
            btnCancelOnPress: () {})
        .show();
  }

  updateData() async {
    name.text = tempData[id]['name'].toString();
    city.text = tempData[id]['city'].toString();
    linkAddress.text = tempData[id]['link_address'].toString();
    linkAddress1.text = tempData[id]['link_address1'].toString();
    AwesomeDialog(
      context: context,
      onDissmissCallback: (type) {
        name.text = "";
        city.text = "";
        linkAddress.text = "";
        linkAddress1.text = "";
      },
      dialogType: DialogType.NO_HEADER,
      animType: AnimType.SCALE,
      headerAnimationLoop: false,
      body: Column(
        children: <Widget>[
          TextField(
            style: GoogleFonts.nunito(fontSize:20),
            controller: name,
            keyboardType: TextInputType.text,
            decoration: const InputDecoration(
                icon: Icon(Icons.account_box_rounded, size:35),
                labelText: "Nama Apotek"),
          ),
          TextField(
            style: GoogleFonts.nunito(fontSize:20),
            controller: city,
            keyboardType: TextInputType.text,
            decoration: const InputDecoration(
              icon: Icon(Icons.location_city,size:35),
              labelText: "Kota",
            ),
          ),
          TextField(
            style: GoogleFonts.nunito(fontSize:20),
            controller: linkAddress,
            keyboardType: TextInputType.text,
            decoration: const InputDecoration(
              icon: Icon(Icons.link,size:35),
              labelText: "Alamat Apotek (berdasarkan latitude google maps)",
            ),
          ),
          TextField(
            style: GoogleFonts.nunito(fontSize:20),
            controller: linkAddress1,
            keyboardType: TextInputType.text,
            decoration: const InputDecoration(
              icon: Icon(Icons.link,size:35),
              labelText: "Alamat Apotek (berdasarkan longitude google maps)",
            ),
          ),
        ],
      ),
      btnOk: DialogButton(
        color: Color(0xFF2C3246),
        splashColor: defaultColor,
        onPressed: () => {
          updateItem(idUpdate.toString()),
          Navigator.pop(context),
        },
        child: Text(
          "Simpan Data",
          style: GoogleFonts.nunito(color: Colors.white, fontSize: 25),
        ),
      ),
      btnOkOnPress: () {},
    ).show();
  }

  addData() async {
    name.text = "";
    city.text = "";
    linkAddress.text = "";
    linkAddress1.text = "";
    AwesomeDialog(
      context: context,
      onDissmissCallback: (type) {
        name.text = "";
        city.text = "";
        linkAddress.text = "";
        linkAddress1.text = "";
      },
      dialogType: DialogType.NO_HEADER,
      animType: AnimType.SCALE,
      headerAnimationLoop: false,
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: <Widget>[
            TextField(
              style: GoogleFonts.nunito(fontSize:20),
              controller: name,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                  icon: Icon(Icons.account_box_rounded,size:35),
                  labelText: "Nama Apotek"),
            ),
            TextField(
              style: GoogleFonts.nunito(fontSize:20),
              controller: city,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                icon: Icon(Icons.location_city,size:35),
                labelText: "Kota",
              ),
            ),
            TextField(
              style: GoogleFonts.nunito(fontSize:20),
              controller: linkAddress,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                icon: Icon(Icons.link,size:35),
                labelText: "Alamat Apotek (berdasarkan latitude google maps)",
              ),
            ),
            TextField(
              style: GoogleFonts.nunito(fontSize:20),
              controller: linkAddress,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                icon: Icon(Icons.link, size:35),
                labelText: "Alamat Apotek (berdasarkan longitude google maps)",
              ),
            ),
          ],
        ),
      ),
      btnOk: DialogButton(
        color: Color(0xFF2C3246),
        splashColor: defaultColor,
        onPressed: () => {
          createItem(),
          Navigator.pop(context),
        },
        child: Text(
          "Tambah Data",
          style: GoogleFonts.nunito(color: Colors.white, fontSize: 20),
        ),
      ),
      btnOkOnPress: () {},
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    windowHeight = MediaQuery.of(context).size.height;
    windowWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: Color(0xFF2C3246),
          onPressed: () {
            addData();
          },
          child: const Icon(Icons.add,size: 35),
        ),
        appBar: AppBar(
          backgroundColor: Color(0xFF2C3246),
          title: Text(
            "Apotek",
            style: GoogleFonts.nunito(fontSize:25),
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
                    width: double.infinity,
                    child: Column(children: [
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
              : Stack(
                  children: <Widget>[
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: ListView(
                              scrollDirection: Axis.vertical,
                              physics: const AlwaysScrollableScrollPhysics(),
                              shrinkWrap: true,
                              padding: const EdgeInsets.all(5.0),
                              children: <Widget>[
                                Container(
                                    margin: const EdgeInsets.all(2),
                                    alignment: Alignment.topCenter,
                                    child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          for (int index = 0;
                                              index < tempData.length;
                                              index++)
                                            Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 5,
                                                      vertical: 5),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Colors.black12,
                                                  width: 2,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 7,
                                                        horizontal: 10),
                                                child: Row(children: [
                                                  Expanded(
                                                      flex: 4,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal: 10),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                                tempData[index]
                                                                        ['name']
                                                                    .toString(),
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                style: GoogleFonts.nunito(
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize:
                                                                        20,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .normal,
                                                                    decoration:
                                                                        TextDecoration
                                                                            .none)),
                                                            SizedBox(
                                                              height: 5,
                                                            ),
                                                            Text(
                                                                tempData[index]
                                                                        ['city']
                                                                    .toString(),
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                style: GoogleFonts.nunito(
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize:
                                                                        18,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .normal,
                                                                    decoration:
                                                                        TextDecoration
                                                                            .none)),
                                                          ],
                                                        ),
                                                      )),
                                                  Expanded(
                                                    flex:1,
                                                      child: ElevatedButton(
                                                          child: const Align(
                                                            alignment: Alignment
                                                                .center,
                                                            child: Icon(
                                                                Icons.delete,
                                                                size: 30,
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                                  primary: Color(
                                                                      0xFF2C3246),
                                                                  onPrimary:
                                                                      Colors
                                                                          .white,
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            20.0),
                                                                  )),
                                                          onPressed: () => {
                                                                setState(() {
                                                                  id = index;
                                                                  idUpdate =
                                                                      tempData[
                                                                              index]
                                                                          [
                                                                          'id'];
                                                                }),
                                                                deleteAlert(
                                                                    index)
                                                              })),
                                                  SizedBox(
                                                    width: windowWidth * 0.02,
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                      child: ElevatedButton(
                                                          child: const Align(
                                                            alignment: Alignment
                                                                .center,
                                                            child: Icon(
                                                              Icons.edit,
                                                              size: 30,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                                  primary: Color(
                                                                      0xFF2C3246),
                                                                  onPrimary:
                                                                      Colors
                                                                          .white,
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            20.0),
                                                                  )),
                                                          onPressed: () => {
                                                                setState(() {
                                                                  id = index;
                                                                  idUpdate =
                                                                      tempData[
                                                                              index]
                                                                          [
                                                                          'id'];
                                                                }),
                                                                updateData()
                                                              })),
                                                ]),
                                              ),
                                            ),
                                        ])),
                                SizedBox(
                                  height: windowHeight * 0.02,
                                ),
                              ],
                            ),
                          )
                        ]),
                    (cropProses)
                        ? Container(
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width,
                            color: Colors.black54,
                            child: const Center(
                                child: CircularProgressIndicator()),
                          )
                        : const Center(),
                  ],
                ),
        ));
  }
}
