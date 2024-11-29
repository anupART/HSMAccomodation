// class SearchEmp {
//   int? success;
//   List<Data>? data;
//
//   SearchEmp({this.success, this.data});
//
//   SearchEmp.fromJson(Map<String, dynamic> json) {
//     success = json['success'];
//     if (json['data'] != null) {
//       data = <Data>[];
//       json['data'].forEach((v) {
//         data!.add(new Data.fromJson(v));
//       });
//     }
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['success'] = this.success;
//     if (this.data != null) {
//       data['data'] = this.data!.map((v) => v.toJson()).toList();
//     }
//     return data;
//   }
// }
//
// class Data {
//   String? name;
//   String? id;
//   String? deptName;
//   String? email;
//
//   Data({this.name, this.id, this.deptName, this.email});
//
//   Data.fromJson(Map<String, dynamic> json) {
//     name = json['name'];
//     id = json['id'];
//     deptName = json['deptName'];
//     email = json['email'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['name'] = this.name;
//     data['id'] = this.id;
//     data['deptName'] = this.deptName;
//     data['email'] = this.email;
//     return data;
//   }
// }
//
