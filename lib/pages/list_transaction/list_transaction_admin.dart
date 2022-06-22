import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:herbal/api/api_services.dart';
import 'package:herbal/pages/newspaper_details/newspaper_details_public.dart';
import 'package:herbal/pages/show_proof_user/upload_proof_user.dart';
import 'package:herbal/pages/upload_proof/upload_proof.dart';
import 'package:herbal/shared/shared.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TransactionListAdmin extends StatefulWidget {
  const TransactionListAdmin({Key? key}) : super(key: key);

  @override
  TransactionListAdminState createState() => TransactionListAdminState();
}

class TransactionListAdminState extends State<TransactionListAdmin> {
  double windowHeight = 0;
  double windowWidth = 0;
  String token = "";
  var tempData = [];
  bool isLoading = true;
  late Map<String, dynamic> tempData1;
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
    token = prefs.getString('token').toString();

    windowHeight = MediaQuery.of(context).size.height;
    windowWidth = MediaQuery.of(context).size.width;
    await getItem();
  }

  getItem() async {
    await ApiServices().getTransactionAdmin(token).then((json) {
      if (json != null) {
        if (json['status'] == 'success') {
          setState(() {
            tempData = json['data']['data']['data'];
          });
        }
      }
    }).catchError((e) {
      print(e.toString());
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

  uploadProof(index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('dataUploadProofUser', json.encode(tempData[index]));
    Navigator.push(context,
            MaterialPageRoute(builder: (context) => const UploadProofUser()))
        .then((value) => getItem());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF2C3246),
        title: Text("Daftar Transaksi", style: GoogleFonts.nunito(fontSize:25)),
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              children: [
                for (var i = 0; i < tempData.length; i++)
                  Container(
                    margin: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      color: Colors.black12,
                    ),
                    child: InkWell(
                      splashColor: Colors.yellow,
                      highlightColor: Colors.blue.withOpacity(0.5),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(20.0)),
                      onTap: () => uploadProof(i),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 15),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(tempData[i]['data']['id'],
                                              textAlign: TextAlign.left,
                                              style: GoogleFonts.nunito()),
                                          Container(
                                            width: windowWidth * 0.3,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(5.0)),
                                              color: tempData[i]['status'] == 0
                                                  ? tempData[i]['proof'] != null
                                                      ? Colors.red[800]
                                                      : Colors.red[200]
                                                  : Colors.green[800],
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                  tempData[i]['status'] == 0
                                                      ? tempData[i]['proof'] !=
                                                              null
                                                          ? 'Proses'
                                                          : 'Belum Selesai'
                                                      : tempData[i]['status'] ==
                                                              1
                                                          ? 'Selesai'
                                                          : 'Dibatalkan',
                                                  textAlign: TextAlign.center,
                                                  style: GoogleFonts.nunito(
                                                      color: Colors.white)),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text('Pembelian',
                                          style:
                                              GoogleFonts.nunito(fontSize: 15)),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      for (var j = 0;
                                          j <
                                              tempData[i]['data_cart']['data']
                                                  .length;
                                          j++)
                                        // ignore: avoid_unnecessary_containers
                                        Container(
                                            child: Column(children: [
                                          Row(
                                            children: [
                                              Image.network(
                                                  tempData[i]['data_cart']
                                                                  ['data']
                                                              .length >
                                                          0
                                                      ? tempData[i]['data_cart']
                                                                      ['data'][j]
                                                                  [
                                                                  'item_detail']
                                                              ['image']['path']
                                                          .toString()
                                                      : 'https://t4.ftcdn.net/jpg/00/89/55/15/360_F_89551596_LdHAZRwz3i4EM4J0NHNHy2hEUYDfXc0j.jpg',
                                                  width: 50,
                                                  height: 50),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                  tempData[i]['data_cart']
                                                          ['data'][j]
                                                      ['item_detail']['name'],
                                                  style: GoogleFonts.nunito()),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Expanded(
                                                  flex: 1,
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                          tempData[i]['data_cart']
                                                                      ['data']
                                                                  [j]['volume']
                                                              .toString(),
                                                          style: GoogleFonts
                                                              .nunito()),
                                                      Text(
                                                          "x Rp " +
                                                              tempData[i]['data_cart']
                                                                          [
                                                                          'data'][j]
                                                                      ['price']
                                                                  .toString(),
                                                          style: GoogleFonts
                                                              .nunito()),
                                                    ],
                                                  )),
                                            ],
                                          ),
                                        ])),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        children: [
                                          Text("Total Pembayaran",
                                              style: GoogleFonts.nunito()),
                                          Expanded(
                                              flex: 1,
                                              child: Text(
                                                "Rp " +
                                                    tempData[i]['data_cart']
                                                            ['total']
                                                        .toString(),
                                                style: GoogleFonts.nunito(),
                                                textAlign: TextAlign.right,
                                              ))
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: RaisedButton(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              onPressed: () {
                                                uploadProof(i);
                                              },
                                              child: Text(
                                                  'Lihat Bukti Pembayaran',
                                                  style: GoogleFonts.nunito(
                                                      fontSize: 15)),
                                              color: Colors.blue,
                                              textColor: Colors.white,
                                              elevation: 5,
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
              ],
            )),
      ),
    );
  }
}
