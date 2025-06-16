// import 'package:flutter/material.dart';

// /// Data model for each bottom nav item
// class BottomNavItem {
//   final IconData icon;
//   final String label;
//   const BottomNavItem({required this.icon, required this.label});
// }

// /// A single icon widget in the custom nav bar
// // class _NavBarIcon extends StatelessWidget {
// //   final BottomNavItem item;
// //   final bool active;

// //   const _NavBarIcon({Key? key, required this.item, required this.active})
// //       : super(key: key);

// //   @override
// //   Widget build(BuildContext context) {
// //     if (active) {
// //       // Active item is drawn in a bubble with an offset
// //       return Container(
// //         width: 60,
// //         height: 60,
// //         margin: const EdgeInsets.only(bottom: 10), // raise it a bit
// //         decoration: BoxDecoration(
// //           color: Color.fromARGB(255, 70, 183, 211),
// //           shape: BoxShape.circle,
// //         ),
// //         child: Icon(
// //           item.icon,
// //           color: Color.fromARGB(255, 255, 255, 255),
// //         ),
// //       );
// //     } else {
// //       // Inactive item is just a simple icon
// //       return SizedBox(
// //         width: 50,
// //         height: 50,
// //         child: Icon(
// //           item.icon,
// //           color: Colors.grey,
// //         ),
// //       );
// //     }
// //   }
// // }

// class _NavBarIcon extends StatelessWidget {
//   final BottomNavItem item;
//   final bool active;

//   const _NavBarIcon({Key? key, required this.item, required this.active})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Icon(
//       item.icon,
//       color: active ? Colors.white : Colors.grey,
//       size: 28,
//     );
//   }
// }

// /// Painter for the wavy background shape
// class _NavBarPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()..color = Color.fromARGB(255, 255, 255, 255);

//     final path = Path();
//     path.moveTo(0, 0); // Start at top-left
//     path.lineTo(size.width, 0); // Top-right
//     path.lineTo(size.width, size.height); // Bottom-right
//     path.lineTo(0, size.height); // Bottom-left
//     path.close(); // Close the rectangle

//     canvas.drawShadow(path, Colors.black26, 5, true);
//     canvas.drawPath(path, paint);
//   }

//   @override
//   bool shouldRepaint(_NavBarPainter oldDelegate) => false;
// }

// /// Custom Bottom Nav Bar with wave and bubble highlight
// // class CustomBottomNavBar extends StatelessWidget {
// //   final int currentIndex;
// //   final ValueChanged<int> onItemSelected;
// //   final List<BottomNavItem> items;

// //   const CustomBottomNavBar({
// //     Key? key,
// //     required this.currentIndex,
// //     required this.onItemSelected,
// //     required this.items,
// //   }) : super(key: key);

// //   @override
// //   Widget build(BuildContext context) {
// //     return SizedBox(
// //       height: 70,
// //       child: Stack(
// //         children: [
// //           // 1) The wavy background
// //           Positioned.fill(
// //             child: CustomPaint(
// //               painter: _NavBarPainter(),
// //             ),
// //           ),
// //           // 2) The row of icons
// //           Row(
// //             mainAxisAlignment: MainAxisAlignment.spaceAround,
// //             children: List.generate(items.length, (index) {
// //               final item = items[index];
// //               final isActive = (index == currentIndex);
// //               return GestureDetector(
// //                 onTap: () => onItemSelected(index),
// //                 child: _NavBarIcon(
// //                   item: item,
// //                   active: isActive,
// //                 ),
// //               );
// //             }),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// class CustomBottomNavBar extends StatelessWidget {
//   final int currentIndex;
//   final ValueChanged<int> onItemSelected;
//   final List<BottomNavItem> items;

//   const CustomBottomNavBar({
//     Key? key,
//     required this.currentIndex,
//     required this.onItemSelected,
//     required this.items,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     double iconSpacing = MediaQuery.of(context).size.width / items.length;

//     return SizedBox(
//       height: 70,
//       child: Stack(
//         alignment: Alignment.bottomCenter,
//         children: [
//           // 1) Background
//           Positioned.fill(
//             child: CustomPaint(
//               painter: _NavBarPainter(),
//             ),
//           ),

//           // 2) Bubble animation
//           AnimatedAlign(
//             duration: const Duration(milliseconds: 400),
//             curve: Curves.easeOutQuint,
//             alignment: Alignment(
//                 -0.89 + (1.78 * currentIndex / (items.length - 1)), 0.3),
//             child: Container(
//               width: 60,
//               height: 60,
//               decoration: const BoxDecoration(
//                 color: Color.fromARGB(255, 70, 183, 211),
//                 shape: BoxShape.circle,
//               ),
//             ),
//           ),

//           // 3) Icons above bubble
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: List.generate(items.length, (index) {
//               final item = items[index];
//               return GestureDetector(
//                 onTap: () => onItemSelected(index),
//                 child: SizedBox(
//                   width: iconSpacing,
//                   height: 70,
//                   child: Center(
//                     child: _NavBarIcon(
//                       item: item,
//                       active: index == currentIndex,
//                     ),
//                   ),
//                 ),
//               );
//             }),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class BottomNavItem {
  final IconData icon;
  final String label;
  const BottomNavItem({required this.icon, required this.label});
}

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onItemSelected;
  final List<BottomNavItem> items;

  const CustomBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onItemSelected,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onItemSelected,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.blueAccent,
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.white,
      items: items
          .map((item) => BottomNavigationBarItem(
                icon: Icon(item.icon),
                label: item.label,
              ))
          .toList(),
    );
  }
}
