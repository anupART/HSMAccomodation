// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
//
// import 'new_home.dart';
//
// class BedDialog {
//   final BuildContext context;
//   final int index;
//   final BedState bedState;
//   final DateTime selectedDate;
//   final Map<int, BedDetails> bedDetailsByIndex;
//   final Map<DateTime, List<BedState>> bedStatusByDate;
//
//   BedDialog({
//     required this.context,
//     required this.index,
//     required this.bedState,
//     required this.selectedDate,
//     required this.bedDetailsByIndex,
//     required this.bedStatusByDate,
//   });
//
//   void show() {
//     if (selectedDate.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
//       _showPastDateDialog();
//     } else {
//       _showBedDialog();
//     }
//   }
//
//   void _showPastDateDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           backgroundColor: Colors.white,
//           title: Text(
//             'Bed ${index}',
//             style: GoogleFonts.poppins(
//               fontSize: 19,
//               fontWeight: FontWeight.bold,
//               color: Colors.black,
//             ),
//           ),
//           content: Text(
//             'This date is in the past and cannot be edited.',
//             style: GoogleFonts.poppins(
//               fontSize: 16,
//               color: Colors.black,
//             ),
//           ),
//           actions: [
//             TextButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.black12,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text(
//                 'OK',
//                 style: GoogleFonts.poppins(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black,
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _showBedDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           backgroundColor: Colors.white,
//           title: Text(
//             'Bed ${index}',
//             style: GoogleFonts.poppins(
//               fontSize: 19,
//               fontWeight: FontWeight.bold,
//               color: Colors.black,
//             ),
//           ),
//           content: bedState == BedState.booked
//               ? Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Current Booking Details:',
//                 style: GoogleFonts.poppins(
//                   fontSize: 17,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black,
//                 ),
//               ),
//               const SizedBox(height: 10),
//               if (bedDetailsByIndex.containsKey(index)) ...[
//                 _detailItem('Room Number', bedDetailsByIndex[index]!.roomNumber),
//                 _detailItem('Employee Name', bedDetailsByIndex[index]!.employeeName),
//                 _detailItem('Department', bedDetailsByIndex[index]!.department),
//                 _detailItem('Start Date', bedDetailsByIndex[index]!.startDate),
//                 _detailItem('End Date', bedDetailsByIndex[index]!.endDate),
//               ],
//               const SizedBox(height: 10),
//               Text(
//                 'Do you want to extend or vacate this bed?',
//                 style: GoogleFonts.poppins(
//                   fontSize: 16,
//                   color: Colors.black,
//                 ),
//               ),
//             ],
//           )
//               : Text(
//             'Do you want to book this bed?',
//             style: GoogleFonts.poppins(
//               fontSize: 16,
//               color: Colors.black,
//             ),
//           ),
//           actions: [
//             if (bedState == BedState.booked) ...[
//               TextButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.orange.shade100,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 onPressed: () async {
//                   if (bedDetailsByIndex.containsKey(index)) {
//                     DateTime? newEndDate = await _selectEndDate(
//                         context, bedDetailsByIndex[index]!.endDate);
//                     if (newEndDate != null) {
//                       _showConfirmationDialog(
//                           context, index, bedDetailsByIndex[index]!, newEndDate);
//                     }
//                   } else {
//                     // Handle the case where bedDetailsByIndex does not contain the index
//                   }
//                 },
//                 child: Text(
//                   'Extend',
//                   style: GoogleFonts.poppins(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: myPrimaryColor,
//                   ),
//                 ),
//               ),
//               TextButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.green.shade100,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                   _showVacateConfirmationDialog(context, index);
//
//                 },
//                 child: Text(
//                   'Vacant',
//                   style: GoogleFonts.poppins(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: bookedColor,
//                   ),
//                 ),
//               ),
//             ],
//             if (bedState == BedState.vacant)
//               TextButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.orange.shade100,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 onPressed: () async {
//                   Navigator.of(context).pop();
//                   dynamic result = await Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => BookingPage(
//                         bedNumber: index,
//                         startDate: selectedDate,
//                       ),
//                     ),
//                   );
//                   if (result != null) {
//                     setState(() {
//                       bedStatusByDate[selectedDate]![index] = BedState.booked;
//                       bedDetailsByIndex[index] = BedDetails(
//                         roomNumber: result['roomNumber'] ?? '',
//                         employeeName: result['employeeName'] ?? '',
//                         department: result['department'] ?? '',
//                         startDate: DateFormat('yyyy-MM-dd')
//                             .format(result['startDate'] ?? DateTime.now()),
//                         endDate: DateFormat('yyyy-MM-dd')
//                             .format(result['endDate'] ?? DateTime.now()),
//                       );
//                     });
//                   }
//                 },
//                 child: Text(
//                   'Book',
//                   style: GoogleFonts.poppins(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: myPrimaryColor,
//                   ),
//                 ),
//               ),
//             TextButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.black12,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text(
//                 'Cancel',
//                 style: GoogleFonts.poppins(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black,
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   Future<DateTime?> _selectEndDate(BuildContext context, String currentEndDate) async {
//     DateTime initialDate = DateTime.now();
//     DateTime lastDate = DateTime.now().add(const Duration(days: 365));
//     if (initialDate.isAfter(lastDate)) {
//       initialDate = lastDate;
//     }
//     DateTime? pickedDate = await showDatePicker(
//       context: context,
//       initialDate: initialDate,
//       firstDate: DateTime.now(),
//       lastDate: lastDate,
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             dialogBackgroundColor: myOnSecondaryColor,
//             colorScheme: ColorScheme.light(
//               primary: myPrimaryColor,
//               onPrimary: Colors.white,
//               onSurface: Colors.black,
//             ),
//             textButtonTheme: TextButtonThemeData(
//               style: TextButton.styleFrom(
//                 textStyle: GoogleFonts.poppins(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//                 foregroundColor: Colors.black,
//               ),
//             ),
//           ),
//           child: child ?? const SizedBox(),
//         );
//       },
//     );
//     return pickedDate;
//   }
//
//   void _showConfirmationDialog(
//       BuildContext context, int index, BedDetails bedDetails, DateTime newEndDate) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           backgroundColor: Colors.white,
//           title: Text(
//             'Confirm Extension',
//             style: GoogleFonts.poppins(
//               fontSize: 20,
//               color: Colors.black,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           content: Text(
//             'Do you want to extend the end date to ${DateFormat('yyyy-MM-dd').format(newEndDate)}?',
//             style: GoogleFonts.poppins(
//               fontSize: 16,
//               color: Colors.black,
//             ),
//           ),
//           actions: [
//             TextButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.black12,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               onPressed: () async {
//                 ExtendDateModel? extendDateModel = await _extendBed(index, newEndDate);
//                 if (extendDateModel != null) {
//                   Navigator.of(context).pop();
//                   Navigator.of(context).pop();
//                   _showBedDialog();
//                 } else {
//                   // Show error message
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('Failed to extend bed. Please try again.')),
//                   );
//                 }
//               },
//               child: Text(
//                 'Yes',
//                 style: GoogleFonts.poppins(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: bookedColor,
//                 ),
//               ),
//             ),
//             TextButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.black12,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text(
//                 'No',
//                 style: GoogleFonts.poppins(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.red,
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   Future<ExtendDateModel?> _extendBed(int index, DateTime newEndDate) async {
//     String url = 'https://beds-accomodation.vercel.app/api/viewUpdateBooking';
//     Map<String, dynamic> body = {
//       'bedId': index,
//       'logoutDate': DateFormat('yyyy-MM-dd').format(newEndDate),
//     };
//     http.Response response = await http.post(
//       Uri.parse(url),
//       headers: {
//         'Content-Type': 'application/json',
//       },
//       body: jsonEncode(body),
//     );
//     if (response.statusCode == 200) {
//       ExtendDateModel extendDateModel = ExtendDateModel.fromJson(jsonDecode(response.body));
//       if (extendDateModel.success == 1) {
//         setState(() {
//           bedDetailsByIndex[index] = BedDetails(
//             roomNumber: bedDetailsByIndex[index]!.roomNumber,
//             employeeName: bedDetailsByIndex[index]!.employeeName,
//             department: bedDetailsByIndex[index]!.department,
//             startDate: bedDetailsByIndex[index]!.startDate,
//             endDate: extendDateModel.data1!.loggedOutDate!,
//           );
//           bedStatusByDate[selectedDate]![index] = BedState.booked;
//         });
//         await fetchItems();
//         print('Bed extended successfully');
//         return extendDateModel;
//       }
//     }
//     print('Failed to extend bed');
//     return null;
//   }
//
//   void _showVacateConfirmationDialog(BuildContext context, int index) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           backgroundColor: Colors.white,
//           title: Text(
//             'Confirm Vacant',
//             style: GoogleFonts.poppins(
//               fontSize: 20,
//               color: Colors.black,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           content: Text(
//             'Are you sure you want to vacate this bed?',
//             style: GoogleFonts.poppins(
//               fontSize: 16,
//               color: Colors.black,
//             ),
//           ),
//           actions: [
//             TextButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.black12,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               onPressed: () async {
//                 VacantBedModel? vacantBedModel = await _vacateBed(index);
//                 if (vacantBedModel != null && vacantBedModel.success == 1) {
//                   setState(() {
//                     bedStatusByDate[selectedDate]![index] = BedState.vacant;
//                     bedDetailsByIndex.remove(index);
//                     fetchItems();
//                   });
//                   Navigator.of(context).pop();
//                 } else {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('Failed to vacate bed. Please try again.')),
//                   );
//                 }
//               },
//               child: Text(
//                 'Yes',
//                 style: GoogleFonts.poppins(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: bookedColor,
//                 ),
//               ),
//             ),
//             TextButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.black12,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text(
//                 'No',
//                 style: GoogleFonts.poppins(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.red,
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   Future<VacantBedModel?> _vacateBed(int index) async {
//     String url = 'https://beds-accomodation.vercel.app/api/bookToVacantBed';
//     Map<String, dynamic> body = {
//       'bedId': index,
//     };
//     http.Response response = await http.post(
//       Uri.parse(url),
//       headers: {
//         'Content-Type': 'application/json',
//       },
//       body: jsonEncode(body),
//     );
//     if (response.statusCode == 200) {
//       VacantBedModel vacantBedModel = VacantBedModel.fromJson(jsonDecode(response.body));
//       print('Response: ${response.body}');
//       return vacantBedModel;
//     } else {
//       print('Failed to vacate bed: ${response.statusCode}');
//       return null;
//     }
//   }
// }
// Widget _detailItem(String label, String value) {
//   return Padding(
//     padding: const EdgeInsets.symmetric(vertical: 8.0),
//     child: Row(
//       children: [
//         Text(
//           '$label: ',
//           style: GoogleFonts.poppins(
//             fontSize: 15,
//             fontWeight: FontWeight.bold,
//             color: Colors.black,
//           ),
//         ),
//         Expanded(
//           child: Text(
//             value,
//             style: GoogleFonts.poppins(
//               fontSize: 15,
//               color: Colors.grey.shade600,
//             ),
//             overflow: TextOverflow.ellipsis,
//           ),
//         ),
//       ],
//     ),
//   );
// }