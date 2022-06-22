import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
// import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:herbal/api/api_services.dart';
import 'package:herbal/widgets/loading.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class ListAddress extends StatefulWidget {
  const ListAddress({Key? key}) : super(key: key);

  @override
  ListAddressState createState() => ListAddressState();
}

class ListAddressState extends State<ListAddress> {
  bool isLoading = false;
  double windowHeight = 0;
  double windowWidth = 0;
  String token = "";
  int totalPrice = 0;
  var tempData = [];
  var cart = [];
  int idxAddress = 0;
  bool changeAddress = false;
  TextEditingController name = TextEditingController();
  TextEditingController categoryAddress = TextEditingController();
  TextEditingController city = TextEditingController();
  TextEditingController no_telp = TextEditingController();
  TextEditingController description = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController postal_code = TextEditingController();
  bool cropProses = false;

  @override
  void initState() {
    super.initState();
    initiateData();
    load();
  }

  Future<void> load() async {
    await Future.delayed(Duration(milliseconds: 2500), () {
      Loading(isLoading);
    });
  }

  initiateData() async {
    setState(() {
      isLoading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token').toString();

    windowHeight = MediaQuery.of(context).size.height;
    windowWidth = MediaQuery.of(context).size.width;
    await getItem();
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

  getItem() async {
    await ApiServices().getAddress(token).then((json) {
      if (json != null) {
        print(json);
        if (json['status'] == 'success') {
          setState(() {
            tempData = json['data']['data'];
          });
        }
      }
    }).catchError((e) {
      alertError(e.toString(), 1);
    });
  }

  createItem() async {
    await ApiServices()
        .createAddress(token, postal_code.text, address.text, description.text)
        .then((json) {
      if (json != null) {
        if (json['status'] == "success") {
          getItem();
        }
      }
    }).catchError((e) {
      alertError(e.toString(), 1);
    });
  }

  updateItem(id) async {
    print(id);
    await ApiServices()
        .updateAddress(token, id.toString(), postal_code.text, address.text,
            description.text)
        .then((json) {
      if (json != null) {
        if (json['status'] == "success") {
          getItem();
        }
      }
    }).catchError((e) {
      alertError(e.toString(), 1);
    });
  }

  deleteItem(id) async {
    await ApiServices().deleteAddress(token, id.toString()).then((json) {
      if (json != null) {
        if (json['status'] == "success") {
          getItem();
        }
      }
    }).catchError((e) {
      alertError(e.toString(), 1);
    });
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
            btnOkText: "Setuju",
            btnOkColor: Colors.red,
            btnCancelColor: Color(0xFF2C3246),
            btnCancelText: "Batal",
            btnCancelIcon: Icons.cancel,
            btnCancelOnPress: () {})
        .show();
  }

  dialogAddress() async {
    description.text = '';
    address.text = '';
    postal_code.text = '';

    AwesomeDialog(
      context: context,
      onDissmissCallback: (type) {
        description.text = '';
        address.text = '';
        postal_code.text = '';
      },
      dialogType: DialogType.NO_HEADER,
      animType: AnimType.SCALE,
      headerAnimationLoop: false,
      title: "Tambah Alamat",
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: <Widget>[
            Card(
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.black, width: 1),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Kode Pos',
                        textAlign: TextAlign.left,
                        style: GoogleFonts.nunito(
                            decoration: TextDecoration.underline, fontSize: 13),
                      ),
                      TextField(
                        controller: postal_code,
                        keyboardType: TextInputType.text,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Alamat',
                        textAlign: TextAlign.left,
                        style: GoogleFonts.nunito(
                            decoration: TextDecoration.underline, fontSize: 13),
                      ),
                      TextField(
                        controller: address,
                        keyboardType: TextInputType.text,
                      ),
                    ],
                  ),
                )),
            Card(
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.black, width: 1),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Deskripsi',
                        textAlign: TextAlign.left,
                        style: GoogleFonts.nunito(
                            decoration: TextDecoration.underline, fontSize: 13),
                      ),
                      TextField(
                        controller: description,
                        keyboardType: TextInputType.text,
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
      btnOk: DialogButton(
        color: Color(0xFF2C3246),
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

  dialogAddressUpdate(index) async {
    description.text = tempData[index]['description'].toString();
    address.text = tempData[index]['address'].toString();
    postal_code.text = tempData[index]['postal_code'].toString();
    AwesomeDialog(
      context: context,
      onDissmissCallback: (type) {
        description.text = '';
        address.text = '';
        postal_code.text = '';
      },
      dialogType: DialogType.NO_HEADER,
      animType: AnimType.SCALE,
      headerAnimationLoop: false,
      title: "Ubah Alamat",
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: <Widget>[
            Card(
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.black, width: 1),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Kode Pos',
                        textAlign: TextAlign.left,
                        style: GoogleFonts.nunito(
                            decoration: TextDecoration.underline, fontSize: 13),
                      ),
                      TextField(
                        controller: postal_code,
                        keyboardType: TextInputType.text,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Alamat',
                        textAlign: TextAlign.left,
                        style: GoogleFonts.nunito(
                            decoration: TextDecoration.underline, fontSize: 13),
                      ),
                      TextField(
                        controller: address,
                        keyboardType: TextInputType.text,
                      ),
                    ],
                  ),
                )),
            Card(
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.black, width: 1),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Deskripsi',
                        textAlign: TextAlign.left,
                        style: GoogleFonts.nunito(
                            decoration: TextDecoration.underline, fontSize: 13),
                      ),
                      TextField(
                        controller: description,
                        keyboardType: TextInputType.text,
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
      btnOk: DialogButton(
        color: Color(0xFF2C3246),
        onPressed: () =>
            {updateItem(tempData[index]['id']), Navigator.pop(context)},
        child: Text(
          "Simpan Data",
          style: GoogleFonts.nunito(fontSize: 20, color: Colors.white),
        ),
      ),
      btnOkOnPress: () {},
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        floatingActionButton: FloatingActionButton(
          backgroundColor: Color(0xFF2C3246),
          onPressed: () {
            dialogAddress();
          },
          child: const Icon(Icons.add),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Color(0xFF2C3246),
                onPrimary: Colors.white,
                shadowColor: Colors.black54,
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)), //////// HERE
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child:
                  Text('Pilih Alamat', style: GoogleFonts.nunito(fontSize: 15)),
            ),
          ),
        ),
        appBar: AppBar(
            leading: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: (Icon(Icons.arrow_back, color: Colors.white))),
            backgroundColor: Color(0xFF2C3246),
            title: Text("Daftar Alamat", style: GoogleFonts.nunito())),
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
              : tempData.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SvgPicture.network(
                            "https://drive.google.com/uc?export=view&id=1SZwpOb9WC7LufDebNjfyjaQ_6hot-82V",
                            height: 80,
                          ),
                          const SizedBox(
                            height: 80,
                          ),
                          Text("Tidak ada Alamat", style: GoogleFonts.nunito())
                        ],
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 6,
                          child: SingleChildScrollView(
                              physics: const ClampingScrollPhysics(),
                              child: Column(
                                children: [
                                  for (var i = 0; i < tempData.length; i++)
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 20),
                                      child: Card(
                                        elevation: 4,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 15, horizontal: 15),
                                          child: Align(
                                            alignment: Alignment.topLeft,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text('Alamat Pengiriman',
                                                    textAlign: TextAlign.left,
                                                    style: GoogleFonts.nunito(
                                                        decoration:
                                                            TextDecoration
                                                                .underline,
                                                        fontSize: 17)),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                        tempData.isNotEmpty
                                                            ? tempData[i]
                                                                    ['address']
                                                                .toString()
                                                            : "",
                                                        textAlign:
                                                            TextAlign.left,
                                                        style:
                                                            GoogleFonts.nunito(
                                                                fontSize: 12)),
                                                    Text(
                                                        tempData.isNotEmpty
                                                            ? tempData[i][
                                                                    'postal_code']
                                                                .toString()
                                                            : "",
                                                        textAlign:
                                                            TextAlign.left,
                                                        style:
                                                            GoogleFonts.nunito(
                                                                fontSize: 12)),
                                                    Text(
                                                      tempData.isNotEmpty
                                                          ? tempData[i][
                                                                  'description']
                                                              .toString()
                                                          : "",
                                                      textAlign: TextAlign.left,
                                                      style: GoogleFonts.nunito(
                                                          fontSize: 12),
                                                    ),
                                                    // ignore: sized_box_for_whitespace
                                                    Container(
                                                      width: double.infinity,
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          ElevatedButton(
                                                            style:
                                                                ElevatedButton
                                                                    .styleFrom(
                                                              onPrimary:
                                                                  Colors.white,
                                                              onSurface:
                                                                  Colors.red,
                                                              shadowColor:
                                                                  Colors.red,
                                                              primary:
                                                                  Colors.red,
                                                              elevation: 3,
                                                              shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10.0)), //////// HERE
                                                            ),
                                                            onPressed: () {
                                                              deleteAlert(
                                                                  tempData[i]
                                                                      ['id']);
                                                            },
                                                            child: Text(
                                                                'Delete Alamat',
                                                                style: GoogleFonts
                                                                    .nunito(
                                                                        fontSize:
                                                                            15)),
                                                          ),
                                                          const SizedBox(
                                                            width: 10,
                                                          ),
                                                          ElevatedButton(
                                                            style:
                                                                ElevatedButton
                                                                    .styleFrom(
                                                              primary: Color(
                                                                  0xFF2C3246),
                                                              onPrimary:
                                                                  Colors.white,
                                                              shadowColor:
                                                                  Colors
                                                                      .black54,
                                                              elevation: 3,
                                                              shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10.0)), //////// HERE
                                                            ),
                                                            onPressed: () {
                                                              dialogAddressUpdate(
                                                                  i);
                                                            },
                                                            child: Text(
                                                                'Ubah Alamat',
                                                                style: GoogleFonts
                                                                    .nunito(
                                                                        fontSize:
                                                                            15)),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              )),
                        ),
                      ],
                    ),
        ));
  }
}
