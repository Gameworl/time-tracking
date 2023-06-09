// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAiFVN9xAH75J03OmdBOodaUlXT4V6j1ek',
    appId: '1:559234511546:android:bcfaabb86da7151621c883',
    messagingSenderId: '559234511546',
    projectId: 'educacode-codapagos',
    databaseURL: 'https://educacode-codapagos-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'educacode-codapagos.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCuzeuAIL3yBWH4HZic_9rAkzmQianQY_o',
    appId: '1:559234511546:ios:27a983fffcef983121c883',
    messagingSenderId: '559234511546',
    projectId: 'educacode-codapagos',
    databaseURL: 'https://educacode-codapagos-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'educacode-codapagos.appspot.com',
    iosClientId: '559234511546-bv9maeo9i2nm516lbfb5i3kr1s862rti.apps.googleusercontent.com',
    iosBundleId: 'com.example.timerTeam',
  );
}
