import 'dart:math';
import 'package:accomodation_app/screens/homescreen/vacantbed_model.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'extend_model.dart';
import 'home_model.dart';

enum BedState { vacant, booked }
class BedDetails {
  final String roomNumber;
  final String employeeName;
  final String department;
  final String startDate;
  String endDate;
  BedDetails({
    required this.roomNumber,
    required this.employeeName,
    required this.department,
    required this.startDate,
    required this.endDate,
  });
  void updateEndDate(DateTime newEndDate) {
    endDate = DateFormat('yyyy-MM-dd').format(newEndDate);
  }
}
class HSMAccommodationController extends GetxController {
  var selectedDate = DateTime.now().obs;
  var focusedDate = DateTime.now().obs;
  var bedStatusByDate = RxMap<DateTime, List<BedState>>({});
  var bedDetailsByIndex = RxMap<int, BedDetails>({});
  var selectedFilter = 'All'.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeBedStatus();
    fetchItems();
  }

  void _initializeBedStatus() {
    DateTime startDate = DateTime.now().subtract(const Duration(days: 365));
    DateTime endDate = DateTime.now().add(const Duration(days: 365));
    for (DateTime date = startDate; date.isBefore(endDate); date = date.add(const Duration(days: 1))) {
      if (!bedStatusByDate.containsKey(date)) {
        bedStatusByDate[date] = List.filled(18, BedState.vacant);
        for (int j = 0; j < 5; j++) {
          int bookedIndex = Random().nextInt(18);
          bedStatusByDate[date]![bookedIndex] = BedState.booked;
          bedDetailsByIndex[bookedIndex] = BedDetails(
            roomNumber: 'Room ${bookedIndex + 100}',
            employeeName: 'Employee ${bookedIndex + 1}',
            department: 'Dept ${bookedIndex % 5}',
            startDate: DateFormat('yyyy-MM-dd').format(date.subtract(const Duration(days: 5))),
            endDate: DateFormat('yyyy-MM-dd').format(date.add(const Duration(days: 5))),
          );
        }
      }
    }
  }

  Future<HomeModel> fetchItems() async {
    String filterType = selectedFilter.value;
    Map<String, String> body = {
      'date': DateFormat('yyyy-MM-dd').format(selectedDate.value),
      'filterType': filterType,
    };
    http.Response response = await http.post(
      Uri.parse('https://beds-accomodation.vercel.app/api/checkBeds'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
    if (response.statusCode == 200) {
      String jsonString = response.body;
      Map<String, dynamic> data = Map<String, dynamic>.from(jsonDecode(jsonString));
      return HomeModel.fromJson(data);
    } else {
      throw Exception('Failed to load home model');
    }
  }

  Future<ExtendDateModel?> extendBed(int index, DateTime newEndDate) async {
    String url = 'https://beds-accomodation.vercel.app/api/viewExtendBooking';
    Map<String, dynamic> body = {
      'bedId': index,
      'logoutDate': DateFormat('yyyy-MM-dd').format(newEndDate),
    };
    http.Response response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
    if (response.statusCode == 200) {
      ExtendDateModel extendDateModel = ExtendDateModel.fromJson(jsonDecode(response.body));
      if (extendDateModel.success == 1) {
        bedDetailsByIndex[index] = BedDetails(
          roomNumber: bedDetailsByIndex[index]!.roomNumber,
          employeeName: bedDetailsByIndex[index]!.employeeName,
          department: bedDetailsByIndex[index]!.department,
          startDate: bedDetailsByIndex[index]!.startDate,
          endDate: extendDateModel.data1!.loggedOutDate!,
        );
        bedStatusByDate[selectedDate.value]![index] = BedState.booked;
        update();
        await fetchItems();
        print('Bed extended successfully');
        return extendDateModel;
      }
    }
    print('Failed to extend bed');
    return null;
  }

  Future<VacantBedModel?> vacateBed(int index) async {
    String url = 'https://beds-accomodation.vercel.app/api/bookToVacantBed';
    Map<String, dynamic> body = {
      'bedId': index,
    };
    http.Response response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
    if (response.statusCode == 200) {
      VacantBedModel vacantBedModel = VacantBedModel.fromJson(jsonDecode(response.body));
      print('Response: ${response.body}');
      if (vacantBedModel.success == 1) {
        bedStatusByDate[selectedDate.value]![index] = BedState.vacant;
        bedDetailsByIndex.remove(index);
        update();
        await fetchItems();
      }
      return vacantBedModel;
    } else {
      print('Failed to vacate bed: ${response.statusCode}');
      return null;
    }
  }

  void updateSelectedDate(DateTime date) {
    selectedDate.value = date;
    focusedDate.value = date;
    update();
  }

  void updateSelectedFilter(String filter) {
    selectedFilter.value = filter;
    update();
  }
}