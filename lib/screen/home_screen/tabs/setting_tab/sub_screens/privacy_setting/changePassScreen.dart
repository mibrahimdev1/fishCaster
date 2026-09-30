import 'package:fish_caster/api_services/api_handler.dart';
import 'package:fish_caster/api_services/reset_password_service.dart/reset_password_service.dart';
import 'package:fish_caster/bloc/token/token_bloc.dart';
import 'package:fish_caster/import_file.dart';
import 'package:fish_caster/screen/auth_screen/signupScreen.dart';
import 'package:fish_caster/screen/home_screen/homeScreen.dart';
import 'package:flutter/material.dart';

class ChangePassScreen extends StatefulWidget {
  const ChangePassScreen({super.key});

  @override
  State<ChangePassScreen> createState() => _ChangePassScreenState();
}

class _ChangePassScreenState extends State<ChangePassScreen> {
  TextEditingController oldPassController = TextEditingController();
  TextEditingController newPassController = TextEditingController();
  TextEditingController confirmPassController = TextEditingController();

  bool isLoading = false;

  Future<void> changePassword() async {
    if (oldPassController.text.isEmpty ||
        newPassController.text.isEmpty ||
        confirmPassController.text.isEmpty) {
      globalSnack.showSnackBar(context, 'Please fill all fields');
      return;
    }

    if (newPassController.text != confirmPassController.text) {
      globalSnack.showSnackBar(context, 'Passwords do not match');
      return;
    }

    setState(() {
      isLoading = true;
    });

    final apiHandler = ApiHandler(
      tokenBloc: TokenBloc(),
      context: context,
    ); // Pass your token or auth logic
    final success = await ResetPasswordService.changeOldPassword(
      apiHandler: apiHandler,
      oldPassword: oldPassController.text.trim(),
      newPassword: newPassController.text.trim(),
    );

    setState(() {
      isLoading = false;
    });

    if (success) {
      globalSnack.showSnackBar(context, 'Password changed successfully');
      Navigator.pop(context);
    } else {
      globalSnack.showSnackBar(context, 'Failed to change password');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        elevation: 0,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
      ),
      body: ThemedBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: Container(
                width: SizeCons.getWidth(context) * 0.8,
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    CustomText(
                      text: "Password",
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                    SizedBox(height: 40),
                    CustomTextField(
                      controller: oldPassController,
                      hintText: 'Old Password',
                      isPassword: true,
                    ),
                    SizedBox(height: 40),
                    CustomTextField(
                      controller: newPassController,
                      hintText: 'New Password',
                      isPassword: true,
                    ),
                    SizedBox(height: 40),
                    CustomTextField(
                      controller: confirmPassController,
                      hintText: 'Confirm Password',
                      isPassword: true,
                    ),
                    SizedBox(height: 40),
                    isLoading
                        ? CircularProgressIndicator()
                        : CustomButton(
                          text: "Confirm",
                          onPressed: changePassword,
                          // () {
                          //   if (oldPassController.text.isEmpty ||
                          //       newPassController.text.isEmpty ||
                          //       confirmPassController.text.isEmpty) {
                          //     globalSnack.showSnackBar(
                          //       context,
                          //       'Please fill all fields',
                          //     );
                          //     return;
                          //   }

                          //   if (newPassController.text !=
                          //       confirmPassController.text) {
                          //     globalSnack.showSnackBar(
                          //       context,
                          //       'Password does not match',
                          //     );
                          //     return;
                          //   }

                          //   Navigator.pop(context);
                          //   globalSnack.showSnackBar(
                          //     context,
                          //     'Password Changed Succesfully',
                          //   );
                          // },
                          width: 220,
                        ),
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
