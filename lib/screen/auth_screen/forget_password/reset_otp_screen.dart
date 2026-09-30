import 'dart:async';
import 'dart:developer';
import 'package:fish_caster/api_services/reset_password_service.dart/reset_password_service.dart';
import 'package:fish_caster/core/color_cons.dart';
import 'package:fish_caster/core/image_cons.dart';
import 'package:fish_caster/core/size_cons.dart';
import 'package:fish_caster/screen/auth_screen/change_credential/forget_password.dart';
import 'package:fish_caster/widgets/Buttons/custom_button.dart';
import 'package:fish_caster/widgets/Text/customText.dart';
import 'package:fish_caster/widgets/TextField/otp_textfield.dart';
import 'package:fish_caster/widgets/Theme/themedBackground.dart';
import 'package:fish_caster/widgets/snackBar/gloabal_snack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/token/token_state.dart';

class ResetPasswordOTPScreen extends StatefulWidget {
  final String email;
  final String token;
  const ResetPasswordOTPScreen({
    super.key,
    required this.email,
    required this.token,
  });

  @override
  State<ResetPasswordOTPScreen> createState() => _ResetPasswordOTPScreenState();
}

class _ResetPasswordOTPScreenState extends State<ResetPasswordOTPScreen> {
  final TextEditingController _otpController1 = TextEditingController();
  final TextEditingController _otpController2 = TextEditingController();
  final TextEditingController _otpController3 = TextEditingController();
  final TextEditingController _otpController4 = TextEditingController();
  final TextEditingController _otpController5 = TextEditingController();
  final TextEditingController _otpController6 = TextEditingController();

  String sid = "";
  bool _isloading = false;
  int _seconds = 60;
  Timer? _timer;

  void _startTimer() {
    _seconds = 60;
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_seconds > 0) {
        setState(() {
          _seconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _onOtpChanged(String value, int index) {
    if (value.length == 1) {
      if (index < 5) {
        FocusScope.of(context).nextFocus();
      }
    } else if (value.isEmpty) {
      if (index > 0) {
        FocusScope.of(context).previousFocus();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    if (sid == "") {
      sid = widget.token;
    }
    print("SID: $sid");
    _startTimer();
  }

  Future<void> _sendVerificationEmail() async {
    try {
      final service = ResetPasswordService();
      sid = await service.sendVerificationEmail(widget.email) ?? '';
      if (sid.isNotEmpty) {
        // log("SID received: $sid");
        _startTimer();
      }
    } catch (e) {
      log("Error sending verification email: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: CustomText(
          text: "Check your email!",
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: ClrCons.whiteColor,
        ),
      ),
      body: ThemedBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 110,
                width: 110,
                child: Image.asset(ImgCons.small_logo, fit: BoxFit.cover),
              ),
              SizedBox(height: SizeCons.getHeight(context) * 0.05),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OtpTextField(
                    controller: _otpController1,
                    onChanged: (value) => _onOtpChanged(value, 0),
                  ),
                  SizedBox(width: 10),
                  OtpTextField(
                    controller: _otpController2,
                    onChanged: (value) => _onOtpChanged(value, 1),
                  ),
                  SizedBox(width: 10),
                  OtpTextField(
                    controller: _otpController3,
                    onChanged: (value) => _onOtpChanged(value, 2),
                  ),
                  SizedBox(width: 10),
                  OtpTextField(
                    controller: _otpController4,
                    onChanged: (value) => _onOtpChanged(value, 3),
                  ),
                  SizedBox(width: 10),
                  OtpTextField(
                    controller: _otpController5,
                    onChanged: (value) => _onOtpChanged(value, 4),
                  ),
                  SizedBox(width: 10),
                  OtpTextField(
                    controller: _otpController6,
                    onChanged: (value) => _onOtpChanged(value, 5),
                  ),
                ],
              ),
              SizedBox(height: SizeCons.getHeight(context) * 0.1),
              _isloading
                  ? CircularProgressIndicator(color: ClrCons.primaryColor)
                  : CustomButton(
                    width: SizeCons.getWidth(context) * 0.4,
                    borderRadius: 30,
                    text: "Verify",
                    onPressed: () async {
                      // Navigator.pushReplacement(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder:
                      //         (context) => ResetPasswordScreen(
                      //           resetPasswordToken:
                      //               '', // ✅ Pass token to next screen
                      //         ),
                      //   ),
                      // );
                      setState(() {
                        _isloading = true;
                      });

                      String otp =
                          _otpController1.text +
                          _otpController2.text +
                          _otpController3.text +
                          _otpController4.text +
                          _otpController5.text +
                          _otpController6.text;

                      if (otp.isNotEmpty && sid.isNotEmpty) {
                        try {
                          final service = ResetPasswordService();
                          final response = await service.verifyPassword(
                            context,
                            sid,
                            otp,
                          );

                          if (response.containsKey('resetToken')) {
                            // ✅ Check if token exists
                            final String resetPasswordToken =
                                response['resetToken'];

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => ResetPasswordScreen(
                                      resetPasswordToken:
                                          resetPasswordToken, // ✅ Pass token to next screen
                                    ),
                              ),
                            );
                          } else {
                            globalSnack.showSnackBar(
                              context,
                              "Verification failed!",
                            );
                          }
                        } catch (e) {
                          print('Error verifying email: $e');
                        }
                      } else {
                        globalSnack.showSnackBar(
                          context,
                          "Please enter OTP received in email",
                        );
                      }

                      setState(() {
                        _isloading = false;
                      });
                    },
                  ),
              SizedBox(height: SizeCons.getHeight(context) * 0.04),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomText(
                    text: 'Didn\'t receive the code? ',
                    color: ClrCons.whiteColor,
                    fontSize: 12,
                  ),
                  SizedBox(width: 5,),
                  InkWell(
                    onTap: _seconds == 0 ? _sendVerificationEmail : null,
                    child: CustomText(
                      text:
                          _seconds == 0
                              ? 'Resend it!'
                              : 'Resend in $_seconds s',
                      color: ClrCons.blueColor,
                      fontSize: 12,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
