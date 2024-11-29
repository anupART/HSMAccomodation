//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get/get_core/src/get_main.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../../style/color.dart';
// import 'new_home.dart';
//
// Color _getBedColor(BedState state) {
//   switch (state) {
//     case BedState.vacant:
//       return Colors.orange.shade300;
//     case BedState.booked:
//       return Colors.green.shade400;
//     default:
//       return Colors.white;
//   }
// }
//
// class BedGroupWidget extends StatelessWidget {
//   final List<int> bedNumbers;
//   final int roomNumber;
//   final Map<int, BedState> bedStatusMap;
//
//   const BedGroupWidget({
//     Key? key,
//     required this.bedNumbers,
//     required this.roomNumber,
//     required this.bedStatusMap,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.zero,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.5),
//             spreadRadius: 0,
//             blurRadius: 10,
//             blurStyle: BlurStyle.normal,
//             offset: const Offset(5, 5),
//           ),
//           const BoxShadow(
//             color: Colors.white,
//             spreadRadius: 0,
//             blurRadius: 10,
//             blurStyle: BlurStyle.normal,
//             offset: Offset(-5, -5),
//           ),
//         ],
//         borderRadius: BorderRadius.circular(10),
//       ),
//       height: Get.size.height / 5.3,
//       width: Get.size.width / 3,
//       margin: const EdgeInsets.all(8),
//       child: Column(
//         children: [
//           _buildRoomNumber(roomNumber),
//           const SizedBox(height: 8),
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: GridView.builder(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2,
//                   childAspectRatio: 2.7,
//                   crossAxisSpacing: 8,
//                   mainAxisSpacing: 8,
//                 ),
//                 itemCount: bedNumbers.length,
//                 itemBuilder: (context, index) {
//                   int bedNumber = bedNumbers[index];
//                   BedState bedState = bedStatusMap[bedNumber] ?? BedState.vacant;
//                   return GestureDetector(
//                     onTap: () => _showBedDialog(bedNumber, bedState),
//                     child: Container(
//                       decoration: BoxDecoration(
//                         color: _getBedColor(bedState),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Center(
//                         child: Text(
//                           'Bed $bedNumber',
//                           style: GoogleFonts.poppins(
//                             fontSize: 14,
//                             color: Colors.black,
//                           ),
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildRoomNumber(int roomNumber) {
//     return Row(
//       children: [
//         Padding(
//           padding: const EdgeInsets.only(top: 8, left: 8, right: 4),
//           child: Container(
//             padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
//             decoration: BoxDecoration(
//               color: myPrimaryColor,
//               borderRadius: BorderRadius.circular (5),
//             ),
//             child: Text(
//               'Room $roomNumber',
//               style: GoogleFonts.poppins(
//                 fontSize: 14,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }