// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:go_router/go_router.dart';
// import 'widgets/weather_widgets.dart';
//
// class WidgetShowcasePage extends StatelessWidget {
//   const WidgetShowcasePage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final designs = [
//       // Rainy
//       WeatherWidgetData(
//         id: 1, type: 'square', icon: getIcon('rain'), temperature: 14, high: 17, low: 12,
//         location: 'San Francisco', condition: 'Rainy',
//         gradient: [const Color(0xFF60A5FA), const Color(0xFF93C5FD), const Color(0xFFBFDBFE)],
//       ),
//       WeatherWidgetData(
//         id: 2, type: 'round', icon: getIcon('rain'), temperature: 14, high: 17, low: 12,
//         location: 'San Francisco', condition: 'Rainy',
//         gradient: [const Color(0xFF60A5FA), const Color(0xFF93C5FD), const Color(0xFFBFDBFE)],
//       ),
//       // Night Rainy
//       WeatherWidgetData(
//         id: 11, type: 'square', icon: getIcon('rain'), temperature: 12, high: 15, low: 10,
//         location: 'Portland', condition: 'Rainy Night', textColor: Colors.white,
//         gradient: [const Color(0xFF0F172A), const Color(0xFF1E1B4B), Colors.black],
//       ),
//     ];
//
//     return Scaffold(
//       backgroundColor: const Color(0xFF0F172A),
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => context.pop(),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
//         child: Center(
//           child: Column(
//             children: [
//               Text(\"Weather Widgets\",
//                   style: GoogleFonts.inter(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w900)),
//               const Text(\"Bold. Minimal. Beautiful.\",
//                   style: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.w500)),
//               const SizedBox(height: 60),
//               Wrap(
//                 spacing: 40,
//                 runSpacing: 40,
//                 children: designs.map((data) {
//                   return Column(
//                     children: [
//                       Text(\"${data.condition} • ${data.type}\".toUpperCase(),
//                           style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
//                       const SizedBox(height: 12),
//                       data.type == 'square' ? SquareWidget(data: data) : RoundWidget(data: data),
//                     ],
//                   );
//                 }).toList(),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

