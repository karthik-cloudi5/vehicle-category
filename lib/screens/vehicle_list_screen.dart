import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../model/category_model.dart';
import '../services/service_request.dart';
import 'add_category.dart';

class VehicleList extends StatefulWidget {
  const VehicleList({Key? key}) : super(key: key);

  @override
  State<VehicleList> createState() => _VehicleListState();
}

class _VehicleListState extends State<VehicleList> {
  final ServiceRequest _serviceRequest = ServiceRequest();

  List<CategoryModel> myGlobalData = <CategoryModel>[];

  @override
  void initState() {
    super.initState();
    _serviceRequest.loadAsset().then((value) async {
      var res = await json.decode(value)["data"] as List;
      setState(() {
        myGlobalData =
            res.map<CategoryModel>((json) => CategoryModel.fromJson(json)).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff9e7f7),
      appBar: AppBar(
        title: const Text('Vehicle'),
      ),
      body: SizedBox(
        height: double.infinity,
        child: ListView.builder(
            itemCount: myGlobalData.length,
            physics: const AlwaysScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              CategoryModel members = myGlobalData[index];
              // List<Name> nameList = members.name;
              Map<String,dynamic> nameList = members.name!;
              debugPrint(nameList[0].value);
              debugPrint(nameList[1].value);
              return GestureDetector(
                onTap: () {},
                child: Container(
                  height: 75,
                  color: Colors.white,
                  child: Card(
                    elevation: 3.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(nameList[0].value),
                          const SizedBox(height: 5.0),
                          Text(nameList[1].value),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(()=> const AddCategory());
        },
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
