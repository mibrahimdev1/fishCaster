import 'dart:developer';
import 'dart:io';
import 'package:fish_caster/api_services/reset_password_service.dart/reset_password_service.dart';
import 'package:fish_caster/core/color_cons.dart';
import 'package:fish_caster/core/size_cons.dart';
import 'package:fish_caster/import_file.dart';
import 'package:fish_caster/screen/auth_screen/forget_password/reset_otp_screen.dart';
import 'package:fish_caster/widgets/Buttons/custom_button.dart';
import 'package:fish_caster/widgets/Text/customText.dart';
import 'package:fish_caster/widgets/TextField/custom_textfield.dart';
import 'package:fish_caster/widgets/gifLoader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  TextEditingController _emailController = TextEditingController();

  late String sid;
  bool isLoading = false;

  // Future<void> _sendVerificationEmail() async {
  //   if (_emailController.text.isEmpty) {
  //     return null;
  //   }
  //   setState(() {
  //     isLoading = true;
  //   });

  //   try {
  //     final service = ResetPasswordService();
  //     sid = await service.sendVerificationEmail(_emailController.text) ?? '';
  //     if (sid.isNotEmpty) {
  //       log("SID received: $sid");
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder:
  //               (context) => ResetPasswordOTPScreen(
  //                 email: _emailController.text,
  //                 token: sid,
  //               ),
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     log("Error sending verification email: $e");

  //   } finally {
  //     setState(() {
  //       isLoading = false;
  //     });
  //   }
  // }

  Future<void> _sendVerificationEmail() async {
    if (_emailController.text.isEmpty) {
      _showError("Please enter your email");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final service = ResetPasswordService();
      sid = await service.sendVerificationEmail(_emailController.text) ?? '';
      if (sid.isNotEmpty) {
        // log("SID received: $sid");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => ResetPasswordOTPScreen(
                  email: _emailController.text,
                  token: sid,
                ),
          ),
        );
      } else {
        _showError("Something went wrong. Please try again.");
      }
    } catch (e) {
      // log("Error sending verification email: $e");
      _showError("Failed to send verification email.");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showError(String message) {
    globalSnack.showErrorSnackBar(context, message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back, color: ClrCons.whiteColor),
        ),
      ),
      body: ThemedBackground(
        child: Center(
          child: SafeArea(
            child: Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 15, bottom: 5),
                      child: CustomText(
                        text: "Email",
                        color: ClrCons.whiteColor,
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    Container(
                      width: SizeCons.getWidth(context) * 0.85,
                      child: CustomTextField(
                        controller: _emailController,
                        hintText: 'Enter your email',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 40, right: 20),
        child:
            isLoading
                ? FastGifWidget()
                : Container(
                  width: SizeCons.getWidth(context) * 0.3,
                  child: CustomButton(
                    text: "Next",
                    onPressed: () {
                      _sendVerificationEmail();
                    },
                  ),
                ),
      ),
    );
  }
}
