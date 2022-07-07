// ignore_for_file: unused_element

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:google_fonts/google_fonts.dart';

import 'package:http/http.dart' as http;

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:herbal/api/api_services.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/date_symbol_data_local.dart';

class NewsPaperList extends StatefulWidget {
  const NewsPaperList({Key? key}) : super(key: key);

  @override
  NewsPaperListState createState() => NewsPaperListState();
}

class NewsPaperListState extends State<NewsPaperList> {
  TextEditingController title = TextEditingController();
  TextEditingController author = TextEditingController();
  TextEditingController description = TextEditingController();
  TextEditingController link = TextEditingController();
  TextEditingController source = TextEditingController();
  late File imageFile;
  Uint8List? imageTemp;
  String baseImage = "";
  late File _img;
  final ImagePicker _picker = ImagePicker();

  List<dynamic> tempPop = [];
  double windowHeight = 0;
  double windowWidth = 0;
  bool cropProses = false;
  String token = '';
  var tempData = [];
  bool isLoading = true;
  int id = 0;
  int idUpdate = 0;
  bool edited = false;
  bool addImage = false;
  String category = "";
  var optCategory = [
    {"val": "", "name": "All Category"},
    {"val": "sport", "name": "Olahraga"},
    {"val": "health", "name": "Kesehatan"},
    {"val": "social", "name": "Sosial dan Budaya"}
  ];
  @override
  void initState() {
    super.initState();
    initiateData();
    title.text = "";
    author.text = "";
    description.text = "";
    category = "";
    source.text = "";
    link.text = "";
    imageTemp = null;
  }

  initiateData() async {
    initializeDateFormatting('id');
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token').toString();
    await getItem();
  }

