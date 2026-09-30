import 'dart:async';
import 'dart:convert';
import 'package:fish_caster/bloc/language/language_state.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:translator/translator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageCubit extends Cubit<LanguageState> {
  final GoogleTranslator _translator = GoogleTranslator();

  LanguageCubit() : super(LanguageState(language: 'en', translations: {})) {
    _loadLanguageFromCache();
  }

  String get selectedLanguage => state.language;

  // Load the saved language from cache
  Future<void> _loadLanguageFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final language =
        prefs.getString('selectedLanguage') ?? 'en'; // Default to 'en' if not

    emit(LanguageState(language: language, translations: state.translations));

    _translateUI(language);
  }

  // Save the selected language to cache
  Future<void> _saveLanguageToCache(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLanguage', lang);
  }

  // Change language and save it to cache
  Future<void> changeLanguage(String lang) async {
    await _saveLanguageToCache(lang); // Save selected language to cache
    print('Language changed to: $lang');
    emit(LanguageState(language: lang, translations: state.translations));
    _translateUI(lang);
    await preloadTranslations(lang);
  }

  Future<String> translateText(String text) async {
    try {
      final translated = await _translator.translate(text, to: state.language);
      return translated.text;
    } catch (e) {
      print('Translation failed: $e');
      return text; // fallback
    }
  }

  Future<void> _translateUI(String lang) async {
    Map<String, String> newTranslations = {};

    final uiTexts = [
      'Hello',
      'Welcome',
      'Settings',
    ]; // Replace with your actual texts

    for (final text in uiTexts) {
      try {
        final translated = await _translator.translate(text, to: lang);
        newTranslations[text] = translated.text;
      } catch (e) {
        newTranslations[text] = text;
      }
    }

    emit(LanguageState(language: lang, translations: newTranslations));
  }

  // Future<String> translateFromJson(String key) async {
  //   try {
  //     String langCode = state.language;
  //     if (langCode == 'en') return key; // fallback to key itself for English

  //     // Load the json file for current language
  //     final String jsonString = await rootBundle.loadString(
  //       'assets/jsons/$langCode.json',
  //     );

  //     final Map<String, dynamic> jsonMap = json.decode(jsonString);

  //     // Return translated value or key itself if not found
  //     return jsonMap[key] ?? key;
  //   } catch (e) {
  //     print('Local JSON translation failed: $e');
  //     return key; // fallback
  //   }
  // }

  Future<String> translateFromJson(String key) async {
    try {
      String langCode = state.language;
      if (langCode == 'en') return key; // fallback to key itself for English

      // // ✅ First, check preloaded translations in state
      // if (state.translations.containsKey(key)) {
      //   return state.translations[key]!;
      // }

      // Otherwise, load the json file for current language
      final String jsonString = await rootBundle.loadString(
        'assets/jsons/$langCode.json',
      );

      final Map<String, dynamic> jsonMap = json.decode(jsonString);

      // Return translated value or key itself if not found
      return jsonMap[key] ?? key;
    } catch (e) {
      print('Local JSON translation failed: $e');
      return key; // fallback
    }
  }

  Future<void> preloadTranslations(String lang) async {
    try {
      // Load the json file for current language
      final String jsonString = await rootBundle.loadString(
        'assets/jsons/$lang.json',
      );

      final Map<String, dynamic> jsonMap = json.decode(jsonString);

      emit(
        LanguageState(
          language: lang,
          translations: jsonMap.map((k, v) => MapEntry(k, v.toString())),
        ),
      );
    } catch (e) {
      print('Preloading translations failed: $e');
    }
  }
}
