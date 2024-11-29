class EmployeeDropdown {
  int? success;
  List<Data>? data;

  EmployeeDropdown({this.success, this.data});

  EmployeeDropdown.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? id;
  String? name;
  String? email;
  String? contact;
  String? gender;
  String? dob;
  String? address;
  String? deptName;
  String? roleName;
  String? createdAt;
  String? updatedAt;

  Data(
      { this.id,
        this.name,
        this.email,
        this.contact,
        this.gender,
        this.dob,
        this.address,
        this.deptName,
        this.roleName,
        this.createdAt,
        this.updatedAt});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    contact = json['contact'];
    gender = json['gender'];
    dob = json['dob'];
    address = json['address'];
    deptName = json['deptName'];
    roleName = json['roleName'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    data['contact'] = this.contact;
    data['gender'] = this.gender;
    data['dob'] = this.dob;
    data['address'] = this.address;
    data['deptName'] = this.deptName;
    data['roleName'] = this.roleName;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}