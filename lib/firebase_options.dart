// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCD-SgYeysbuXaFrDiIR5pewqzdIndHst0',
    appId: '1:333775666671:android:31605f616b78fea7d78a1a',
    messagingSenderId: '333775666671',
    projectId: 'yash-software',
    databaseURL: 'https://yash-software-default-rtdb.firebaseio.com',
    storageBucket: 'yash-software.firebasestorage.app',
  );

  // FIX: iOS ko Firebase Console mein alag register karo
  // Tab tak Android config use hoga — iOS app Firebase mein add karo aur
  // ios appId update karo: Firebase Console → Project Settings → Add iOS App
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCD-SgYeysbuXaFrDiIR5pewqzdIndHst0',
    // TODO: iOS app Firebase mein register karo aur niche wala appId update karo
    appId: '1:333775666671:ios:REPLACE_WITH_IOS_APP_ID',
    messagingSenderId: '333775666671',
    projectId: 'yash-software',
    databaseURL: 'https://yash-software-default-rtdb.firebaseio.com',
    storageBucket: 'yash-software.firebasestorage.app',
  );
}
