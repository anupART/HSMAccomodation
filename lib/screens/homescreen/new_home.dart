import 'dart:convert';
import 'package:accomodation_app/screens/homescreen/vacantbed_model.dart';
import 'package:accomodation_app/screens/homescreen/viewdetails_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../../style/color.dart';
import '../bookingpage/booking_page.dart';
import 'home_model.dart';
import 'homescreen_controller.dart';

Color _getBedColor(BedState state) {
  switch (state) {
    case BedState.vacant:
      return Colors.orange.shade300;
    case BedState.booked:
      return Colors.green.shade400;
    default:
      return Colors.white;
  }
}

Widget _detailItem(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      children: [
        Text(
          '$label: ',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: Colors.grey.shade600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}

Widget _buildLegend() {
  return Padding(
    padding: const EdgeInsets.only(bottom: 25, left: 16, right: 16),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem(bookedColor, 'Booked'),
        const SizedBox(width: 16),
        _legendItem(vacantColor, 'Vacant'),
      ],
    ),
  );
}

Widget _legendItem(Color color, String label) {
  return Row(
    children: [
      Container(
        width: 20,
        height: 20,
        color: color,
      ),
      const SizedBox(width: 8),
      Text(label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.black,
          )),
    ],
  );
}

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

class HSMAccommodation extends StatefulWidget {
  final Function(int, String, String, String) onBookingRequested;

  HSMAccommodation({this.index, super.key, required this.onBookingRequested});
  HSMAccommodationController hsmAccommodationController =
      HSMAccommodationController();
  final _startDateController = TextEditingController();
  final _bedNumberController = TextEditingController();
  int? index;
  @override
  _CalendarBedBookingState createState() =>
      _CalendarBedBookingState(hsmAccommodationController);
// _CalendarBedBookingState createState() => _CalendarBedBookingState();
}

