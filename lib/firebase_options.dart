// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDrgRLc5Y282PVUXgDqdrSf1vDHSSl4zwg',
    appId: '1:1059733316750:web:2c49e4343e78cf8944d5df',
    messagingSenderId: '1059733316750',
    projectId: 'fir-project-cbea0',
    authDomain: 'fir-project-cbea0.firebaseapp.com',
    storageBucket: 'fir-project-cbea0.appspot.com',
    measurementId: 'G-3YGDEX1B57',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCd_ofm88F-qVGgA2dm5anb6SIxTMNOkpg',
    appId: '1:1059733316750:android:60700019e133f7eb44d5df',
    messagingSenderId: '1059733316750',
    projectId: 'fir-project-cbea0',
    storageBucket: 'fir-project-cbea0.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDInK5GaMcwnJR8fE611M9M_HiIVTGVXcw',
    appId: '1:1059733316750:ios:8d122d5ecf881f5a44d5df',
    messagingSenderId: '1059733316750',
    projectId: 'fir-project-cbea0',
    storageBucket: 'fir-project-cbea0.appspot.com',
    iosBundleId: 'com.example.fireia',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDInK5GaMcwnJR8fE611M9M_HiIVTGVXcw',
    appId: '1:1059733316750:ios:8d122d5ecf881f5a44d5df',
    messagingSenderId: '1059733316750',
    projectId: 'fir-project-cbea0',
    storageBucket: 'fir-project-cbea0.appspot.com',
    iosBundleId: 'com.example.fireia',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDrgRLc5Y282PVUXgDqdrSf1vDHSSl4zwg',
    appId: '1:1059733316750:web:897c3a32e8c55cb444d5df',
    messagingSenderId: '1059733316750',
    projectId: 'fir-project-cbea0',
    authDomain: 'fir-project-cbea0.firebaseapp.com',
    storageBucket: 'fir-project-cbea0.appspot.com',
    measurementId: 'G-1YP5REJ151',
  );

}