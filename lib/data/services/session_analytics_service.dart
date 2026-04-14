import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/providers/app_providers.dart';

final sessionAnalyticsServiceProvider = Provider<SessionAnalyticsService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SessionAnalyticsService(prefs);
});

class SessionAnalyticsService {
  SessionAnalyticsService(this._prefs);

  final SharedPreferences _prefs;
  static const _eventsKey = 'analytics_events_v1';
  static const _metricsKey = 'learning_metrics_v1';

  Future<void> logEvent(String name, Map<String, dynamic> payload) async {
    final events = _readList(_eventsKey);
    events.add({
      'name': name,
      'ts': DateTime.now().toIso8601String(),
      'payload': payload,
    });
    await _prefs.setString(_eventsKey, jsonEncode(events.take(3000).toList()));
  }

  Future<void> logMetric(Map<String, dynamic> metric) async {
    final metrics = _readList(_metricsKey);
    metrics.add({
      ...metric,
      'ts': DateTime.now().toIso8601String(),
    });
    await _prefs.setString(_metricsKey, jsonEncode(metrics.take(3000).toList()));
  }

  List<Map<String, dynamic>> _readList(String key) {
    final raw = _prefs.getString(key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List;
      return decoded
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    } catch (_) {
      return [];
    }
  }

  String exportCsv() {
    final events = _readList(_eventsKey);
    final metrics = _readList(_metricsKey);
    final lines = <String>[
      'type,name,ts,data',
      ...events.map((e) => 'event,${_esc(e['name'])},${_esc(e['ts'])},${_esc(jsonEncode(e['payload']))}'),
      ...metrics.map((m) => 'metric,learning_metric,${_esc(m['ts'])},${_esc(jsonEncode(m))}'),
    ];
    return lines.join('\n');
  }

  Map<String, int> weeklyEventCounts() {
    final events = _readList(_eventsKey);
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final counts = <String, int>{};
    for (final e in events) {
      final ts = DateTime.tryParse(e['ts'] as String? ?? '');
      if (ts == null || ts.isBefore(weekStart)) continue;
      final name = e['name'] as String? ?? 'unknown';
      counts[name] = (counts[name] ?? 0) + 1;
    }
    return counts;
  }

  String _esc(Object? value) {
    final text = '${value ?? ''}'.replaceAll('"', '""');
    return '"$text"';
  }
}

