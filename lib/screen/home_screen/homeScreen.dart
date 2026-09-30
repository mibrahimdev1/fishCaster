import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';
import 'package:intl/intl.dart';
import 'package:cross_file/cross_file.dart';
import 'dart:typed_data';

import 'package:fish_caster/import_file.dart';
import 'package:fish_caster/screen/home_screen/tabs/help_tab/HelpTab.dart';
import 'package:fish_caster/screen/home_screen/tabs/home_tab/homeTab.dart';
import 'package:fish_caster/screen/home_screen/tabs/setting_tab/settginTab.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

class HomeScreen extends StatefulWidget {
  final int? initialIndex;
  final bool? isLoad;
  const HomeScreen({Key? key, this.initialIndex, this.isLoad = false})
    : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //  int _selectedIndex;
  int _selectedIndex = 0;
  bool _isTakingScreenshot = false;

  final GlobalKey<ScreenshotState> _screenshotKey =
      GlobalKey<ScreenshotState>();

  final ScreenshotController _screenshotController = ScreenshotController();

  final List<String> _icons = [
    ImgCons.homeIcon,
    ImgCons.helpIcon,
    ImgCons.shareIcon,
    ImgCons.settingIcon,
  ];

  final List<String> text = ["Home", "Help", "Share", "Setting"];

  // Future<void> _takeScreenshotAndShare(BuildContext context) async {
  //   setState(() => _isTakingScreenshot = true);
  //   await Future.delayed(Duration(milliseconds: 200));

  //   final image = await _screenshotController.capture();
  //   setState(() => _isTakingScreenshot = false);

  //   if (image != null) {
  //     final directory = await getTemporaryDirectory();
  //     final filePath = '${directory.path}/screenshot.png';
  //     final imageFile = File(filePath);
  //     await imageFile.writeAsBytes(image);

  //     await Share.shareXFiles(
  //       [XFile(imageFile.path)],
  //       text: 'Check out my app screenshot!',
  //     );
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Failed to capture screenshot')),
  //     );
  //   }
  // }
  Future<void> _takeScreenshotAndShare(BuildContext context) async {
    if (_selectedIndex != 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please go to the Home tab to take a screenshot.')),
        );
        return;
    }

    setState(() => _isTakingScreenshot = true);
    await Future.delayed(const Duration(milliseconds: 200));