class _CalendarBedBookingState extends State<HSMAccommodation> {
  final HSMAccommodationController hsmAccommodationController;
  // ExtendDateModel extendDateModelFromJson(String str) => ExtendDateModel.fromJson(json.decode(str));
  // String extendDateModelToJson(ExtendDateModel data) => json.encode(data.toJson());
  late DateTime selectedDate;
  Map<DateTime, List<BedState>> bedStatusByDate = {};
  late DateTime focusedDate;
  Map<int, BedDetails> bedDetailsByIndex = {};
  String selectedFilter = 'All';
  _CalendarBedBookingState(this.hsmAccommodationController);
  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    focusedDate = DateTime.now();
    _initializeBedStatus();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
              child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 8),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 1.05,
                  child: Card(
                    elevation: 6,
                    color: Colors.white,
                    child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        child: _buildTableCalendar()),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 1, horizontal: 4),
                  child: _buildChoiceChips(),
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _buildBedLayout(),
                ),
              ],
            ),
          )),
        ),
      ),
    );
  }

  Widget _buildChoiceChips() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildSingleChoiceChip('All'),
        const SizedBox(
          width: 10,
        ),
        _buildSingleChoiceChip('Female'),
        const SizedBox(
          width: 10,
        ),
        _buildSingleChoiceChip('Male'),
      ],
    );
  }

  Widget _buildSingleChoiceChip(String label) {
    bool isSelected = selectedFilter ==
        (label == 'Female'
            ? 'Girls'
            : label == 'Male'
                ? 'Boys'
                : 'All');

    return SizedBox(
      height: Get.size.height / 17,
      child: ChoiceChip(
        label: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            overflow: TextOverflow.ellipsis,
            softWrap: true,
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? myPrimaryColor : Colors.black87,
            ),
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            selectedFilter = label == 'Female'
                ? 'Girls'
                : label == 'Male'
                    ? 'Boys'
                    : 'All';
          });
        },
        showCheckmark: false,
        backgroundColor: Colors.white,
        selectedColor: Colors.white,
        elevation: 4,
        pressElevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? myPrimaryColor : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Widget _buildRoomNumber(int roomNumber) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8, left: 8, right: 4),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
            decoration: BoxDecoration(
              color: myPrimaryColor,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              'Room $roomNumber',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBedLayout() {
    if(_isRefreshing){
      return Center(child: CircularProgressIndicator(),);
    }
    return FutureBuilder<HomeModel>(
      future: fetchItems(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          HomeModel homeModel = snapshot.data!;
          Map<int, BedState> bedStatusMap = {};
          for (var room in homeModel.data ?? []) {
            for (var bed in room.beds ?? []) {
              bedStatusMap[bed.bedNumber!] =
                  bed.bedStatus == true ? BedState.booked : BedState.vacant;
              if (bed.bedStatus == true) {
                bedDetailsByIndex[bed.bedNumber!] = BedDetails(
                  roomNumber: 'Room ${room.roomNumber!}',
                  employeeName: bed.employee ?? '',
                  department: '',
                  startDate: bed.loggedInDate ?? '',
                  endDate: bed.loggedOutDate ?? '',
                );
              }
            }
          }

          List<int> girlsBedNumbers = List.generate(9, (bedId) => bedId + 1);
          List<int> boysBedNumbers = List.generate(9, (bedId) => bedId + 10);

          return Column(
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (selectedFilter != 'Boys') ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: _buildBedGroup(girlsBedNumbers.sublist(0, 4),
                                101, bedStatusMap),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildBedGroup(girlsBedNumbers.sublist(4, 9),
                                102, bedStatusMap),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                    ],
                    if (selectedFilter != 'Girls') ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: _buildBedGroup(boysBedNumbers.sublist(0, 4),
                                103, bedStatusMap),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildBedGroup(boysBedNumbers.sublist(4, 9),
                                104, bedStatusMap),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Selected Date: ${DateFormat('dd-MM-yyyy').format(selectedDate)}',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              _buildLegend(),
            ],
          );
        } else if (snapshot.hasError) {
          return Center(
              child: Text(
            'Date cannot be extended as another bed is booked for that date',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ));
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _buildBedGroup(
      List<int> bedNumbers, int roomNumber, Map<int, BedState> bedStatusMap) {
    return Container(
      height: Get.size.height / 5,
      width: Get.size.width / 10,
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 0,
            blurRadius: 10,
            blurStyle: BlurStyle.normal,
            offset: const Offset(5, 5),
          ),
          const BoxShadow(
            color: Colors.white,
            spreadRadius: 0,
            blurRadius: 10,
            blurStyle: BlurStyle.normal,
            offset: Offset(-5, -5),
          ),
        ],
        borderRadius: BorderRadius.circular(10),
      ),
      // height: Get.size.height / 5.3,
      // width: Get.size.width / 3,
      margin: const EdgeInsets.all(8),
      child: Column(
        children: [
          _buildRoomNumber(roomNumber),
          const SizedBox(height: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2.7,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: bedNumbers.length,
                itemBuilder: (context, index) {
                  int bedNumber = bedNumbers[index];
                  BedState bedState =
                      bedStatusMap[bedNumber] ?? BedState.vacant;
                  return GestureDetector(
                    onTap: () => _showBedDialog(bedNumber, bedState),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _getBedColor(bedState),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          'Bed $bedNumber',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: (BedState.booked == true)
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableCalendar() {
    return TableCalendar(
      startingDayOfWeek: StartingDayOfWeek.monday,
      focusedDay: focusedDate,
      firstDay: DateTime.now().subtract(const Duration(days: 90)),
      lastDay: DateTime.now().add(const Duration(days: 90)),
      calendarFormat: CalendarFormat.week,
      selectedDayPredicate: (day) => isSameDay(selectedDate, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          selectedDate = selectedDay;
          focusedDate = focusedDay;
        });
      },
      headerStyle: HeaderStyle(
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: myPrimaryColor,
        ),
        formatButtonVisible: false,
        titleCentered: true,
        leftChevronIcon: Icon(
          Icons.chevron_left,
          color: myPrimaryColor,
        ),
        rightChevronIcon: Icon(
          Icons.chevron_right,
          color: myPrimaryColor,
        ),
      ),
      calendarStyle: CalendarStyle(
        defaultTextStyle: GoogleFonts.poppins(
          fontSize: 16,
          color: Colors.black,
        ),
        weekendTextStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.red,
        ),
        selectedTextStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        todayTextStyle: GoogleFonts.poppins(
          fontSize: 16,
          color: Colors.white,
        ),
        outsideTextStyle: GoogleFonts.poppins(
          color: Colors.grey.shade400,
        ),
        disabledTextStyle: GoogleFonts.poppins(
          color: Colors.grey.shade600,
        ),
        todayDecoration: const BoxDecoration(
          color: Colors.orangeAccent,
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: myPrimaryColor,
          shape: BoxShape.circle,
        ),
      ),
      enabledDayPredicate: (day) => true,
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(message,style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w400,
          )),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showBedDialog(int bedNumber, BedState bedState) async {
    bool isToday = DateTime.now().year == selectedDate.year &&
        DateTime.now().month == selectedDate.month &&
        DateTime.now().day == selectedDate.day;

    if (selectedDate
        .isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      _showErrorDialog(
          'Past Date', 'This date is in the past and cannot be edited.');
      return;
    }

    if (bedState == BedState.booked) {
      try {
        HomeModel homeModel = await fetchItems();
        Beds? selectedBed;
        for (var room in homeModel.data!) {
          for (var bed in room.beds!) {
            if (bed.bedNumber == bedNumber && bed.bedStatus == true) {
              selectedBed = bed;
              break;
            }
          }
          if (selectedBed != null) break;
        }

        if (selectedBed != null) {
          ViewDetailsModel? viewDetailsModel =
              await fetchViewDetails(bedNumber, selectedBed.bookingId!);

          if (viewDetailsModel != null && viewDetailsModel.success == 1) {
            _showDetailsDialog(
                viewDetailsModel.data1!, bedNumber, selectedBed.bookingId!);
          } else {
            String vacantDate = selectedBed.loggedOutDate != null
                ? DateFormat('dd-MM-yyyy')
                    .format(DateTime.parse(selectedBed.loggedOutDate!))
                : 'unknown date';
            _showErrorDialog('Booked Bed',
                'Bed no. $bedNumber cannot be booked until $vacantDate. It is currently occupied by ${selectedBed.employee}.'
            );
                }
        } else {
          _showErrorDialog('Error', 'Bed details not found.');
        }
      } catch (e) {
        _showErrorDialog('Error', 'An error occurred: $e');
      }
    } else {
      _showBookingConfirmationDialog(bedNumber);
    }
  }

  void _showBookingConfirmationDialog(int bedNumber) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('Book Bed $bedNumber',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              )),
          content: Text('Do you want to book this bed?',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w400,
              )),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No',
                  style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _navigateToBookingPage(bedNumber);
              },
              child: Text('Yes',
                  style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.green)),
            ),
          ],
        );
      },
    );
  }
  String formatDate(String? date) {
    if (date == null || date.isEmpty) {
      return ''; // Return empty string if date is null or empty
    }

    try {
      DateTime parsedDate = DateTime.parse(date);
      return DateFormat('dd-MM-yyyy').format(parsedDate); // Format to dd-MM-yyyy
    } catch (e) {
      return ''; // Return empty string if parsing fails
    }
  }
  void _showDetailsDialog(Data1 bedDetails, int bedNumber, int bookingId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('Bed ${bedDetails.bedNumber}',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              )),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailItem('Name', bedDetails.name ?? ''),
              _detailItem('Department', bedDetails.deptName ?? ''),
              _detailItem(
                  'Room Number', bedDetails.roomNumber?.toString() ?? ''),
              _detailItem('Check-in Date',formatDate(bedDetails.loggedInDate) ?? ''),
              _detailItem('Check-out Date',formatDate( bedDetails.loggedOutDate)?? ''),
            ],
          ),
          actions: [
            TextButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade100,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                DateTime? newEndDate = await _selectEndDate(
                    context, bedDetails.loggedOutDate ?? '');
                if (newEndDate != null) {
                  Navigator.of(context).pop();
                  _showExtendConfirmationDialog(
                      bedDetails, bookingId, newEndDate);
                }
              },
              child: Text(
                'Extend',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: bookedColor,
                ),
              ),
            ),
            TextButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade100,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                DateTime? vacantDate = await _selectVacantDate(context);
                if (vacantDate != null) {
                  Navigator.of(context).pop();
                  _showVacateConfirmationDialog(
                      bedNumber, bookingId, vacantDate);
                }
              },
              child: Text(
                'Vacant',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,

                  color: myPrimaryColor,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<DateTime?> _selectVacantDate(BuildContext context) async {
    DateTime initialDate = DateTime.now();
    DateTime lastDate = DateTime.now().add(const Duration(days: 365));

    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogBackgroundColor: myOnSecondaryColor,
            colorScheme: ColorScheme.light(
              primary: myPrimaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                textStyle: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                foregroundColor: Colors.black,
              ),
            ),
          ),
          child: child ?? const SizedBox(),
        );
      },
    );
  }
  bool _isRefreshing = false;
  void _navigateToBookingPage(int bedNumber) {
    String gender = (bedNumber >= 1 && bedNumber <= 9) ? 'Female' : 'Male';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingPage(
          bedIndex: bedNumber,
          roomNumber: 'Room ${bedNumber ~/ 10}',
          gender: gender,
          dateTime: DateFormat('yyyy-MM-dd').format(selectedDate),
        ),
      ),
    ).then((value) async {
      if (value == true) {
        setState(() {
          _isRefreshing = true;
        });

        await fetchItems();

        setState(() {
          _isRefreshing = false;
        });
      }
    });
  }
  Future<ViewDetailsModel?> fetchViewDetails(int bedId, int bookingId) async {
    String url = 'https://beds-accomodation.vercel.app/api/viewExtendBooking';
    print("bed id : $bedId");
    print("booking id : $bookingId");

    Map<String, dynamic> body = {'bedId': bedId, 'bookingId': bookingId};

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return ViewDetailsModel.fromJson(jsonDecode(response.body));
      } else {
        print('Failed to fetch view details: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error in fetchViewDetails: $e');
      return null;
    }
  }

  void _showExtendConfirmationDialog(
      Data1 bedDetails, int booking_Id, DateTime newEndDate) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('Confirm Extension Bed no. ${bedDetails.bedNumber}',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              )),
          content: Text(
              'Do you want to extend the logout date to ${DateFormat('dd-MM-yyyy').format(newEndDate)}?',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w400,
              )),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No',
                  style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();

                _extendLogoutDate(
                    bedDetails.bedNumber ?? 0, booking_Id, newEndDate);
              },
              child: Text('Yes',
                  style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.green)),
            ),
          ],
        );
      },
    );
  }

  void _showVacateConfirmationDialog(
      int bedNumber, int bookingId, DateTime vacantDate) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('Confirm Vacant Bed no. $bedNumber',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              )),
          content: Text(
              'Do you want to vacate the bed on ${DateFormat('dd-MM-yyyy').format(vacantDate)}?',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w400,
              )),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('No',
                  style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _vacateBed(bedNumber, bookingId,
                    DateFormat('yyyy-MM-dd').format(vacantDate));
              },
              child: Text('Yes',
                  style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.green)),
            )
          ],
        );
      },
    );
  }

  Future<void> _vacateBed(
      int bed_number, int booking_id, String logoutVacantDate) async {
    String url = 'https://beds-accomodation.vercel.app/api/bookToVacantBed';
    Map<String, dynamic> body = {
      'bedId': bed_number,
      'bookingId': booking_id,
      'loggedOutDate': logoutVacantDate
    };
    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        VacantBedModel vacantBedModel =
            VacantBedModel.fromJson(jsonDecode(response.body));
        print('Response: ${response.body}');
        if (vacantBedModel.success == 1) {
          setState(() {
            fetchItems();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orangeAccent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Bed vacated successfully',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              backgroundColor: Colors.transparent,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 0,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Failed to vacate bed. Please try again.',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              backgroundColor: Colors.transparent,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 0,
            ),
          );
        }
      } else {
        print('Failed to vacate bed: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Failed to vacate bed. Please try again',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            backgroundColor: Colors.transparent,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 0,
          ),
        );
      }
    } catch (e) {
      print('Error in _vacateBed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('An error occurred. Please try again.',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ))),
      );
    }
  }

  Future<DateTime?> _selectEndDate(
      BuildContext context, String currentEndDate) async {
    DateTime initialDate = DateTime.now();
    DateTime lastDate = DateTime.now().add(const Duration(days: 365));
    if (initialDate.isAfter(lastDate)) {
      initialDate = lastDate;
    }
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogBackgroundColor: myOnSecondaryColor,
            colorScheme: ColorScheme.light(
              primary: myPrimaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                textStyle: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                foregroundColor: Colors.black,
              ),
            ),
          ),
          child: child ?? const SizedBox(),
        );
      },
    );
    return pickedDate;
  }

  void _initializeBedStatus() {
    DateTime startDate = DateTime.now().subtract(const Duration(days: 365));
    DateTime endDate = DateTime.now().add(const Duration(days: 365));
    for (DateTime date = startDate;
        date.isBefore(endDate);
        date = date.add(const Duration(days: 1))) {
      if (!bedStatusByDate.containsKey(date)) {
        bedStatusByDate[date] = List.filled(18, BedState.vacant);
        for (int j = 0; j < 5; j++) {
          int bookedIndex = Random().nextInt(18);
          bedStatusByDate[date]![bookedIndex] = BedState.booked;
          bedDetailsByIndex[bookedIndex] = BedDetails(
            roomNumber: 'Room ${bookedIndex + 100}',
            employeeName: 'Employee ${bookedIndex + 1}',
            department: 'Dept ${bookedIndex % 5}',
            startDate: DateFormat('yyyy-MM-dd')
                .format(date.subtract(const Duration(days: 5))),
            endDate: DateFormat('yyyy-MM-dd')
                .format(date.add(const Duration(days: 5))),
          );
        }
      }
    }
  }
