import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/providers/app_providers.dart';
import '../models/lesson_session_model.dart';

final sessionResumeServiceProvider = Provider<SessionResumeService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SessionResumeService(prefs);
});

class SessionResumeService {
  SessionResumeService(this._prefs);

  final SharedPreferences _prefs;
  static const _resumeKey = 'daily_session_resume_state_v1';

  Future<void> save(SessionResumeState state) async {
    await _prefs.setString(_resumeKey, jsonEncode(state.toJson()));
  }

  SessionResumeState? load() {
    final raw = _prefs.getString(_resumeKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return SessionResumeState.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() async {
    await _prefs.remove(_resumeKey);
  }
}

