// import 'package:flutter/material.dart';

// class CustomButtonTextField extends StatelessWidget {
//   final Widget child;
//   final double? width;
//   final double? height;

//   const CustomButtonTextField({
//     Key? key,
//     required this.child,
//     this.width,
//     this.height,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: height ?? 55,
//       width: width ?? null,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(15),
//         gradient: const LinearGradient(
//           begin: Alignment.centerLeft,
//           end: Alignment.centerRight,
//           colors: [Color(0xFF111f4c), Color(0xff1a2c53)],
//         ),
//         boxShadow: const [
//           BoxShadow(color: Colors.black54, blurRadius: 6, offset: Offset(5, 5)),
//         ],
//       ),
//       child: CustomPaint(painter: _LeftBorderPainter(), child: child),
//     );
//   }
// }

import 'package:flutter/material.dart';

class CustomButtonTextField extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final bool isHeight;
  final Function()? ontap;

  const CustomButtonTextField({
    Key? key,
    required this.child,
    this.width,
    this.height,
    this.isHeight = false,
    this.ontap, // 👈 default false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontap,
      child: Container(
        height: isHeight ? null : (height ?? 55),
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFF111f4c), Color(0xff1a2c53)],
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 6,
              offset: Offset(5, 5),
            ),
          ],
        ),
        child: CustomPaint(painter: _LeftBorderPainter(), child: child),
      ),
    );
  }
}

class _LeftBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint =
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment(0.85, 0),
            colors: [Colors.white, Colors.transparent],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(15),
    );

    canvas.drawRRect(rrect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
