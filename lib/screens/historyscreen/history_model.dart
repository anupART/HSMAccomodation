class HistoryModel {
  int success;
  List<Data> data;

  HistoryModel({required this.success, required this.data});

  HistoryModel.fromJson(Map<String, dynamic> json)
      : success = json['success'],
        data = (json['data'] as List).map((i) => Data.fromJson(i)).toList();

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['success'] = success;
    data['data'] = this.data.map((v) => v.toJson()).toList();
    return data;
  }
}

class Data {
  String empId;
  String name;
  String deptName;
  String email;
  List<BookingDetails>? bookingDetails;

  Data(
      {
        required this.empId,
        required this.name,
        required this.deptName,
        required this.email,
        this.bookingDetails});

  Data.fromJson(Map<String, dynamic> json)
      :empId = json['empId'],
        name = json['name'],
        deptName = json['deptName'],
        email = json['email'],
        bookingDetails = (json['bookingDetails'] as List?)
            ?.map((i) => BookingDetails.fromJson(i))
            .toList();

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['empId'] = empId;
    data['name'] = name;
    data['deptName'] = deptName;
    data['email'] = email;
    if (bookingDetails != null) {
      data['bookingDetails'] =
          bookingDetails?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class BookingDetails {
  String id;
  int roomNumber;
  int bedNumber;
  int bedId;
  String loggedInDate;
  String loggedOutDate;
  int isCancel;

  BookingDetails(
      {required this.id,
        required this.roomNumber,
        required this.bedNumber,
        required this.bedId,
        required this.loggedInDate,
        required this.loggedOutDate,
        required this.isCancel});

  BookingDetails.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        roomNumber = json['roomNumber'],
        bedNumber = json['bedNumber'],
        bedId = json['bedId'],
        loggedInDate = json['loggedInDate'],
        loggedOutDate = json['loggedOutDate'],
        isCancel = json['isCancel'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['roomNumber'] = roomNumber;
    data['bedNumber'] = bedNumber;
    data['bedId'] = bedId;
    data['loggedInDate'] = loggedInDate;
    data['loggedOutDate'] = loggedOutDate;
    data['isCancel'] = isCancel;
    return data;
  }
}