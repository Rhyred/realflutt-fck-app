// File ini dibuat oleh FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// [FirebaseOptions] default untuk digunakan dengan aplikasi Firebase Anda.
///
/// Contoh:
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
        throw UnsupportedError(
          'DefaultFirebaseOptions belum dikonfigurasi untuk ios - '
          'Anda dapat mengonfigurasi ulang ini dengan menjalankan FlutterFire CLI lagi.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions belum dikonfigurasi untuk macos - '
          'Anda dapat mengonfigurasi ulang ini dengan menjalankan FlutterFire CLI lagi.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions belum dikonfigurasi untuk windows - '
          'Anda dapat mengonfigurasi ulang ini dengan menjalankan FlutterFire CLI lagi.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions belum dikonfigurasi untuk linux - '
          'Anda dapat mengonfigurasi ulang ini dengan menjalankan FlutterFire CLI lagi.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions tidak didukung untuk platform ini.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCYdrBa7Fcai9Z2P1V59E6iDjiHf9gNnLg',
    appId: '1:1018651216333:web:b81e26692223e750fd1c84',
    messagingSenderId: '1018651216333',
    projectId: 'my-app-fak',
    authDomain: 'my-app-fak.firebaseapp.com',
    storageBucket: 'my-app-fak.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCMUElDu-qeEvtDpnVl593WaUiIQm85NzY',
    appId: '1:1018651216333:android:d0d09d0682c6e27efd1c84',
    messagingSenderId: '1018651216333',
    projectId: 'my-app-fak',
    storageBucket: 'my-app-fak.firebasestorage.app',
  );
}
