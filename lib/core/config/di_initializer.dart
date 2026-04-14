import 'package:shared_preferences/shared_preferences.dart';

class DiContainer {
  final SharedPreferences sharedPreferences;

  const DiContainer({
    required this.sharedPreferences,
  });
}

class DiInitializer {
  const DiInitializer();

  Future<DiContainer> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    return DiContainer(sharedPreferences: prefs);
  }
}

