import 'package:fish_caster/api_services/auth_service/auth_service.dart';
import 'package:fish_caster/bloc/criteria/criteria_bloc.dart';
import 'package:fish_caster/bloc/criteria/criteria_event.dart';
import 'package:fish_caster/bloc/language/language_bloc.dart';
import 'package:fish_caster/bloc/location/location_bloc.dart';
import 'package:fish_caster/bloc/location/location_event.dart';
import 'package:fish_caster/bloc/share_prefrences/criteria_shared/criteria_shared.dart';
import 'package:fish_caster/bloc/share_prefrences/location_shared/shared_preferences.dart';
import 'package:fish_caster/bloc/share_prefrences/user_shared/user_shared_helper.dart';
import 'package:fish_caster/import_file.dart';
import 'package:fish_caster/screen/auth_screen/loginScreen.dart';
import 'package:fish_caster/screen/home_screen/tabs/setting_tab/custom_drop_down_widget.dart';
import 'package:fish_caster/screen/home_screen/tabs/setting_tab/sub_screens/notification_screen.dart';
import 'package:fish_caster/screen/home_screen/tabs/setting_tab/sub_screens/prefrences_screen.dart';
import 'package:fish_caster/screen/home_screen/tabs/setting_tab/sub_screens/privacy_policy.dart';
import 'package:fish_caster/screen/home_screen/tabs/setting_tab/sub_screens/privacy_setting/changePassScreen.dart';
import 'package:fish_caster/screen/home_screen/tabs/setting_tab/sub_screens/profile/profile_setting.dart';
import 'package:fish_caster/screen/home_screen/tabs/setting_tab/sub_screens/term_condition.dart';
import 'package:fish_caster/widgets/Buttons/custom_button_textfield.dart';
import 'package:fish_caster/widgets/Theme/themedBackground.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settgintab extends StatefulWidget {
  const Settgintab({super.key});

  @override
  State<Settgintab> createState() => _SettgintabState();
}

