
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;


class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        return linux;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCUxyPB0RODBoT0SLw8lAIB083EEqAP6Qo',
    appId: '1:56265206453:web:af661829d4c8f6e5522cfc',
    messagingSenderId: '56265206453',
    projectId: 'mitcampus-ab3db',
    authDomain: 'mitcampus-ab3db.firebaseapp.com',
    storageBucket: 'mitcampus-ab3db.appspot.com',
    measurementId: 'G-KNWB36NTKQ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC5-aL1sUkn_hjlEfY4b_ft76AacxlQUuo',
    appId: '1:56265206453:android:d3e44a42fa0d2536522cfc',
    messagingSenderId: '56265206453',
    projectId: 'mitcampus-ab3db',
    storageBucket: 'mitcampus-ab3db.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBGW8h8Ct7K3juvM8k2xEMM6_7I_mqoB0M',
    appId: '1:56265206453:ios:1b305f57f78fc64b522cfc',
    messagingSenderId: '56265206453',
    projectId: 'mitcampus-ab3db',
    storageBucket: 'mitcampus-ab3db.appspot.com',
    iosBundleId: 'com.example.mitcampus',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBGW8h8Ct7K3juvM8k2xEMM6_7I_mqoB0M',
    appId: '1:56265206453:ios:1b305f57f78fc64b522cfc',
    messagingSenderId: '56265206453',
    projectId: 'mitcampus-ab3db',
    storageBucket: 'mitcampus-ab3db.appspot.com',
    iosBundleId: 'com.example.mitcampus',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCUxyPB0RODBoT0SLw8lAIB083EEqAP6Qo',
    appId: '1:56265206453:web:65a75b29cad94a7d522cfc',
    messagingSenderId: '56265206453',
    projectId: 'mitcampus-ab3db',
    authDomain: 'mitcampus-ab3db.firebaseapp.com',
    storageBucket: 'mitcampus-ab3db.appspot.com',
    measurementId: 'G-YMTHFTLBDC',
  );

  static FirebaseOptions linux = const FirebaseOptions(
    apiKey: 'AIzaSyCUxyPB0RODBoT0SLw8lAIB083EEqAP6Qo',
    appId: '1:56265206453:web:65a75b29cad94a7d522cfc',
    messagingSenderId: '56265206453',
    projectId: 'mitcampus-ab3db',
    storageBucket: 'mitcampus-ab3db.appspot.com',
  );
}
