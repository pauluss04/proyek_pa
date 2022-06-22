import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:favorite_button/favorite_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:herbal/api/api_services.dart';
import 'package:herbal/pages/list_cart/list_cart.dart';
import 'package:herbal/shared/shared.dart';
import 'package:herbal/widgets/loading.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MedicineDetails extends StatefulWidget {
  const MedicineDetails({Key? key}) : super(key: key);

  @override
  MedicineDetailsState createState() => MedicineDetailsState();
}

class MedicineDetailsState extends State<MedicineDetails> {
  double windowHeight = 0;
  double windowWidth = 0;
  bool isLoading = false;
  int unit = 0;
  List<dynamic> dataCart = [];
  String token = "";
  var dataIdCart = [];
  int price = 0;
  var cart = [];
  int idItem = 0;
  int maxCart = 0;
  bool same = false;
  int indexSame = 0;
  bool active = false;
  String exTitle = "Sport Categories";
  int idx = 0;
  @override
  void initState() {
    super.initState();
    initiateData();
  }

  initiateData() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token').toString();
    String tempDataIdCart = prefs.getString('idItemCart')!;
    dataIdCart = json.decode(tempDataIdCart);
    setState(() {
      idItem = dataIdCart[0]['detail'][idx]['id'];
      price = dataIdCart[0]['detail'][idx]['price'];
    });
    if (prefs.getString('dataCart') != "") {
      String tempCart = prefs.getString('dataCart')!;
      cart = json.decode(tempCart);
      await checkItem();
    }
  }

  getItem() async {
    await ApiServices()
        .getItemsPublic(token, idItem.toString(), "")
        .then((json) {
      if (json != null) {
        if (json['status'] == 'success') {
          dataIdCart.clear();
          setState(() {
            dataIdCart = json['data']['data'];
          });
          checkItem();
        } else {
          alertError(json.toString(), 1);
        }
      }
    }).catchError((e) {
      alertError(e.toString(), 1);
    });
  }

  setIdx(index) {
    setState(() {
      idx = index;
      idItem = dataIdCart[0]['detail'][idx]['id'];
      price = dataIdCart[0]['detail'][idx]['price'];
    });
  }

  likeManagement(id, value) async {
    if (value == true) {
      await removeLikeItem(id);
    } else {
      await addLikeItem(id);
    }
  }

  addLikeItem(id) async {
    await ApiServices().addLikeItem(token, id.toString()).then((json) {
      print(json);
      if (json != null) {
        if (json['status'] == 'success') {
          initiateData();
          // getItem();
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
      print(json);
      if (json != null) {
        if (json['status'] == 'success') {
          initiateData();
          // getItem();
        } else {
          alertError(json.toString(), 1);
        }
      }
    }).catchError((e) {
      alertError(e.toString(), 1);
    });
  }

  checkItem() {
    maxCart = cart.length;
    for (var i = 0; i < maxCart; i++) {
      dataCart.add({
        'id': cart[i]['id'],
        'volume': cart[i]['volume'],
        'price': cart[i]['price']
      });
      if (cart[i]['id'] == idItem) {
        setState(() {
          same = true;
          indexSame = i;
        });
        unit = cart[i]['volume'];
      }
    }
  }

  sendData(String fastBuy) async {
    dataCart.length = maxCart;
    if (same) {
      dataCart[indexSame] = {'id': idItem, 'volume': unit, 'price': price};
    } else {
      dataCart.add({'id': idItem, 'volume': unit, 'price': price});
    }
    if (unit > 0) {
      await ApiServices().setCart(token, json.encode(dataCart)).then((json) {
        if (json != null) {
          if (json['status'] == 'success') {
            if (fastBuy != '') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ListCart()),
              );
            } else {
              Navigator.pop(context);
            }
          } else {
            alertError(json.toString(), 1);
          }
        }
      }).catchError((e) {
        alertError(e.toString(), 1);
      });
    } else {
      Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    windowHeight = MediaQuery.of(context).size.height - 25;
    windowWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Color(0xFF2C3246),
            title:
                Text("Detail Obat", style: GoogleFonts.nunito(fontSize: 25))),
        bottomNavigationBar: Container(
            height: 60,
            child: Expanded(
                child: Container(
              color: Colors.white,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 20, right: 25, top: 10, bottom: 5),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: ElevatedButton(
                          onPressed: () {
                            sendData("fastBuy");
                          },
                          style: ElevatedButton.styleFrom(
                            side: const BorderSide(
                              width: 1.0,
                              color: Colors.black,
                            ),
                            onPrimary: defaultColor,
                            primary: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0)),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Beli Langsung',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.nunito(
                                  color: Colors.black, fontSize: 18),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: windowWidth * 0.03,
                      ),
                      Expanded(
                        flex: 1,
                        child: ElevatedButton(
                          onPressed: () {
                            sendData("");
                          },
                          style: ElevatedButton.styleFrom(
                            side: BorderSide(
                              width: 1.0,
                              color: defaultColor,
                            ),
                            onPrimary: defaultColor,
                            primary: Color(0xFF2C3246),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0)),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              '+ Keranjang',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.nunito(
                                  color: Colors.white, fontSize: 18),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ))),
        body: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                // ignore: sized_box_for_whitespace
                Container(
                    height: windowHeight,
                    child: Column(children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(10),
                        margin: EdgeInsets.all(10),
                        child: ExpansionPanelList(
                          expansionCallback: (panelIndex, isExpanded) {
                            active = !active;
                            if (exTitle == "Sport Categories")
                              exTitle = "Contract";
                            else
                              exTitle = "Sport Categories";
                            setState(() {});
                          },
                          children: <ExpansionPanel>[
                            ExpansionPanel(
                                headerBuilder: (context, isExpanded) {
                                  return const ListTile(
                                    visualDensity: VisualDensity.compact,
                                    dense: true,
                                    title: Text('Show Apotek'),
                                  );
                                },
                                body: dataIdCart.isNotEmpty
                                    ? Column(
                                        children: [
                                          for (var i = 0;
                                              i <
                                                  dataIdCart[0]['detail']
                                                      .length;
                                              i++)
                                            Container(
                                                color: Colors.white,
                                                alignment: Alignment.topCenter,
                                                child: InkWell(
                                                  highlightColor: Colors.blue,
                                                  onTap: () {
                                                    setIdx(i);
                                                  },
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 5,
                                                            left: 20,
                                                            right: 20,
                                                            bottom: 20),
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                          flex: 1,
                                                          child: Container(
                                                            child: Align(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              child: Text(
                                                                  dataIdCart
                                                                          .isNotEmpty
                                                                      ? dataIdCart[0]['detail'][i]['data_apotek']
                                                                              [
                                                                              'name']
                                                                          .toString()
                                                                      : "",
                                                                  style: GoogleFonts
                                                                      .nunito(
                                                                          fontSize:
                                                                              15)),
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 1,
                                                          child: Container(
                                                            child: Align(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              child: Text(
                                                                  dataIdCart
                                                                          .isNotEmpty
                                                                      ? dataIdCart[0]['detail'][i]['data_apotek']
                                                                              [
                                                                              'city']
                                                                          .toString()
                                                                      : "",
                                                                  style: GoogleFonts
                                                                      .nunito(
                                                                          fontSize:
                                                                              15)),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                )),
                                        ],
                                      )
                                    : Text(''),
                                isExpanded: active,
                                canTapOnHeader: true)
                          ],
                        ),
                      ),
                      Expanded(
                          flex: 1,
                          child: Container(
                            child: Image.network(
                                dataIdCart.isNotEmpty
                                    ? dataIdCart[0]['detail'][idx]['image']
                                            ['path']
                                        .toString()
                                    : 'https://t4.ftcdn.net/jpg/00/89/55/15/360_F_89551596_LdHAZRwz3i4EM4J0NHNHy2hEUYDfXc0j.jpg',
                                width: 200,
                                height: 200),
                          )),
                      Expanded(
                          flex: 2,
                          child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    offset: Offset(0.0, 2.0),
                                    blurRadius: 25.0,
                                  )
                                ],
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(32),
                                    topRight: Radius.circular(32))),
                            alignment: Alignment.topCenter,
                            child: Column(
                              children: <Widget>[
                                Padding(
                                    padding: const EdgeInsets.only(
                                        left: 25,
                                        right: 25,
                                        top: 20,
                                        bottom: 5),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            dataIdCart.isNotEmpty
                                                ? dataIdCart[0]['detail'][idx]
                                                        ['name']
                                                    .toString()
                                                : '',
                                            textAlign: TextAlign.left,
                                            style: GoogleFonts.nunito(
                                                fontSize: 20),
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            FavoriteButton(
                                              iconSize: 50,
                                              isFavorite: false,
                                              valueChanged: (value) {
                                                value = likeManagement(
                                                    dataIdCart[0]['detail'][idx]
                                                        ['id'],
                                                    dataIdCart[0]['detail'][idx]
                                                        ['has_like']);
                                                print('Is Favorite : $value');
                                              },
                                            ),
                                            IconButton(
                                            onPressed: () async {
                                              final availableMaps =
                                                  await MapLauncher
                                                      .installedMaps;
                                              for (var map in availableMaps) {
                                                map.showMarker(
                                                    coords: Coords(
                                                        double.parse(dataIdCart[0]['detail'][idx]
                                                                    ['data_apotek']
                                                                ['link_address']
                                                            .toString()),
                                                        double.parse(dataIdCart[0]['detail']
                                                                    [idx]['data_apotek'][
                                                                'link_address1']
                                                            .toString())),
                                                    title: dataIdCart[0]['detail'][idx]
                                                            ['data_apotek']['name']
                                                        .toString());
                                              }
                                            },
                                            icon: Icon(Icons.location_on)),
                                          ],
                                        ),
                                      ],
                                    )),
                                Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20, right: 25, top: 5, bottom: 5),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                flex: 1,
                                                child: IconButton(
                                                    onPressed: () {
                                                      if (unit > 0) {
                                                        setState(() {
                                                          unit = unit - 1;
                                                        });
                                                      }
                                                    },
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    icon: const Icon(
                                                      Icons.remove_circle,
                                                      size: 40,
                                                    )),
                                              ),
                                              Container(
                                                height: windowHeight * 0.04,
                                                margin: const EdgeInsets.only(
                                                    top: 5),
                                                child: Align(
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    unit.toString(),
                                                    textAlign: TextAlign.center,
                                                    style: GoogleFonts.nunito(
                                                        fontSize: 20),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: IconButton(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    onPressed: () {
                                                      setState(() {
                                                        unit = unit + 1;
                                                      });
                                                    },
                                                    icon: const Icon(
                                                      Icons.add_circle,
                                                      size: 40,
                                                    )),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            dataIdCart.isNotEmpty
                                                ? "Rp. " +
                                                    dataIdCart[0]['detail'][idx]
                                                            ['price']
                                                        .toString()
                                                : "Rp. -",
                                            textAlign: TextAlign.right,
                                            style: GoogleFonts.nunito(
                                                fontSize: 20),
                                          ),
                                        )
                                      ],
                                    )),
                                Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20,
                                        right: 25,
                                        top: 10,
                                        bottom: 5),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            dataIdCart.isNotEmpty
                                                ? dataIdCart[0]['detail'][idx]
                                                        ['description']
                                                    .toString()
                                                : "",
                                            textAlign: TextAlign.left,
                                            style: GoogleFonts.nunito(
                                                fontSize: 20),
                                          ),
                                        )
                                      ],
                                    )),
                              ],
                            ),
                          )),
                    ])),
                Loading(isLoading)
              ],
            ),
          ),
        ));
  }
}
