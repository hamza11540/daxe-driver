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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCeDRu7NFLpTcaIl-v0AFX_Y85Xh8uN938',
    appId: '1:21434577467:android:dd343b03336d8f5fd1a21e',
    messagingSenderId: '21434577467',
    projectId: 'ride-man-cd318',
    storageBucket: 'ride-man-cd318.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDRZzSV9n3npRcXFOakFoC5iOPuOOCWhG8',
    appId: '1:21434577467:ios:f07dc266d06d2e77d1a21e',
    messagingSenderId: '21434577467',
    projectId: 'ride-man-cd318',
    storageBucket: 'ride-man-cd318.appspot.com',
    iosClientId:
        '21434577467-mp0rbcsfgs7hcepjeb6m453lqrgf89od.apps.googleusercontent.com',
    iosBundleId: 'br.com.carvs.rideman',
  );
}
