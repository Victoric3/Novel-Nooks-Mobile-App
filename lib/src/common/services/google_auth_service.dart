import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  // Remove the clientId for Android - let it use the one from google-services.json
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/userinfo.profile',
    ],
    // Only specify clientId for web platforms
    // clientId: '481620385308-50k8v2a7idv5e9hdjrujgdgg5ltcqqbj.apps.googleusercontent.com',
  );
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      // Clear previous sign-in state first
      await _googleSignIn.signOut();
      
      print('Starting Google Sign In process...');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        print('Google Sign In was cancelled by user');
        return null;
      }

      print('Got Google user: ${googleUser.email}');
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      if (googleAuth.idToken == null) {
        print('Failed to get ID token');
        return null;
      }

      print('Successfully got ID token');
      return {
        'idToken': googleAuth.idToken,
        'accessToken': googleAuth.accessToken,
        'email': googleUser.email,
        'displayName': googleUser.displayName,
      };
    } catch (e) {
      print('Google Sign In Error: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}

final googleAuthServiceProvider = Provider((ref) => GoogleAuthService());