import 'package:firebase_core/firebase_core.dart';

class FirebaseInitializer {
  const FirebaseInitializer();

  Future<void> initialize({required bool enabled}) async {
    if (!enabled) return;
    if (Firebase.apps.isNotEmpty) return;
    await Firebase.initializeApp();
  }
}

