import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => const FirebaseOptions(
    apiKey: 'AIzaSyDnfV32Pa3WM-hI9Cf_uKdL9F_tzFpKq8Y', // From google-services.json api_key
    appId: '1:481620385308:android:92bef593d32a2cc10409d9', // From google-services.json mobilesdk_app_id
    messagingSenderId: '481620385308', // From google-services.json project_number
    projectId: 'eulaiqapp', // From google-services.json project_id
    androidClientId: '481620385308-50k8v2a7idv5e9hdjrujgdgg5ltcqqbj.apps.googleusercontent.com', // From google-services.json client_id
  );
}