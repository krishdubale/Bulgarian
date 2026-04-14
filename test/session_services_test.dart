import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:linguaflow_app/core/models/lesson_session_model.dart';
import 'package:linguaflow_app/core/services/session_analytics_service.dart';
import 'package:linguaflow_app/core/services/session_resume_service.dart';

void main() {
  test('SessionResumeService saves and loads snapshot', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final service = SessionResumeService(prefs);

    final session = LessonSession(
      id: 's1',
      lessonId: 'practice',
      languageId: 'bg',
      exercises: const [
        SessionExercise(
          id: 'e1',
          type: ExerciseType.mcq,
          question: 'Q',
          correctAnswer: 'A',
        ),
      ],
      difficulty: 3,
      xpReward: 10,
      sessionType: SessionType.practice,
    );
    final snapshot = SessionResumeState(
      session: session,
      currentIndex: 0,
      answered: false,
      selectedAnswer: null,
      results: const [],
      updatedAt: DateTime.now(),
    );

    await service.save(snapshot);
    final loaded = service.load();

    expect(loaded, isNotNull);
    expect(loaded!.session.id, 's1');
    expect(loaded.currentIndex, 0);
  });

  test('SessionAnalyticsService exports csv', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final service = SessionAnalyticsService(prefs);

    await service.logEvent('session_start', {'sessionId': 's1'});
    await service.logMetric({'sessionId': 's1', 'immediateAccuracy': 0.8});

    final csv = service.exportCsv();
    expect(csv, contains('session_start'));
    expect(csv, contains('learning_metric'));
  });
}

