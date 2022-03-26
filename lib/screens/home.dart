import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/service_request.dart';
import 'add_category.dart';
import 'detail_page.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final ServiceRequest _fireStoreRepository = ServiceRequest();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Icon customIcon = const Icon(Icons.search);
  Widget customSearchBar = const Text('Vehicle');

  List<String> dropDownItems = [];
  List<String> dropDownCategory = [];

  Future read(String? categoryId) async {
    QuerySnapshot querySnapshot;
    try {
      querySnapshot = await ServiceRequest()
          .userRef
          .where("parentID", isEqualTo: categoryId)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        dropDownItems.clear();
        dropDownCategory.clear();
        for (var doc in querySnapshot.docs.toList()) {
          var nameEnglish = jsonDecode(doc.get('name'));
          setState(() {
            dropDownItems.add(nameEnglish[0]['value']);
            dropDownCategory.add(doc.get('categoryId'));
            debugPrint('eng:::: ' '$dropDownItems');
            debugPrint(doc.get('categoryId'));
          });
        }
      } else {}
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  final TextEditingController searchController = TextEditingController();
  List searchResult = [];

  String searchKey = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xfff9e7f7),
        appBar: AppBar(
          title: customSearchBar,
          backgroundColor: Colors.purple,
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  if (customIcon.icon == Icons.search) {
                    customIcon = const Icon(Icons.cancel);
                    customSearchBar = ListTile(
                      leading: const Icon(
                        Icons.search,
                        color: Colors.white,
                        size: 28,
                      ),
                      title: TextField(
                        onChanged: (value) {
                          setState(() {
                            searchKey = value;
                          });
                        },
                        decoration: const InputDecoration(
                          hintText: 'type here...',
                          hintStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontStyle: FontStyle.italic,
                          ),
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    );
                  } else {
                    customIcon = const Icon(Icons.search);
                    customSearchBar = const Text('Vehicle');
                  }
                });
              },
              icon: customIcon,
            )
          ],
        ),
        body: Container(
          padding: const EdgeInsets.all(15.0),
          alignment: Alignment.center,
          height: double.infinity,
          child: StreamBuilder<QuerySnapshot>(
            stream: searchKey.isEmpty
                ? _fireStoreRepository.readItem()
                : _fireStoreRepository.searchItem(searchKey),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text("Something went wrong");
              } else if (snapshot.hasData || snapshot.data != null) {
                debugPrint("length");
                debugPrint("${snapshot.data!.docs.length}");
                if (snapshot.data!.docs.isEmpty) {
                  return const Text("No data Available");
                } else {
                  return ListView.separated(
                    separatorBuilder: (context, index) => const SizedBox(
                      height: 16.0,
                    ),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> note = snapshot.data!.docs[index]
                          .data() as Map<String, dynamic>;
                      String id = snapshot.data!.docs[index].id;
                      var namesAry = jsonDecode(note['name']);
                      String aNameEng = namesAry[0]['value'];
                      String aNameHindi = namesAry[1]['value'];
                      return Ink(
                        decoration: BoxDecoration(
                          color: const Color(0xcc5ac18e),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: ExpansionTile(
                                onExpansionChanged: (bool isExpanded) {
                                  read(note['categoryId']);
                                  debugPrint('categoryId');
                                  debugPrint(note['categoryId']);
                                },
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(left: 10.0),
                                        child: Text(
                                          "Sub category",
                                          style: TextStyle(
                                              color: Colors.purple,
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 200.0,
                                        child: ListView.builder(
                                            itemCount: dropDownItems.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return ExpansionTile(
                                                  title: Text(
                                                      dropDownItems[index]));
                                            }),
                                      ),
                                    ],
                                  )
                                ],
                                title: Text(
                                  aNameEng,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  aNameHindi,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: ElevatedButton(
                                  onPressed: () {
                                    Get.to(() => DetailPage(documentId: id));
                                  },
                                  style: ElevatedButton.styleFrom(
                                      primary: const Color(0xff06114F)),
                                  child: const Text('View')),
                            )
                          ],
                        ),
                      );
                    },
                  );
                }
              }
              return const Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.orangeAccent),
                ),
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Get.to(() => const AddCategory());
          },
          child: const Icon(Icons.add),
        ));
  }
}
