import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => const FirebaseOptions(
    apiKey: 'AIzaSyD-gJKLH89_l8YbM-9i8LKtvgPZiHOpwFc', // From google-services.json api_key
    appId: '1:804161081670:android:3eafd9c394966ebf2c9547', // From google-services.json mobilesdk_app_id
    messagingSenderId: '804161081670', // From google-services.json project_number
    projectId: 'novel-nooks-e1d16', // From google-services.json project_id
    androidClientId: '804161081670-e309jbs15qqe0tggj5vpo0bpr3b5m2rm.apps.googleusercontent.com', // From google-services.json client_id
    storageBucket: 'novel-nooks-e1d16.firebasestorage.app', // From google-services.json storage_bucket
  );
}