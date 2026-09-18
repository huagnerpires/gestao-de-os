import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyC_0cbzkworbVDkJHbPFZcjHNRksD0neTw",
            authDomain: "h-p-s-modificado-emdcp0.firebaseapp.com",
            projectId: "h-p-s-modificado-emdcp0",
            storageBucket: "h-p-s-modificado-emdcp0.appspot.com",
            messagingSenderId: "864598419738",
            appId: "1:864598419738:web:734c7e98b6a9ddcb3fe4a3"));
  } else {
    await Firebase.initializeApp();
  }

  // firebase_app_check 0.3.2+7: androidProvider / appleProvider / webProvider.
  // There is no debug WebProvider — only ReCaptchaV3 / ReCaptchaEnterprise.
  // No reCAPTCHA site key exists in this repo; placeholder + try/catch so
  // the app still starts. Register a real key / debug token in Firebase Console.
  try {
    await FirebaseAppCheck.instance.activate(
      androidProvider:
          kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
      appleProvider:
          kDebugMode ? AppleProvider.debug : AppleProvider.deviceCheck,
      webProvider: ReCaptchaV3Provider('6LcAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'),
    );
    await FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(true);
  } catch (e, st) {
    debugPrint('Firebase App Check activate failed: $e\n$st');
  }
}
