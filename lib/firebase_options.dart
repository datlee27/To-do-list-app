// Firebase configuration options
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
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
      default:
        return android;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCP8CrCyUqJsWRY7GRwnD8YbMaNvCOuGJQ',
    appId: '1:821101079230:web:7065035e5b7ca65ba1ccef',
    messagingSenderId: '821101079230',
    projectId: 'to-do-list-prm',
    authDomain: 'to-do-list-prm.firebaseapp.com',
    storageBucket: 'to-do-list-prm.firebasestorage.app',
  );


  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCP8CrCyUqJsWRY7GRwnD8YbMaNvCOuGJQ',
    appId: '1:821101079230:android:7065035e5b7ca65ba1ccef',
    messagingSenderId: '821101079230',
    projectId: 'to-do-list-prm',
    storageBucket: 'to-do-list-prm.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCP8CrCyUqJsWRY7GRwnD8YbMaNvCOuGJQ',
    appId: '1:821101079230:ios:7065035e5b7ca65ba1ccef',
    messagingSenderId: '821101079230',
    projectId: 'to-do-list-prm',
    storageBucket: 'to-do-list-prm.firebasestorage.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCP8CrCyUqJsWRY7GRwnD8YbMaNvCOuGJQ',
    appId: '1:821101079230:ios:7065035e5b7ca65ba1ccef',
    messagingSenderId: '821101079230',
    projectId: 'to-do-list-prm',
    storageBucket: 'to-do-list-prm.firebasestorage.app',
  );
}
