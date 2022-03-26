import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/service_request.dart';
import '../utils/error_dialog.dart';
import '../utils/loading_dialog.dart';
import 'home.dart';

class AddCategory extends StatefulWidget {
  const AddCategory({Key? key}) : super(key: key);

  @override
  State<AddCategory> createState() => _AddCategoryState();
}

class _AddCategoryState extends State<AddCategory> {
  TextEditingController nameEnglishController = TextEditingController();
  TextEditingController nameHindiController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  TextEditingController subCategoryController = TextEditingController();
  TextEditingController superSubCategoryController = TextEditingController();

  bool isFeaturedValue = false;

  XFile? imageXFile;
  final ImagePicker _picker = ImagePicker();

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  String imageUrl = "";

  Future<void> _getImage() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    } else {
      if (await Permission.storage.request().isGranted) {
        imageXFile = await _picker.pickImage(source: ImageSource.gallery);
        setState(() {
          imageXFile;
        });
      } else {
        debugPrint('Please give permission');
      }
    }
  }

  Future<void> formValidation() async {
    if (imageXFile == null) {
      showDialog(
          context: context,
          builder: (c) {
            return const ErrorDialog(
              message: "Please select an image",
            );
          });
    } else {
      if (nameEnglishController.text.isEmpty) {
        showDialog(
            context: context,
            builder: (c) {
              return const ErrorDialog(
                message: "Please enter your English Name",
              );
            });
      } else if (nameHindiController.text.isEmpty) {
        showDialog(
            context: context,
            builder: (c) {
              return const ErrorDialog(
                message: "Please enter valid Hindi Name",
              );
            });
      } else if (descriptionController.text.isEmpty) {
        showDialog(
            context: context,
            builder: (c) {
              return const ErrorDialog(
                message: "Please enter your Description",
              );
            });
      } else {
        showDialog(
            context: context,
            builder: (c) {
              return const LoadingDialog(
                message: "Category is adding",
              );
            });
        // String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        // storage.Reference reference = storage.FirebaseStorage.instance
        //     .ref()
        //     .child("images")
        //     .child(fileName);
        // storage.UploadTask uploadTask =
        //     reference.putFile(File(imageXFile!.path));
        // storage.TaskSnapshot snapshot = await uploadTask.whenComplete(() => {});
        // await snapshot.ref.getDownloadURL().then((url) {
        // imageUrl = url;
        String _attributeSet = getRandomString(24);
        String _categoryId = getRandomString(24);
        String _categoryNumber = getRandomNumber(4);
        String _description = descriptionController.text.toString();

        Map<String, dynamic> map2 = {
          '_id': getRandomString(24),
          'language': 'en',
          'value': nameEnglishController.text.toString()
        };
        Map<String, dynamic> map3 = {
          '_id': getRandomString(24),
          'language': 'hi',
          'value': nameHindiController.text.toString()
        };
        var nameEnglishMap = {map2, map3};

        String parentID;
        int level;

        if (mainCategory.isEmpty) {
          parentID = "0";
          level = 0;
        } else if (mainCategory.isNotEmpty && subCategory.isEmpty) {
          parentID = mainCategory;
          level = 1;
        } else {
          parentID = subCategory;
          level = 2;
        }

        debugPrint('ATTRIBUTE: ' + _attributeSet);
        debugPrint('CATEGORY ID: ' + _categoryId);
        debugPrint('CATEGORY NUMBER: ' + _categoryNumber);
        debugPrint('DESCRIPTION: ' + _description);
        debugPrint('NAMES: ' + nameEnglishMap.toString());
        debugPrint('PARENT ID: ' + parentID);
        debugPrint('LEVEL: ' + level.toString());

        _saveDataToFireStore(_attributeSet, _categoryId, _categoryNumber,
            _description, nameEnglishMap,parentID,level);
        // });
      }
    }
  }

  Future _saveDataToFireStore(
      String attributeSet,
      String categoryId,
      String categoryNumber,
      String description,
      Set<Map<String, dynamic>> nameEnglishMap,
      String parentID,
      int level) async {
    String dateTimeInMilli = DateTime.now().millisecondsSinceEpoch.toString();
    FirebaseFirestore.instance
        .collection("Vehicle")
        .doc()
        .set({
          "attributeSet": attributeSet,
          "categoryId": categoryId,
          "categoryNumber": categoryNumber,
          "create_date": dateTimeInMilli,
          "description": description,
          "featured": isFeaturedValue,
          "icon": "",
          "level": level,
          "name": nameEnglishMap.toString(),
          "parentID": parentID,
          "slug": nameEnglishController.text.toString().toLowerCase(),
          "status": true,
          "type": 1,
        })
        .whenComplete(() => Get.off(() => const Home()))
        .catchError((e) => debugPrint(e.toString()));
  }

  @override
  void initState() {
    super.initState();
    read('0');
    String randomValue = getRandomString(5);
    debugPrint(randomValue);
  }

  List<String> dropDownCategoryItems = ['Select Category'];
  List<String> dropDownCategory = ['0'];

  Future read(String? categoryId) async {
    try {
      QuerySnapshot querySnapshot = await ServiceRequest()
          .userRef
          .where("parentID", isEqualTo: categoryId)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs.toList()) {
          var nameEnglish = await jsonDecode(doc.get('name'));
          setState(() {
            dropDownCategoryItems.add(nameEnglish[0]['value']);
            dropDownCategory.add(doc.get('categoryId'));
            debugPrint('MAIN:::: ' '$dropDownCategoryItems');
          });
        }
      } else {}
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  List<String> dropDownSubCategoryItems = [];
  List<String> dropDownSubCategoryId = [];

  Future readSubCategoryDetails(String? categoryId) async {
    try {
      QuerySnapshot querySnapshot = await ServiceRequest()
          .userRef
          .where("parentID", isEqualTo: categoryId)
          .orderBy("slug", descending: false)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        dropDownSubCategoryItems.clear();
        dropDownSubCategoryId.clear();

        dropDownSubCategoryItems.add('Select Sub Category');
        dropDownSubCategoryId.add('0');

        for (var doc in querySnapshot.docs.toList()) {
          var nameEnglish = jsonDecode(doc.get('name'));
          setState(() {
            dropDownSubCategoryItems.add(nameEnglish[0]['value']);
            dropDownSubCategoryId.add(doc.get('categoryId'));
            debugPrint('SUB:::: ' '$dropDownSubCategoryItems');
          });
        }
      } else {}
    } catch (e) {
      debugPrint(e.toString());
    }
    return dropDownSubCategoryItems;
  }

  late String mainCategory = "", subCategory = "";

  static const _chars = '0123456789abcdefghijklmnopqrstuvwxyz';
  static const _number = '0123456789';
  final Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  String getRandomNumber(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _number.codeUnitAt(_rnd.nextInt(_number.length))));

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add category"),
        backgroundColor: Colors.purple,
      ),
      body: SafeArea(
        child: GestureDetector(
          child: Stack(
            children: <Widget>[
              Container(
                color: const Color(0xfff9e7f7),
                height: double.infinity,
                width: double.infinity,
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      SizedBox(height: size.height * 0.03),
                      InkWell(
                        onTap: () {
                          _getImage();
                        },
                        child: CircleAvatar(
                          radius: MediaQuery.of(context).size.width * 0.20,
                          backgroundColor: Colors.white,
                          backgroundImage: imageXFile == null
                              ? null
                              : FileImage(File(imageXFile!.path)),
                          child: imageXFile == null
                              ? Icon(
                                  Icons.add_photo_alternate,
                                  size:
                                      MediaQuery.of(context).size.width * 0.20,
                                  color: Colors.grey,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      SizedBox(height: size.height * 0.03),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text(
                            "Name in English",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            alignment: Alignment.centerLeft,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: const [
                                  BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 6,
                                      offset: Offset(0, 2)),
                                ]),
                            height: 60,
                            child: TextFormField(
                              keyboardType: TextInputType.name,
                              style: const TextStyle(
                                color: Colors.black87,
                              ),
                              decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.only(top: 14),
                                  prefixIcon: Icon(
                                    Icons.person,
                                    color: Colors.purple,
                                  ),
                                  hintText: "Enter name in english",
                                  hintStyle: TextStyle(
                                    color: Colors.black38,
                                  )),
                              controller: nameEnglishController,
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: size.height * 0.02),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text(
                            "Name in hindi",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            alignment: Alignment.centerLeft,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: const [
                                  BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 6,
                                      offset: Offset(0, 2)),
                                ]),
                            height: 60,
                            child: TextFormField(
                              keyboardType: TextInputType.name,
                              style: const TextStyle(
                                color: Colors.black87,
                              ),
                              decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.only(top: 14),
                                  prefixIcon: Icon(
                                    Icons.person,
                                    color: Colors.purple,
                                  ),
                                  hintText: "Enter name in hindi",
                                  hintStyle: TextStyle(
                                    color: Colors.black38,
                                  )),
                              controller: nameHindiController,
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: size.height * 0.02),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text(
                            "Description",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            alignment: Alignment.centerLeft,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: const [
                                  BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 6,
                                      offset: Offset(0, 2)),
                                ]),
                            height: 60,
                            child: TextFormField(
                              keyboardType: TextInputType.name,
                              style: const TextStyle(
                                color: Colors.black87,
                              ),
                              decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.only(top: 14),
                                  prefixIcon: Icon(
                                    Icons.description,
                                    color: Colors.purple,
                                  ),
                                  hintText: "Enter description",
                                  hintStyle: TextStyle(
                                    color: Colors.black38,
                                  )),
                              controller: descriptionController,
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: size.height * 0.02),
                      Row(
                        children: [
                          Checkbox(
                            value: isFeaturedValue,
                            activeColor: Colors.purple,
                            onChanged: (bool? value) {
                              setState(() {
                                isFeaturedValue = value!;
                              });
                            },
                          ),
                          const Text(
                            'Featured',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(height: size.height * 0.02),
                      DropdownButtonFormField(
                        hint: const Text('Select Category'),
                        value: dropDownCategoryItems.isEmpty
                            ? "Select Category"
                            : dropDownCategoryItems[0],
                        items: dropDownCategoryItems.map((account) {
                          return DropdownMenuItem(
                            value: account,
                            child: Text(account),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            debugPrint('MAIN CATEGORY *** $val');
                            mainCategory = dropDownCategory[
                                dropDownCategoryItems.indexOf(val.toString())];
                            debugPrint('MAIN CATEGORY ID *** $mainCategory');
                            readSubCategoryDetails(dropDownCategory[
                                dropDownCategoryItems.indexOf(val.toString())]);
                          });
                        },
                      ),
                      SizedBox(height: size.height * 0.02),
                      DropdownButtonFormField(
                        hint: const Text('Select Sub Category'),
                        value: dropDownSubCategoryItems.isEmpty
                            ? "Select Sub Category"
                            : dropDownSubCategoryItems[0],
                        items: dropDownSubCategoryItems.map((accountType) {
                          return DropdownMenuItem(
                            value: accountType,
                            child: Text(accountType),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            debugPrint('SUB CATEGORY *** $value');
                            subCategory = dropDownSubCategoryId[
                            dropDownSubCategoryItems
                                .indexOf(value.toString())];
                            debugPrint('SUB CATEGORY ID *** $subCategory');
                          });
                        },
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          formValidation();
                        },
                        child: const Text(
                          "Submit",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 35, vertical: 15),
                        ),
                      ),
                      SizedBox(height: size.height * 0.03),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
