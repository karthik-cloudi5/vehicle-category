
import 'dart:convert';

class CategoryModel {
  String? categoryId;
  Map<String,dynamic>? name;
  String? slug;
  String? description;
  String? parentID;
  int? type;
  String? attributeSet;
  int? categoryNumber;
  int? level;
  bool? featured;
  String? icon;
  bool? status;
  String? createDate;

  CategoryModel(
      {this.categoryId,
        this.name,
        this.slug,
        this.description,
        this.parentID,
        this.type,
        this.attributeSet,
        this.categoryNumber,
        this.level,
        this.featured,
        this.icon,
        this.status,
        this.createDate});

  CategoryModel.fromJson(Map<String, dynamic> json) {
    categoryId = json['categoryId'];
    if (json['name'] != null) {
      var nameEnglish = jsonDecode(json['name']);
      Map<String,dynamic> nameData = nameEnglish;
      name = nameData;
    }
    slug = json['slug'];
    description = json['description'];
    parentID = json['parentID'];
    type = json['type'];
    attributeSet = json['attributeSet'];
    categoryNumber = json['categoryNumber'];
    level = json['level'];
    featured = json['featured'];
    icon = json['icon'];
    status = json['status'];
    createDate = json['create_date'];
  }

}

