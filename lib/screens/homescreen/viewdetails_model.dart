class ViewDetailsModel {
  int? success;
  String? message;
  Data1? data1;
  List<int>? data2;

  ViewDetailsModel({this.success, this.message, this.data1, this.data2});

  ViewDetailsModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data1 = json['data1'] != null ? new Data1.fromJson(json['data1']) : null;
    data2 = json['data2'].cast<int>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    if (this.data1 != null) {
      data['data1'] = this.data1!.toJson();
    }
    data['data2'] = this.data2;
    return data;
  }
}

class Data1 {
  String? name;
  String? deptName;
  int? roomNumber;
  int? bedNumber;
  String? loggedInDate;
  String? loggedOutDate;
  bool? bedStatus;

  Data1(
      {this.name,
        this.deptName,
        this.roomNumber,
        this.bedNumber,
        this.loggedInDate,
        this.loggedOutDate,
        this.bedStatus});

  Data1.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    deptName = json['deptName'];
    roomNumber = json['roomNumber'];
    bedNumber = json['bedNumber'];
    loggedInDate = json['loggedInDate'];
    loggedOutDate = json['loggedOutDate'];
    bedStatus = json['bedStatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['deptName'] = this.deptName;
    data['roomNumber'] = this.roomNumber;
    data['bedNumber'] = this.bedNumber;
    data['loggedInDate'] = this.loggedInDate;
    data['loggedOutDate'] = this.loggedOutDate;
    data['bedStatus'] = this.bedStatus;
    return data;
  }
}
// from here i am fetching teh date from dialo box see this also
/**
    {
    "bedId":15,
    "bookingId":5
    //"loggedOutDate":"2024-09-19" // this loogout key useed only in extedn
    // body
    }
 */

