import 'dart:io';

import 'package:fish_caster/core/color_cons.dart';
import 'package:fish_caster/widgets/Text/customText.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void openFullScreenImage(File image, BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            // Full screen image
            Center(
              child: Image.file(
                image,
                fit: BoxFit.contain,
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
              ),
            ),
            // Close button (cross button)
            Positioned(
              top: 30,
              right: 30,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(
                    context,
                  ).pop(); // Close the full-screen image on tap
                },
                child: Icon(Icons.close, color: Colors.white, size: 40),
              ),
            ),
          ],
        ),
      );
    },
  );
}

Future<void> showImageSourceDialog(
  BuildContext context,
  Function _pickImage,
) async {
  showModalBottomSheet(
    backgroundColor: ClrCons.surfaceClr,
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 10),
            ListTile(
              leading: Icon(Icons.camera_alt, color: ClrCons.whiteColor),
              title: CustomText(text: 'Camera', color: ClrCons.whiteColor),
              onTap: () {
                _pickImage(ImageSource.camera);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.image, color: ClrCons.whiteColor),
              title: CustomText(text: 'Gallery', color: ClrCons.whiteColor),
              onTap: () {
                _pickImage(ImageSource.gallery);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    },
  );
}
