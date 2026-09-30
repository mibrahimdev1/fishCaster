import 'package:flutter/material.dart';
import 'package:fish_caster/import_file.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final bool enabled;
  final TextStyle? hintStyle;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final EdgeInsetsGeometry? contentPadding;
  final bool isPassword;
  final Widget? prefixIcon;
  final String? suffixIcon;
  final int? maxline;
  final FocusNode? focusNode;
  final TextStyle? style;
  final Function()? ontap;
  final bool readOnly;
  final Color? suffixColor;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.enabled = true,
    this.hintStyle,
    this.onChanged,
    this.validator,
    this.contentPadding,
    this.isPassword = false,
    this.prefixIcon,
    this.suffixIcon,
    this.maxline = 1,
    this.focusNode,
    this.style,
    this.ontap,
    this.readOnly = false, this.suffixColor,
  }) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.isPassword ? true : widget.obscureText;
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isObscured = !_isObscured;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFF111f4c), // Solid color on the left

            Color(0xff1a2c53), // Transparent on the right
          ],
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black54, blurRadius: 6, offset: Offset(5, 5)),
        ],
      ),
      child: CustomPaint(
        painter: _LeftBorderPainter(),
        child: TextFormField(
          cursorColor: ClrCons.whiteColor,
          readOnly: widget.readOnly,
          onTap: widget.ontap,
          controller: widget.controller,
          focusNode: widget.focusNode,
          obscureText: widget.isPassword ? _isObscured : widget.obscureText,
          keyboardType: widget.keyboardType,
          enabled: widget.enabled,
          maxLines: widget.isPassword ? 1 : widget.maxline,
          style:
              widget.style ??
              TextStylesCons.custom(fontSize: 18, color: ClrCons.whiteColor),
          onChanged: widget.onChanged,
          validator: widget.validator,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle:
                widget.hintStyle ??
                TextStyle(color: ClrCons.whiteColor, fontSize: 18),
            border: InputBorder.none,
            contentPadding:
                widget.contentPadding ??
                const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            // prefixIcon: widget.prefixIcon ??
            // Padding(
            //   padding: const EdgeInsets.only(left: 12.0, right: 8),
            //   child: Image.asset(
            //     ImgCons.gooGleIcon, // Replace with your asset path
            //     width: 24,
            //     height: 24,
            //   ),
            //     ),
            suffixIcon:
                widget.isPassword
                    ? IconButton(
                      icon: Icon(
                        _isObscured ? Icons.visibility : Icons.visibility_off,
                        color: ClrCons.whiteColor,
                        size: 24,
                      ),
                      onPressed: _togglePasswordVisibility,
                    )
                    : widget.suffixIcon != null
                    ? Padding(
                      padding: const EdgeInsets.only(right: 12.0, left: 8),
                      child: Image.asset(
                        widget.suffixIcon ?? "", // Replace with your asset path
                        width: 24,
                        height: 24,
                        color: widget.suffixColor,
                      ),
                    )
                    : null,
          ),
        ),
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
            end: Alignment(0.85, 0), // up to 85% of the width
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
