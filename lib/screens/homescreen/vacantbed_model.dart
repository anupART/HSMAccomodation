class VacantBedModel {
  int? success;
  String? message;

  VacantBedModel({this.success, this.message});

  VacantBedModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    return data;
  }
}
// this is body
// {
// "bedId":1
// }
