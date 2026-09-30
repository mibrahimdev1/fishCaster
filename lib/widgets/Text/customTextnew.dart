import 'package:fish_caster/bloc/language/language_bloc.dart';
import 'package:fish_caster/bloc/language/language_state.dart';
import 'package:fish_caster/import_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomTextNew extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color color;
  final TextDecoration? decoration;
  final TextAlign? textAlign;
  final int? maxline;
  final TextOverflow? overflow;
  final double? latterSpacing;
  const CustomTextNew({
    super.key,
    required this.text,
    this.fontSize = 14,
    this.fontWeight = FontWeight.normal,
    this.color = ClrCons.whiteColor,
    this.decoration,
    this.textAlign,
    this.maxline,
    this.overflow,
    this.latterSpacing,
  });

 

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageCubit, LanguageState>(
      builder: (context, state) {
        return FutureBuilder<String>(
          future: context.read<LanguageCubit>().translateFromJson(text),
          builder: (context, snapshot) {
            return Text(
              snapshot.data ?? text,
              maxLines: maxline,
              overflow: overflow,
              style: TextStylesCons.custom(
                letterSpacing: latterSpacing ?? 0,
                fontSize: fontSize,
                fontWeight: fontWeight,
                color: color,
                decoration: decoration,
              ),
              textAlign: textAlign,
            );
          },
        );
      },
    );
  }
}
