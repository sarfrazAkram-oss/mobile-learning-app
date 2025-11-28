import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // Replace these with your Firebase project configuration
    return const FirebaseOptions(
      apiKey: 'AIzaSyCT56irSHTULaFw1h36z9ZNSt-6zlRcnaQ',
      appId: '1:652365949497:android:e58cf7f054c78a1383bbe8',
      messagingSenderId: '652365949497',
      projectId: 'quran-learning-app-5df5c',
      authDomain: 'quran-learning-app-5df5c.firebaseapp.com',
      storageBucket: 'quran-learning-app-5df5c.firebasestorage.app',
    );
  }
}
