// import 'package:equatable/equatable.dart';

// class LanguageState extends Equatable {
//   final String currentLanguageCode;
//   final Map<String, String> translations;

//   const LanguageState({
//     required this.currentLanguageCode,
//     required this.translations,
//   });

//   @override
//   List<Object> get props => [currentLanguageCode, translations];
// }

class LanguageState {
  final String language;
  final Map<String, String> translations;

  LanguageState({required this.language, required this.translations});
}
