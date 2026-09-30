
import 'dart:io';

import 'package:fish_caster/bloc/token/token_bloc.dart';
import 'package:fish_caster/bloc/token/token_event.dart';
import 'package:fish_caster/bloc/token/token_state.dart';
import 'package:fish_caster/bloc/user/user_bloc.dart';
import 'package:fish_caster/bloc/user/user_event.dart';
import 'package:fish_caster/bloc/user/user_state.dart';
import 'package:fish_caster/import_file.dart';
import 'package:fish_caster/screen/home_screen/homeScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileSettingScreen extends StatefulWidget {
  const ProfileSettingScreen({super.key});

  @override
  State<ProfileSettingScreen> createState() => _ProfileSettingScreenState();
}

class _ProfileSettingScreenState extends State<ProfileSettingScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController countryController= TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController zipController = TextEditingController();


  String token = '';
  String userId = '';
  String _initialName = '';
  String _initialEmail = '';
  String _initialCountry= '';
  String _initialState = '';
  String _initialCity = '';
  String _initialZipCode = '';

  bool _isModified = false;

  @override
  void initState() {
    super.initState();
    context.read<UserBloc>().add(GetUserEvent());
    context.read<TokenBloc>().add(GetTokenEvent());

    nameController.addListener(_checkIfModified);
    emailController.addListener(_checkIfModified);
    countryController.addListener(_checkIfModified);
    stateController.addListener(_checkIfModified);
    cityController.addListener(_checkIfModified);
    zipController.addListener(_checkIfModified);

  }

  void _checkIfModified() {
    final isNowModified =
        nameController.text != _initialName ||
        emailController.text != _initialEmail ||
        countryController.text != _initialCountry ||
        stateController.text != _initialState ||
        cityController.text != _initialCity ||
        zipController.text != _initialZipCode;

    if (_isModified != isNowModified) {
      setState(() {
        _isModified = isNowModified;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state is UserLoaded) {
          nameController.text = state.user.name;
          emailController.text = state.user.email;
          countryController.text = state.user.country;
          stateController.text = state.user.state;
          cityController.text = state.user.city;
          zipController.text = state.user.zipCode;

          userId = state.user.id;

          // Set initial values
          _initialName = state.user.name;
          _initialEmail = state.user.email;
          _initialCountry = state.user.country;
          _initialState = state.user.state;
          _initialCity = state.user.city;
          _initialZipCode = state.user.zipCode;
          _checkIfModified(); // Trigger initial state check
        }
      },
      child: BlocListener<TokenBloc, TokenState>(
        listener: (context, state) {
          if (state is TokenLoaded) {
            token = state.token;
          }
        },
        child: Scaffold(
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
                          text: "Profile",
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                        SizedBox(height: 20),

                        CustomTextField(
                          controller: nameController,
                          hintText: 'Name',
                          suffixIcon: ImgCons.person,
                          suffixColor: Colors.white,
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
                          hintText: 'State',
                          suffixIcon: ImgCons.state,
                          suffixColor: Colors.white,
                        ),
                        SizedBox(height: 20),

                        CustomTextField(
                          controller: cityController,
                          hintText: 'City',
                          suffixIcon: ImgCons.city,
                          suffixColor: Colors.white,
                        ),
                        SizedBox(height: 20),

                        CustomTextField(
                          controller: zipController,
                          hintText: 'ZipCode',
                          suffixIcon: ImgCons.zip,
                          suffixColor: Colors.white,
                        ),
                        SizedBox(height: 20),

                        GestureDetector(
                          onTap: () {
                            globalSnack.showErrorSnackBar(
                              context,
                              'Email cannot be modified.',
                            );
                          },
                          child: AbsorbPointer(
                            child: CustomTextField(
                              controller: emailController,
                              hintText: 'Email',
                              suffixIcon: ImgCons.mailIcon,
                            ),
                          ),
                        ),

                        SizedBox(height: 40),
                        _isModified
                            ? CustomButton(
                              text: "Update Profile",
                              suffixIcon: ImgCons.editIcon,
                              onPressed: () {
                                BlocProvider.of<UserBloc>(context).add(
                                  UpdateProfileEvent(
                                    token: token,
                                    userId: userId,
                                    name: nameController.text,
                                    email: emailController.text,
                                    country: countryController.text,
                                    city: cityController.text,
                                    state: stateController.text,
                                    zipCode: zipController.text,

                                  ),
                                );
                              }, // Disabled if not modified
                              width: 220,
                            )
                            : CustomButton(
                              width: 220,
                              text: 'Update Profile',
                              fillColor: [
                                Color.fromARGB(255, 9, 19, 27),
                                Color.fromARGB(255, 43, 51, 59),
                              ],
                              onPressed: () {
                                globalSnack.showErrorSnackBar(
                                  context,
                                  'No changes made to update.',
                                );
                              },
                              fontColor: Colors.grey,
                              borderColor: Colors.grey,
                            ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }
}
