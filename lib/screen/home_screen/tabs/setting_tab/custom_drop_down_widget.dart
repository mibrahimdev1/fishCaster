import 'package:fish_caster/core/size_cons.dart';
import 'package:fish_caster/import_file.dart';
import 'package:flutter/material.dart';

class CustomDropDownWidget extends StatefulWidget {
  final Widget leadingIcon;
  final String title;
  final Map<String, String> items;
  final String? selectedValue; // Add a property for the selected value
  final ValueChanged<String?> onChanged; // Callback for value changes

  const CustomDropDownWidget({
    Key? key,
    required this.leadingIcon,
    required this.title,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
  }) : super(key: key);

  @override
  _CustomDropDownWidgetState createState() => _CustomDropDownWidgetState();
}

class _CustomDropDownWidgetState extends State<CustomDropDownWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      // decoration: BoxDecoration(
      //   border: Border.all(
      //     color: ColorConstants.textfieldborder,
      //     width: 1,
      //   ),
      // ),
      width: SizeCons.getWidth(context) * 0.4,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: widget.selectedValue, // Use the selected value property
          dropdownColor: Colors.white,
          isExpanded: true,
          // hint: Row(
          //   children: [
          //     widget.leadingIcon,
          //     const SizedBox(width: 8),
          //     Text(
          //       widget.title,
          //       style: TextStyle(
          //         fontSize: 12,
          //         color: ColorConstants.getPrimaryText(context),
          //       ),
          //     ),
          //   ],
          // ),
          items:
              widget.items.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.value,
                  child: Text(entry.key),
                  // TranslateText(
                  //   text: entry.key,
                  // ),
                );
              }).toList(),
          onChanged: widget.onChanged, // Use the callback for changes
          // Remove the dropdown icon here to avoid duplicating it
          selectedItemBuilder: (BuildContext context) {
            return widget.items.keys.map<Widget>((String key) {
              return Container(
                margin: const EdgeInsets.only(left: 17),
                width: SizeCons.getWidth(context) * 0.8,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Removed the dropdown icon here
                    Text(
                      key,
                      style: TextStyle(fontSize: 10, color: ClrCons.blueColor),
                    ),
                  ],
                ),
              );
            }).toList();
          },
        ),
      ),
    );
  }
}
