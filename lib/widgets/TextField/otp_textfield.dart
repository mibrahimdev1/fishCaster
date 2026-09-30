import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpTextField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String)? onChanged;

  const OtpTextField({Key? key, required this.controller, this.onChanged})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      width: 45,
      child: TextFormField(
        controller: controller,
        onChanged: onChanged,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        maxLength: 1,
        decoration: InputDecoration(
          counterText: '',
          hintText: '',
          hintStyle: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.white),
          ),
          filled: true,
          fillColor: Colors.black,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.white),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.white),
          ),
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly, // Only digits are allowed
        ],
      ),
    );
  }
}
