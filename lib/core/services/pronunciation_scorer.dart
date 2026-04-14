import 'package:flutter_riverpod/flutter_riverpod.dart';

final pronunciationScorerProvider = Provider<PronunciationScorer>((ref) {
  return PronunciationScorer();
});

/// Result of pronunciation scoring.
class PronunciationResult {
  final double accuracy; // 0.0 – 1.0
  final String expectedText;
  final String spokenText;
  final List<WordMatch> wordMatches;
  final String feedback;

  const PronunciationResult({
    required this.accuracy,
    required this.expectedText,
    required this.spokenText,
    required this.wordMatches,
    required this.feedback,
  });
}

/// Individual word comparison result.
class WordMatch {
  final String expected;
  final String? spoken;
  final bool isMatch;
  final double similarity;

  const WordMatch({
    required this.expected,
    this.spoken,
    required this.isMatch,
    this.similarity = 0,
  });
}

/// Scores pronunciation by comparing spoken text to expected text.
class PronunciationScorer {
  /// Score pronunciation of spoken text against expected.
  PronunciationResult score(String expected, String spoken) {
    final expectedWords = _normalize(expected).split(' ');
    final spokenWords = _normalize(spoken).split(' ');

    final matches = <WordMatch>[];
    int matchCount = 0;

    for (int i = 0; i < expectedWords.length; i++) {
      final expectedWord = expectedWords[i];
      String? spokenWord;
      double similarity = 0;
      bool isMatch = false;

      if (i < spokenWords.length) {
        spokenWord = spokenWords[i];
        similarity = _calculateSimilarity(expectedWord, spokenWord);
        isMatch = similarity >= 0.7; // 70% similarity threshold
        if (isMatch) matchCount++;
      }

      matches.add(WordMatch(
        expected: expectedWord,
        spoken: spokenWord,
        isMatch: isMatch,
        similarity: similarity,
      ));
    }

    final accuracy = expectedWords.isEmpty
        ? 0.0
        : matchCount / expectedWords.length;

    String feedback;
    if (accuracy >= 0.9) {
      feedback = 'Excellent pronunciation! 🎉';
    } else if (accuracy >= 0.7) {
      feedback = 'Good job! A few words need practice.';
    } else if (accuracy >= 0.5) {
      feedback = 'Getting there! Try speaking more slowly.';
    } else {
      feedback = 'Keep practicing! Listen to the audio and try again.';
    }

    return PronunciationResult(
      accuracy: accuracy,
      expectedText: expected,
      spokenText: spoken,
      wordMatches: matches,
      feedback: feedback,
    );
  }

  /// Normalize text for comparison.
  String _normalize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\p{L}\s]', unicode: true), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Calculate Levenshtein-based similarity between two strings.
  double _calculateSimilarity(String a, String b) {
    if (a == b) return 1.0;
    if (a.isEmpty || b.isEmpty) return 0.0;

    final distance = _levenshteinDistance(a, b);
    final maxLen = a.length > b.length ? a.length : b.length;
    return 1.0 - (distance / maxLen);
  }

  /// Levenshtein edit distance.
  int _levenshteinDistance(String s1, String s2) {
    final len1 = s1.length;
    final len2 = s2.length;

    final matrix = List.generate(
      len1 + 1,
      (i) => List.generate(len2 + 1, (j) => 0),
    );

    for (int i = 0; i <= len1; i++) {
      matrix[i][0] = i;
    }
    for (int j = 0; j <= len2; j++) {
      matrix[0][j] = j;
    }

    for (int i = 1; i <= len1; i++) {
      for (int j = 1; j <= len2; j++) {
        final cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,
          matrix[i][j - 1] + 1,
          matrix[i - 1][j - 1] + cost,
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return matrix[len1][len2];
  }
}