// calling the extend function
  Future<void> _extendLogoutDate(
      int bedNumber, int bookingId, DateTime newEndDate) async {
    String url = 'https://beds-accomodation.vercel.app/api/viewExtendBooking';
// calling the body function
    Map<String, dynamic> body = {
      'bedId': bedNumber,
      'bookingId': bookingId,
      'loggedOutDate': DateFormat('yyyy-MM-dd').format(newEndDate),
    };
// applying try and catch function
    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );
// printing the status code
      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        if (responseData['success'] == 1) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Logout date extended successfully!',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              backgroundColor: Colors.transparent,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 0,
            ),
          );
          // Optionally update the UI state here
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Failed to extend the logout date.',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              backgroundColor: Colors.transparent,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 0,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                // 'Error: ${response.statusCode}',
                'The date cannot be extended because the bed is booked on that date',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            backgroundColor: Colors.transparent,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 0,
          ),
        );
      }
    } catch (e) {
      print('Error in _extendLogoutDate: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'An error occurred. Please try again.',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          backgroundColor: Colors.transparent,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 0,
        ),
      );
    }
  }

  Future<HomeModel> fetchItems() async {
    Map<int, BedState> bedStatusMap = {};
    String filterType = selectedFilter;
    Map<String, String> body = {
      'date': DateFormat('yyyy-MM-dd').format(selectedDate),
      'filterType': filterType,
    };

    http.Response response = await http.post(
      Uri.parse('https://beds-accomodation.vercel.app/api/checkBeds'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    print(response);
    if (response.statusCode == 200) {
      HomeModel homeModel = HomeModel.fromJson(jsonDecode(response.body));
      bedStatusMap.clear();
      bedDetailsByIndex.clear();
      bedDetailsByIndex.clear();

      // Loop through each room in the `homeModel.data!`
      for (var room in homeModel.data!) {
        // Now, loop through each bed in the room
        for (var bed in room.beds!) {
          if (bed.bedStatus != null) {
            bedStatusMap[bed.bedNumber!] =
                bed.bedStatus! ? BedState.booked : BedState.vacant;
            // If the bed is booked, store its details
            if (bed.bedStatus == true) {
              bedDetailsByIndex[bed.bedNumber!] = BedDetails(
                roomNumber: 'Room ${room.roomNumber!}',
                employeeName: bed.employee ?? '',
                department: '',
                startDate: bed.loggedInDate ?? '',
                endDate: bed.loggedOutDate ?? '',
              );
            }
          }
        }
      }
      return homeModel;
    } else {
      throw Exception('Failed to load home model');
    }
  }
}
