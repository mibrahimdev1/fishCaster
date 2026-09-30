import 'package:fish_caster/api_services/auth_service/auth_service.dart';
import 'package:fish_caster/bloc/token/token_bloc.dart';
import 'package:fish_caster/bloc/token/token_event.dart';
import 'package:fish_caster/import_file.dart';
import 'package:fish_caster/screen/auth_screen/loginScreen.dart';
import 'package:fish_caster/widgets/gifLoader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController firstnameController = TextEditingController();
  TextEditingController lastnameController = TextEditingController();
  // TextEditingController dateController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController zipController = TextEditingController();

  bool _isloading = false;

  // Regex for email validation
  RegExp emailRegExp = RegExp(
    r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
  );

  RegExp passwordRegExp = RegExp(
    r'^(?=.*[A-Z])(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{6,}$',
  );

  bool _validateForm() {
    String name = nameController.text.trim();
    String firstname = firstnameController.text.trim();
    String lastname = lastnameController.text.trim();

    String email = emailController.text.trim();
    String password = passController.text;

    // Check if the name is empty
    if (firstname.isEmpty || lastname.isEmpty) {
      _showError("Full Name is required.");
      return false;
    }

    // Validate email format
    if (!emailRegExp.hasMatch(email)) {
      _showError("Please enter a valid email.");
      return false;
    }

    // Validate password strength
    if (!passwordRegExp.hasMatch(password)) {
      _showError(
        "Password must be at least 6 characters long, with 1 uppercase letter and 1 special character.",
      );
      return false;
    }

    return true;
  }

  // Show error message using SnackBar
  void _showError(String message) {
    globalSnack.showSnackBar(context, message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ThemedBackground(
        child: SingleChildScrollView(
          child: SafeArea(
            child: Center(
              child: Container(
                width: SizeCons.getWidth(context) * 0.8,
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    Container(
                      width: 300,
                      height: 100,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(ImgCons.fullLogo),
                        ),
                      ),
                    ),
                    CustomText(
                      text: "Sign up",
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                    SizedBox(height: 10),
                    CustomTextField(
                      controller: firstnameController,
                      hintText: 'First Name',
                      suffixIcon: ImgCons.person,
                      suffixColor: Colors.white,
                    ),
                    SizedBox(height: 20),
                    CustomTextField(
                      controller: lastnameController,
                      hintText: 'Last Name',
                      suffixIcon: ImgCons.person,
                      suffixColor: Colors.white,
                    ),
                    SizedBox(height: 20),
                    // CustomDateField(
                    //   controller: dateController,
                    //   hintText: "Birth Date",
                    //   onDateSelected: (pickedDate) {
                    //     // Do something with the picked date
                    //   },
                    // ),
                    // SizedBox(height: 40),
                    CustomTextField(
                      controller: emailController,
                      hintText: 'Email',
                      suffixIcon: ImgCons.mailIcon,
                    ),
                    SizedBox(height: 20),
                    CustomTextField(
                      controller: passController,
                      hintText: 'Password',
                      isPassword: true,
                    ),
                    SizedBox(height: 20),
                    CustomTextField(
                      controller: countryController,
                      hintText: 'Country',
                      suffixIcon: ImgCons.country,
                      suffixColor: Colors.white,
                    ),
                    SizedBox(height: 20),
                    CustomTextField(
                      controller: stateController,
                      hintText: 'State/Province/Region',
                      suffixIcon: ImgCons.state,
                      suffixColor: Colors.white,
                    ),
                    SizedBox(height: 20),
                    CustomTextField(
                      controller: cityController,
                      hintText: 'City/Town',
                      suffixIcon: ImgCons.city,
                      suffixColor: Colors.white,
                    ),
                    SizedBox(height: 20),
                    CustomTextField(
                      controller: zipController,
                      hintText: 'Postal/ZipCode',
                      suffixIcon: ImgCons.zip,
                      suffixColor: Colors.white,
                    ),
                    SizedBox(height: 40),
                    _isloading
                        ? FastGifWidget()
                        : CustomButton(
                          text: "Sign up",
                          onPressed: () async {
                            final prefs = await SharedPreferences.getInstance();

                            if (_validateForm()) {
                              setState(() {
                                _isloading = true;
                              });

                              AuthService authService = AuthService();

                              Map<String, String>?
                              tokens = await authService.registerUser(
                                context,
                                emailController.text.trim(),
                                passController.text.trim(),
                                // nameController.text.trim(),
                                '${firstnameController.text.trim()} ${lastnameController.text.trim()}',
                                countryController.text.trim(),
                                stateController.text.trim(),
                                cityController.text.trim(),
                                zipController.text.trim(),
                              );

                              if (tokens != null) {
                                String accessToken = tokens["accessToken"]!;
                                String refreshToken = tokens["refreshToken"]!;

                                await prefs.setString(
                                  'refreshToken',
                                  refreshToken,
                                );

                                // Store both tokens in TokenBloc
                                BlocProvider.of<TokenBloc>(context).add(
                                  SaveTokenEvent(accessToken, refreshToken),
                                );

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => BlocProvider.value(
                                          value: BlocProvider.of<TokenBloc>(
                                            context,
                                          ),
                                          child: Loginscreen(),
                                        ),
                                  ),
                                );
                                setState(() {
                                  _isloading = false;
                                });
                              } else {
                                // _showError(
                                //   "Registration failed. Please try again.",
                                // );
                                setState(() {
                                  _isloading = false;
                                });
                              }

                              setState(() {
                                _isloading = false;
                              });
                            }
                          },
                          width: 220,
                        ),
                    SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomText(
                          text: "Already have an account?",
                          fontSize: 14,
                        ),
                        SizedBox(width: 5),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Loginscreen(),
                              ),
                            );
                          },
                          child: CustomText(
                            text: "Login !",
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
  }
}
