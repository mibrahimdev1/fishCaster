import 'package:fish_caster/bloc/share_prefrences/criteria_shared/criteria_shared.dart';
import 'package:fish_caster/bloc/share_prefrences/location_shared/shared_preferences.dart';
import 'package:fish_caster/bloc/share_prefrences/user_shared/user_shared_helper.dart';
import 'package:fish_caster/import_file.dart';
import 'package:fish_caster/screen/auth_screen/loginScreen.dart';
import 'package:flutter/material.dart';
import 'dart:async'; // For Timer

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Timer function to navigate to the next screen after 3

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(seconds: 2), () async {
    // After delay, run the loading functions
    loadUserAndSaveToBloc(context);
    await getSelectedLocation(context);
    await getSelectedCriteria(context);

    // You can optionally navigate to another screen after loading is done
    // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
  });
    // WidgetsBinding.instance.addPostFrameCallback((_) async {
    //   loadUserAndSaveToBloc(context);
    //   await getSelectedLocation(context);
    //   await getSelectedCriteria(context);
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ThemedBackground(
        child: Center(
          child: Container(
            width: 350,
            height: 140,
            decoration: BoxDecoration(
              image: DecorationImage(image: AssetImage(ImgCons.fullLogo)),
            ),
          ),
        ),
      ),
    );
  }
}
