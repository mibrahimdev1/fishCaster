import 'package:fish_caster/import_file.dart';
import 'package:fish_caster/widgets/Buttons/custom_button_textfield.dart';
import 'package:fish_caster/widgets/Theme/themedBackground.dart';
import 'package:flutter/material.dart';

class HelpTab extends StatefulWidget {
  const HelpTab({super.key});

  @override
  State<HelpTab> createState() => _HelpTabState();
}

class _HelpTabState extends State<HelpTab> {
  final List<Map<String, dynamic>> settingItems = [
    {
      'title': 'Apparent Temperature',
      'icon': ImgCons.tempIcon,
      'onTap': () => print('Profile tapped'),
    },
    {
      'title': 'Barometric Pressure',
      'icon': ImgCons.pressureIcon,
      'onTap': () => print('Notifications tapped'),
    },
    {
      'title': 'Clouds',
      'icon': ImgCons.cloudIcon,
      'onTap': () => print('Privacy tapped'),
    },
    {
      'title': 'Wind',
      'icon': ImgCons.windIcon,
      'onTap': () => print('Language tapped'),
    },
    {
      'title': 'Percipitation',
      'icon': ImgCons.percipitationIcon,
      'onTap': () => print('Theme tapped'),
    },
    {
      'title': 'Thunderstorms',
      'icon': ImgCons.thunderIcon,
      'onTap': () => print('Help tapped'),
    },
    {
      'title': 'UV Index',
      'icon': ImgCons.uvIcon,
      'onTap': () => print('Logout tapped'),
    },
    {
      'title': 'Solunar',
      'icon': ImgCons.solunarIcon,
      'onTap': () => print('Logout tapped'),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ThemedBackground(
        child: SafeArea(
          child: Center(
            child: Container(
              width: SizeCons.getWidth(context) * 0.8,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    const CustomText(
                      text: 'Guide',
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                    // const SizedBox(height: 20),
                    ...settingItems.map((item) {
                      return GestureDetector(
                        onTap: item['onTap'],
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14.0),
                          child: CustomButtonTextField(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Image.asset(
                                    item['icon'],
                                    width: 26,
                                    height: 26,
                                  ),
                                  CustomText(
                                    text: item['title'],
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  CustomText(
                                    text: '',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
