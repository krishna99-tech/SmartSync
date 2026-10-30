// File generated for SmartHome Firebase Configuration
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
      default:
        return android;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBNa5KqEncenSyw4Zg-1QIlBHhJjpIX28o',
    appId: '1:253492695515:web:78424d6cf72f158bb997fe',
    messagingSenderId: '253492695515',
    projectId: 'smarthome-2524a',
    authDomain: 'smarthome-2524a.firebaseapp.com',
    databaseURL: 'https://smarthome-2524a-default-rtdb.firebaseio.com/',
    storageBucket: 'smarthome-2524a.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBNa5KqEncenSyw4Zg-1QIlBHhJjpIX28o',
    appId: '1:253492695515:android:78424d6cf72f158bb997fe',
    messagingSenderId: '253492695515',
    projectId: 'smarthome-2524a',
    authDomain: 'smarthome-2524a.firebaseapp.com',
    databaseURL: 'https://smarthome-2524a-default-rtdb.firebaseio.com/',
    storageBucket: 'smarthome-2524a.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBNa5KqEncenSyw4Zg-1QIlBHhJjpIX28o',
    appId: '1:253492695515:ios:78424d6cf72f158bb997fe',
    messagingSenderId: '253492695515',
    projectId: 'smarthome-2524a',
    authDomain: 'smarthome-2524a.firebaseapp.com',
    databaseURL: 'https://smarthome-2524a-default-rtdb.firebaseio.com/',
    storageBucket: 'smarthome-2524a.appspot.com',
    iosBundleId: 'com.electrogadgedc.SmartHome',
  );
}

