class ParentProfileModel {
  String? parentName;
  String? parentEmail;
  String? parentPhone;
  List<Child>? children;

  ParentProfileModel({this.parentName, this.parentEmail, this.parentPhone, this.children});

  ParentProfileModel.fromJson(Map<String, dynamic> json) {
    parentName = json['parentName'];
    parentEmail = json['parentEmail'];
    parentPhone = json['parentPhone'];
    if (json['children'] != null) {
      children = <Child>[];
      json['children'].forEach((v) {
        children!.add(Child.fromJson(v));
      });
    }
  }
}

class Child {
  int? id;
  String? fullName;
  String? dateOfBirth;
  String? gender;

  Child({this.id, this.fullName, this.dateOfBirth, this.gender});

  Child.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fullName = json['fullName'];
    dateOfBirth = json['dateOfBirth'];
    gender = json['gender'];
  }
}