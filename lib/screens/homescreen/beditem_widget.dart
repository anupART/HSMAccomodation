//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
//
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
// class BedItemWidget extends StatelessWidget {
//   final int bedNumber;
//   final BedState bedState;
//
//   const BedItemWidget({
//     Key? key,
//     required this.bedNumber,
//     required this.bedState,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () => _showBedDialog(bedNumber, bedState),
//       child: Container(
//         decoration: BoxDecoration(
//           color: _getBedColor(bedState),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Center(
//           child: Text(
//             'Bed $bedNumber',
//             style: GoogleFonts.poppins(
//               fontSize: 14,
//               color: Colors.black,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }