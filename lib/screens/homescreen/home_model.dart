//
// class HomeModel {
//   int? success;
//   List<Data>? data;
//
//   HomeModel({this.success, this.data});
//
//   HomeModel.fromJson(Map<String, dynamic> json) {
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
//   String? bookingId;
//   int? roomNumber;
//   int? bedNumber;
//   bool? bedStatus;
//   String? employee;
//   String? loggedInDate;
//   String? loggedOutDate;
//
//   Data(
//       {this.bookingId,
//         this.roomNumber,
//         this.bedNumber,
//         this.bedStatus,
//         this.employee,
//         this.loggedInDate,
//         this.loggedOutDate});
//
//   Data.fromJson(Map<String, dynamic> json) {
//     bookingId = json['bookingId'];
//     roomNumber = json['roomNumber'];
//     bedNumber = json['bedNumber'];
//     bedStatus = json['bedStatus'];
//     employee = json['employee'];
//     loggedInDate = json['loggedInDate'];
//     loggedOutDate = json['loggedOutDate'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['bookingId'] = bookingId;
//     data['roomNumber'] = roomNumber;
//     data['bedNumber'] = bedNumber;
//     data['bedStatus'] = bedStatus;
//     data['employee'] = employee;
//     data['loggedInDate'] = loggedInDate;
//     data['loggedOutDate'] = loggedOutDate;
//     return data;
//   }
// }
//
// above is old model and belo is neew moel soi wnat to chnage in new screen SHM Sreen acoorng to th ethe new me only chnag emean when i am calling the Hommodel in homcreen i want that it shoudl call specific with new model like how to call it i dont know
class HomeModel {
  int? success;
  List<Data>? data;

  HomeModel({this.success, this.data});

  HomeModel.fromJson(Map<String, dynamic> json) {
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
  int? roomNumber;
  List<Beds>? beds;

  Data({this.roomNumber, this.beds});

  Data.fromJson(Map<String, dynamic> json) {
    roomNumber = json['roomNumber'];
    if (json['beds'] != null) {
      beds = <Beds>[];
      json['beds'].forEach((v) {
        beds!.add(new Beds.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['roomNumber'] = this.roomNumber;
    if (this.beds != null) {
      data['beds'] = this.beds!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Beds {
  int? bedNumber;
  bool? bedStatus;
  int? bookingId;
  String? employee;
  String? loggedInDate;
  String? loggedOutDate;

  Beds(
      {this.bedNumber,
        this.bedStatus,
        this.bookingId,
        this.employee,
        this.loggedInDate,
        this.loggedOutDate});

  Beds.fromJson(Map<String, dynamic> json) {
    bedNumber = json['bedNumber'];
    bedStatus = json['bedStatus'];
    bookingId = json['bookingId'] != null ? int.tryParse(json['bookingId']) : null;
    employee = json['employee'];
    loggedInDate = json['loggedInDate'];
    loggedOutDate = json['loggedOutDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['bedNumber'] = this.bedNumber;
    data['bedStatus'] = this.bedStatus;
    data['bookingId'] = this.bookingId; // Now it's an int
    data['employee'] = this.employee;
    data['loggedInDate'] = this.loggedInDate;
    data['loggedOutDate'] = this.loggedOutDate;
    return data;
  }
}