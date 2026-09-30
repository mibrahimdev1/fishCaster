import 'package:firebase_core/firebase_core.dart';
import 'package:fish_caster/api_services/location_service/locationService.dart';
import 'package:fish_caster/bloc/criteria/criteria_bloc.dart';
import 'package:fish_caster/bloc/language/language_bloc.dart';
import 'package:fish_caster/bloc/location/location_bloc.dart';
import 'package:fish_caster/bloc/prefrences/prefrences_bloc.dart';
import 'package:fish_caster/bloc/prefrences/prefrences_event.dart';
import 'package:fish_caster/bloc/token/token_bloc.dart';
import 'package:fish_caster/bloc/user/user_bloc.dart';
import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:fish_caster/screen/splash_screen/splashScreen.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp();

  runApp(
    DevicePreview(enabled: !kReleaseMode, builder: (context) => const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => TokenBloc()),
        BlocProvider(create: (context) => LanguageCubit()),
        BlocProvider(
          create: (context) => UserBloc(context.read<TokenBloc>(), context),
        ),
        BlocProvider(
          create:
              (context) => LocationBloc(
                locationService: LocationService(
                  tokenBloc: context.read<TokenBloc>(),
                  context: context,
                ), // Pass the tokenBloc to LocationService
              ),
        ),
        BlocProvider(create: (context) => CriteriaBloc()),
        // BlocProvider(
        //   create: (context) => PreferencesBloc()..add(LoadPreferences()),
        // ),
        BlocProvider(
          create:
              (context) =>
                  PreferencesBloc(context.read<TokenBloc>())
                    ..add(LoadPreferences()),
        ),
      ],
      child: Builder(
        builder: (context) {
          return MaterialApp(
            builder: DevicePreview.appBuilder,
            locale: DevicePreview.locale(context),
            title: 'Chaser',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            ),
            home: SplashScreen(),
          );
        },
      ),
    );
  }
}
