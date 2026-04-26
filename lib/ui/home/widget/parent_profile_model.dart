class ParentProfileModel {
  String? parentName;
  String? parentEmail;
  String? parentPhone;
  List<Child>? children;

  ParentProfileModel({
    this.parentName,
    this.parentEmail,
    this.parentPhone,
    this.children,
  });

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

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['parentName'] = parentName;
    data['parentEmail'] = parentEmail;
    data['parentPhone'] = parentPhone;
    if (children != null) {
      data['children'] = children!.map((v) => v.toJson()).toList();
    }
    return data;
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

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['fullName'] = fullName;
    data['dateOfBirth'] = dateOfBirth;
    data['gender'] = gender;
    return data;
  }
}