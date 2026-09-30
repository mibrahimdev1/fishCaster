import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class ExpandableText extends StatefulWidget {
  final String text;

  ExpandableText({required this.text});

  @override
  _ExpandableTextState createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _isExpanded = false;
  bool _isOverflow = false;

  @override
  void initState() {
    super.initState();
    _checkOverflow();
  }

  void _checkOverflow() {
    final textPainter = TextPainter(
      text: TextSpan(
        text: widget.text,
        style: const TextStyle(fontSize: 10, color: Colors.white),
      ),
      maxLines: 3,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 250); // Adjust max width if needed

    setState(() {
      _isOverflow = textPainter.didExceedMaxLines;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_isOverflow) {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 13, color: Colors.white),
              children: [
                TextSpan(
                  text:
                      _isExpanded || !_isOverflow
                          ? widget.text
                          : '${widget.text.substring(0, widget.text.length.clamp(0, 250))}...',
                ),
                if (_isOverflow) // Only show "See more" if text overflows 3 lines
                  TextSpan(
                    text: _isExpanded ? ' See less' : ' See more',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange, // Change to match your design
                      fontSize: 10,
                    ),
                    recognizer:
                        TapGestureRecognizer()
                          ..onTap = () {
                            setState(() {
                              _isExpanded = !_isExpanded;
                            });
                          },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// import 'package:fish_caster/import_file.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';

// class ExpandableText extends StatefulWidget {
//   final String text;

//   ExpandableText({required this.text});

//   @override
//   _ExpandableTextState createState() => _ExpandableTextState();
// }

// class _ExpandableTextState extends State<ExpandableText> {
//   bool _isExpanded = false;
//   bool _isOverflow = false;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _checkOverflow();
//     });
//   }

//   void _checkOverflow() {
//     final textPainter = TextPainter(
//       text: TextSpan(
//         text: widget.text,
//         style: const TextStyle(fontSize: 10, color: Colors.white),
//       ),
//       maxLines: 3,
//     )..layout(maxWidth: 250); // Adjust max width if needed

//     setState(() {
//       _isOverflow = textPainter.didExceedMaxLines;
//     });
//   }

//   List<TextSpan> _highlightText(String text) {
//     final RegExp exp = RegExp(r"(\#\w+|\@\w+)");
//     final List<TextSpan> spans = [];
//     int start = 0;

//     for (final match in exp.allMatches(text)) {
//       if (match.start > start) {
//         spans.add(TextSpan(text: text.substring(start, match.start)));
//       }
//       spans.add(
//         TextSpan(
//           text: match.group(0),
//           style: const TextStyle(
//               color: ClrCons.primaryColor, fontWeight: FontWeight.bold),
//           recognizer: TapGestureRecognizer()
//             ..onTap = () {
//               print("Tapped: ${match.group(0)}");
//             },
//         ),
//       );
//       start = match.end;
//     }

//     if (start < text.length) {
//       spans.add(TextSpan(text: text.substring(start)));
//     }

//     return spans;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final displayedText = _isExpanded || !_isOverflow
//         ? widget.text
//         : '${widget.text.substring(0, widget.text.length.clamp(0, 250))}...';

//     return GestureDetector(
//       onTap: () {
//         if (_isOverflow) {
//           setState(() {
//             _isExpanded = !_isExpanded;
//           });
//         }
//       },
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           RichText(
//             text: TextSpan(
//               style: const TextStyle(fontSize: 13, color: Colors.white),
//               children: [
//                 ..._highlightText(displayedText),
//                 if (_isOverflow)
//                   TextSpan(
//                     text: _isExpanded ? ' See less' : ' See more',
//                     style: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: Colors.orange,
//                       fontSize: 10,
//                     ),
//                     recognizer: TapGestureRecognizer()
//                       ..onTap = () {
//                         setState(() {
//                           _isExpanded = !_isExpanded;
//                         });
//                       },
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
