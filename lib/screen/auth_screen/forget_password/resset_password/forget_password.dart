import 'dart:developer';
import 'dart:io';
import 'package:fish_caster/api_services/reset_password_service.dart/reset_password_service.dart';
import 'package:fish_caster/core/color_cons.dart';
import 'package:fish_caster/core/size_cons.dart';
import 'package:fish_caster/screen/auth_screen/loginScreen.dart';
import 'package:fish_caster/widgets/Buttons/custom_button.dart';
import 'package:fish_caster/widgets/Text/customText.dart';
import 'package:fish_caster/widgets/TextField/custom_textfield.dart';
import 'package:fish_caster/widgets/snackBar/gloabal_snack.dart';
import 'package:flutter/material.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String resetPasswordToken;
  const ResetPasswordScreen({super.key, required this.resetPasswordToken});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  TextEditingController _passController = TextEditingController();
  TextEditingController _confirmPassController = TextEditingController();

  bool _isloading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back, color: ClrCons.whiteColor),
        ),
      ),
      body: Center(
        child: Container(
          width: SizeCons.getWidth(context) * 0.85,
          child: Column(
            children: [
              _buildInputField(
                "New Password",
                _passController,
                "Enter your new password",
                isPassword: true,
              ),
              SizedBox(height: 20),
              _buildInputField(
                "Confirm Password",
                _confirmPassController,
                "Enter your password again",
                isPassword: true,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 40, right: 20),
        child: Container(
          width: SizeCons.getWidth(context) * 0.3,
          child:
              !_isloading
                  ? CustomButton(
                    text: "Submit",
                    onPressed: () async {
                      setState(() {
                        _isloading = true;
                      });
                      if (_passController.text == _confirmPassController.text) {
                        ResetPasswordService resetPasswordService =
                            ResetPasswordService();

                        try {
                          final response = await resetPasswordService
                              .changePassword(
                                _passController.text,
                                widget.resetPasswordToken,
                              );

                          if (response == null) {
                            // ✅ Password reset was successful (204 No Content)
                            globalSnack.showSnackBar(
                              context,
                              "Password changed successfully",
                            );

                            // ✅ Navigate to Login Screen
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Loginscreen(),
                              ),
                              (route) =>
                                  false, // Clears all previous screens from the stack
                            );

                            setState(() {
                              _isloading = false;
                            });
                          }
                        } catch (e) {
                          globalSnack.showSnackBar(
                            context,
                            "Failed to reset password: $e",
                          );
                          setState(() {
                            _isloading = false;
                          });
                        }
                      } else {
                        globalSnack.showSnackBar(
                          context,
                          "Password does not match",
                        );
                        setState(() {
                          _isloading = false;
                        });
                      }
                    },
                  )
                  : Center(
                    child: CircularProgressIndicator(
                      color: ClrCons.primaryColor,
                    ),
                  ),
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    String hintText, {
    bool isPassword = false,
  }) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15, bottom: 5),
            child: CustomText(
              text: label,
              color: ClrCons.whiteColor,
              fontSize: 12,
              fontWeight: FontWeight.normal,
            ),
          ),
          CustomTextField(
            controller: controller,
            hintText: hintText,
            isPassword: isPassword,
          ),
        ],
      ),
    );
  }
}
