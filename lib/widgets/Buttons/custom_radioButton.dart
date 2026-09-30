import 'package:flutter/material.dart';
import 'package:fish_caster/import_file.dart';

class CustomRadioButon<T> extends StatefulWidget {
  final List<T> options;
  final T? selectedValue;
  final ValueChanged<T?>? onChanged;
  final String? title;
  final String? description;
  final Color activeColor;
  final bool row;

  const CustomRadioButon({
    Key? key,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
    this.title,
    this.row = false,
    this.description,
    this.activeColor = ClrCons.primaryColor,
  }) : super(key: key);

  @override
  _CustomRadioButonState<T> createState() => _CustomRadioButonState<T>();
}

class _CustomRadioButonState<T> extends State<CustomRadioButon<T>> {
  @override
  Widget build(BuildContext context) {
    return widget.row
        ? Row(
          children:
              widget.options.map((T option) {
                return Flexible(
                  child: RadioListTile<T>(
                    title: CustomText(
                      text: option.toString(),
                      color: ClrCons.whiteColor,
                      fontSize: 13,
                    ),
                    value: option,
                    groupValue: widget.selectedValue,
                    contentPadding: EdgeInsets.zero,
                    onChanged: widget.onChanged,
                    activeColor: widget.activeColor,
                  ),
                );
              }).toList(),
        )
        : Column(
          children:
              widget.options.map((T option) {
                return RadioListTile<T>(
                  title: CustomText(
                    text: option.toString(),
                    color: ClrCons.whiteColor,
                    fontSize: 13,
                  ),
                  value: option,
                  groupValue: widget.selectedValue,
                  contentPadding: EdgeInsets.zero,
                  onChanged: widget.onChanged,
                  activeColor: widget.activeColor,
                );
              }).toList(),
        );
  }
}
