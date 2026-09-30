// import 'dart:developer';

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:fish_caster/api_services/auth_service/auth_service.dart';
// import 'package:fish_caster/bloc/user/user_bloc.dart';
// import 'package:fish_caster/bloc/user/user_event.dart';
// import 'package:google_sign_in/google_sign_in.dart';

// class GoogleAuthService {
//   static final FirebaseAuth _auth = FirebaseAuth.instance;
//   static final GoogleSignIn _googleSignIn = GoogleSignIn();

//   static Future<Map<String, dynamic>?> signInWithGoogle({
//     required String fcmToken,
//     required UserBloc userBloc,
//   }) async {
//     try {
//       final GoogleSignIn _googleSignIn = GoogleSignIn(
//         scopes: ['email', 'profile', 'openid'], // ✅ Ensure correct scopes
//       );

//       final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
//       if (googleUser == null) {
//         print("❌ Google Sign-In Cancelled");
//         return null; // User canceled the sign-in
//       }

//       final GoogleSignInAuthentication googleAuth =
//           await googleUser.authentication;

//       final String? idToken = googleAuth.idToken; // ✅ ID Token
//       final String? accessToken = googleAuth.accessToken; // ✅ Access Token
//       log("Google ID Token: $idToken");
//       log("Google Access Token: $accessToken");

//       if (accessToken != null) {
//         print("✅ Google Access Token: $accessToken");
//       } else {
//         print("❌ Failed to retrieve access token");
//       }

//       if (idToken != null) {
//         print("✅ Google ID Token: $idToken");
//         log("Google ID Token: $idToken");
//         log("Google Access Token: $accessToken");

//         // Send token to backend API
//         final response = await AuthService.googleSignIn(idToken: accessToken!);
//         userBloc.add(GoogleLoginEvent(token: idToken, fcmToken: fcmToken));

//         return response;
//       } else {
//         print("❌ Failed to retrieve ID Token");
//         return null;
//       }
//     } catch (e) {
//       print("❌ Google Sign-In Error: $e");
//       return null;
//     }
//   }

//   static Future<void> signOutGoogle() async {
//     await _googleSignIn.signOut();
//     await _auth.signOut();
//   }
// }
