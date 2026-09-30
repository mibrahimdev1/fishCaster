import 'package:fish_caster/core/color_cons.dart';
import 'package:fish_caster/widgets/Buttons/custom_button.dart';
import 'package:fish_caster/widgets/Text/customText.dart';
import 'package:flutter/material.dart';

void showGlobalPopup({
  required BuildContext context,
  required String title,
  required VoidCallback onConfirm,
  String message = "",
  IconData? icon, // Optional icon
  Color iconColor = Colors.blue, // Default icon color
}) {
  showDialog(
    context: context,
    barrierDismissible: false, // Prevent closing by tapping outside
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: ClrCons.surfaceClr,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15), // Rounded corners
        ),
        title: Column(
          children: [
            if (icon != null) // Show icon only if provided
              Icon(icon, color: iconColor, size: 40),
            SizedBox(
              height: icon != null ? 10 : 0,
            ), // Add spacing if icon exists
            CustomText(
              text: title,
              color: ClrCons.whiteColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ],
        ),
        content:
            message.isNotEmpty
                ? Text(
                  message,
                  style: TextStyle(color: ClrCons.whiteColor, fontSize: 14),
                  textAlign: TextAlign.center,
                )
                : null,
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Cancel Button
              CustomButton(
                text: "Cancel",
                onPressed: () => Navigator.pop(context),
              ),
              // Confirm Button
              CustomButton(
                text: "Confirm",
                onPressed: () {
                  Navigator.pop(context);
                  onConfirm(); // Execute confirmation action
                },
              ),
            ],
          ),
        ],
      );
    },
  );
}
