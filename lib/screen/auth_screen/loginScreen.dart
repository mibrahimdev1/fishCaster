import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:fish_caster/api_services/auth_service/auth_service.dart';
import 'package:fish_caster/bloc/token/token_bloc.dart';
import 'package:fish_caster/bloc/token/token_event.dart';
import 'package:fish_caster/bloc/user/user_bloc.dart';
import 'package:fish_caster/bloc/user/user_event.dart';
import 'package:fish_caster/bloc/user/user_state.dart';
import 'package:fish_caster/import_file.dart';
import 'package:fish_caster/model/user_model/user_model.dart';
import 'package:fish_caster/screen/auth_screen/change_credential/forget_password.dart';
import 'package:fish_caster/screen/auth_screen/forget_password/forget_password.dart';
import 'package:fish_caster/screen/auth_screen/signupScreen.dart';
import 'package:fish_caster/screen/home_screen/homeScreen.dart';
import 'package:fish_caster/widgets/gifLoader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:http/http.dart' as http;

class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  bool isSocialLogin = false;

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    try {
      setState(() {
        isSocialLogin = true;
      });
      final GoogleSignIn _googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      setState(() {
        isSocialLogin = true;
      });
      if (googleUser == null) {
        setState(() {
          isSocialLogin = false;
        });
        print("❌ Google Sign-In Cancelled");
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.accessToken; // ✅ Get ID Token

      if (idToken != null) {
        setState(() {
          isSocialLogin = true;
        });
        print("✅ Google ID Token: $idToken");

        // Replace with actual FCM token
        String fcmToken = "your_fcm_token_here";

        // ✅ Call API with ID Token
        final response = await AuthService.googleSignIn(idToken: idToken);

        if (response != null) {
          print("🎉 Login Successful: $response");

          context.read<UserBloc>().add(
            GoogleLoginEvent(token: idToken, fcmToken: fcmToken),
          );
          setState(() {
            isSocialLogin = false;
          });
        } else {
          setState(() {
            isSocialLogin = false;
          });
          print("❌ Login Failed");
        }
      }
    } catch (e) {
      setState(() {
        isSocialLogin = false;
      });
      print("❌ Google Sign-In Error: $e");
    }
  }

  Future<void> _handleAppleSignIn(BuildContext context) async {
    try {
      setState(() {
        isSocialLogin = true;
      });
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final String? identityToken = appleCredential.identityToken;
      final String? authorizationCode = appleCredential.authorizationCode;
      final String? fullName = appleCredential.givenName ?? "";

      if (identityToken == null || authorizationCode == null) {
        setState(() {
          isSocialLogin = false;
        });
        print("❌ Apple Sign-In Failed: Missing credentials");
        return;
      }

      print("✅ Apple Identity Token: $identityToken");

      final response = await AuthService.appleSignIn(
        identityToken: identityToken,
        authorizationCode: authorizationCode,
        fullName: fullName ?? "",
      );

      if (response != null && response.containsKey("user")) {
        setState(() {
          isSocialLogin = true;
        });
        print("🎉 Apple Login Successful: $response");

        final user = response["user"];
        final tokens = response["tokens"];

        context.read<UserBloc>().add(
          SaveUserEvent(
            user: UserModel(
              id: user["id"],
              email: user["email"],
              name: user["name"] ?? "",
              role: user["role"],
              isEmailVerified: user["isEmailVerified"] ?? false,
              country: user["country"] ?? "",
              state: user["state"] ?? "",
              city: user["city"] ?? "",
              zipCode: user["zipCode"] ?? "",
            ),
          ),
        );

        context.read<TokenBloc>().add(
          SaveTokenEvent(tokens["access"]["token"], tokens["refresh"]["token"]),
        );

        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => HomeScreen()));
        setState(() {
          isSocialLogin = false;
        });
        setState(() {
          isSocialLogin = false;
        });
      } else {
        setState(() {
          isSocialLogin = false;
        });
        print("❌ Apple Login Failed");
      }
    } catch (e) {
      setState(() {
        isSocialLogin = false;
      });
      print("❌ Apple Sign-In Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserBloc, UserState>(
      listener: (context, state) {
        if (state is UserRedirectToSetup) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
            (route) => false,
          );
        } else if (state is UserRedirectToHome) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
            (route) => false,
          );
        } else if (state is UserError) {
          globalSnack.showErrorSnackBar(context, state.error);
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: ThemedBackground(
            child: SafeArea(
              child: Center(
                child:
                    isSocialLogin
                        ? // Show loader if login is in progress
                        // CircularProgressIndicator(color: Colors.blueAccent)
                        FastGifWidget()
                        : Container(
                          width: SizeCons.getWidth(context) * 0.8,
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                SizedBox(height: 20),
                                Container(
                                  width: 300,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(ImgCons.fullLogo),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20),
                                CustomText(
                                  text: "Login",
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                                SizedBox(height: 40),
                                CustomTextField(
                                  controller: emailController,
                                  hintText: 'Email',
                                ),
                                SizedBox(height: 40),
                                CustomTextField(
                                  controller: passController,
                                  hintText: 'Password',
                                  isPassword: true,
                                ),
                                SizedBox(height: 20),
                                Container(
                                  width: double.infinity,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      ForgetPasswordScreen(),
                                            ),
                                          );
                                        },
                                        child: CustomText(
                                          text: "Forget Password?",
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 40),
                                if (state
                                    is UserLoading) // Show loader if login is in progress
                                  // CircularProgressIndicator(color: Colors.blueAccent)
                                  FastGifWidget()
                                else
                                  CustomButton(
                                    text: "Login",
                                    onPressed: () {
                                      context.read<UserBloc>().add(
                                        LoginUserEvent(
                                          email: emailController.text.trim(),
                                          password: passController.text.trim(),
                                        ),
                                      );
                                    },
                                    width: 220,
                                  ),

                                SizedBox(height: 40),

                                // CustomText(text: "Continue with", fontSize: 20),
                                // SizedBox(height: 20),
                                // Row(
                                //   mainAxisAlignment: MainAxisAlignment.center,
                                //   children: [
                                //     GestureDetector(
                                //       onTap: () => _handleGoogleSignIn(context),
                                //       child: Container(
                                //         width: 50,
                                //         height: 50,
                                //         decoration: BoxDecoration(
                                //           borderRadius: BorderRadius.circular(
                                //             10,
                                //           ),
                                //           color: ClrCons.socialIcon.withOpacity(
                                //             0.85,
                                //           ),
                                //         ),
                                //         child: Padding(
                                //           padding: const EdgeInsets.all(6.0),
                                //           child: Container(
                                //             decoration: BoxDecoration(
                                //               image: DecorationImage(
                                //                 image: AssetImage(
                                //                   ImgCons.gooGleIcon,
                                //                 ),
                                //               ),
                                //             ),
                                //           ),
                                //         ),
                                //       ),
                                //     ),
                                //     SizedBox(width: 10),
                                //     if (Platform.isIOS)
                                //       GestureDetector(
                                //         onTap:
                                //             () => _handleAppleSignIn(context),

                                //         child: Container(
                                //           width: 50,
                                //           height: 50,
                                //           decoration: BoxDecoration(
                                //             borderRadius: BorderRadius.circular(
                                //               10,
                                //             ),
                                //             color: ClrCons.socialIcon
                                //                 .withOpacity(0.85),
                                //           ),
                                //           child: Padding(
                                //             padding: const EdgeInsets.all(6.0),
                                //             child: Container(
                                //               decoration: BoxDecoration(
                                //                 image: DecorationImage(
                                //                   image: AssetImage(
                                //                     ImgCons.appleIcon,
                                //                   ),
                                //                 ),
                                //               ),
                                //             ),
                                //           ),
                                //         ),
                                //       ),
                                //   ],
                                // ),

                                // SizedBox(height: 40),
                                SizedBox(height: 40),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CustomText(
                                      text: "Don't have an account?",
                                      fontSize: 14,
                                    ),
                                    SizedBox(width: 5),
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    const SignupScreen(),
                                          ),
                                        );
                                      },
                                      child: CustomText(
                                        text: "Sign up!",
                                        fontSize: 14,
                                        decoration: TextDecoration.underline,
                                        color: ClrCons.blueColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
              ),
            ),
          ),
        );
      },
    );
  }
}
