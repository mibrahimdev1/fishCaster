import 'package:flutter/material.dart';
import 'package:fish_caster/import_file.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double borderRadius;
  final double elevation;
  final double fontSize;
  final double height;
  final double width;
  final FontWeight? fontWeight;
  final String? suffixIcon;
  final List<Color>? fillColor;
  final Color? fontColor;
  final Color? borderColor;

  CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.borderRadius = 50,
    this.elevation = 0,
    this.fontSize = 16.0,
    this.height = 50,
    this.width = double.infinity,
    this.fontWeight,
    this.suffixIcon,
    this.fillColor,
    this.fontColor,
    this.borderColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: fillColor ?? [Color(0xFF12395D), Color(0xFF00182E)],
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor ?? Colors.white, width: 1.5),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 2)),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          fixedSize: Size(width, height),
          minimumSize: Size(width, height),
          padding: EdgeInsets.zero,
          elevation: 0,
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStylesCons.custom(
                fontSize: fontSize,
                color: fontColor ?? ClrCons.whiteColor,
                fontWeight: fontWeight ?? FontWeight.normal,
              ),
            ),
            if (suffixIcon != null) ...[
              const SizedBox(width: 8),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  image: DecorationImage(image: AssetImage(suffixIcon ?? "")),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
