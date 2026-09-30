import 'package:fish_caster/import_file.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for DateFormat

// class CustomDateField extends StatefulWidget {
//   final TextEditingController controller;
//   final String hintText;
//   final Function(DateTime)? onDateSelected;
//   final TextStyle? hintStyle;
//   final Color borderColor;
//   final EdgeInsetsGeometry? contentPadding;
//   final bool enabled;
//   final String? initialDate;
//   final bool? dob;

//   const CustomDateField({
//     Key? key,
//     required this.controller,
//     required this.hintText,
//     this.onDateSelected,
//     this.hintStyle,
//     this.borderColor = Colors.white,
//     this.contentPadding,
//     this.enabled = true,
//     this.initialDate, this.dob,
//   }) : super(key: key);

//   @override
//   _CustomDateFieldState createState() => _CustomDateFieldState();
// }

// class _CustomDateFieldState extends State<CustomDateField> {
//   DateTime? _selectedDate;

//   @override
//   void initState() {
//     super.initState();
//     // Parse the initial date if provided
//     if (widget.initialDate != null) {
//       _selectedDate = DateFormat('yyyy-dd-MM').parse(widget.initialDate!);
//       widget.controller.text = DateFormat('yyyy-dd-MM').format(_selectedDate!);
//     }
//   }

//   // Show date picker when user taps on the text field
//   // Future<void> _selectDate(BuildContext context) async {
//   //   DateTime initialDate = _selectedDate ?? DateTime.now();

//   //   final DateTime? pickedDate = await showDatePicker(
//   //     context: context,
//   //     initialDate: initialDate,
//   //     firstDate: DateTime(1900),
//   //     lastDate: DateTime(2100),
//   //     builder: (BuildContext context, Widget? child) {
//   //       return Theme(
//   //         data: ThemeData.light().copyWith(
//   //           primaryColor: Colors.blue,
//   //           colorScheme: ColorScheme.light(primary: Colors.blue),
//   //           buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
//   //         ),
//   //         child: child!,
//   //       );
//   //     },
//   //   );

//   //   if (pickedDate != null && pickedDate != _selectedDate) {
//   //     setState(() {
//   //       _selectedDate = pickedDate;
//   //       widget.controller.text = DateFormat('yyyy-dd-MM').format(pickedDate);
//   //     });

//   //     // Call the callback if provided
//   //     if (widget.onDateSelected != null) {
//   //       widget.onDateSelected!(pickedDate);
//   //     }
//   //   }
//   // }

//   // Show date picker when user taps on the text field
//   Future<void> _selectDate(BuildContext context) async {
//     DateTime initialDate = _selectedDate ?? DateTime.now();

//     final DateTime? pickedDate = await showDatePicker(
//       context: context,
//       initialDate: initialDate,
//       firstDate: DateTime(1900),
//       lastDate: widget.dob == true
//           ? DateTime.now()
//           : DateTime(2100), // Restrict future dates for DOB
//       builder: (BuildContext context, Widget? child) {
//         return Theme(
//           data: ThemeData.light().copyWith(
//             primaryColor: Colors.blue,
//             colorScheme: ColorScheme.light(primary: Colors.blue),
//             buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
//           ),
//           child: child!,
//         );
//       },
//     );

//     if (pickedDate != null && pickedDate != _selectedDate) {
//       setState(() {
//         _selectedDate = pickedDate;
//         widget.controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
//       });

//       // Call the callback if provided
//       if (widget.onDateSelected != null) {
//         widget.onDateSelected!(pickedDate);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return TextFormField(
//       controller: widget.controller,
//       readOnly: true, // Make it read-only to trigger date picker
//       enabled: widget.enabled,
//       style: TextStyle(color: Colors.white, fontSize: 14),
//       onTap: () {
//         if (widget.enabled) {
//           _selectDate(context);
//         }
//       },
//       decoration: InputDecoration(
//         hintText: widget.hintText,
//         suffixIcon: Icon(Icons.calendar_today, color: Colors.white),
//         hintStyle:
//             widget.hintStyle ?? TextStyle(color: Colors.grey, fontSize: 12),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(20),
//           borderSide: BorderSide(color: widget.borderColor),
//         ),
//         contentPadding: widget.contentPadding ??
//             EdgeInsets.symmetric(vertical: 14, horizontal: 16),
//         filled: true,
//         fillColor: Colors.black,
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(20),
//           borderSide: BorderSide(color: widget.borderColor),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(20),
//           borderSide: BorderSide(color: widget.borderColor),
//         ),
//       ),
//     );
//   }
// }

class CustomDateField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final Function(DateTime)? onDateSelected;

  const CustomDateField({
    Key? key,
    required this.controller,
    required this.hintText,
    this.onDateSelected,
  }) : super(key: key);

  @override
  State<CustomDateField> createState() => _CustomDateFieldState();
}

class _CustomDateFieldState extends State<CustomDateField> {
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogBackgroundColor: ClrCons.whiteColor,
            colorScheme: ColorScheme.dark(
              primary: ClrCons.primaryColor,
              onPrimary: Colors.white,
              surface: ClrCons.surfaceClr,
              onSurface: Colors.white,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: ClrCons.whiteColor),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formatted = "${picked.day}/${picked.month}/${picked.year}";
      widget.controller.text = formatted;
      widget.onDateSelected?.call(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _selectDate,
      child: AbsorbPointer(
        child: CustomTextField(
          controller: widget.controller,
          hintText: widget.hintText,
          readOnly: true,
          ontap: _selectDate,
          suffixIcon: ImgCons.calenderIcon, // Add your calendar icon path
        ),
      ),
    );
  }
}
