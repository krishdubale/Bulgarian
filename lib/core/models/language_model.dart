/// Represents a language available for learning.
class LanguageModel {
  final String id; // 'bg', 'ro', 'ka', 'sv'
  final String name; // 'Bulgarian'
  final String nativeName; // 'Български'
  final String flag; // '🇧🇬'
  final String script; // 'Cyrillic', 'Latin', 'Georgian'
  final bool hasAlphabet; // true for non-Latin scripts
  final List<String> availableLevels;

  const LanguageModel({
    required this.id,
    required this.name,
    required this.nativeName,
    required this.flag,
    required this.script,
    this.hasAlphabet = false,
    this.availableLevels = const ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'],
  });

  /// All supported languages defined here.
  static const List<LanguageModel> supportedLanguages = [
    LanguageModel(
      id: 'bg',
      name: 'Bulgarian',
      nativeName: 'Български',
      flag: '🇧🇬',
      script: 'Cyrillic',
      hasAlphabet: true,
      availableLevels: ['A1', 'A2', 'B1'],
    ),
    LanguageModel(
      id: 'ro',
      name: 'Romanian',
      nativeName: 'Română',
      flag: '🇷🇴',
      script: 'Latin',
      hasAlphabet: false,
      availableLevels: ['A1'],
    ),
    LanguageModel(
      id: 'ka',
      name: 'Georgian',
      nativeName: 'ქართული',
      flag: '🇬🇪',
      script: 'Georgian',
      hasAlphabet: true,
      availableLevels: ['A1'],
    ),
    LanguageModel(
      id: 'sv',
      name: 'Swedish',
      nativeName: 'Svenska',
      flag: '🇸🇪',
      script: 'Latin',
      hasAlphabet: false,
      availableLevels: ['A1'],
    ),
  ];

  static LanguageModel getById(String id) {
    return supportedLanguages.firstWhere(
      (l) => l.id == id,
      orElse: () => supportedLanguages.first,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'nativeName': nativeName,
        'flag': flag,
        'script': script,
        'hasAlphabet': hasAlphabet,
        'availableLevels': availableLevels,
      };

  factory LanguageModel.fromJson(Map<String, dynamic> json) {
    return LanguageModel(
      id: json['id'] as String,
      name: json['name'] as String,
      nativeName: json['nativeName'] as String? ?? '',
      flag: json['flag'] as String? ?? '🏳️',
      script: json['script'] as String? ?? 'Latin',
      hasAlphabet: json['hasAlphabet'] as bool? ?? false,
      availableLevels: List<String>.from(
        json['availableLevels'] as List? ?? ['A1'],
      ),
    );
  }
}
