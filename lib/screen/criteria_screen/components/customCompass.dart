import 'dart:math' as math;

import 'package:fish_caster/core/image_cons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:permission_handler/permission_handler.dart';

class CustomCompass extends StatefulWidget {
  const CustomCompass({Key? key}) : super(key: key);

  @override
  _CustomCompassState createState() => _CustomCompassState();
}

// class _CustomCompassState extends State<CustomCompass> {
//   bool _hasPermissions = false;
//   CompassEvent? _lastRead;
//   DateTime? _lastReadAt;

//   @override
//   void initState() {
//     super.initState();

//     _fetchPermissionStatus();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         backgroundColor: Colors.white,
//         appBar: AppBar(
//           title: const Text('Flutter Compass'),
//         ),
//         body: Builder(builder: (context) {
//           if (_hasPermissions) {
//             return Column(
//               children: <Widget>[
//                 _buildManualReader(),
//                 Expanded(child: _buildCompass()),
//               ],
//             );
//           } else {
//             return _buildPermissionSheet();
//           }
//         }),
//       ),
//     );
//   }

//   Widget _buildManualReader() {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Row(
//         children: <Widget>[
//           ElevatedButton(
//             child: Text('Read Value'),
//             onPressed: () async {
//               final CompassEvent tmp = await FlutterCompass.events!.first;
//               setState(() {
//                 _lastRead = tmp;
//                 _lastReadAt = DateTime.now();
//               });
//             },
//           ),
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: <Widget>[
//                   Text(
//                     '$_lastRead',
//                     style: Theme.of(context).textTheme.bodySmall,
//                   ),
//                   Text(
//                     '$_lastReadAt',
//                     style: Theme.of(context).textTheme.bodySmall,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCompass() {
//     return StreamBuilder<CompassEvent>(
//       stream: FlutterCompass.events,
//       builder: (context, snapshot) {
//         if (snapshot.hasError) {
//           return Text('Error reading heading: ${snapshot.error}');
//         }

//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Center(
//             child: CircularProgressIndicator(),
//           );
//         }

//         double? direction = snapshot.data!.heading;

//         // if direction is null, then device does not support this sensor
//         // show error message
//         if (direction == null)
//           return Center(
//             child: Text("Device does not have sensors !"),
//           );

//         return Material(
//           shape: CircleBorder(),
//           clipBehavior: Clip.antiAlias,
//           elevation: 4.0,
//           child: Container(
//             padding: EdgeInsets.all(16.0),
//             alignment: Alignment.center,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//             ),
//             child: Transform.rotate(
//               angle: (direction * (math.pi / 180) * -1),
//               child: Image.asset(ImgCons.compassImg),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildPermissionSheet() {
//     return Center(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: <Widget>[
//           Text('Location Permission Required'),
//           ElevatedButton(
//             child: Text('Request Permissions'),
//             onPressed: () {
//               Permission.locationWhenInUse.request().then((ignored) {
//                 _fetchPermissionStatus();
//               });
//             },
//           ),
//           SizedBox(height: 16),
//           ElevatedButton(
//             child: Text('Open App Settings'),
//             onPressed: () {
//               openAppSettings().then((opened) {
//                 //
//               });
//             },
//           )
//         ],
//       ),
//     );
//   }

//   void _fetchPermissionStatus() {

class _CustomCompassState extends State<CustomCompass> {
  bool _hasPermissions = false;
  double? _selectedAngle;

  @override
  void initState() {
    super.initState();
    _fetchPermissionStatus();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Custom Compass')),
        body: _hasPermissions ? _buildCustomCompass() : _buildPermissionSheet(),
      ),
    );
  }

  Widget _buildCustomCompass() {
    return Center(
      child: GestureDetector(
        onTapDown: (TapDownDetails details) {
          RenderBox box = context.findRenderObject() as RenderBox;
          Offset local = box.globalToLocal(details.globalPosition);
          Size size = box.size;
          Offset center = Offset(size.width / 2, size.height / 2);

          final dx = local.dx - center.dx;
          final dy = local.dy - center.dy;
          double angle = (math.atan2(dy, dx) * 180 / math.pi + 360 + 90) % 360;

          print("Selected: ${angle.toStringAsFixed(2)}°");
          setState(() {
            _selectedAngle = angle;
          });
        },
        child: CustomPaint(
          painter: CompassPainter(angle: _selectedAngle),
          size: Size(300, 300),
        ),
      ),
    );
  }

  Widget _buildPermissionSheet() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Location Permission Required'),
          ElevatedButton(
            onPressed:
                () => Permission.locationWhenInUse.request().then(
                  (_) => _fetchPermissionStatus(),
                ),
            child: Text('Request Permissions'),
          ),
        ],
      ),
    );
  }

  void _fetchPermissionStatus() {
    Permission.locationWhenInUse.status.then((status) {
      if (mounted) {
        setState(() => _hasPermissions = status == PermissionStatus.granted);
      }
    });
  }
}

class CompassPainter extends CustomPainter {
  final double? angle;

  CompassPainter({this.angle});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;

    final paint =
        Paint()
          ..color = Colors.grey.shade300
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4;

    canvas.drawCircle(center, radius, paint);

    // Draw cardinal points
    final textStyle = TextStyle(color: Colors.black, fontSize: 16);
    final textPainter =
        (String text) => TextPainter(
          text: TextSpan(text: text, style: textStyle),
          textDirection: TextDirection.ltr,
        );

    const directions = ['N', 'E', 'S', 'W'];
    for (int i = 0; i < 4; i++) {
      final angleRad = (i * 90 - 90) * math.pi / 180;
      final offset = Offset(
        center.dx + radius * 0.8 * math.cos(angleRad),
        center.dy + radius * 0.8 * math.sin(angleRad),
      );
      final tp = textPainter(directions[i])..layout();
      tp.paint(canvas, offset - Offset(tp.width / 2, tp.height / 2));
    }

    // Draw selection arrow
    if (angle != null) {
      final angleRad = (angle! - 90) * math.pi / 180;
      final arrowEnd = Offset(
        center.dx + radius * 0.6 * math.cos(angleRad),
        center.dy + radius * 0.6 * math.sin(angleRad),
      );

      final arrowPaint =
          Paint()
            ..color = Colors.red
            ..strokeWidth = 4;

      canvas.drawLine(center, arrowEnd, arrowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CompassPainter oldDelegate) =>
      oldDelegate.angle != angle;
}

//     Permission.locationWhenInUse.status.then((status) {
//       if (mounted) {
//         setState(() => _hasPermissions = status == PermissionStatus.granted);
//       }
//     });
//   }
// }