    try {
        // Request storage/gallery permissions
        final status = await Permission.storage.request();
        if (!status.isGranted) {
            setState(() => _isTakingScreenshot = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Storage permission is required.')),
            );
            return;
        }

        // Capture the screenshot
        final Uint8List? image = await _screenshotController.capture();
        setState(() => _isTakingScreenshot = false);

        if (image != null) {
            try {
              // Save screenshot to gallery first
              final result = await ImageGallerySaver.saveImage(
                image, 
                quality: 100, 
                name: 'fishcaster_screenshot_${DateTime.now().millisecondsSinceEpoch}'
              );
              
              if (result['isSuccess'] == true) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Screenshot saved to gallery!')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to save screenshot to gallery.')),
                );
              }
            } catch (e) {
              print('Error saving to gallery: $e');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Could not save to gallery, but will still share.')),
              );
            }
            
            // Screenshot saved to gallery successfully
            // No share dialog will open
        } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not capture screenshot.')),
            );
        }
    } catch (e) {
        setState(() => _isTakingScreenshot = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
    }
}

  // Future<void> _takeScreenshotAndShare(BuildContext context) async {
  //   if (_selectedIndex != 0) {
  //     // Not in Home tab where screenshot controller is active
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(builder: (context) => HomeScreen()),
  //     );
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Please go to the Home tab to share.')),
  //     );
  //     return;
  //   }

  //   setState(() => _isTakingScreenshot = true);
  //   await Future.delayed(Duration(milliseconds: 200));

  //   try {
  //     final image = await _screenshotController.capture();
  //     setState(() => _isTakingScreenshot = false);

  //     if (image != null) {
  //       final timestamp = DateTime.now().millisecondsSinceEpoch;
        
  //       // Try multiple approaches for iOS compatibility
  //       bool shareSuccess = false;
        
  //       // Method 1: Try with documents directory
  //       try {
  //         final documentsDirectory = await getApplicationDocumentsDirectory();
  //         final documentsFilePath = '${documentsDirectory.path}/fishcaster_screenshot_$timestamp.png';
  //         final documentsImageFile = File(documentsFilePath);
  //         await documentsImageFile.writeAsBytes(image);
          
  //         await Future.delayed(Duration(milliseconds: 200));
          
  //         if (await documentsImageFile.exists() && await documentsImageFile.length() > 0) {
  //           await Share.shareXFiles(
  //             [XFile(documentsImageFile.path)],
  //             text: 'Check out this fishing forecast from my FishCaster app! 🎣\n\nWhen should you go fishing? Find out with FishCaster!\n\nhttps://www.fishcasterapp.com',
  //             subject: 'FishCaster Fishing Forecast',
  //           );
  //           shareSuccess = true;
  //         }
  //       } catch (e) {
  //         print('Method 1 failed: $e');
  //       }
        
  //       // Method 2: Try with temporary directory if Method 1 failed
  //       if (!shareSuccess) {
  //         try {
  //           final directory = await getTemporaryDirectory();
  //           final filePath = '${directory.path}/fishcaster_screenshot_$timestamp.png';
  //           final imageFile = File(filePath);
  //           await imageFile.writeAsBytes(image);
            
  //           await Future.delayed(Duration(milliseconds: 200));
            
  //           if (await imageFile.exists() && await imageFile.length() > 0) {
  //             await Share.shareXFiles(
  //               [XFile(imageFile.path)],
  //               text: 'Check out this fishing forecast from my FishCaster app! 🎣\n\nWhen should you go fishing? Find out with FishCaster!\n\nhttps://www.fishcasterapp.com',
  //               subject: 'FishCaster Fishing Forecast',
  //             );
  //             shareSuccess = true;
  //           }
  //         } catch (e) {
  //           print('Method 2 failed: $e');
  //         }
  //       }
        
  //       // Method 3: Fallback to text-only sharing
  //       if (!shareSuccess) {
  //         await Share.share(
  //           'Check out this fishing forecast from my FishCaster app! 🎣\n\nWhen should you go fishing? Find out with FishCaster!\n\nhttps://www.fishcasterapp.com',
  //           subject: 'FishCaster Fishing Forecast',
  //         );
  //       }
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Could not capture screenshot.')),
  //       );
  //     }
  //   } catch (e) {
  //     setState(() => _isTakingScreenshot = false);
  //     print('Share error: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Something went wrong while sharing: ${e.toString()}')),
  //     );
  //   }
  // }

  @override
 Widget build(BuildContext context) {
    final List<Widget> _pages = [
      Hometab(
        controller: _screenshotController,
        isTakingScreenshot: _isTakingScreenshot,
        isLoadAPi: widget.isLoad == true ? true : false,
      ),
      HelpTab(),
      Container(),
      Settgintab(),
    ];

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        height: 110,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF01274A), Color(0xFF00182E)],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(4, (index) {
            bool isSelected = index == _selectedIndex;

            return GestureDetector(
              onTap: () async {
                if (index == 2) {
                  await _takeScreenshotAndShare(context);
                } else {
                  setState(() => _selectedIndex = index);
                }
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 1),
                      borderRadius: BorderRadius.circular(10),
                      image:
                          isSelected
                              ? DecorationImage(
                                image: AssetImage(ImgCons.bottomGlow),
                                fit: BoxFit.cover,
                              )
                              : null,
                    ),
                    child: Image.asset(
                      _icons[index],
                      width: 28,
                      height: 28,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: 5),
                  CustomText(text: text[index], color: ClrCons.whiteColor),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