  getItem() async {
    setState(() {
      isLoading = true;
    });
    await ApiServices().getNewsAdmin(token).then((json) {
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

  getCustomFormattedDateTime(String givenDateTime, String dateFormat) {
    final DateTime docDateTime = DateTime.parse(givenDateTime).toLocal();
    return DateFormat(dateFormat, 'id').format(docDateTime);
  }

  createItem() async {
    setState(() {
      isLoading = true;
    });
    await ApiServices()
        .addNews(token, title.text, author.text, description.text, source.text,
            link.text, baseImage, category)
        .then((json) {
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
    setState(() {
      isLoading = false;
    });
  }

  updateItem(index) async {
    setState(() {
      isLoading = true;
    });
    await ApiServices()
        .updateNews(token, idUpdate.toString(), title.text, author.text,
            description.text, source.text, link.text, baseImage, category)
        .then((json) {
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
    setState(() {
      isLoading = false;
    });
  }

  deleteItem(int index) async {
    setState(() {
      isLoading = true;
    });
    await ApiServices().deleteNews(token, index.toString()).then((json) {
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

  popUpCamera() {
    // ignore: avoid_single_cascade_in_expression_statements
    AwesomeDialog(
        context: context,
        dialogType: DialogType.WARNING,
        animType: AnimType.SCALE,
        headerAnimationLoop: false,
        title: '',
        desc: 'Pilih gambar',
        btnOkOnPress: () {
          fromCamera('camera');
        },
        btnCancelOnPress: () {
          fromCamera('galeri');
        },
        btnOkText: 'Camera',
        btnCancelText: 'File',
        btnOkIcon: Icons.camera,
        btnCancelIcon: Icons.file_upload,
        btnCancelColor: Color(0xFF2C3246),
        btnOkColor: Colors.red)
      ..show();
  }

  fromCamera(value) async {
    var result;
    if (value == 'camera') {
      result = _takePic(ImageSource.camera);
    } else {
      result = _takePic(ImageSource.gallery);
    }
  }

  Future<void> _takePic(ImageSource source) async {
    final pickedFile = await _picker.getImage(source: source, maxWidth: 600);
    if (pickedFile != null) {
      baseImage = "";
      _img = File(pickedFile.path);
      List<int> imageBytes = _img.readAsBytesSync();
      String _img64 = base64Encode(imageBytes);
      imageTemp = const Base64Decoder().convert(_img64);
      baseImage = "data:image/png;base64," + _img64;
    }
    if (edited) {
      editData();
    } else {
      addData();
    }
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

  Future<String?> networkImageToBase64(String imageUrl) async {
    http.Response response = await http.get(Uri.parse(imageUrl));
    final bytes = response.bodyBytes;
    // ignore: unnecessary_null_comparison
    return (bytes != null ? base64Encode(bytes) : null);
  }

  editData() async {
    title.text = tempData[id]['title'].toString();
    author.text = tempData[id]['author'].toString();
    description.text = tempData[id]['description'].toString();
    source.text = tempData[id]['source'].toString();
    link.text = tempData[id]['link'].toString();
    category = tempData[id]['category'].toString();
    if (baseImage == "") {
      final imgBase64Str =
          await networkImageToBase64(tempData[id]['image']['path'].toString());
      baseImage = "data:image/png;base64," + imgBase64Str.toString();
    }

    showModalBottomSheet(
        enableDrag: true,
        isDismissible: false,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
        ),
        context: context,
        builder: (context) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).pop(),
            child: DraggableScrollableSheet(
              initialChildSize: 0.9,
              maxChildSize: 0.9,
              minChildSize: 0.5,
              expand: false,
              builder: (context, scrollController) {
                return Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: Container(
                    padding: EdgeInsets.all(30),
                    child: ListView(
                      children: <Widget>[
                        SizedBox(height: 20),
                        Align(
                          alignment: const Alignment(0, 1),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                  backgroundColor: Colors.white,
                                  radius: 55,
                                  child: Hero(
                                      tag: "pp",
                                      child: imageTemp != null
                                          ? CircleAvatar(
                                              backgroundColor: Colors.black38,
                                              backgroundImage:
                                                  MemoryImage(imageTemp!),
                                              radius: 100.0,
                                            )
                                          : Image.network(
                                              tempData[id]['image']['path']
                                                  .toString(),
                                              width: 200))),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        Align(
                          alignment: Alignment.center,
                          // ignore: sized_box_for_whitespace
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.3,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  primary: Color(0xFF2C3246),
                                  onPrimary: Colors.white),
                              onPressed: () {
                                Navigator.pop(context);
                                popUpCamera();
                              },
                              child: Container(
                                alignment: Alignment.center,
                                // ignore: avoid_unnecessary_containers
                                child: Container(
                                  child: Row(
                                    children: <Widget>[
                                      Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        "Tambah",
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.nunito(
                                            color: Colors.white, fontSize: 15),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        TextField(
                          controller: title,
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              icon: Icon(Icons.label_important_rounded),
                              labelText: "Judul Berita"),
                        ),
                        SizedBox(height: 20),
                        TextField(
                          controller: author,
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            icon: Icon(Icons.account_circle),
                            labelText: "Penulis",
                          ),
                        ),
                        SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          child: Row(
                            children: [
                              const Icon(
                                Icons.medical_services,
                                color: Colors.grey,
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              Expanded(
                                flex: 1,
                                child: DropdownButtonFormField<String>(
                                  isExpanded: true,
                                  items: optCategory
                                      .map<DropdownMenuItem<String>>((items) {
                                    return DropdownMenuItem(
                                        value: items['val'].toString(),
                                        child: Text(items['name'].toString()));
                                  }).toList(),
                                  value: category,
                                  onChanged: (val) => setState(() {
                                    category = val.toString();
                                  }),
                                  onSaved: (val) => setState(() {
                                    category = val.toString();
                                  }),
                                  hint: Text(
                                    "Select Item",
                                    style:
                                        GoogleFonts.nunito(color: Colors.grey),
                                    textAlign: TextAlign.end,
                                  ),
                                  icon: const Padding(
                                      //Icon at tail, arrow bottom is default icon
                                      padding: EdgeInsets.only(left: 20),
                                      child: Icon(Icons.arrow_downward)),
                                  style: TextStyle(
                                    color: category == ""
                                        ? Colors.grey[800]
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        TextField(
                          textInputAction: TextInputAction.newline,
                          maxLines: 5,
                          keyboardType: TextInputType.multiline,
                          controller: description,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            icon: Icon(Icons.details),
                            labelText: "Deskripsi",
                          ),
                        ),
                        SizedBox(height: 20),
                        TextField(
                          controller: source,
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            icon: Icon(Icons.account_circle),
                            labelText: "Sumber",
                          ),
                        ),
                        SizedBox(height: 20),
                        TextField(
                          controller: link,
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            icon: Icon(Icons.account_circle),
                            labelText: "Alamat Tautan",
                          ),
                        ),
                        // ignore: sized_box_for_whitespace
                        SizedBox(height: 20),
                        InkWell(
                          child: Container(
                            alignment: Alignment.center,
                            height: 40,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Color(0xFF2C3246),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              "Simpan Data",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.nunito(
                                  color: Colors.white, fontSize: 20),
                            ),
                          ),
                          onTap: () => {
                            updateItem(idUpdate.toString()),
                            Navigator.pop(context),
                          },
                        ),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        });
  }

  addData() async {
    title.text = "";
    author.text = "";
    description.text = "";
    category = "";
    source.text = "";
    link.text = "";
    if (addImage = false) {
      imageTemp = null;
    }

    showModalBottomSheet(
        enableDrag: true,
        isDismissible: false,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
        ),
        context: context,
        builder: (context) {
          return DraggableScrollableSheet(
              initialChildSize: 0.9,
              maxChildSize: 0.9,
              minChildSize: 0.7,
              expand: false,
              builder: (context, scrollController) {
                return Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: Container(
                    padding: EdgeInsets.all(30),
                    child: ListView(
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        Align(
                          alignment: const Alignment(0, 1),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                  backgroundColor: Colors.white,
                                  radius: 55,
                                  child: Hero(
                                      tag: "pp",
                                      child: imageTemp != null
                                          ? CircleAvatar(
                                              backgroundColor: Colors.black38,
                                              backgroundImage:
                                                  MemoryImage(imageTemp!),
                                              radius: 100.0,
                                            )
                                          : const CircleAvatar(
                                              backgroundColor: Colors.black38,
                                              backgroundImage: null,
                                              radius: 100.0,
                                            )))
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Align(
                          alignment: Alignment.center,
                          // ignore: sized_box_for_whitespace
                          child: Container(
                            alignment:Alignment.center,
                            width: MediaQuery.of(context).size.width * 0.35,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Color(0xFF2C3246),
                                onPrimary: Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  addImage = true;
                                });
                                Navigator.pop(context);
                                popUpCamera();
                              },
                              child: Container(
                                alignment: Alignment.center,
                                child: Container(
                                  child: Row(
                                    mainAxisAlignment:MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        "Tambah",
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.nunito(
                                            color: Colors.white,
                                            fontSize: 15),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextField(
                          controller: title,
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              icon: Icon(Icons.label_important_rounded),
                              labelText: "Judul Berita"),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextField(
                          controller: author,
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            icon: Icon(Icons.account_circle),
                            labelText: "Penulis",
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          width: double.infinity,
                          child: Row(
                            children: [
                              const Icon(
                                Icons.medical_services,
                                color: Colors.grey,
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              Expanded(
                                flex: 1,
                                child: DropdownButtonFormField<String>(
                                  isExpanded: true,
                                  items: optCategory
                                      .map<DropdownMenuItem<String>>((items) {
                                    return DropdownMenuItem(
                                        value: items['val'].toString(),
                                        child:
                                            Text(items['name'].toString()));
                                  }).toList(),
                                  value: category,
                                  onChanged: (val) => setState(() {
                                    category = val.toString();
                                  }),
                                  onSaved: (val) => setState(() {
                                    category = val.toString();
                                  }),
                                  hint: Text(
                                    "Select Item",
                                    style: GoogleFonts.nunito(
                                        color: Colors.grey),
                                    textAlign: TextAlign.end,
                                  ),
                                  icon: const Padding(
                                      //Icon at tail, arrow bottom is default icon
                                      padding: EdgeInsets.only(left: 20),
                                      child: Icon(Icons.arrow_downward)),
                                  style: TextStyle(
                                    color: category == ""
                                        ? Colors.grey[800]
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextField(
                          textInputAction: TextInputAction.newline,
                          maxLines: 5,
                          keyboardType: TextInputType.multiline,
                          controller: description,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            icon: Icon(Icons.details),
                            labelText: "Deskripsi",
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        TextField(
                          controller: source,
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            icon: Icon(Icons.source),
                            labelText: "Sumber",
                          ),
                        ),
                        SizedBox(height: 20),
                        TextField(
                          controller: link,
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            icon: Icon(Icons.add_link),
                            labelText: "Tautan",
                          ),
                        ),
                        // ignore: sized_box_for_whitespace
                        SizedBox(height: 20),
                        InkWell(
                          child: Container(
                            alignment: Alignment.center,
                            height: 40,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Color(0xFF2C3246),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              "Tambah Data",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.nunito(
                                  color: Colors.white, fontSize: 20),
                            ),
                          ),
                          onTap: () => {
                            imageTemp = null,
                            createItem(),
                            Navigator.pop(context),
                          },
                        ),
                        // DialogButton(
                        //   color: HexColor("#2C3246"),
                        //   onPressed: () => {
                        //     createItem(),
                        //     Navigator.pop(context),
                        //   },
                        //   child: const Text(
                        //     "Tambah Data",
                        //     style:
                        //         TextStyle(color: Colors.white, fontSize: 20),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                );
              });
        });
  }

  @override
  Widget build(BuildContext context) {
    windowHeight = MediaQuery.of(context).size.height;
    windowWidth = MediaQuery.of(context).size.width;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          textTheme: GoogleFonts.latoTextTheme(Theme.of(context).textTheme)),
      home: Scaffold(
          floatingActionButton: FloatingActionButton(
            backgroundColor: Color(0xFF2C3246),
            onPressed: () {
              setState(() {
                edited = false;
              });
              addData();
            },
            child: const Icon(Icons.add),
          ),
          appBar: AppBar(
            leading: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: (Icon(Icons.arrow_back, color: Colors.white))),
            backgroundColor: Color(0xFF2C3246),
            title: Text("Berita", style: GoogleFonts.nunito()),
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
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      vertical: 7,
                                                      horizontal: 10),
                                                  child: Row(children: [
                                                    Image.network(
                                                      tempData[index]['image']
                                                              ['path']
                                                          .toString(),
                                                      width: 70,
                                                      errorBuilder: (context,
                                                          error, stackTrace) {
                                                        return Image.network(
                                                          'https://t4.ftcdn.net/jpg/00/89/55/15/360_F_89551596_LdHAZRwz3i4EM4J0NHNHy2hEUYDfXc0j.jpg',
                                                          width: 70,
                                                        );
                                                      },
                                                    ),
                                                    Expanded(
                                                        flex: 2,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      10),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                  tempData[index]
                                                                          [
                                                                          'title']
                                                                      .toString(),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .start,
                                                                  style:  GoogleFonts.nunito(
                                                                      color: Colors
                                                                          .black,
                                                                      fontSize:
                                                                          12,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .normal,
                                                                      decoration:
                                                                          TextDecoration
                                                                              .none)),
                                                              Text(
                                                                  tempData[index]
                                                                          [
                                                                          'author']
                                                                      .toString(),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .start,
                                                                  style:  GoogleFonts.nunito(
                                                                      color: Colors
                                                                          .black,
                                                                      fontSize:
                                                                          12,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .normal,
                                                                      decoration:
                                                                          TextDecoration
                                                                              .none)),
                                                              Text(
                                                                  getCustomFormattedDateTime(
                                                                          tempData[index]
                                                                              [
                                                                              'created_at'],
                                                                          'dd-MM-yyyy hh:mm a')
                                                                      .toString(),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .start,
                                                                  style:  GoogleFonts.nunito(
                                                                      color: Colors
                                                                          .black,
                                                                      fontSize:
                                                                          12,
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
                                                        flex: 1,
                                                        child: ElevatedButton(
                                                            child: const Align(
                                                              alignment: Alignment
                                                                  .bottomCenter,
                                                              child: Icon(
                                                                Icons.delete,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                            style: ElevatedButton
                                                                .styleFrom(
                                                                    primary:Color(0xFF2C3246),
                                                                    onPrimary:
                                                                        Colors
                                                                            .white,
                                                                    shape:
                                                                        RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              20.0),
                                                                    )),
                                                            onPressed: () {
                                                              deleteAlert(
                                                                  tempData[
                                                                          index]
                                                                      ['id']);
                                                            })),
                                                    SizedBox(
                                                      width: windowWidth * 0.02,
                                                    ),
                                                    Expanded(
                                                        flex: 1,
                                                        child: ElevatedButton(
                                                            child: const Align(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              child: Icon(
                                                                Icons.edit,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                            style: ElevatedButton
                                                                .styleFrom(
                                                                    primary:Color(0xFF2C3246),
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
                                                                        tempData[index]
                                                                            [
                                                                            'id'];
                                                                    edited =
                                                                        true;
                                                                  }),
                                                                  editData(),
                                                                }))
                                                  ]),
                                                ),
                                              ),
                                          ])),
                                  SizedBox(
                                    height: windowHeight * 0.02,
                                  ),
                                  
                                ],
                              ),
                            ),
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
          )),
    );
  }
}
