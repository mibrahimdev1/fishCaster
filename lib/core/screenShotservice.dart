import 'dart:io';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class ScreenshotService {
  final ScreenshotController screenshotController = ScreenshotController();

  // Global function to take a screenshot and share
  Future<void> takeScreenshotAndShare(
    BuildContext context,
    Function(bool) onUpdateLoading,
  ) async {
    onUpdateLoading(true); // Update the UI with loading state

    // Set a delay to ensure the UI updates before capturing
    await Future.delayed(Duration(milliseconds: 200));

    final image = await screenshotController.capture();

    if (image != null) {
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/screenshot.png';
      final imageFile = File(filePath);
      await imageFile.writeAsBytes(image);

      // Share the screenshot
      await Share.shareXFiles([
        XFile(imageFile.path),
      ], text: 'Check out my app screenshot!');
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to capture screenshot')));
    }

    onUpdateLoading(false); // Stop the loading state
  }
}
