import 'package:flutter/material.dart';
import 'package:fish_caster/import_file.dart';

class CustomGroupRadioButon<T> extends StatefulWidget {
  final List<T> options;
  final T? selectedValue;
  final ValueChanged<T?>? onChanged;
  final String? title;
  final String? description;
  final Color activeColor;
  final bool row;
  final String text;

  const CustomGroupRadioButon({
    Key? key,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
    this.title,
    this.row = false,
    this.description,
    this.activeColor = ClrCons.primaryColor,
    required this.text,
  }) : super(key: key);

  @override
  _CustomGroupRadioButonState<T> createState() =>
      _CustomGroupRadioButonState<T>();
}

class _CustomGroupRadioButonState<T> extends State<CustomGroupRadioButon<T>> {
  List<String> text = [
    'Anyone, on or off Chaser can see posts in the group. The group appears in search results and is visible to others on member’s profile',
    'Only group members can see posts in the group.',
  ];
  @override
  Widget build(BuildContext context) {
    return widget.row
        ? Row(
          crossAxisAlignment: CrossAxisAlignment.start,
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
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  widget.options.map((T option) {
                    return Column(
                      children: [
                        RadioListTile<T>(
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
                        Container(
                          // height: 40,
                          width: SizeCons.getWidth(context) * 0.85,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: ClrCons.darkGreyColor,
                              width: 1,
                            ),
                            gradient: LinearGradient(
                              colors: [
                                Color.fromRGBO(36, 35, 35, 0.894),
                                Color.fromRGBO(44, 44, 44, 0.9),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: [0.1, 0.9],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            child: CustomText(
                              text: text[widget.options.indexOf(option)],
                              color: ClrCons.whiteColor,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
            ),
          ],
        );
  }
}
