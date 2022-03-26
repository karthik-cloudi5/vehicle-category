import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/service_request.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({Key? key, required this.documentId}) : super(key: key);

  final String documentId;

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  TextEditingController nameEnglishController = TextEditingController();
  TextEditingController nameHindiController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  final ServiceRequest _fireStoreRepository = ServiceRequest();
  String imageUrl = "";
  bool value = false;
  List<String> english = [];
  List<String> hindi = [];
  Future read(String? categoryId) async {
    QuerySnapshot querySnapshot;
    try {
      setState(() async {
        querySnapshot = await ServiceRequest()
            .userRef
            .where("parentID", isEqualTo: categoryId)
            .where("level", isEqualTo: 1)
            .get();
        if (querySnapshot.docs.isNotEmpty) {
          for (var doc in querySnapshot.docs.toList()) {
            var nameEnglish = jsonDecode(doc.get('name'));
            setState(() {
              english.add(nameEnglish[0]['value']);
              hindi.add(nameEnglish[1]['value']);
              debugPrint('eng:::: ' '$english');
              debugPrint(doc.get('categoryId'));
            });
          }
        } else {}
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  String? categoryId;

  @override
  void initState() {
    super.initState();

    try {
      _fireStoreRepository.userRef
          .doc(widget.documentId)
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          debugPrint('Document data: ${documentSnapshot.data()}');
          debugPrint('name data: ${documentSnapshot.get('name')}');
          String avatarUrl = documentSnapshot.get('icon');
          var nameEnglish = jsonDecode(documentSnapshot.get('name'));
          var eng = nameEnglish[0]['value'];
          var hindi = nameEnglish[1]['value'];
          String description = documentSnapshot.get('description').toString();
          categoryId = documentSnapshot.get('categoryId').toString();
          bool featured = documentSnapshot.get('featured') as bool;

          setState(() {
            imageUrl = avatarUrl;
            nameEnglishController.text = eng;
            nameHindiController.text = hindi;
            descriptionController.text = description;
            value = featured;
            read(categoryId);
          });
        } else {
          debugPrint('Document does not exist on the database');
        }
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff9e7f7),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.purple,
        title: const Text(
          "Details",
        ),
        centerTitle: false,
        automaticallyImplyLeading: true,
      ),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: GestureDetector(
          child: Stack(
            children: <Widget>[
              SizedBox(
                height: double.infinity,
                width: double.infinity,
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 40),
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Container(
                    alignment: Alignment.center,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // CircleAvatar(
                        //   radius: MediaQuery.of(context).size.width * 0.20,
                        //   backgroundColor: Colors.white,
                        //   backgroundImage: imageUrl.isEmpty
                        //       ? null
                        //       : NetworkImage(imageUrl.toString()),
                        //   child: imageUrl.isEmpty
                        //       ? Icon(
                        //           Icons.person,
                        //           size:
                        //               MediaQuery.of(context).size.width * 0.30,
                        //           color: Colors.grey,
                        //         )
                        //       : null,
                        // ),
                        const SizedBox(height: 25),
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
                        const SizedBox(height: 10),
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
                        const SizedBox(height: 10),
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
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Checkbox(
                              value: value,
                              activeColor: Colors.purple,
                              onChanged: (bool? value) {
                                setState(() {
                                  this.value = value!;
                                });
                              },
                            ),
                            const Text(
                              'Featured',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Sub category",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(
                          height: 300.0,
                          child: ListView.builder(
                              itemCount: english.length,
                              itemBuilder: (BuildContext context, int index) {
                                return ListTile(title: Text(english[index]));
                              }),
                        ),
                        const Text(
                          "Super sub category",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(
                          height: 300.0,
                          child: ListView.builder(
                              itemCount: hindi.length,
                              itemBuilder: (BuildContext context, int index) {
                                return ListTile(title: Text(hindi[index]));
                              }),
                        ),
                      ],
                    ),
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
