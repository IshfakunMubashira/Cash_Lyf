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
    apiKey: 'AIzaSyBQX2ItU1SmgGcWr42jxwOMP2yW-7RNOsY',
    appId: '1:533091735602:web:dc34b7d06d0a1aabb7442b',
    messagingSenderId: '533091735602',
    projectId: 'cashlyf',
    authDomain: 'cashlyf.firebaseapp.com',
    storageBucket: 'cashlyf.firebasestorage.app',
    measurementId: 'G-3SBXD6R0HB',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCzsrhscRiJAsH-V9M3-_Q53NUieacoaFA',
    appId: '1:533091735602:android:82f1d1f141202523b7442b',
    messagingSenderId: '533091735602',
    projectId: 'cashlyf',
    storageBucket: 'cashlyf.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCzsrhscRiJAsH-V9M3-_Q53NUieacoaFA',
    appId: '1:533091735602:ios:82f1d1f141202523b7442b',
    messagingSenderId: '533091735602',
    projectId: 'cashlyf',
    storageBucket: 'cashlyf.firebasestorage.app',
    androidClientId: '533091735602-xxxx.apps.googleusercontent.com',
    iosClientId: '533091735602-xxxx.apps.googleusercontent.com',
    iosBundleId: 'com.example.cashlyf',
  );

  static const FirebaseOptions windows = web;
  static const FirebaseOptions linux = web;
}