class _SettgintabState extends State<Settgintab> {
  String? selectedLanguage;
  bool isLoading = false;
  bool isLoading1 = false;
  @override
  Widget build(BuildContext context) {
    void showBottomDialogue(BuildContext context) async {
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

                // ListTile(
                //   title: CustomText(text: 'English', color: ClrCons.whiteColor),
                //   onTap: () {
                //     context.watch<LanguageCubit>().state.language ?? 'en';

                //     Navigator.pop(context);
                //   },
                // ),
                // ListTile(
                //   title: CustomText(text: 'German', color: ClrCons.whiteColor),
                //   onTap: () {
                //     Navigator.pop(context);
                //   },
                // ),
                // ListTile(
                //   title: CustomText(text: 'Arabic', color: ClrCons.whiteColor),
                //   onTap: () {
                //     Navigator.pop(context);
                //   },
                // ),
                // ListTile(
                //   title: CustomText(text: 'English', color: ClrCons.whiteColor),
                //   onTap: () {
                //     context.read<LanguageCubit>().changeLanguage('en');
                //     Navigator.pop(context);
                //   },
                // ),
                // ListTile(
                //   title: CustomText(text: 'German', color: ClrCons.whiteColor),
                //   onTap: () {
                //     context.read<LanguageCubit>().changeLanguage('de');
                //     Navigator.pop(context);
                //   },
                // ),
                // ListTile(
                //   title: CustomText(text: 'Arabic', color: ClrCons.whiteColor),
                //   onTap: () {
                //     context.read<LanguageCubit>().changeLanguage('ar');
                //     Navigator.pop(context);
                //   },
                // ),
                ListTile(
                  title: CustomText(text: 'English', color: ClrCons.whiteColor),
                  onTap: () {
                    context.read<LanguageCubit>().changeLanguage('en');
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: CustomText(
                    text: 'Japanese',
                    color: ClrCons.whiteColor,
                  ),
                  onTap: () {
                    context.read<LanguageCubit>().changeLanguage('ja');
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: CustomText(text: 'Spanish', color: ClrCons.whiteColor),
                  onTap: () {
                    context.read<LanguageCubit>().changeLanguage('es');
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: CustomText(text: 'Arabic', color: ClrCons.whiteColor),
                  onTap: () {
                    context.read<LanguageCubit>().changeLanguage('ar');
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: CustomText(text: 'German', color: ClrCons.whiteColor),
                  onTap: () {
                    context.read<LanguageCubit>().changeLanguage('de');
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        },
      );
    }

    final List<Map<String, dynamic>> settingItems = [
      {
        'title': 'Profile',
        'icon': ImgCons.profileIcon,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfileSettingScreen()),
          );
        },
      },
      // {
      //   'title': 'Notifications',
      //   'icon': ImgCons.notiIcon,
      //   'onTap': () {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(builder: (context) => NotificationScreen()),
      //     );
      //   },
      // },
      //  {
      //    'title': 'Preferences',
      //    'icon': ImgCons.prefIcon,
      //    'onTap': () {
      //      Navigator.push(
      //        context,
      //        MaterialPageRoute(builder: (context) => PreferencesScreen()),
      //      );
      //    },
      //  },
      {
        'title': 'Language',
        'icon': ImgCons.langIcon,
        'onTap': () {
          showBottomDialogue(context);
        },
      },
      {
        'title': 'Privacy Settings',
        'icon': ImgCons.privacySettingIcon,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChangePassScreen()),
          );
        },
      },
      {
        'title': 'Privacy Policy',
        'icon': ImgCons.policyIcon,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PrivacyPolicyScreen()),
          );
        },
      },
      {
        'title': 'Terms & Conditions',
        'icon': ImgCons.termIcon,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TermsConditionsScreen()),
          );
        },
      },
      {
        'title': 'Logout',
        'icon': ImgCons.termIcon,

        'onTap': () async {
          final prefs = await SharedPreferences.getInstance();
          String sharedRefreshToken = prefs.getString('refreshToken') ?? "";

          // final response = await AuthService.logoutService(
          //   refreshToken: sharedRefreshToken,
          // );

          // if (response != null) {
          // Clear local caches
          await prefs.remove('criteria_result_cache');
          await prefs.remove('criteria_result_timestamp');
          await prefs.remove('criteria_score');
          await prefs.remove('criteria_score_color');
          await prefs.remove('hot_fishing_created_at');

          globalSnack.showSnackBar(context, "Logout Successfully");

          // Clear local app data
          clearSharedPreferencesAndLogout(context);
          await clearLocationData();
          await clearCriteriaData();

          // Clear BLoC state
          context.read<LocationBloc>().add(ClearLocation());
          context.read<CriteriaBloc>().add(ClearCriteria());

          // Navigate to login
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => Loginscreen()),
            (route) => false,
          );
          // } else {
          //   globalSnack.showSnackBar(context, "Failed To Logout");
          // }
        },
      },
    ];
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
                      text: 'Settings',
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                    const SizedBox(height: 30),
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
                                  SizedBox(
                                    width: SizeCons.getWidth(context) * 0.6,
                                    child: CustomText(
                                      text: item['title'],
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Image.asset(
                                    item['icon'],
                                    width: 26,
                                    height: 26,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    //     CustomDropDownWidget(
                    //   leadingIcon: Image.asset(
                    //     ImgCons.langIcon,
                    //     color: ClrCons.primaryColor,
                    //   ),
                    //   title: 'Language',
                    //   items: {
                    //     'English': 'en',
                    //     'Arabic': 'ar',
                    //     'Spanish': 'es',
                    //     'French': 'fr',
                    //     'German': 'de',
                    //     'Bangla': 'bn',
                    //   },
                    //   selectedValue:
                    //       context.watch<LanguageCubit>().state.language ?? 'en',
                    //   onChanged: (value) async {
                    //     if (value != null) {
                    //       setState(() {
                    //         isLoading1 = true; // Show the loader
                    //       });

                    //       await context.read<LanguageCubit>().changeLanguage(value);

                    //       setState(() {
                    //         selectedLanguage = value;
                    //         isLoading1 = false; // Hide the loader
                    //       });
                    //     }
                    //   },
                    // ),
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
